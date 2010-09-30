<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="This content renderer displays posts from a Twitter account.">
	<cfproperty name="accountName" type="string" hint="Name of the twitter account">
	<cfproperty name="maxitems" default="10" type="numeric" displayname="Max Items" hint="Maximum number of items to display">

	<cfscript>
		variables.CACHE_NAME = "twitterTagCacheService";	// name of the cache instance to use for rss feeds
		variables.DEFAULT_MAX_ITEMS = 10;
	</cfscript>

	<!---------------------------------------->
	<!--- renderContent	                   --->
	<!---------------------------------------->		
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">
		<cfset arguments.headContentBuffer.set( renderHead() )>
		<cfset arguments.bodyContentBuffer.set( renderBody() )>
	</cffunction>

	<cffunction name="renderHead" access="private" returntype="string">
		<cfset var html = "">
		<cfreturn html>
	</cffunction>

	<cffunction name="renderBody" access="private" returntype="string" >
		<cfset var tmpHTML = "">
		<cfset var maxitems = getContentTag().getAttribute("maxitems",variables.DEFAULT_MAX_ITEMS)>	
		<cfset var data = 0>
		<cfset var i = 0>
		<cfset var id = getContentTag().getAttribute("id")>
		<cfset var lst = "">
		<cfset var accountName = getContentTag().getAttribute("accountName")>
		<cfset var dataURL = "http://twitter.com/statuses/user_timeline/" & accountName & ".xml">

		<cfset xmlDoc = retrieveData(dataURL)>

		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<cfset aItems = xmlSearch(xmlDoc,"//status")>
				<cfloop from="1" to="#min(arrayLen(aItems),val(maxItems))#" index="i">
					<cfset text = aItems[i].text.xmlText>
					<cfset text = reReplace(text, "((http|ftp|https)://[A-Za-z0-9._/]+)", "<a href=""\1"">\1</a>","ALL")>
					<cfset text = reReplace(text, "(\##([A-Za-z0-9._/]+))", "<a href='http://twitter.com/search?q=%23\2'>\1</a>","ALL")>
					<cfset text = reReplace(text, "(@([A-Za-z0-9._/]+))", "<a href='http://twitter.com/\2'>\1</a>","ALL")>
					<div style="font-size:12px;margin-bottom:10px;padding-bottom:10px;border-bottom:1px dotted silver;">
						&raquo;	#text#<br />
					</div>
				</cfloop>
				
				<div>
					<a href="http://www.twitter.com/#accountName#" style="font-weight:bold;font-size:14px;">Follow @#accountName#</a>
				</div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn tmpHTML>
	</cffunction>	


	<cffunction name="retrieveData" access="private" returntype="any">
		<cfargument name="srcURL" type="string" required="true">
		<cfset var xmlData = 0>
		<cfset var oCache = getCache()>
		<cfset var oCatalog = getPageRenderer().getHomePortals().getCatalog()>
		<cfset var accountName = getContentTag().getAttribute("accountName")>

		<cftry>
			<cfset xmlData = oCache.retrieve(accountName)>
			
			<cfcatch type="homePortals.cacheService.itemNotFound">
				<cfset xmlData = xmlParse(arguments.srcURL)>
				<cfset oCache.store(accountName, xmlData)>
			</cfcatch>
		</cftry>
	
		<cfreturn xmlData>
	</cffunction>

	<cffunction name="getCache" access="private" returntype="homePortals.components.cacheService" hint="Retrieves a cacheService instance used for caching rss feeds for the RSS content tag renderer">
		<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
		<cfset var cacheName = variables.CACHE_NAME>
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
