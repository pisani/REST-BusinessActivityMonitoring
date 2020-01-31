# REST Business Activity Monitoring

This code extends on the Business Activity Monitoring features natively available with InterSystems IRIS’s integration framework. 

## Features:
* Capture and push (using HTTP POST) business metric values to a nominated REST endpoint. 
This is useful if you want to capture metrics and update a remote system. For example – using this feature one can push the metric values to a Power BI Streaming dataset which can be then consumed by Microsoft Power BI Dashboards for real-time visualization in that framework.

* Setup a REST API as an endpoint for external systems to call in and retrieve the list of business metric classes running in a production, as well as the metric values of a one or all enabled Business Metric Classes  


It is worth mentioning that this functionality is accomplished without needing to modify, subclass or otherwise extend any existing Business Metric class code you have. This functionality taps into the tables currently defined by IRIS, that hold the most recent calculated metric values. 
It is possible to import the entire package and implement both options offered here.


## Installation:
- Clone or download/extract the [REST-BusinessActivityMonitoring repository](https://github.com/pisani/REST-BusinessActivityMonitoring) into an empty folder on your system
- Open an InterSystems IRIS Terminal Window
- Switch into a Namespace configured for interoperability.
- Import the code into your namespace by executing execute the following command, where <yourTempDir> is the folder containing extracted  repository.(Note this imports the entire package) : 
```
do $System.OBJ.LoadDir(<yourTempDir>,”ck”,,1)
```
Note: this method imports all functionality, including the Sample Production and Sample Metric class. You may remove the classes not required (ex zaux.rBAM.Sample*). Please refer to the Installation section of the included [documentation](https://github.com/pisani/REST-BusinessActivityMonitoring/blob/master/zaux.rBAM.OpenExchange.pdf) to identify which classes to retain. 

