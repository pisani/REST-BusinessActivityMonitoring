/// Business Metric Class 
Class zaux.rBAM.Sample.MetricClass Extends Ens.BusinessMetric [ ClassType = "", ProcedureBlock ]
{

/// Metric to report average humidity
Property CurrentHumidity as Ens.DataType.Metric(UNITS = " %",RANGEUPPER=30,RANGELOWER=0);

/// Average temperature calculated from 20 previous readings. 
Property AverageTemp As Ens.DataType.Metric(UNITS = "Centigrade",RANGEUPPER=60,RANGELOWER=-60);

/// Metric to export latest CO2 reading
Property CO2Level as Ens.DataType.Metric(UNITS = "ppm",RANGEUPPER=600,RANGELOWER=200)[Multidimensional];

/// Calculate and update the set of metrics for this class
/// This method is just a sample, and generates random values (not using real data) only for demo purposes.
Method OnCalculateMetrics() As %Status
{
	/// 
	/// In the absence of a table with real data random value are being populated for demo purposes
		
	/// Single metrics: get last temp recorded
	/// For Example:  &sql(SELECT TOP 1 into :Humidity from iot_Data.Readings Order By ReadingDate DESC)
	set ..CurrentHumidity=10+$r(20)
		
	/// For Example:  &sql(SELECT TOP 20 AVG(temp) into :avgTemp from iot_Data.Readings Order By ReadingDate DESC)
	set ..AverageTemp = 20+$r(4)_"."_$r(100)
	
	/// Multi-dimensional Metric - Same metric name, with independent subscript
	/// For example, reporting the air quality at 3 different location.
	SET ..CO2Level("Offices")= 		310+$r(10)
	SET ..CO2Level("CarPark")=		200+$r(10)
	SET ..CO2Level("LoadingDocks")=	250+$r(10) 
	  
	  
	/// Metric classes can also be multi-instance, whereby these different instances of the same set of metrics
	/// are collected during a sampling cycle.
	/// For example, in this context, one might have "Building A" and "Building B" as instances.
	/// Instances are not included in this sample for brevity.
	
	Quit $$$OK
} 

}
