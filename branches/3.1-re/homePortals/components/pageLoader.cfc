<cfcomponent>

	<cfset variables.instance = structNew()>
	<cfset variables.instance.homePortals = 0>

	<cffunction name="init" access="public" returntype="pageLoader" hint="constructor">
		<cfargument name="homePortals" type="homePortals" required="true" hint="HomePortals application instance">
		<cfset setHomePortals(arguments.homePortals)>
		<cfreturn this>
	</cffunction>

	<cffunction name="load" access="public" returntype="pageRenderer" hint="returns the page renderer for the requested page">
		<cfargument name="href" type="string" hint="the location of the page document">
		<cfscript>
			var oPageRenderer = 0;
			var oPage = 0;
			var pageCacheKey = arguments.href;
			var oCacheRegistry = createObject("component","cacheRegistry").init();			
			var oCache = oCacheRegistry.getCache("hpPageCache");
			var oPageProvider = getHomePortals().getPageProvider();
			var stInfo = structNew();

			// get information about the page
			stInfo = oPageProvider.query(arguments.href);

			// if the page exists on the cache, and the page hasnt been modified after
			// storing it on the cache, then get it from the cache
			try {
				oPageRenderer = oCache.retrieveIfNewer(pageCacheKey, stInfo.lastModified);
			
			} catch(homePortals.cacheService.itemNotFound e) {
				// page is not in cache, so load the page
				oPage = oPageProvider.load(arguments.href);
				
				// create a page renderer for this page
				oPageRenderer = createObject("component","pageRenderer").init(arguments.href, oPage, getHomePortals());
			
				// store page in cache
				oCache.store(pageCacheKey, oPageRenderer);
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