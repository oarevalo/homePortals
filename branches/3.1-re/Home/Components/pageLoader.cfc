<cfcomponent>

	<cfset variables.instance = structNew()>
	<cfset variables.instance.homePortals = 0>

	<cffunction name="init" access="public" returntype="pageLoader" hint="constructor">
		<cfargument name="homePortals" type="homePortals" required="true" hint="HomePortals application instance">
		<cfset setHomePortals(arguments.homePortals)>
		<cfreturn this>
	</cffunction>

	<cffunction name="load" access="public" returntype="pageRenderer" hint="returns the page renderer for the requested page">
		<cfargument name="uri" type="string" hint="an identifier for the page">
		<cfscript>
			var oPageRenderer = 0;
			var oPage = 0;
			var pageCacheKey = arguments.uri;
			var oCacheRegistry = createObject("component","cacheRegistry").init();			
			var oCache = oCacheRegistry.getCache("hpPageCache");
			var oPageProvider = getHomePortals().getPageProvider();

			// get information about the page
			stInfo = oPageProvider.query(arguments.uri);

			// if the page exists on the cache, and the page hasnt been modified after
			// storing it on the cache, then get it from the cache
			try {
				oPageRenderer = oCache.retrieveIfNewer(pageCacheKey, stInfo.lastModified);
			
			} catch(homePortals.cacheService.itemNotFound e) {
				// page is not in cache, so load the page
				oPage = oPageProvider.load(arguments.uri);
				
				// create a page renderer for this page
				oPageRenderer = createObject("component","pageRenderer").init(arguments.uri, oPage, getHomePortals());
			
				// store page in cache
				oCache.store(pageCacheKey, oPageRenderer);
				
				// clear persistent storage for module data
				oConfigBeanStore = createObject("component","configBeanStore").init();
				oConfigBeanStore.flushByPageURI(arguments.uri);
				
			}
			
			return oPageRenderer;
		</cfscript>		
	</cffunction>

	<cffunction name="getHomePortals" access="public" returntype="homePortals">
		<cfreturn variables.instance.HomePortals>
	</cffunction>

	<cffunction name="setHomePortals" access="public" returntype="void">
		<cfargument name="data" type="homePortals" required="true">
		<cfset variables.instance.HomePortals = arguments.data>
	</cffunction>

</cfcomponent>