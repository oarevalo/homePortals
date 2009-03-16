<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<cfsetting showdebugoutput="true">

<!---
/*
	Copyright 2007 - Oscar Arevalo (http://www.oscararevalo.com)

    This file is part of HomePortals.

    HomePortals is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    HomePortals is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with HomePortals.  If not, see <http://www.gnu.org/licenses/>.

*/ 
---->

<cfsilent>
	<!------- Page parameters ----------->
	<cfparam name="page" default=""> 				<!--- page to load --->
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
			application.homePortals = CreateObject("component","homePortals.components.homePortals").init(request.appRoot);
		}

		// load and parse page
		request.oPageRenderer = application.homePortals.loadPage(page);

		// render page html
		html = request.oPageRenderer.renderPage();
	</cfscript>
</cfsilent>

<cfoutput>#html#</cfoutput>

