/// This Business Operation sends, over HTTP using REST (POST) the values of one or more Business Metric classes.
/// set to run in this production.
Class zaux.rBAM.Operation Extends (EnsLib.REST.Operation, zaux.rBAM.Utils) [ Language = objectscript ]
{

Parameter INVOCATION = "Queue";

Parameter SETTINGS = "CallInterval:REST Output,StructuredOutput:REST Output,MetricParameters:REST Output,SkipEmptyJSON:REST Output,ServiceClassNames:REST Output:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?services=1&productionName=@productionId&className=Ens.BusinessMetric},ClassNamePrefix:REST Output,HideMetrics:REST Output,PathForDebugFile:REST Output";

/// Identify this productions BusinessMetrics that will be interrogated for their most recent metric values
Property ServiceClassNames As %String(MAXLEN = 1000) [ MultiDimensional ];

/// This applies to No-Structured JSON ouput. FALSE by default
/// <br>
/// If TRUE omit the classname from the JSON attribute name
/// Note - if collecting metrics from multiple business services, and there are common metric names, then, these will be
/// repeated, and the target will not be able to differentiate. 
/// This setting applies when only one BusinessMetric class is used, or when metric names are unique across multiple BusinessMetric Classes 
Property ClassNamePrefix As %Boolean [ InitialExpression = 0 ];

/// Case-Sensitive, Comma separated list of Business Metric Property names to avoid from all output.<br/> 
/// May specify BusinessMetric ClassName, Instance name and or MetricPropertyName </br>
/// Format:  [BusinessComponentName]:[Instance]:[MetricProperty],.. <br>
/// <p>
/// eg:  to hide the metric "totalRevenue", in the instance "North", from any BusinessHostname, specify, (without quotes):- </br>  
/// 		 ":North:totalRevenue"
/// 
Property HideMetrics As %String(MAXLEN = 2500);

/// if TRUE, include metric parameters (like RANGEUPPER/LOWER, UNITS and THRESHOLDUPPER/LOWER) as part of JSON data. </br>
/// The default is FALSE. Currently, iether all metric parameters are expressed for all metrics, or, none at all.
Property MetricParameters As %Boolean;

/// a file path that can be ussed to received a file JSONPostData.txt, representing the most recent data being distributed over HTTP
Property PathForDebugFile As %String;

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
// 		"zaux.bs.SampleMetrics_[Lat-RANGELOWER]":10,
// 		"zaux.bs.SampleMetrics_[Lat-RANGEUPPER]":99,
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
// 		"_HostnameName":"zaux.bs.SampleMetrics",
// 		"instances": [
// 						 	{"metrics" [
// 								 {"City" :"AAAAA555555"},
// 								 {"Lat" :"AAAAA555555"},
// 								 {"Long" :"AAAAA555555"},
// 								 {"TwitterMentions" :"98.6"},
// 								 {"HiLowTemp":[
// 											   {"key":"Low","value":"13"},
// 											   {"key":"High","value":"26"}
// 											  ]},
// 								 {"AirQuality":[
// 											   {"key":"1","value":"106"},
// 											   {"key":"2","value":"102"},
// 											   {"key":"3","value":"103"},
// 											  ]}
// 								 ]}
// 					]	
// 	    "MetricProperties":[ 
//		       { 
//		          "Metric":"AirQuality",
//		          "RANGELOWER":"0",
//		          "RANGEUPPER":"100",
//		          "THRESHOLDLOWER":"0",
//		          "THRESHOLDUPPER":"100",
//		          "UNITS":""
//		       },
//			   {
//      	  ... 
//		       }
//		]
// 	}
//  ]
// 
// for BusinessMetrics with multiple instances, the element "instances" will include a json property "instanceName" (in the structured
// output) and be part of the json property name in the non-structured output format.
// 
*/
/// Set to FALSE if the JSON body of data is to be flattened into a single level of JSON properties, regardless of BusinessMetric name, Instance, or Metric property
/// If false, the JSON body will be structured with a collection of Business Metrics, that wraps a collection of Instances, and then Metrics in a more structured format.
Property StructuredOutput As %Boolean [ InitialExpression = 0 ];

/// Time (in seconds) to wait before checking recently collected Metric values from the Business Metric classes defined <br>
/// and posting to a REST endpoint. </br>
/// A value of 0 - means do not regularly collect and post. This will be used in conjunction with <br>
/// the ad-hoc, manual posting of metrics when the Business Operation reveives a Message (Ens.StringRequest) with a metric Host Name. 
Property CallInterval As %Integer [ InitialExpression = 5 ];

Property DelimeterForFlattenedData As %String [ InitialExpression = "_" ];

/// Don't send JSON if JSON is empty.
Property SkipEmptyJSON As %Boolean [ InitialExpression = 1 ];

Parameter DEBUG As %Boolean = 0;

/// used to avoid re-posting data, if previous cycle failed.
Property ErrorStatus As %Boolean;

/// This method will be called within KeepaliveInterval of the last return from OnTask() or OnKeepalive().
/// It is called via the Adapter's OnKeepalive() method, which is called from the Host.OnTask() method;
/// if there is no Adapter there is no keepalive call.
Method OnKeepalive(pAdapterStatus As %Status, ServiceClassNames = "") As %Status
{
	
	set tSC=$$$OK
	try {
		if '..ErrorStatus set tSC=..CollectAndPostData(ServiceClassNames)
		
	} catch ex {
		set tSC=ex.AsStatus()
	}
	if tSC'=$$$OK quit ##super(tSC)
     
	quit ##super(pAdapterStatus)
}

Method PostMetricData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	set tSC=$$$OK
	
	try {
		set ServiceClassNames=pRequest.StringValue
		set tSC=..CollectAndPostData(ServiceClassNames,1)
			
	} catch ex {
		set tSC=ex.AsStatus()
	}
	
	quit tSC
}

Method CollectAndPostData(ServiceClassNames = "", MessageDriven = 0) As %Status
{
	set tSC=$$$OK
	set metricData=..getSampleTime()
	
	set:ServiceClassNames="" ServiceClassNames=..ServiceClassNames
	quit:ServiceClassNames="" $$$OK // nothing to do.
	
	if ..#DEBUG set formatter=##class(%JSON.Formatter).%New()
	
	try
	{
		merge intHideArr=..intHideArr
		
		for i=1:1:$l(ServiceClassNames,",") {
			
			set Hostname=$piece(ServiceClassNames,",",i) 
			continue:Hostname=""
			
			continue:'##class(Ens.Director).IsItemEnabled(Hostname,.status)
			merge metricData(Hostname)=$$$EnsMetrics(Hostname) 
			
		} 
		
		// Build JSON for measures
		$$$THROWONERROR(tSC,..buildJSON(.metricData,..StructuredOutput,..MetricParameters,..DelimeterForFlattenedData,..ClassNamePrefix,.intHideArr, .json))
		  
		;# Write JSON to foreground for now
		if $d(json),$isObject(json) {
			
			set skip=0
			if $tr(json.%ToJSON(),"[{}]","")=""&&(..SkipEmptyJSON) set skip=1
			
			if ..#DEBUG {
				write !,$select(skip:"Skipping ",1:"Sending ")_"Metric data as: ",! 
				do formatter.FormatToStream(json,.formattedStream)
				do formattedStream.OutputToDevice() 
				write !
			}
			
			; Call HTTP Post
  			if 'skip $$$THROWONERROR(tSC,..Adapter.Post(.tHttpResponse,,json.%ToJSON()))
  			
  			if ..PathForDebugFile'="" do ..CreateJSONPostData(json)
  		}
		
	} catch ex {
		set tSC=ex.AsStatus()
	}
	
	if $$$ISERR(tSC) {
		if ..#DEBUG write !,$System.Status.DisplayError(tSC)
		if ..#DEBUG,$d(tHttpResponse) {
			write !,tHttpResponse.Data.OutputToDevice()
		} 
		
		/// For non-message driven postings, Comment this line out if you want Business operation to stop periodically sending data on call interval, once an error is encountered.
		/// if 'MessageDriven set ..ErrorStatus=1
	}
    quit tSC
}

Method CreateJSONPostData(json)
{

	quit:'##class(%File).DirectoryExists(..PathForDebugFile)
	
	set dir=..PathForDebugFile,filename=##class(%File).NormalizeDirectory("JSONPostData.txt",dir)
	set file=##class(%File).%New(filename)
	do file.Open("WNS")
	do file.WriteLine("HTTP Server: "_..Adapter.HTTPServer)
	do file.WriteLine("HTTP Port: "_..Adapter.HTTPPort)
	do file.WriteLine("HTTP URL: "_..Adapter.URL)
	do file.WriteLine("SSL Credentials: "_..Adapter.Credentials)
	do file.WriteLine("")
	set formatter=##class(%JSON.Formatter).%New()
	do formatter.FormatToStream(json,.formattedStream)
	do file.CopyFrom(formattedStream) 

	do file.%Save()
}

/// This user callback method is called via initConfig() from %OnNew() or in the case of SOAP Services from OnPreSOAP()
Method OnInit() As %Status
{
	set ..ErrorStatus=0
	set ..Adapter.KeepaliveInterval=..CallInterval
	
	// populate internal multi-dimensional property of metrics to ommit from view  
	do ..buildHideArray(..HideMetrics,.intHideArr)	merge ..intHideArr=intHideArr
	
	Quit $$$OK
}

XData MessageMap
{
<MapItems>
<MapItem MessageType="Ens.StringRequest">
<Method>PostMetricData</Method>
</MapItem>
</MapItems>
}

}
