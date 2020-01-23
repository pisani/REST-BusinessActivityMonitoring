Class zaux.rBAM.Utils Extends %RegisteredObject
{

/// This is the core method that generates JSON for metrics being captured by a producion.
/// metricData 				- Array of metric readings captured from ^IRIS.Temp.EnsMetrics in the form of:
/// 							  metricData(<hostName>,<instanceName or 1>,<metricPropertyName>,<AutoHistoryNumber or Multi-Dimensional subscript>)					 
/// StructuredOutput		- 0/1 for a 'flat', single level JSON object, or multi-level structured JSON output format
/// IncludeMetricParameters	- 0/1 defining whether to hide/show RANGEUPPER, RANGELOWER, etc metric property parameters
/// DelimeterForFlatData	- Delimeter (single character) to use when generating the non-Structured format of JSON data
/// OmmitClassName			- 0/1 define whether to include/exclude MetricClassName when generating the non-Structured format of JSON data
/// %HideArraMap			- Array of metricClass,instance,metricProperty names to hide from output, for the purposes of hiding specific metricProperties.
/// json					- generated JSON Object of metric data.
ClassMethod buildJSON(metricData, StructuredOutput = 0, IncludeMetricParameters = 0, DelimeterForFlatData = "-", OmmitClassName = 1, %HideArrMap, Output json As %DynamicObject) As %Status
{
	kill json
	set tSC=$$$OK 
	set json=[]
	
	set production=##class(Ens.Director).GetActiveProductionName()

	set tMetricHostname=""
	set TimeStamp=metricData 
	 	
	try { 
		set data={}
		set data."_Production"=production
		set data."_SampledDateTime"=TimeStamp
	
		if StructuredOutput=0 {
			set del=DelimeterForFlatData
		}
		
		// remove metrics flagged for as hidden in %HideArrMap
		for  {
			set tMetricHostname=$order(metricData(tMetricHostname)) quit:tMetricHostname=""	
			
			// Check for hiding all metrics of given business class 
			if $d(%HideArrMap(tMetricHostname,"*","*")) kill metricData(tMetricHostname) continue
			
			// Check for hiding specific instances metrics of given business class
			set inst=""
			for  {
				set inst=$order(metricData(tMetricHostname,inst)) quit:inst=""
				if $d(%HideArrMap(tMetricHostname,inst,"*")) kill metricData(tMetricHostname,inst)
			}
		}
				
		set tMetricHostname=""		
		for  {
			kill pProperties,ins
			set tMetricHostname=$order(metricData(tMetricHostname)) quit:tMetricHostname=""		
		
			// Get Metric Instances.  
			set tMetricClassName=..resolveClassName(tMetricHostname)
			do $CLASSMETHOD(tMetricClassName,"GetInstances",.ins)
			
			// record if multi-instance, using 'flgMultiInatance', so that in the 'flat' output format, avoid adding
			// "1" as an instance ID, with each metric.
			set flgMultiInstance=1  
			if $g(ins(1))=1,$order(ins(""))=1,$order(ins(1),-1)="" {
				set flgMultiInstance=0
			}
						 
			Set tSC = ..getPropertiesForDataSource(tMetricClassName,IncludeMetricParameters,.pProperties)
										
			set i="",p="" 
			if StructuredOutput=0 {				
				set attMetric=tMetricHostname_del if OmmitClassName set attMetric=""
				for  {
					set i=$order(ins(i)) quit:i=""  
					continue:..hide("*",ins(i))
					continue:..hide(tMetricHostname,ins(i))
					
					for  {
						set p=$order(pProperties(p)) quit:p=""  
						continue:..hide(tMetricHostname,ins(i),pProperties(p))
						continue:..hide(tMetricHostname,"*",pProperties(p))
																	
						if $d(metricData(tMetricHostname,ins(i),pProperties(p)))=1 {
							do data.%Set(attMetric_$select(flgMultiInstance:(ins(i)_del),1:"")_pProperties(p),metricData(tMetricHostname,ins(i),pProperties(p)))
						} 
						
						// sub nodes ?
						if $DATA(metricData(tMetricHostname,ins(i),pProperties(p)))>9 {
							set sn=""
							for  {
								set sn=$order(metricData(tMetricHostname,ins(i),pProperties(p),sn)) quit:sn="" 
								do data.%Set(attMetric_$select(flgMultiInstance:(ins(i)_del),1:"")_pProperties(p)_del_sn,metricData(tMetricHostname,ins(i),pProperties(p),sn))
							}
						}
						
						// add property parameters
						// TODO: smarter way if including/excluding metric parameters
						// do ..addRemoveMetricParameters(StructuredOutput,IncludeMetricParameters,.pProperties,.data,attMetric)
						
						set meta=""
						for  {
							set meta=$order(pProperties(p,meta)) quit:meta=""
							do data.%Set(attMetric_pProperties(p)_"("_meta_")",pProperties(p,meta))
						}
						
						
					}
				}
				
			} else {
				 
				set data={}
				set data."_MetricClassName"=tMetricHostname
				
				if flgMultiInstance {
					set data.instance=[]
				}
				
				set i=""
				for  { 
					set instance={}
					set i=$order(ins(i)) quit:i=""
					continue:..hide("*",ins(i)) 
					continue:..hide(tMetricHostname,ins(i))
					
					if flgMultiInstance {
						set instance.instanceName=ins(i)
					}		
						
					// add values.	
					set metrics=[],p=""
					for  { 
						set metric={}
						set p=$order(pProperties(p)) quit:p="" 
						continue:..hide(tMetricHostname,ins(i),pProperties(p))
						
						if $d(metricData(tMetricHostname,ins(i),pProperties(p)))=1 {
							do metric.%Set(pProperties(p),metricData(tMetricHostname,ins(i),pProperties(p)))
						}
						
						// sub nodes ?
						if $DATA(metricData(tMetricHostname,ins(i),pProperties(p)))>9 {
							//
							set sn="",subnodes=[]
							for  {
								set subnode={}
								set sn=$order(metricData(tMetricHostname,ins(i),pProperties(p),sn)) quit:sn="" 
								set subnode.key=sn
								set subnode.value=metricData(tMetricHostname,ins(i),pProperties(p),sn)
								do subnodes.%Push(subnode)
							}
							// Add metric with subnodes array
							do metric.%Set(pProperties(p),subnodes)
						}
						do metrics.%Push(metric)
					}
					set instance.metrics=metrics
					
					if flgMultiInstance {
						do data.instance.%Push(instance)			
					} else {
						set data.instance=instance
					}
				}
				
				// TODO: smarter way if including/excluding metric parameters
				// do ..addRemoveMetricParameters(StructuredOutput,IncludeMetricParameters,.pProperties,.metricProperties)
					
				if IncludeMetricParameters {
					set p="",metricProperties=[]
					for  { 
						set p=$order(pProperties(p)) quit:p="" 
					
						// add property parameters
						set meta=""
						set metricProp={}
						set metricProp.Metric=pProperties(p)
						for  {
							set meta=$order(pProperties(p,meta)) quit:meta=""					
							do metricProp.%Set(meta,pProperties(p,meta))
						}
						do metricProperties.%Push(metricProp)
					}
					set data.metricProperties=metricProperties			
				}
				
				do json.%Push(data)
			}
		}
		
		if 'StructuredOutput do json.%Push(data)
		
	} catch ex {
		set tSC=ex.AsStatus() 
	}
	
	if tSC set tSC=..OnBuildJSON(.json,.pProperties)
	quit tSC
}

ClassMethod getSampleTime() As %String
{

	set st=$zdt($h,3,,3)
	set st=$tr(st," ","T")
	quit st
}

ClassMethod getPropertiesForDataSource(pDataSource As %String, IncludeMetricParameters, Output pProperties) As %Status
{
	Set tSC = $$$OK
	Try {
		set class=##class(%Dictionary.CompiledClass).%OpenId(pDataSource)
		set pCount=class.Properties.Count()
		set n=0
		for i=1:1:pCount {
			continue:class.Properties.GetAt(i).Type'="Ens.DataType.Metric"
			set prop=class.Properties.GetAt(i)
			continue:$extract(prop.Name)="%"
			
			set n=n+1,pProperties(n)=prop.Name
			continue:'IncludeMetricParameters
			
			for meta="UNITS","RANGEUPPER","RANGELOWER","THRESHOLDUPPER","THRESHOLDLOWER" {
				set pProperties(n,meta)=prop.Parameters.GetAt(meta)
			}
		}
	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// take user-specified configuration sting of metric data to hide, and turn it
/// into a 3-dimensional array to be used during the data collection/projection phase.
ClassMethod buildHideArray(HideMetricsString, intHideArr)
{
 
	kill intHideArr
	for x=1:1:$l(HideMetricsString,",") { 
		set mic=$piece(HideMetricsString,",",x) continue:mic=""
		set m=$p(mic,":",3),i=$p(mic,":",2),c=$p(mic,":",1)
		
 		; setup intHideArr() to be used later for skipping over specific entries from collected metric data.
		set:c="" c="*"
		set:i="" i="*"
		set:m="" m="*"
		set intHideArr(c,i,m)=""
	}
}

ClassMethod hide(class = "*", instance = "*", property = "*") As %Boolean
{
	
	quit:$d(%HideArrMap("*","*",property)) 1
	quit:$d(%HideArrMap("*",instance,property)) 1
	quit:$d(%HideArrMap(class,instance,property)) 1
	
	quit 0
}

ClassMethod resolveClassName(itemName) As %String
{
 
	set configItem=##class(Ens.Config.Production).OpenItemByConfigName(itemName)
	if $IsObject(configItem) quit configItem.ClassName
	quit ""
}

// Work in progress:
ClassMethod addRemoveMetricParameters(OutputFormat, pProperties, Output metricProperties As %DynamicObject, attMetric)
{
					
					// $ALL; {p}:RTU; 
					/*
						if +

						set imp("$ALL")=""
						set imp("+","AirQuality")="RT"
						set imp("-","AverageTemp")="U"
						
						RT; -Air*:r;-
					*/
											
					set p=""
					for  { 
						set p=$order(pProperties(p)) quit:p="" 
					
						// add property parameters
						set meta=""
						set metricProp={}
						set metricProp.Metric=pProperties(p)
						for  {
							set meta=$order(pProperties(p,meta)) quit:meta=""
							if $d(imp("$ALL$")) {
								if $d(imp("-",p)) {
									set remove=imp("-",p)
									for i=1:1:$l(remove) { 
										if $zconvert($e(remove,i),"U")'[$zconvert($e(meta),"U") {do metricProp.%Set(meta,pProperties(p,meta))}
											}
								}	
							} elseif $d(imp("$NONE$")) {
								if $d(imp("+",p)) {
									set remove=imp("+",p)
									for i=1:1:$l(remove) { 
										if $zconvert($e(remove,i),"U")[$zconvert($e(meta),"U") {do metricProp.%Set(meta,pProperties(p,meta))}
									}
								}								
							} else {
								if $d(imp("+",p)) {
									set remove=imp("+",p)
									for i=1:1:$l(remove) { 
										if $zconvert($e(remove,i),"U")[$zconvert($e(meta),"U") {do metricProp.%Set(meta,pProperties(p,meta))}
									}
								}								
							}
							//do metricProp.%Set(meta,pProperties(p,meta))
						}
						do metricProperties.%Push(metricProp)			
					}
}

/// Called after normal compilation of JSON body just before sending result.
/// pProperties is an array of metric property names and included meta tags.
ClassMethod OnBuildJSON(json As %Library.DynamicObject, pProperties) As %Status
{
	
	quit $$$OK
}

}
