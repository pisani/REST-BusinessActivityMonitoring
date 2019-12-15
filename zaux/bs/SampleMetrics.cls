/// Business Metric Class 
Class zaux.bs.SampleMetrics Extends Ens.BusinessMetric [ ClassType = "", ProcedureBlock ]
{

Property Long As Ens.DataType.Metric(RANGELOWER = 0, RANGEUPPER = 150, UNITS = "Long");

Property Lat As Ens.DataType.Metric(RANGELOWER = 0, RANGEUPPER = 150, UNITS = "Long");

Property City As Ens.DataType.Metric(RANGELOWER = 0, RANGEUPPER = 150, UNITS = "City");

Property TwitterMentions As Ens.DataType.Metric(RANGELOWER = 0, RANGEUPPER = 150, UNITS = "Volume");

Property HiLowTemp As Ens.DataType.Metric(UNITS = "Degrees") [Multidimensional];

Property AirQualityReadings as Ens.DataType.Metric(AUTOHISTORY=3) [Multidimensional];

/// Calculate and update the set of metrics for this class
Method OnCalculateMetrics() As %Status
{
	
	set cid=$r(5)+ 1201 	
	&sql(SELECT * into :PLIST() from zaux_data.Cities where ID=:cid)
	
	set ..City=PLIST(2)
	SET ..Long=PLIST(5)
	SET ..Lat=PLIST(6)
	SET ..TwitterMentions=$R(1000)
	
	// Multi-dimensional Metric
	SET ..HiLowTemp("Low")=10+$r(5)
	SET ..HiLowTemp("High")=22+$r(5)
	
	// AutoHistory metric
	SET ..AirQualityReadings=100+$r(10)
	
	Quit $$$OK
} 
 
/// Instances - define instances
ClassMethod OnGetInstances(ByRef pInstSet As %String) As %Status 
{ 
	set pInstSet(1)="North"
	set pInstSet(2)="South"
	Quit $$$OK
} 

}
