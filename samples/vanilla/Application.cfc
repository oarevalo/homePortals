<cfcomponent extends="core.coreApp">
	
	<!--- Application settings --->
	<cfset this.name = "Vanilla">
	<cfset this.sessionManagement = true>

	<!--- App Mapping --->
	<cfset this.paths.app = "/vanilla">
	<!------------------->

	<!--- Framework settings --->
	<cfset this.mainHandler = "main">
	<cfset this.defaultEvent = "loadPage">
	<cfset this.dirs.handlers = "handlers">
	<cfset this.dirs.layouts = "layouts">
	<cfset this.dirs.views = "views">
	<cfset this.configDoc = "config/config.xml.cfm">

	<cfset request.appRoot = this.paths.app>

	<cffunction name="onMissingTemplate" returnType="boolean">
	    <cfargument type="string" name="targetPage" required="true" />
		<cfset var page = replaceNoCase(cgi.SCRIPT_NAME,".cfm","")>

		<cfif listLen(page,".") eq 2>
			<cfset event = getFileFromPath(page)>
		<cfelse>
			<cfset url.homePortalsPage = replaceNoCase(page,this.paths.app,"",'all')>
			<cfset event = "loadPage">
		</cfif>

		<cfset onRequestStart()>

		<cfinclude template="#this.paths.app#/index.cfm">
		
	    <cfreturn true /> 
	</cffunction>
			
</cfcomponent>