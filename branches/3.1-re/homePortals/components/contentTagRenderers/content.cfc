<cfcomponent extends="homePortals.components.contentTagRenderer">
	
	<cfscript>
		variables.HTTP_GET_TIMEOUT = 30;	// timeout for HTTP requests in content modules
	</cfscript>

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfscript>
			var moduleID = getContentTag().getAttribute("id");
			var tmpHTML = "";
			var cacheKey = "";
			var oCache = 0;
			var cache = getContentTag().getAttribute("cache",false);
			var cacheTTL = getContentTag().getAttribute("cacheTTL");
			
			try {
				if(isBoolean(cache) and cache) {
					// get the content cache (this will initialize it, if needed)
					oCache = getContentCache();

					// generate a key for the cache entry
					cacheKey = getContentTag().getAttribute("resourceID") & "/" 
								& getContentTag().getAttribute("resourceType") & "/" 
								& getContentTag().getAttribute("href");
					
					try {
						// read from cache
						tmpHTML = oCache.retrieve(cacheKey);
					
					} catch(homePortals.cacheService.itemNotFound e) {
						// read from source
						tmpHTML = retrieveContent( getContentTag().getNode() );
						
						// update cache
						if(cacheTTL neq "" and val(cacheTTL) gte 0)
							oCache.store(cacheKey, tmpHTML, val(cacheTTL));
						else
							oCache.store(cacheKey, tmpHTML);
					}
					
				} else {
					// retrieve from source
					tmpHTML = retrieveContent( getContentTag().getNode() );
				}

				// add rendered content to buffer
				arguments.bodyContentBuffer.set( tmpHTML );

			} catch(any e) {
				tmpHTML = "<b>An unexpected error ocurred while retrieving content for content module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				arguments.bodyContentBuffer.set( tmpHTML );
			}
		</cfscript>		
	</cffunction>


	<!---------------------------------------->
	<!--- getContentCache                  --->
	<!---------------------------------------->		
	<cffunction name="getContentCache" access="private" returntype="cacheService" hint="Retrieves a cacheService instance used for caching content for content modules">
		<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
		<cfset var cacheName = "contentCacheService">
		<cfset var oCacheService = 0>
		<cfset var cacheSize = getPageRenderer().getHomePortals().getConfig().getContentCacheSize()>
		<cfset var cacheTTL = getPageRenderer().getHomePortals().getConfig().getContentCacheTTL()>

		<cflock type="exclusive" name="contentCacheLock" timeout="30">
			<cfif not oCacheRegistry.isRegistered(cacheName)>
				<!--- crate cache instance --->
				<cfset oCacheService = createObject("component","cacheService").init(cacheSize, cacheTTL)>

				<!--- add cache to registry --->
				<cfset oCacheRegistry.register(cacheName, oCacheService)>
			</cfif>
		</cflock>
		
		<cfreturn oCacheRegistry.getCache(cacheName)>
	</cffunction>
	
	<!---------------------------------------->
	<!--- retrieveContent                  --->
	<!---------------------------------------->		
	<cffunction name="retrieveContent" access="private" returntype="string" hint="retrieves content from source for a content module">
		<cfargument name="moduleNode" type="any" required="true">
		<cfscript>
			var oResourceBean = 0;
			var contentSrc = "";
			var tmpHTML = "";
			var st = structNew();
			var oCatalog = getPageRenderer().getHomePortals().getCatalog();
			var oHPConfig = getPageRenderer().getHomePortals().getConfig();
			
			// define source of content (resource or external)
			if(arguments.moduleNode.resourceID neq "") {
				oResourceBean = oCatalog.getResourceNode(arguments.moduleNode.resourceType, arguments.moduleNode.resourceID);
				contentSrc = oResourceBean.getResLibPath() & "/" & oResourceBean.getHref();
			
			} else if(arguments.moduleNode.href neq "") {
				contentSrc = arguments.moduleNode.href;
			}

			// retrieve content
			if(contentSrc neq "") {
				if(left(contentSrc,4) eq "http") {
					st = httpget(contentSrc);
					tmpHTML = st.fileContent;
				} else {
					tmpHTML = readFile( expandPath( contentSrc) );
				}
			}
		</cfscript>
		<cfreturn tmpHTML>
	</cffunction>

	<!---------------------------------------->
	<!--- httpget		                   --->
	<!---------------------------------------->		
	<cffunction name="httpget" access="private" returntype="struct">
		<cfargument name="href" type="string" required="true">
		<cfhttp url="#arguments.href#" method="get" throwonerror="true" 
				resolveurl="true" redirect="true" 
				timeout="#variables.HTTP_GET_TIMEOUT#">
		<cfreturn cfhttp>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- readFile		                   --->
	<!---------------------------------------->		
	<cffunction name="readFile" access="private" returntype="string" hint="Reads a file from disk and returns the contents.">
		<cfargument name="filePath" type="string" required="true">
		<cfset var txtDoc = "">
		<cffile action="read" file="#filePath#" variable="txtDoc">
		<cfreturn txtDoc>
	</cffunction>		
	

</cfcomponent>