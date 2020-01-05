/// Business Metric Class 
Class zaux.bs.SampleMetrics Extends Ens.BusinessMetric [ ClassType = "", ProcedureBlock ]
{

/// Metric to expose average temperature from readings gathered in last 24 hours.
Property AverageDailyTemp As Ens.DataType.Metric(UNITS = "Degrees",RANGEUPPER=100,RANGELOWER=10);

/// Metric to export readings from multiple AirQuality sensors
Property AirQuality as Ens.DataType.Metric(RANGEUPPER=200,RANGELOWER=20) [Multidimensional];
 

/// Calculate and update the set of metrics for this class
/// This method is just a sample, and generates random values (not using real data) only for demo purposes.
Method OnCalculateMetrics() As %Status
{
	 
	/// Sample query: &sql(SELECT AVG(temp) into :avgTemp from iot_Data.Readings)
	/// Generate random value for demo purposes
	set ..AverageDailyTemp=10+$r(20) 
	
	// Multi-dimensional Metric. 
	SET ..AirQuality("Offices")= 		300+$r(10)
	SET ..AirQuality("CarPark")=		200+$r(10)
	SET ..AirQuality("LoadingDocks")=	100+$r(10) 
	  
	Quit $$$OK
} 

}
