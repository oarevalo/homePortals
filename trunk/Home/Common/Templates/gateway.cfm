<!--- gateway.cfm

This file is a gateway for calls to server-side components. 
---->

<cfset moduleControllerRemotePath = "Home.Components.moduleControllerRemote">
<cfset hpCommonTemplatesPath = "/Home/Common/Templates">

<!--- Headers to avoid caching of content --->
<meta http-equiv="Expires" content="0">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<cfheader name="Expires" value="0">
<cfheader name="Pragma" value="no-cache">
<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">

<cftry>
	<cfparam name="moduleID"> 
	<cfparam name="method">
	
	<!--- Create a structure with form and url fields --->
	<cfset stRequest = form>
	<cfset structAppend(stRequest, url)>
	
	<!--- Initialize remote module controller --->
	<cfset oModuleControllerRemote = CreateObject("component", moduleControllerRemotePath).init(moduleID, application.homePortals.getConfig())>
	
	<!--- create and execute call --->
	<cfinvoke   component="#oModuleControllerRemote#" 
				returnvariable="tmpHTML" 
				method="#stRequest.method#" 
				argumentcollection="#stRequest#" />
	
	<!---- output results ---->
	<cfset WriteOutput(tmpHTML)>

	<!--- error handling --->
	<cfcatch type="any">
		<cfinclude template="#hpCommonTemplatesPath#/error.cfm">
	</cfcatch>
</cftry> 