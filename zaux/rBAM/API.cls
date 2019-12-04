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
		
		// Insist that the first piece of the url is a version
		Set tVersion = $Piece(pUrl,"/",2)
		If ("v1"'[tVersion) {
			Set tSC = $$$ERROR($$$GeneralError,"Version "_ tVersion_" is not supported by this api")
			Quit
		}
		
		// Insist that the second piece of the url is a valid namespace and switch to it
		Set tNamespace=$Piece(pUrl,"/",3)
		
		// Ensure that the specified namespace exists and is enabled
		If (tNamespace="") || '##class(%SYS.Namespace).Enabled(tNamespace) {
			Set tSC = $$$ERROR($$$GeneralError,"Invalid namespace provided")
			Quit
		}
		
		// Prefer changing into the appropriate namespace here
		If (tNamespace'=$namespace) Set $namespace=tNamespace
		
		// Set the return type according to the Accept type in the request. Default is application/json.
		If ('..AcceptsContentType(..#CONTENTTYPEJSON)) {
			Set tSC=..ReportHttpStatusCode(..#HTTP406NOTACCEPTABLE),pContinue=0
			Quit 
        } 
        Else {   
			// This always returns json
			Set %response.ContentType=..#CONTENTTYPEJSON
        }

		// De-escalate privileges back to the user's login privileges now that 
		// namespace redirection is complete
		$$$ResetToLoginRoles
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	
	If $$$ISERR(tSC) {
		Set pContinue = 0 
		do ..StatusToJSON(tSC)
	}

	Quit $$$OK
}

}
