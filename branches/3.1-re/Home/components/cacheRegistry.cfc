<cfcomponent hint="this component serves as a central registry for individual caches. There is no need to persist this component since it uses the Application scope to store the cache registry">
	
	<cfset variables.CACHE_REGISTRY_NAME = "_cacheManagerRegistry">
	
	<cffunction name="init" access="public" returntype="cacheRegistry">
		<cfset checkRegistry()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="isRegistered" access="public" returntype="boolean" hint="checks whether a cache with the given name exists on the registry">
		<cfargument name="cacheName" type="string" required="true">
		<cfset checkRegistry()>
		<cfreturn structKeyExists( getRegistry(), arguments.cacheName)>
	</cffunction>
	
	<cffunction name="register" access="public" returntype="void" hint="Adds a cache to the registry.">
		<cfargument name="cacheName" type="string" required="true">
		<cfargument name="cache" type="cacheService" required="true">
		<cfset var st = structNew()>
		<cfset checkRegistry()>
		<cfset st = getRegistry()>
		<cflock name="cacheRegistryLock_#arguments.cacheName#" type="exclusive" timeout="10">
			<cfset st[arguments.cacheName] = arguments.cache>
		</cflock>
	</cffunction>
	
	<cffunction name="getCache" access="public" returntype="cacheService" hint="Retrieves a cache instance from the registry">
		<cfargument name="cacheName" type="string" required="true">
		<cfset var st = structNew()>
		<cfset checkRegistry()>
		<cfset st = getRegistry()>
		<cfif isRegistered(arguments.cacheName)>
			<cfreturn st[arguments.cacheName]>
		<cfelse>
			<cfthrow message="Requested cache not found" type="cacheManager.cacheNotFound">
		</cfif>
	</cffunction>
	
	<cffunction name="getCacheNames" access="public" returntype="string" hint="Returns a list with the names of all the caches in the registry">
		<cfset var st = structNew()>
		<cfset checkRegistry()>
		<cfset st = getRegistry()>
		<cfreturn structKeyList(st)>			
	</cffunction>
	
	<cffunction name="flush" access="public" returntype="void" hint="Clears one or all items on the registry. If no parameter is given, then clears all caches">
		<cfargument name="cacheName" type="string" required="false" default="">
		<cfset var st = structNew()>
		<cfset checkRegistry()>
		<cfset st = getRegistry()>

		<cfif arguments.cacheName neq "">
			<cflock name="cacheRegistryLock_#arguments.cacheName#" type="exclusive" timeout="10">
				<cfset structDelete(application[variables.CACHE_REGISTRY_NAME], arguments.cacheName, false)>
			</cflock>		
		<cfelse>
			<cflock name="cacheRegistryLock" type="exclusive" timeout="10">
				<cfset structDelete(application, variables.CACHE_REGISTRY_NAME)>
			</cflock>		
		</cfif>
	</cffunction>


	<!--- Private Methods --->
	<cffunction name="checkRegistry" access="private" returntype="void" hint="checks if the registry exists, if not then creates it">
		<cfif not structKeyExists(application,variables.CACHE_REGISTRY_NAME)>
			<cflock name="cacheRegistryLock" type="exclusive" timeout="10">
				<cfset application[variables.CACHE_REGISTRY_NAME] = structNew()>
			</cflock>		
		</cfif>
	</cffunction>
	
	<cffunction name="getRegistry" access="private" returntype="struct" hint="returns a references to the registry structure in memory">
		<cfreturn application[variables.CACHE_REGISTRY_NAME]>
	</cffunction>
	
</cfcomponent>