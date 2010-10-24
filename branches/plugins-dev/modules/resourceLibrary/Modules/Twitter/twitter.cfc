<cfcomponent extends="homePortals.plugins.modules.components.baseModule">

	<cfscript>
		variables.CACHE_NAME = "twitterTagCacheService";	// name of the cache instance to use for rss feeds
		variables.DEFAULT_MAX_ITEMS = 5;
	</cfscript>

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();

			cfg.setModuleClassName("twitter");
			cfg.setView("default", "main");
			cfg.setView("htmlhead", "HTMLHead");
		</cfscript>	
	</cffunction>

	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="accountName" type="string" default="">
		<cfargument name="maxItems" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var tmpScript = "";
			
			arguments.maxItems = val(arguments.maxItems);
			if(arguments.maxItems gt 0) 
				cfg.setPageSetting("maxItems", arguments.maxItems);
			else
				cfg.setPageSetting("maxItems", "");
			
			cfg.setPageSetting("accountName", arguments.accountName);

			this.controller.setMessage("Twitter settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
		</cfscript>
	</cffunction>	

	<cffunction name="retrieveData" access="private" returntype="any">
		<cfargument name="accountName" type="string" required="true">
		<cfargument name="refresh" type="boolean" required="false" default="false">
		<cfset var xmlData = 0>
		<cfset var oCache = getCache()>
		<cfset var srcURL = "http://twitter.com/statuses/user_timeline/" & accountName & ".xml">

		<cftry>
			<cfif arguments.refresh>
				<cfset xmlData = xmlParse(srcURL)>
				<cfset oCache.store(arguments.accountName, xmlData)>
			<cfelse>
				<cfset xmlData = oCache.retrieve(accountName)>
			</cfif>
			
			<cfcatch type="homePortals.cacheService.itemNotFound">
				<cfset xmlData = xmlParse(srcURL)>
				<cfset oCache.store(arguments.accountName, xmlData)>
			</cfcatch>
		</cftry>
	
		<cfreturn xmlData>
	</cffunction>

	<cffunction name="getCache" access="private" returntype="homePortals.components.cacheService" hint="Retrieves a cacheService instance used for caching rss feeds for the RSS content tag renderer">
		<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
		<cfset var cacheName = variables.CACHE_NAME>
		<cfset var oCacheService = 0>
		<cfset var cacheSize = this.controller.getHomePortals().getConfig().getCatalogCacheSize()>
		<cfset var cacheTTL = this.controller.getHomePortals().getConfig().getCatalogCacheTTL()>

		<cflock type="exclusive" name="contentCacheLock" timeout="30">
			<cfif not oCacheRegistry.isRegistered(cacheName)>
				<!--- crate cache instance --->
				<cfset oCacheService = createObject("component","homePortals.components.cacheService").init(cacheSize, cacheTTL)>

				<!--- add cache to registry --->
				<cfset oCacheRegistry.register(cacheName, oCacheService)>
			</cfif>
		</cflock>
		
		<cfreturn oCacheRegistry.getCache(cacheName)>
	</cffunction>	

</cfcomponent>