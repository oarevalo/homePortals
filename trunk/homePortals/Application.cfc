<cfcomponent output="false">
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

	<cfset this.name = "hpEngine"> 
		
	<cffunction name="onRequestStart">	
		<cfset var oSystem =  createObject("java","java.lang.System")>
		<cfset var pathSeparator = oSystem.getProperty("file.separator")>
		<cfset var currentPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cfset var configFile = currentPath & pathSeparator & "config" & pathSeparator & "homePortals-config.xml.cfm">
		
		<cfif cgi.QUERY_STRING eq "version">
			<b>HomePortals Application Platform</b><br>
	
			<!--- read the base config --->
			<cfif fileExists(configFile)>
				<cfset xmlDoc = xmlParse(configFile)>
				<cfif structKeyExists(xmlDoc.xmlRoot.xmlAttributes,"version")>
					<cfoutput><em>Version: #xmlDoc.xmlRoot.xmlAttributes.version#</em></cfoutput>
				<cfelse>
					<b>Error: Config file is corrupted!</b>
				</cfif>
			<cfelse>
				<b>Error: Config file not found!</b>
			</cfif>
			
			<cfabort>
		</cfif>
	</cffunction>

</cfcomponent>