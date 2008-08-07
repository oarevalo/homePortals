<!--- gateway.cfm

This file is a gateway for calls to server-side components. 
---->

<!--- this is a reference to the homeportals application instance,
	it is done as a cfparam to allow the caller to override the reference
	when storing in on a different place --->
<cfparam name="HOMEPORTALS_INSTANCE" default="">

<!--- this is the name of the mapping or directory where HomePortals is located --->
<cfparam name="HOMEPORTALS_MAPPING" default="Home">


<!--- references to homeportals resources --->
<cfset moduleControllerRemotePath = HOMEPORTALS_MAPPING & ".Components.moduleControllerRemote">
<cfset hpCommonTemplatesPath = "/" & HOMEPORTALS_MAPPING & "/Common/Templates">

<cfif isSimpleValue(HOMEPORTALS_INSTANCE) and HOMEPORTALS_INSTANCE eq "" and structKeyExists(application,"homePortals")>
	<cfset HOMEPORTALS_INSTANCE = application.homePortals>
</cfif>

<!--- Headers to avoid caching of content --->
<meta http-equiv="Expires" content="0">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<cfheader name="Expires" value="0">
<cfheader name="Pragma" value="no-cache">
<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">

<cftry>
	<cfparam name="pageHREF">	<!--- the current page --->
	<cfparam name="moduleID"> 	<!--- the requested module --->
	<cfparam name="method">		<!--- the method to execute in the module --->
	
	<!--- Create a structure with form and url fields --->
	<cfset stRequest = form>
	<cfset structAppend(stRequest, url)>
	
	<!--- Initialize remote module controller --->
	<cfset oModuleControllerRemote = CreateObject("component", moduleControllerRemotePath).init(pageHREF, moduleID, HOMEPORTALS_INSTANCE)>
	
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