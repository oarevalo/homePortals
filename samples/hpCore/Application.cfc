<cfcomponent extends="core.coreApp">
	<cfset this.name = "hpCore">

	<cfset this.defaultEvent = "main.loadPage">
	<cfset this.paths.core = "/core">
	<cfset this.dirs.handlers = "handlers">
	<cfset this.dirs.views = "views">
	<cfset this.configDoc = "config/config.xml.cfm">
	
	<cffunction name="onMissingTemplate" returnType="boolean">
	    <cfargument type="string" name="targetPage" required="true" />
		<cfset var req = replaceNoCase(arguments.targetPage,".cfm","")>

		<cfif getDirectoryFromPath(arguments.targetPage) eq this.paths.app & "handlers/">
			<cfset event = getFileFromPath(req)>
		<cfelse>
			<cfset url.page = replaceNoCase(req,this.paths.app,"",'all')>
			<cfset event = "main.loadPage">
		</cfif>

		<cfset onRequestStart()>

		<cfinclude template="#this.paths.app#/index.cfm">
		
	    <cfreturn true /> 
	</cffunction>
		
</cfcomponent>