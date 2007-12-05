<!--- gateway.cfm

This file is a gateway for calls to server-side components. 

---->
<cftry>
	<cfparam name="moduleID"> 
	<cfparam name="method">
	
	<!--- this is to avoid caching--->
	<meta http-equiv="Expires" content="0">
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
	<cfheader name="Expires" value="0">
	<cfheader name="Pragma" value="no-cache">
	<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">

	<cfscript>
		stRequest = structNew();
		stRequest = form;
		structAppend(stRequest, url);
		
		tmpCFCPath = listAppend(application.homePortalsRoot, "Components/moduleControllerRemote", "/");
		oModuleControllerRemote = CreateObject("component", tmpCFCPath);
		oModuleControllerRemote.init(moduleID);
	</cfscript>
	
	<!--- create and execute call --->
	<cfinvoke   component="#oModuleControllerRemote#" 
				returnvariable="tmpHTML" 
				method="#stRequest.method#" 
				argumentcollection="#stRequest#" />
	
	<!---- output results ---->
	<cfset WriteOutput(tmpHTML)>

	<!--- error handling --->
	<cfcatch type="homePortals.sessionTimedOut">
		<cfinclude template="errorSessionTimeOut.cfm">
	</cfcatch>
	<cfcatch type="any">
		<cfinclude template="error.cfm">
	</cfcatch>
</cftry> 