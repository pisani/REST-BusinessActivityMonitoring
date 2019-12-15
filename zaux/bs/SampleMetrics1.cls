/// Business Metric Class 
Class zaux.bs.SampleMetrics1 Extends Ens.BusinessMetric [ ClassType = "", ProcedureBlock ]
{

/// Number of times these metrics have been calculated.
Property Counter As Ens.DataType.Metric(RANGELOWER = 0, RANGEUPPER = 100000, UNITS = "Events");

/// Total Sales for the current day.
Property SalesHistory As Ens.DataType.Metric(AUTOHISTORY = 50, RANGELOWER = 0, RANGEUPPER = 50, UNITS = "$US") [ MultiDimensional ];

/// Calculate and update the set of metrics for this class
Method OnCalculateMetrics() As %Status
{
  // set the values of our metrics
  Set ..Counter = ..Counter + 1
  Set ..SalesHistory = $GET(..SalesHistory) + $RANDOM(10) - 5

  Quit $$$OK
}

}
