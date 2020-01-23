Class zaux.rBAM.API Extends %CSP.REST
{

/// The UrlMap describes how incoming REST URL requests and their parameters get
/// dispatched to each of the handler-methods in this class.
XData UrlMap
{
<Routes>
 <Map Prefix="/v1" Forward="zaux.rBAM.API.v1"/>
</Routes>
}

ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pContinue As %Boolean) As %Status
{
	Set tSC = $$$OK
	Try { 
		
		// Set the return type according to the Accept type in the request. must be application/json.
		If ('..AcceptsContentType(..#CONTENTTYPEJSON)) {
			Set tSC=..ReportHttpStatusCode(..#HTTP406NOTACCEPTABLE),pContinue=0
			Quit 
        } 
        Else {   
			// This always returns json
			Set %response.ContentType=..#CONTENTTYPEJSON
        }
		
		// Insist that the first piece of the url is a version
		Set tVersion = $Piece(pUrl,"/",2)
		If ("v1"'[tVersion) {
			Set tSC = $$$ERROR($$$GeneralError,"Version "_ tVersion_" is not supported by this api.")
			Quit
		}
				
		set pProductionName = ##class(Ens.Director).GetActiveProductionName()
		if pProductionName  ="" Set tSC = $$$ERROR($$$GeneralError,"No active Integration Production found in Namespace "_namespace) quit
		
		if '##class(Ens.Director).IsProductionRunning(pProductionName) {
			Set tSC = $$$ERROR($$$GeneralError,"Active Integration Production "_pProductionName_" is not running right now.") quit
		}
		
	} Catch ex {
		Set tSC = ex.AsStatus()
	}
	
	If $$$ISERR(tSC) {
		Set pContinue = 0 
		do ..StatusToJSON(tSC,.errJSON)
		do errJSON.%ToJSON()
	}

	Quit $$$OK
}

}
