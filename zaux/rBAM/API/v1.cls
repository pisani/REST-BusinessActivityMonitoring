Include Ensemble

Class zaux.rBAM.API.v1 Extends (%CSP.REST, zaux.rBAM.Utils)
{

Parameter HandleCorsRequest As %Integer = 1;

Parameter DefaultContentType As %String = "application/fhir+json";

/// The UrlMap describes how incoming REST URL requests and their parameters get
/// dispatched to each of the handler-methods in this class.
XData UrlMap
{
<Routes>
<Route Url="/Data"					Method="GET" 		Call="GetMetricClassData"/>
<Route Url="/Data/:metricHostName"	Method="GET" 		Call="GetMetricClassData"/>
<Route Url="/List"					Method="GET" 		Call="GetMetricClasses"/>
</Routes>
}

ClassMethod GetMetricClasses() As %Status
{
	set tSC=$$$OK
	try {
		
		do ..getProductionBusinessMetrics(.hostList,1)
		set c=""
		set json={}
		set json."_Production"=##class(Ens.Director).GetActiveProductionName()
		set items=[]
		
		for  {
			set c=$order(hostList(c)) quit:c=""
			set class={}
			set class.ConfigName=hostList(c)
			set class.DataURL=$piece(%request.URL,"/",1,$l(%request.URL,"/")-1)_"/Data/"_class.ConfigName
			set class.Enabled=##class(Ens.Director).IsItemEnabled(hostList(c),.status)
			
			do items.%Push(class)
		}

	} catch ex { 	
		set tSC=ex.AsStatus()
	}
	
	set json.items=items
	
	if $$$ISERR(tSC) {
		// Setup Error response 
		do ..StatusToJSON(tSC,.jsonErr)
		do jsonErr.%ToJSON()
		
	} else {
		write json.%ToJSON()
	}
	
	quit $$$OK
}

ClassMethod GetMetricClassData( metricHostName = "") As %Status
{
	set tSC=$$$OK
	set metricData=$zdt($h,3)
	try
	{
		do ..getParams(.StructuredOutput,.IncludeMetricParameters,.DelimeterForFlattenedData,.OmmitClassName,.HideMetricsString)
		if HideMetricsString'="" {
			do ..buildHideArray(HideMetricsString,.intHideArr)
		} 
		
		if metricHostName="" { 
			do ..getProductionBusinessMetrics(.hostList,0)
		} else {  
			
			set class=##class(zaux.rBAM.Utils).resolveClassName(metricHostName)
			if class=""!('##class(%Dictionary.CompiledClass).%ExistsId(class)) {
				// class not found or not enabled
				$$$ThrowStatus($$$ERROR($$$GeneralError,"Metric class: "_metricHostName_" not found, or not enabled to run."))
			} else {
				set hostList(1)=metricHostName
			}
		}
		
		set c=""
		set json=[]
		
		for  {
			set c=$order(hostList(c)) quit:c=""
			set metricHostName=hostList(c)

			merge metricData(metricHostName)=$$$EnsMetrics(metricHostName)
		
		}
		
		
		// Build JSON for measures
		$$$THROWONERROR(tSC,..buildJSON(.metricData,StructuredOutput,IncludeMetricParameters,DelimeterForFlattenedData,OmmitClassName,.intHideArr,.json))
			  
		;# Write JSON to foreground for now
		if $d(json),$isObject(json) {
			; Return metric data
			Write json.%ToJSON()
		}

	} catch ex { 
		set tSC=ex.AsStatus()
	}
	
	if $$$ISERR(tSC) {
		// Setup Error response 
		do ..StatusToJSON(tSC,.jsonErr)
		do jsonErr.%ToJSON()
	}
	
	quit $$$OK
}

ClassMethod getParams(StructuredOutput, IncludeMetricParameters,DelimeterForFlattenedData,OmmitClassName,HideMetrics)
{
	set StructuredOutput=$GET(%request.Data("StructuredOutput",1),0)
	set IncludeMetricParameters=$GET(%request.Data("MetricParameters",1),0)
	set DelimeterForFlattenedData=$GET(%request.Data("DelimeterForFlattenedData",1),"_")
	set OmmitClassName=$GET(%request.Data("OmmitClassName",1),0)
	set HideMetrics=$GET(%request.Data("HideMetrics",1),"")
	
}

ClassMethod getProductionBusinessMetrics(results, ignoreStatus = 0)
{
	
	set pParams("services")=1
	set pParams("productionName")=$$$EnsRuntime("Name")
	set pParams("className")="Ens.BusinessMetric" 
	do ##class(Ens.ContextSearch).ProductionItems(.cap,.top,.results,.pParams)
	quit:ignoreStatus
	
	set c=""
	for  {
		set c=$order(results(c)) quit:c=""
		if '##class(Ens.Director).IsItemEnabled(results(c),.status) kill results(c)
	}
}

}
