<cfcomponent hint="this is the base component for all plugins">
	
	<cfset variables.homePortals = 0>
	<cfset variables._pluginID = createUUID()>

	<cffunction name="init" access="public" returntype="plugin" hint="constructor">
		<cfargument name="homePortals" type="homePortals" required="true">
		<cfset variables.homePortals = arguments.homePortals>
		<cfreturn this>
	</cffunction>

	<cffunction name="onAppInit" access="public" returntype="void" hint="this method is executed when the HomePortals application is initialized.">
		<!--- perform any plugin initialization tasks here --->
	</cffunction>
		
	<cffunction name="onBeforePageLoad" access="public" returntype="string" hint="this method is executed before a call to loadPage(). The argument is the path to the requested page, and its return value is also a page path">
		<cfargument name="eventArg" type="string" required="true" hint="the page to load">	
		<cfreturn arguments.eventArg>
	</cffunction>

	<cffunction name="onAfterPageLoad" access="public" returntype="pageRenderer" hint="this method is executed right before the call to loadPage() returns.">
		<cfargument name="eventArg" type="pageRenderer" required="true" hint="a pageRenderer object intialized for the requested page">	
		<cfreturn arguments.eventArg>
	</cffunction>
		
	<cffunction name="getHomePortals" access="public" returntype="homePortals" hint="returns the current HomePortals environment">
		<cfreturn variables.homePortals>
	</cffunction>	

</cfcomponent>