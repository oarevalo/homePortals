<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="This content renderer displays the contents of an RSS feed.">
	<cfproperty name="rssurl" default="" type="string" displayname="RSS URL" hint="The URL for the RSS feed">
	<cfproperty name="maxitems" default="10" type="numeric" displayname="Max Items" hint="Maximum number of feed items to display">
	<cfproperty name="titlesonly" default="true" type="boolean" displayname="Titles Only" hint="Determines whether to display only the title and link for each item, or to display an excerpt along with the title">

	<cfscript>
		variables.RSS_CACHE_NAME = "rssTagCacheService";	// name of the cache instance to use for rss feeds
	</cfscript>

	<!---------------------------------------->
	<!--- renderContent	                   --->
	<!---------------------------------------->		
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">

		<cfscript>
			var moduleID = getContentTag().getAttribute("id");

			try {
				arguments.bodyContentBuffer.set( renderFeed() );
				
			} catch(any e) {
				tmpHTML = "<b>An unexpected error ocurred while retrieving content for module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				arguments.bodyContentBuffer.set( tmpHTML );
			}
		</cfscript>
	</cffunction>

	<cffunction name="renderFeed" access="private" returntype="string" >
		<cfset var tmpHTML = "">
		<cfset var maxitems = getContentTag().getAttribute("maxitems",10)>	
		<cfset var titlesonly = getContentTag().getAttribute("titlesonly",true)>	
		<cfset var data = 0>
		<cfset var i = 0>

		<cfset titlesonly = isBoolean(titlesonly) and titlesonly>
		
		<cfset data = retrieveRSSFeed()>

		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<a href="#data.link#"><h2>#data.title#</h2></a><br />
				<cfloop from="1" to="#min(arrayLen(data.item),val(maxItems))#" index="i">
					<li>
						<a href="#data.item[i].link#" <cfif not titlesonly>style="font-weight:bold;"</cfif>>#data.item[i].title#</a>
						<cfif not titlesonly>
							<br />
							#data.item[i].description.value#
						</cfif>
					</li>
					<br />
				</cfloop>
			</cfoutput>
		</cfsavecontent>

		<cfreturn tmpHTML>
	</cffunction>	

	<cffunction name="retrieveRSSFeed" access="private" returntype="any">
		<cfset var data = 0>
		<cfset var rssurl = getContentTag().getAttribute("rssurl")>
		<cfset var oCache = getRSSCache()>
		<cfset var cacheKey = rssurl>

		<cftry>
			<cfset data = oCache.retrieve(cacheKey)>
			
			<cfcatch type="homePortals.cacheService.itemNotFound">
				<cffeed action="read" source="#rssurl#" name="data">	
				<cfset oCache.store(cacheKey, data)>
			</cfcatch>
		</cftry>
	
		<cfreturn data>
	</cffunction>

	<!---------------------------------------->
	<!--- getRSSCache    	              --->
	<!---------------------------------------->		
	<cffunction name="getRSSCache" access="private" returntype="homePortals.components.cacheService" hint="Retrieves a cacheService instance used for caching rss feeds for the RSS content tag renderer">
		<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
		<cfset var cacheName = variables.RSS_CACHE_NAME>
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
</cfcomponent>