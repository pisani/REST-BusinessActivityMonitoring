# REST Business Activity Monitoring extension

This code extends on the Business Activity Monitoring features natively available with InterSystems IRIS’s integration framework. 

* Capture and push (using HTTP POST) business metric values to a nominated REST endpoint. 
This is useful if you want to capture metrics and update a remote system. For example – using this feature one can push the metric values to a Power BI Streaming dataset which can be then consumed by Microsoft Power BI Dashboards for real-time visualization in that framework.

* Setup a REST API as an endpoint for external systems to call in and retrieve the list of business metric classes running in a production, as well as the metric values of a one or all enabled Business Metric Classes  

```
It is worth mentioning that this functionality is accomplished without needing to modify, 
subclass or otherwise extend any existing Business Metric class code you have. This functionality 
taps into the tables currently defined by IRIS, that hold the most recent calculated metric values. 
It is possible to import the entire package and implement both options offered here.
```

## Installation:
- if using git, clone the repository found here:        https://github.com/pisani/REST-BusinessActivityMonitoring

Classes need to be downloaded and imported into your IRIS Namespace
If using the REST API to retrieve metric values, a WEB Applications needs to be defined in IRIS.
Follow the instructions in the provided documentation for a step by step setup of the above.  


## Try it out: HTTP Post to push metric data to external sources.
Using an alternative dashboard (eg Power BI Dashboard) to plot metric data
-	This gives you instant mobile device compatibility for the dashboard you build.
-	This gives the ability to display multiple metrics from different IRIS Productions/Namespaces/Servers on a single Power BI dashboard

To accomplish this, the overall steps needed are:
(a)	Add the zaux.rBAM.Operation to your IRIS production, identify which metrics to broadcast in an HTTP Rest call to a Microsoft Power BI Streaming Dataset, together with other settings
(b)	Define a Microsoft Power BI Streaming Dataset with the same JSON payload as that being broadcast by your IRIS Business Operation,
(c)	Use the URL provided by the Power BI Streaming Dataset, in the Business Operation
(d)	Define a Microsoft Power BI Dashboard to consume and plot IRIS streaming data into dashboard tiles.

To try this out we will use the sample production, and sample metric class and configuration which is provided in the code, as the data source, however, you can use your own if you wish. Note – the sample Metric class only issues random values, but in a production environment, these values will be calculated from data within the IRIS database.
Step 1:	Import code and setup the sample production.
1.1	Import the zaux.rBAM.* classes into an interoperability enabled IRIS Namespace. View the production: zaux.rBAM.Sample.Production. Do not start the production yet.

 

Step 2: Define a Streaming Dataset that aligns with the IRIS Output.
2.1	Log into your PowerBI Microsoft account:  powerbi.microsoft.com
2.2	With your Workspace selected, refer to the top right-hand drop menu + Create, and select Create -> Streaming Dataset
2.3	Select { API }  to define a generic streaming dataset, then click NEXT.
2.4	Give your Dataset a name (eg: ‘IRISStreamingDataset’), and add the values as per screen grab below:

 

* For brevity, ‘AverageTemp’ is the only metric we are choosing to publish from the IRIS production. 
2.5	Click on CREATE to save this Streaming Dataset definition.
2.6	Once created, you will be provided with URL that can we need to supply to IRIS, in order for it to stream data. Copy the long Push URL value provided, (shown below, but yours will be different..) as we need to supply this to multiple IRIS Business Operation configuration settings.

  


Step 3. Update the IRIS Business Operation
3.1	Back in IRIS, and the Basic Settings of zaux.rBAM.Operation;  configure HTTP Server, HTTP Port and URL – with elements from the POST URL provided by Microsoft Stream Dataset properties eg:

 

Note: URL is everything after ‘api.powerbi.com’ in the POST URL provided to you.

3.2	Create an SSL Certificate for the communication between IRIS and Microsoft, and specify this in the SSL Configuration field.

3.3	You may now start the production. I will start collecting and pushing data to the data stream. 

Warning: Data pushed to the cloud this way ends up going through infrastructure outside of your organization, therefore – this may raise security concerns and do not publish sensitive data.

3.4	There are other settings that govern the output format of the data, as well as hiding metrics, and more. The documentation included with the code downloaded from Open Exchange elaborates further on the options.

Step 4. Create a Power BI Dashboard to consume and visualize the streaming data.
4.1	Log back into your PowerBI Microsoft account:  powerbi.microsoft.com
4.2	Within your Workspace selected, select Create -> Dashboard
4.3	Provide a name for your dashboard, eg: “IRISMetricsDashboard”
4.4	Using the drop down menu activated by selecting elipse (…) in the menu ribbon
 
And further select the option Add Tile to add the first tile to your dashboard.
4.5	Select Custom Streaming Data as a source for this tile’s data and click Next
4.6	Locate the Streaming Dataset (eg “IRISStreamingDataset”) you created in Step 2 and click Next
 
4.7	At this point select the visualization type of the tile to use, and the JSON elements to plot.
You have a limited choice of a Card, Line Chart, Gauge or Clustered Bar/Column chart. 

For this example and to plot Average Temperature over time, in a Line Chart set the following:

Visualization type to:	Line Chart
Axis:			_SampledDateTime
Values:  		AverageTemp
 
As soon as these values have been set (and even before selecting NEXT) – as long as the IRIS production is  correctly configured, started and posting to the correct REST Endpoint – you should see values being plotted on your tile:
 

Line Chart populated from streaming dataset that’s receiving values from an IRIS Business Metric
4.8	Click Next and you can continue to modify the tile’s Title, Subtitle and other parameters if needed.  At this point you may continue to add more tiles, with other visualisations, and populated from the same or other IRIS data stream – or other, publicly published data streams.

 
## Try it out: Invoke REST API Hosted by IRIS to retrieve metric Data. 
Step 1:	Import the code and setup the Sample production
1.1	If you haven’t already done so previously, import the zaux.rBAM.* classes into an interoperability enabled IRIS Namespace. View the production: zaux.rBAM.Sample.Production. Do not start the production yet.

1.2	The Business Operation zaux.rBAM.Operation is not used in this use case (it is used to PUSH metric data), so it can be disabled within the production.

1.3	Create a REST WEB Application using your preferred web application name, accessing your production’s namespace (eg IRISDEMO), your preferred security, and assign a REST Dispatch Class of: zaux.rBAM.API
Below if my configuration using the REST Web Application name:  /metrics
 
1.4	Start the IRIS Production

1.5	Using your preferred REST Client access one of the three URL paths offered by the API – for example:

http://localhost:52775/metrics/v1/List			
lists out running metric class names

http://localhost:52775/metrics/v1/Data	
lists out all metric data for all configured metric hosts.

http://localhost:52775/metrics/v1/Data/EnvironmentMetrics	
lists out all metric data for given configured metric host eg: ‘EnvironmentMetrics’
