<cfcomponent>

	<cfset variables.instance = structNew()>
	<cfset variables.instance.pageProvider = 0>

	<cffunction name="init" access="public" returntype="pageLoader" hint="constructor">
		<cfargument name="pageProvider" type="pageProvider" required="true" hint="An cfc that implements the pageProvider interface">
		<cfset setPageProvider(arguments.pageProvider)>
		<cfreturn this>
	</cffunction>

	<cffunction name="load" access="public" returntype="pageBean" hint="returns a cached reference to the page object for the requested page">
		<cfargument name="href" type="string" hint="the location of the page document">
		<cfscript>
			var oPageRenderer = 0;
			var oPage = 0;
			var pageCacheKey = arguments.href;
			var oCacheRegistry = createObject("component","cacheRegistry").init();			
			var oCache = oCacheRegistry.getCache("hpPageCache");
			var oPageProvider = getPageProvider();
			var stInfo = structNew();

			// get information about the page
			stInfo = oPageProvider.getInfo(arguments.href);

			// if the page exists on the cache, and the page hasnt been modified after
			// storing it on the cache, then get it from the cache
			try {
				oPage = oCache.retrieveIfNewer(pageCacheKey, stInfo.lastModified);
			
			} catch(homePortals.cacheService.itemNotFound e) {
				// page is not in cache, so load the page
				oPage = oPageProvider.load(arguments.href);
				
				// store page in cache
				oCache.store(pageCacheKey, oPage);
			}

			return oPage;
		</cfscript>		
	</cffunction>

	<cffunction name="getPageProvider" access="public" returntype="pageProvider">
		<cfreturn variables.instance.pageProvider>
	</cffunction>

	<cffunction name="setPageProvider" access="public" returntype="void">
		<cfargument name="data" type="pageProvider" required="true">
		<cfset variables.instance.pageProvider = arguments.data>
	</cffunction>

</cfcomponent>