<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="Inserts a block of HTML-formatted content into the page. Content can be located on the same server or retrieved from an external URL. Content can also be obtained from the resource library.">

	<cfproperty name="resourceID" type="resource:content" required="false"  displayname="ID of a resource of type 'content' to display." />
	<cfproperty name="href" type="string" required="false" displayname="Indicates the location of an external document. Can be either a full URL starting with http:// or a relative url for a resource located in the same server." />
	
	<!---
		Optional attributes:
			This renderer supports these additional attributes:
			* resourceType: Indicates the type of resource to use when giving a resourceID. Defaults to 'content'
			* cache: When using external content via href attribute, indicates whether to cache or not the content retrieved.
			* cacheTTL: Time to cache external content.
	--->
	
	<cfscript>
		variables.HTTP_GET_TIMEOUT = 30;	// timeout for HTTP requests in content modules
		variables.EXT_CONTENT_CACHE = "extContentCacheService";	// name of the cache instance to use for external content
		variables.CONTENT_RES_TYPE = "content";	// name of resource type to use for content
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
			var resourceType = getContentTag().getAttribute("resourceType",variables.CONTENT_RES_TYPE );
			var resourceID = getContentTag().getAttribute("resourceID");
			var gotContent = false;
			
			try {
				// for content resources, we try to get it first from the catalog
				// there is no need for us to worry about caching here since the catalog
				// itself caches local resources
				if(resourceID neq "") {
					oResBean = getPageRenderer()
									.getHomePortals()
									.getCatalog()
									.getResource(resourceType, resourceID);
					
					if(oResBean.targetFileExists()) {
						tmpHTML = oResBean.readFile();
						gotContent = true;
					}
				}
					
				// at this point the requested content is not a resource, or may be a
				// resource that is pointing to an external source	
				if(not gotContent) {
					if(isBoolean(cache) and cache) {
						// get the content cache (this will initialize it, if needed)
						oCache = getContentCache();
	
						// generate a key for the cache entry
						cacheKey = resourceID & "/" 
									& getContentTag().getAttribute("href");
						
						try {
							// read from cache
							tmpHTML = oCache.retrieve(cacheKey);
						
						} catch(homePortals.cacheService.itemNotFound e) {
							// read from source
							tmpHTML = retrieveContent();
							
							// update cache
							if(cacheTTL neq "" and val(cacheTTL) gte 0)
								oCache.store(cacheKey, tmpHTML, val(cacheTTL));
							else
								oCache.store(cacheKey, tmpHTML);
						}
						
					} else {
						// retrieve from source
						tmpHTML = retrieveContent();
					}
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
	<cffunction name="getContentCache" access="private" returntype="homePortals.components.cacheService" hint="Retrieves a cacheService instance used for caching content for content modules">
		<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
		<cfset var cacheName = variables.EXT_CONTENT_CACHE>
		<cfset var oCacheService = 0>
		<cfset var cacheSize = getPageRenderer().getHomePortals().getConfig().getCatalogCacheSize()>
		<cfset var cacheTTL = getPageRenderer().getHomePortals().getConfig().getCatalogCacheTTL()>

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
	
	<!---------------------------------------->
	<!--- retrieveContent                  --->
	<!---------------------------------------->		
	<cffunction name="retrieveContent" access="private" returntype="string" hint="retrieves content from source for a content module">
		<cfscript>
			var oResourceBean = 0;
			var tmpHTML = "";
			var st = structNew();
			var oCatalog = 0;
			var oHPConfig = getPageRenderer().getHomePortals().getConfig();
			
			var resourceID = getContentTag().getAttribute("resourceID");
			var resourceType = getContentTag().getAttribute("resourceType",variables.CONTENT_RES_TYPE );
			var href = getContentTag().getAttribute("href");
			
			// define source of content (resource or external)
			if(resourceID neq "") {
				oCatalog = getPageRenderer().getHomePortals().getCatalog();
				oResourceBean = oCatalog.getResource(resourceType, resourceID);
				if(oResourceBean.getHref() neq "") {
					tmpHTML = oResourceBean.readFile();
				}
			
			} else if(href neq "") {
				// retrieve content directly
				if(left(href,4) eq "http") {
					st = httpget(href);
					tmpHTML = st.fileContent;
				} else {
					tmpHTML = readFile( expandPath( href ) );
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
		<cfif arguments.filePath neq "">
			<cffile action="read" file="#arguments.filePath#" variable="txtDoc">
		</cfif>
		<cfreturn txtDoc>
	</cffunction>		
	

</cfcomponent>