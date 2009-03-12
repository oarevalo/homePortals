<cfcomponent>
	<!---- 
		homePortalsProxy.cfc 
	
		This component provides allows remote interaction with the homePortals application instance.
		To enable an application to be remotely accessed, create a component within the target application
		that extends this CFC and override the following variables as needed.
	---->
	
	<!--- This variable contains the location where the homePortals application instance is stored.--->
	<cfset variables.HOMEPORTALS_INSTANCE_VAR = "application.homePortals">
	
	<!--- This variable points to the target application root --->
	<cfset variables.APP_ROOT = "/Home">

	
	<cffunction name="init" access="public" returntype="homePortalsProxy" hint="constructor">
		<cfreturn this>
	</cffunction>

	<!--- Application Lifecycle Management --->
	<cffunction name="reset" access="remote" returntype="boolean" hint="Restarts the homePortals instance for the application">
		<cfif isLoaded()>
			<cfset stop()>
		</cfif>
		<cfset start()>
		<cfreturn true>
	</cffunction>

	<cffunction name="isLoaded" access="remote" returntype="boolean" hint="Returns whether the homePortals application has been initialized and loaded into memory">
		<cfreturn isDefined(variables.HOMEPORTALS_INSTANCE_VAR) 
					and not isSimpleValue(evaluate(variables.HOMEPORTALS_INSTANCE_VAR))>
	</cffunction>

	<cffunction name="start" access="remote" returntype="boolean" hint="Initializes and loads into memory the HomPortals application">
		<cfset var oHP = 0>
		<cflock name="hpProxyAppControl" type="exclusive" timeout="30">
			<cfset oHP = createObject("component","Home.components.homePortals").init(variables.APP_ROOT)>
			<cfset setVariable(variables.HOMEPORTALS_INSTANCE_VAR, oHP)>
		</cflock>
		<cfreturn true>
	</cffunction>

	<cffunction name="stop" access="remote" returntype="boolean" hint="Removes the HomePortals application from memory and clears all cached objects">
		<cfset var oCacheRegistry = 0>

		<cflock name="hpProxyAppControl" type="exclusive" timeout="30">
			<!--- delete reference to homePortals instance --->
			<cfset setVariable(variables.HOMEPORTALS_INSTANCE_VAR, 0)>
			
			<!--- clear all cached information --->
			<cfset oCacheRegistry = createObject("component","Home.components.cacheRegistry").init()>
			<cfset oCacheRegistry.flush()>
		</cflock>

		<cfreturn true>
	</cffunction>


	<!--- Cache Monitoring --->
	<cffunction name="getCacheNames" access="remote" returntype="Array" hint="Returns an array with the names of all registered caches">
		<cfset var oCacheRegistry = createObject("component","Home.components.cacheRegistry").init()>
		<cfset var lstCaches = oCacheRegistry.getCacheNames()>
		<cfreturn listToArray(lstCaches)>
	</cffunction>

	<cffunction name="getCacheInfo" access="remote" returntype="struct" hint="Returns a struct with status information about the requested cache">
		<cfargument name="cacheName" type="string" required="true">
		<cfset var oCacheRegistry = createObject("component","Home.components.cacheRegistry").init()>
		<cfset var oCache = oCacheRegistry.getCache(arguments.cacheName)>
		<cfreturn oCache.getStats()>
	</cffunction>

	<cffunction name="clearCache" access="remote" returntype="boolean" hint="Removes the requested cache from memory">
		<cfargument name="cacheName" type="string" required="true">
		<cfset var oCacheRegistry = createObject("component","Home.components.cacheRegistry").init()>
		<cfset var oCache = oCacheRegistry.getCache(arguments.cacheName)>
		<cfif left(arguments.cacheName,2) neq "hp">
			<cfset oCache.flush(arguments.cache)>
		<cfelse>
			<cfthrow message="You are not allowed to clear the requested cache" type="homePortals.proxy.cacheClearNotAllowed">
		</cfif>
		<cfreturn true>
	</cffunction>

	<cffunction name="cleanupCache" access="remote" returntype="boolean" hint="Executes a reap on the requested cache to remove expired entries">
		<cfargument name="cacheName" type="string" required="true">
		<cfset var oCacheRegistry = createObject("component","Home.components.cacheRegistry").init()>
		<cfset var oCache = oCacheRegistry.getCache(arguments.cacheName)>
		<cfset oCache.cleanup(arguments.cache)>
		<cfreturn true>
	</cffunction>
	
	
	<!--- Page Processing --->
	<cffunction name="renderPage" access="remote" returntype="string" hint="Returns the output generated from rendering the requested page">
		<cfargument name="account" type="string" required="true">
		<cfargument name="page" type="string" required="true">
		
		<cfset var oHP = 0>
		<cfset var oPageRenderer = 0>
		<cfset var html = "">
		
		<!--- make sure homeportals is loaded into memory --->
		<cfif not isLoaded()>
			<cfset start()>
		</cfif>
		
		<!--- load page --->
		<cfset oHP = evaluate(variables.HOMEPORTALS_INSTANCE_VAR)>
		<cfset request.oPageRenderer = oHP.loadPage(arguments.account, arguments.page)>
		
		<!--- render page output --->	
		<cfset html = request.oPageRenderer.renderPage()>
		
		<cfreturn html>
	</cffunction>	

	
	<!--- JVM Status --->
	<cffunction name="getJVMFreeMemoryPercent" access="remote" returntype="numeric" hint="Returns the amount of free memory on the JVM as a percentage of the total memory">
		<cfset var jrt = CreateObject("java", "java.lang.Runtime")>
		<cfreturn ( (jrt.getRuntime().freeMemory() / jrt.getRuntime().totalMemory() ) * 100 )>
	</cffunction>

</cfcomponent>