Class zaux.rBAM.Utils Extends %RegisteredObject
{

 
ClassMethod buildJSON(metricData, StructuredOutput, DelimeterForFlattenedData,OmmitClassName=1, %HideArrList, Output json As %DynamicObject) As %Status
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
			set del=DelimeterForFlattenedData
		}
				
		for  {
			kill pProperties,ins
			set tMetricHostname=$order(metricData(tMetricHostname)) quit:tMetricHostname=""		
		
			// Get Metric Instances.  
			do $CLASSMETHOD(..resolveClassName(tMetricHostname),"GetInstances",.ins)
			
			// record if multi-instance, using 'flgMultiInatance', so that in the 'flat' output format, avoid adding
			// "1" as an instance ID, with each metric.
			set flgMultiInstance=1  
			if $g(ins(1))=1,$order(ins(""))=1,$order(ins(1),-1)="" {
				set flgMultiInstance=0
			}
						
			Set tFullMetricClass=production_"/"_tMetricHostname 
			Set tsc = ..getPropertiesForDataSource(tFullMetricClass_".metric",.pProperties)
						
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
											
						if $d(metricData(tMetricHostname,ins(i),pProperties(p)))=1{
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
				do json.%Push(data)
			}
		}
		
		if 'StructuredOutput do json.%Push(data)
		
	} catch ex {
		set tSC=ex.AsStatus() 
	}
	
	quit tSC
}

ClassMethod getPropertiesForDataSource(pDataSource As %String, Output pProperties As %List) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tSC = $zobjclassmethod("Ens.BusinessMetricKPI","%GetPropertyInfo",.tInfo,0,pDataSource)
		If $$$ISERR(tSC) Quit

		Set n = 0
		Set p = $O(tInfo(""))
		While (p'="") {
			If (p'["%") {
				Set pProperties($I(n))=p
			}
			Set p = $O(tInfo(p))
		}
	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

ClassMethod buildHideArray(HideMetricsString,intHideArr) {
 
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

ClassMethod hide(class="*",instance="*",property="*") as %Boolean {
	
	quit:$d(%HideArrList("*","*",property)) 1
	quit:$d(%HideArrList("*",instance,property)) 1
	quit:$d(%HideArrList(class,instance,property)) 1
	
	quit 0
	}

ClassMethod resolveClassName(itemName) as %String 
{ 
	quit ##class(Ens.Config.Production).OpenItemByConfigName(itemName).ClassName
}
}
