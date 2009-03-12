<cfcomponent output="false">
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
	<cfset this.name = "hpEngine"> 
	<cfset this.sessionManagement = true>
		
	<cffunction name="onRequestStart">
		
		<cfset var oSystem =  createObject("java","java.lang.System")>
		<cfset var pathSeparator = oSystem.getProperty("file.separator")>
		<cfset var currentPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cfset var configFile = currentPath & pathSeparator & "config" & pathSeparator & "homePortals-config.xml">
		
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