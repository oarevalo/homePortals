<cfsilent>
	<cfsetting showdebugoutput="true">
	<!---
		homePortals
		http://www.homeportals.net
	
	    This file is part of HomePortals.
	
		Copyright 2007-2010 Oscar Arevalo
		Licensed under the Apache License, Version 2.0 (the "License");
		you may not use this file except in compliance with the License.
		You may obtain a copy of the License at
		
		http://www.apache.org/licenses/LICENSE-2.0
		
		Unless required by applicable law or agreed to in writing, software
		distributed under the License is distributed on an "AS IS" BASIS,
		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		See the License for the specific language governing permissions and
		limitations under the License.	
	--->

	<!------- Page parameters ----------->
	<cfparam name="id"> 										<!--- resource to load --->
	<cfparam name="type"> 									<!--- type of resource --->
	<cfparam name="page" default=""> 				<!--- page to use for rendering (accepts $name to use a resource attribute as pagename) --->
	<cfparam name="resetApp" default="false"> 	<!--- Force a reload and parse of the HomePortals application --->
	<cfparam name="context" default="#structNew()#">
	<!----------------------------------->
	
	<!------- Application Root ----------->
	<!--- This variable must point to the root directory of the application --->
	<!--- if not specified on the calling template, then it defaults to the current directory. --->
	<cfparam name="request.appRoot" default="#GetDirectoryFromPath(cgi.script_Name)#"> 	
	<!----------------------------------->

	<cfscript>
		if(structIsEmpty(context)) {
			context = duplicate(form);
			StructAppend(context, url);
		}
		
		// Initialize application if requested or needed
		if((isBoolean(resetApp) and resetApp) or Not StructKeyExists(application, "homePortals")) {
			application.homePortals = CreateObject("component","homePortals.components.homePortals").init(request.appRoot);
		}

		// load resource
		request.oResource = application.homePortals.getCatalog().getResource(type, id);

		// load and parse page
		if(left(page,1) eq "$") 
			page = request.oResource.getProperty(replace(page,"$",""));
		request.oPageRenderer = application.homePortals.loadPage(page);

		// render page html
		html = request.oPageRenderer.renderPage(context);
	</cfscript>
</cfsilent><cfoutput>#html#</cfoutput>

