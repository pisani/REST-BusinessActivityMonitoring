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
<Route Url="/:namespace/Data"					Method="GET" 		Call="GetMetricClassData"/>
<Route Url="/:namespace/Data/:metricClassname"	Method="GET" 		Call="GetMetricClassData"/>
<Route Url="/:namespace/List"					Method="GET" 		Call="GetMetricClasses"/>
</Routes>
}

ClassMethod GetMetricClasses(namespace) As %Status
{
	set tSC=$$$OK
	try {
		
		do ..getProductionBusinessMetrics(.hostList,1)
		set c=""
		set json=[]
		
		for  {
			set c=$order(hostList(c)) quit:c=""
			set class={}
			set class.ConfigName=hostList(c)
			set class.Enabled=##class(Ens.Director).IsItemEnabled(hostList(c),.status)
			do json.%Push(class)
		}

	} catch ex { 	
		set tSC=ex.AsStatus()
	}
	
	if $$$ISERR(tSC) {
		// Setup Error response 
		do ..StatusToJSON(tSC,.jsonErr)
		do jsonErr.%ToJSON()
		
	} else {
		write json.%ToJSON()
	}
	
	quit $$$OK
}

ClassMethod GetMetricClassData(namespace, metricClassName = "") As %Status
{
	set tSC=$$$OK
	set metricData=$zdt($h,3)
	try
	{
		do ..getParams(.StructuredOutput,.DelimeterForFlattenedData,.OmmitClassName,.HideMetricsString)
		if HideMetricsString'="" {
			do ..buildHideArray(HideMetricsString,.intHideArr)
		} 
		
		if metricClassName="" { 
			do ..getProductionBusinessMetrics(.hostList,0)
		} else {  
			if '##class(%Dictionary.CompiledClass).%ExistsId(metricClassName) {
				// class not found or not enabled
				$$$ThrowStatus($$$ERROR($$$GeneralError,metricClassName_" is not found, or not enabled to run."))
			} else {
				set hostList(1)=metricClassName
			}
		}
		
		set c=""
		set json=[]
		
		for  {
			set c=$order(hostList(c)) quit:c=""
			set metricClassName=hostList(c)

			// specifically hide all metrics of given business class  ?
			if $d(intHideArr(metricClassName,"*","*")) continue
			
			merge metricData(metricClassName)=$$$EnsMetrics(metricClassName)
			 
			// hide all metrics of business class+instance combination
			set inst=""
			for  {
				set inst=$order(metricData(metricClassName,inst)) quit:inst=""
				if $d(intHideArr(metricClassName,inst,"*")) kill metricData(metricClassName,inst)
			}			
		}
		
		
		// Build JSON for measures
		$$$THROWONERROR(tSC,..buildJSON(.metricData,StructuredOutput,DelimeterForFlattenedData,OmmitClassName,.intHideArr,.json))
			  
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

ClassMethod getParams(StructuredOutput, DelimeterForFlattenedData,OmmitClassName,HideMetrics)
{
	set StructuredOutput=$GET(%request.Data("StructuredOutput",1),0)
	set DelimeterForFlattenedData=$GET(%request.Data("DelimeterForFlattenedData",1),"_")
	set OmmitClassName=$GET(%request.Data("OmmitClassName",1),0)
	set HideMetrics=$GET(%request.Data("HideMetrics",1),"")
	
}

ClassMethod getProductionBusinessMetrics(results, ignoreStatus = 0)
{
	set pParams("class")="Ens.BusinessMetric" 
	do ##class(Ens.ContextSearch).SubclassOf(.cap,.top,.results,.pParams)
	
	quit:ignoreStatus
	
	set c=""
	for  {
		set c=$order(results(c)) quit:c=""
		if '##class(Ens.Director).IsItemEnabled(results(c),.status) kill results(c)
	}
}

}
