<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<cfsetting showdebugoutput="true">

<!------- Page parameters ----------->
<cfparam name="account" default=""> 			<!--- HomePortals account --->
<cfparam name="page" default=""> 				<!--- page to load within account --->
<cfparam name="refreshApp" default="true"> 	<!--- Force a reload and parse of the HomePortals application --->
<!----------------------------------->

<!------- Application Root ----------->
<!--- This variable must point to the root directory of the application --->
<!--- if not specified on the calling template, then it defaults to the current directory. --->
<cfparam name="request.appRoot" default="#GetDirectoryFromPath(cgi.script_Name)#"> 	
<!----------------------------------->

<cfscript>
	// Initialize application if requested or needed
	if((isBoolean(refreshApp) and refreshApp) or Not StructKeyExists(application, "homePortals")) {
		application.homePortals = CreateObject("component","Home.Components.homePortals").init(request.appRoot);
	}
	hp = application.homePortals;

	// load and parse page
	request.oPageRenderer = hp.loadPage(account, page);

	// render page html
	html = request.oPageRenderer.renderPage();
	
	// remove request variables
	if(structKeyExists(variables,"page")) structDelete(variables,"page");
	if(structKeyExists(form,"page")) structDelete(form,"page");
	if(structKeyExists(url,"page")) structDelete(url,"page");
	if(structKeyExists(variables,"account")) structDelete(variables,"account");
	if(structKeyExists(form,"account")) structDelete(form,"account");
	if(structKeyExists(url,"account")) structDelete(url,"account");
</cfscript>

<cfoutput>
	<cfdump var="#application.homePortals.getTimers()#" label="HomePortals.cfc">
	<cfdump var="#application.homePortals.getCatalog().getTimers()#" label="Catalog.cfc">
	<cfdump var="#request.oPageRenderer.getTimers()#" label="PageRenderer.cfc">
</cfoutput>

<cffunction name="abort">
	<cfabort>
</cffunction>
<cffunction name="dump">
	<cfargument name="data" type="any">
	<cfdump var="#arguments.data#">
</cffunction>
