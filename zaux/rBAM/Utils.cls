Class zaux.rBAM.Utils Extends %RegisteredObject
{

ClassMethod buildJSON(metricData, StructuredOutput, DelimeterForFlattenedData, Output json As %DynamicObject) As %Status
{
	kill json
	set tSC=$$$OK 
	set json=[]
	
	// Get Properties of metric class.
	set production=##class(Ens.Director).GetActiveProductionName()

	set tMetricClassName=""
	set TimeStamp=metricData 
	
	try { 
		if StructuredOutput=0 {
			set data={}
			set data."_SampledDateTime"=TimeStamp
			set data."_Production"=production
			set del=DelimeterForFlattenedData
		}
		
		for  {
			set tMetricClassName=$order(metricData(tMetricClassName)) quit:tMetricClassName=""		
			// Get Metric Instances.
			do $CLASSMETHOD(tMetricClassName,"GetInstances",.ins)
			
			// record if multi-instance, using 'flgMultiInatance', so that in the 'flat' output format, avoid adding
			// "1" as an instance ID, with each metric.
			set flgMultiInstance=1  
			if $g(ins(1))=1,$order(ins(""))=1,$order(ins(1),-1)="" {
				set flgMultiInstance=0
			}
						
			Set tFullMetricClass=production_"/"_tMetricClassName 
			Set tsc = ..getPropertiesForDataSource(tFullMetricClass_".metric",.pProperties)
						
			set i="",p="" 
			if StructuredOutput=0 {				
				for  {
					set i=$order(ins(i)) quit:i=""  
					for  {
						set p=$order(pProperties(p)) quit:p=""  
						
						if $d(metricData(tMetricClassName,ins(i),pProperties(p)))=1{
							do data.%Set(tMetricClassName_del_$select(flgMultiInstance:(ins(i)_del),1:"")_pProperties(p),metricData(tMetricClassName,ins(i),pProperties(p)))
						} 
						
						// sub nodes ?
						if $DATA(metricData(tMetricClassName,ins(i),pProperties(p)))>9 {
							set sn=""
							for  {
								set sn=$order(metricData(tMetricClassName,ins(i),pProperties(p),sn)) quit:sn="" 
								do data.%Set(tMetricClassName_del_$select(flgMultiInstance:(ins(i)_del),1:"")_pProperties(p)_del_sn,metricData(tMetricClassName,ins(i),pProperties(p),sn))
							}
						}
					}
				}
				
			} else {
				 
				set data={}
				set data."_Production"=production
	 			set data."_MetricClassName"=tMetricClassName
				set data."_SampledDateTime"=TimeStamp 
				
				if flgMultiInstance {
					set data.instances=[]
				}
				
				for  { 
					set instance={}
					set i=$order(ins(i)) quit:i="" 
					if flgMultiInstance {
						set instance.instanceName=ins(i)
					}
					
					set metrics=[]
					for  {
						set metric={}
						set p=$order(pProperties(p)) quit:p="" 
						
						if $d(metricData(tMetricClassName,ins(i),pProperties(p)))=1 {
							do metric.%Set(pProperties(p),metricData(tMetricClassName,ins(i),pProperties(p)))
						}
						// sub nodes ?
						if $DATA(metricData(ins(i),pProperties(p)))>9 {
							// 
							set sn="",subnodes=[]
							for  {
								set subnode={}
								set sn=$order(metricData(tMetricClassName,ins(i),pProperties(p),sn)) quit:sn="" 
								set subnode.key=sn
								set subnode.value=metricData(tMetricClassName,ins(i),pProperties(p),sn)
								do subnodes.%Push(subnode)
							}
							// Add metric with subnodes array
							do metric.%Set(pProperties(p),subnodes)
						}
						do metrics.%Push(metric)
					}
					set instance.metrics=metrics
					if flgMultiInstance {
						do data.instances.%Push(instance)			
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

}
