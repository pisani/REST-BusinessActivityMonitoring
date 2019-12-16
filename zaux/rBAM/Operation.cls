/// TODO:
/// 3. Create a zaux.bs.SampleMetrics class good for the Quickstart Interoperability solution.
/// 4. Create API as %zaux.rBAM.API for CACHELIB install. Document appropriatly
/// 5. Expose Units ?

/// 98. Make github repository public !
/// 99. Complete Documentation and Post !
/// This Business Operation sends, over HTTP using REST (POST) the values of one or more Business Metric classes.
/// set to run in this production.
/// 
Class zaux.rBAM.Operation Extends (EnsLib.REST.Operation, zaux.rBAM.Utils) [ Language = objectscript ]
{

Parameter INVOCATION = "Queue";

Parameter SETTINGS = "CallInterval:REST Output,StructuredOutput:REST Output,SkipEmptyJSON:REST Output,BusinessMetricsNames:REST Output:selector?multiSelect=1&context={Ens.ContextSearch/SubclassOf?class=Ens.BusinessMetric},ClassNamePrefix:REST Output,HideMetrics:REST Output";

/// Identify this productions BusinessMetrics that will be interrogated for their most recent metric values
Property BusinessMetricsNames As %String(MAXLEN = 1000) [ MultiDimensional ];

/// This applies to No-Structured JSON ouput. FALSE by default
/// <br>
/// If TRUE omit the classname from the JSON attribute name
/// Note - if collecting metrics from multiple business services, and there are common metric names, then, these will be
/// repeated, and the target will not be able to differentiate. 
/// This setting applies when only one BusinessMetric class is used, or when metric names are unique across multiple BusinessMetric Classes 
Property ClassNamePrefix As %Boolean [ InitialExpression = 0 ];

/// Comma separated list of Business Metric Property names to avoid from all output.<br/> 
/// May specify BusinessMetric ClassName, Instance name and or MetricPropertyName </br>
/// Format:  [BusinessComponentName]:[Instance]:[MetricProperty],.. <br>
/// <p>
/// eg:  to hide the metric "totalRevenue", in the instance "North", from any BusinessMetricClass, specify, (without quotes):- </br>  
/// 		 ":North:totalRevenue"
/// 
Property HideMetrics As %String(MAXLEN = 2500);

Property intHideArr As %String [ MultiDimensional, Private ];

/*
// EG:
// (Default, as require by PowerBI) 
// StructuredOutput = FALSE pushes a JSON body of data as follows:
// [
// {
// 		"_Production" :"AAAAA555555",
// 		"_SampledDateTime" :"AAAAA555555",
// 		"zaux.bs.SampleMetrics_City" :"AAAAA555555",
// 		"zaux.bs.SampleMetrics_Lat" :"AAAAA555555",
// 		"zaux.bs.SampleMetrics_Long" :"AAAAA555555",
// 		"zaux.bs.SampleMetrics_TwitterMentions" :"98.6"
// 		"zaux.bs.SampleMetrics_HiLowTemp_Low" :"13"
// 		"zaux.bs.SampleMetrics_HiLowTemp_High" :"26"
// 		"zaux.bs.SampleMetrics_AirQuality_1" :"106"
// 		"zaux.bs.SampleMetrics_AirQuality_2" :"102"
// 		"zaux.bs.SampleMetrics_AirQuality_3" :"103"
// 
// 	}
// ]
// 
// and with StructuredOutput = TRUE pushes a JSON body of data as follows:
// [
// {
// 		"_Production" :"AAAAA555555",
// 		"_SampledDateTime" :"AAAAA555555",
// 		"_MetricClassName":"zaux.bs.SampleMetrics",
// 		"instances": [
// 						 	{"metrics" [
// 								 {"City" :"AAAAA555555"},
// 								 {"Lat" :"AAAAA555555"},
// 								 {"Long" :"AAAAA555555"},
// 								 {"TwitterMentions" :"98.6"}
// 									 {"HiLowTemp":[
// 												   {"key":"Low","value":"13"},
// 												   {"key":"High","value":"26"}
// 												  ]
// 									 {"AirQuality":[
// 												   {"key":"1","value":"106"},
// 												   {"key":"2","value":"102"},
// 												   {"key":"3","value":"103"},
// 												  ]
// 									 }
// 								]
// 						}
// 						]	
// 	}
// ]
// 
// for BusinessMetrics with multiple instances, the element "instances" will include a json property "instanceName" (in the structured
// output) and be part of the json property name in the non-structured output format.
// 
*/
/// Set to FALSE if the JSON body of data is to be flattened into a single level of JSON properties, regardless of BusinessMetric name, Instance, or Metric property
/// If false, the JSON body will be structured with a collection of Business Metrics, that wraps a collection of Instances, and then Metrics in a more structured format.
Property StructuredOutput As %Boolean [ InitialExpression = 0 ];

/// Time (in seconds) to wait before checking Metric values from the Business Metric classes defined
Property CallInterval As %Integer [ InitialExpression = 5 ];

Property DelimeterForFlattenedData As %String [ InitialExpression = "_" ];

/// Don't send JSON if JSON is empty.
Property SkipEmptyJSON As %Boolean [ InitialExpression = 1 ];

Parameter DEBUG As %Boolean = 0;

/// This method will be called within KeepaliveInterval of the last return from OnTask() or OnKeepalive().
/// It is called via the Adapter's OnKeepalive() method, which is called from the Host.OnTask() method;
/// if there is no Adapter there is no keepalive call.
Method OnKeepalive(pAdapterStatus As %Status) As %Status
{
	set tSC=$$$OK
	set metricData=$zdt($h,3)
	try
	{
		merge intHideArr=..intHideArr
		
		for i=1:1:$l(..BusinessMetricsNames,",") {
			
			set MetricClass=$piece(..BusinessMetricsNames,",",i) 
			continue:MetricClass=""
			
			// hide all metrics of given business class  ?
			if $d(intHideArr(MetricClass,"*","*")) continue
			
			continue:'##class(Ens.Director).IsItemEnabled(MetricClass,.status)
			merge metricData(MetricClass)=$$$EnsMetrics(MetricClass) 
			
			// hide all metrics of business class,instance combination
			set inst=""
			for  {
				set inst=$order(metricData(MetricClass,inst)) quit:inst=""
				if $d(intHideArr(MetricClass,inst,"*")) kill metricData(MetricClass,inst)
			}
		} 
		
		// Build JSON for measures
		$$$THROWONERROR(tSC,..buildJSON(.metricData,..StructuredOutput,..DelimeterForFlattenedData,..ClassNamePrefix,.intHideArr, .json))
		  
		;# Write JSON to foreground for now
		if $d(json),$isObject(json) {
			
			set skip=0
			if $tr(json.%ToJSON(),"[{}]","")=""&&(..SkipEmptyJSON) set skip=1
			
			if ..#DEBUG {
				write !,$select(skip:"Skipping ",1:"Sending ")_"Metric data as: ",!
				write !,json.%ToJSON(),!
			}
			
			; Call HTTP Post
  			if 'skip $$$THROWONERROR(tSC,..Adapter.Post(.tHttpResponse,,json.%ToJSON()))
  			
  		}
		
	} catch ex {
		set tSC=ex.AsStatus()
	}
	if $$$ISERR(tSC) {
		if ..#DEBUG write !,$System.Status.DisplayError(tSC) 
		quit tSC
	}
    
	quit ##super(pAdapterStatus)
}

/// This user callback method is called via initConfig() from %OnNew() or in the case of SOAP Services from OnPreSOAP()
Method OnInit() As %Status
{
	set ..Adapter.KeepaliveInterval=..CallInterval
	
	do ..buildHideArray(..HideMetrics,.intHideArr)
	merge ..intHideArr=intHideArr
			
	Quit $$$OK
}

}
