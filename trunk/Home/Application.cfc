<cfcomponent output="false">

	<cfset this.name = "hpEngine"> 
		
	<cffunction name="onRequestStart">
		
		<cfset var oSystem =  createObject("java","java.lang.System")>
		<cfset var pathSeparator = oSystem.getProperty("file.separator")>
		<cfset var currentPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cfset var configFile = currentPath & pathSeparator & "Config" & pathSeparator & "homePortals-config.xml">
		
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
	</cffunction>

</cfcomponent>