<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<cfsetting showdebugoutput="true">

<cfsilent>
	<!------- Page parameters ----------->
	<cfparam name="account" default=""> 			<!--- HomePortals account --->
	<cfparam name="page" default=""> 				<!--- page to load within account --->
	<cfparam name="refreshApp" default="false"> 	<!--- Force a reload and parse of the HomePortals application --->
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

		// load and parse page
		request.oPageRenderer = application.homePortals.loadPage(account, page);

		// render page html
		html = request.oPageRenderer.renderPage();
	</cfscript>
</cfsilent>

<cfoutput>#html#</cfoutput>

