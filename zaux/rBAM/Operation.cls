/// This Business Operation sends, over HTTP using REST (POST) the values of one or more Business Metric classes.
/// set to run in this production.
/// 
Class zaux.rBAM.Operation Extends (EnsLib.REST.Operation, zaux.rBAM.Utils) [ Language = objectscript ]
{

Parameter INVOCATION = "Queue";

Parameter SETTINGS = "CallInterval:REST Output,StructuredOutput:REST Output,SkipEmptyJSON:REST Output,BusinessMetricsNames:REST Output:selector?multiSelect=1&context={Ens.ContextSearch/SubclassOf?class=Ens.BusinessMetric}";

/// Identy this productions BusinessMetrics that will be interrogated for their most recent metric values
Property BusinessMetricsNames As %String(MAXLEN = 1000) [ MultiDimensional ];

/// Set to FALSE if the JSON body of data is to be flattened into a single list of JSON elements, regardless of BusinessMetric name, Instance, or Metric property
/// If false, the JSON bodyy will be structured with a collection of Business Metrics, that wraps a collection of Instances, and then Metrics in a more structured format.
Property StructuredOutput As %Boolean [ InitialExpression = 0 ];

/// Time (in seconds) to wait before checking Metric values from the Business Metric classes defined
Property CallInterval As %Integer [ InitialExpression = 5 ];

Property DelimeterForFlattenedData As %String [ InitialExpression = "_" ];

/// Don't send JSON if JSON is empty.
Property SkipEmptyJSON As %Boolean [ InitialExpression = 1 ];

Parameter DEBUG As %Boolean = 1;

/// This method will be called within KeepaliveInterval of the last return from OnTask() or OnKeepalive().
/// It is called via the Adapter's OnKeepalive() method, which is called from the Host.OnTask() method;
/// if there is no Adapter there is no keepalive call.
Method OnKeepalive(pAdapterStatus As %Status) As %Status
{
	set tSC=$$$OK
	set metricData=$zdt($h,3)
	try
	{
		for i=1:1:$l(..BusinessMetricsNames,",") {
			
			set MetricClass=$piece(..BusinessMetricsNames,",",i) 
			continue:MetricClass=""
			continue:'##class(Ens.Director).IsItemEnabled(MetricClass,.status)
			
			merge metricData(MetricClass)=$$$EnsMetrics(MetricClass)
			
		} 
		
		// Build JSON for measures
		$$$THROWONERROR(tSC,..buildJSON(.metricData,..StructuredOutput,..DelimeterForFlattenedData,.json))
		  
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
	Quit $$$OK
}

}
