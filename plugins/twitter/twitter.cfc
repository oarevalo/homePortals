<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="This content renderer displays posts from a Twitter account.">
	<cfproperty name="user" type="string" hint="Name of the twitter account to display. If empty and no search term is given, then displays recent tweets from the public timeline">
	<cfproperty name="search" type="string" hint="Use this to search twitter for recent tweets that match the given query. This is only used if accountName is empty.">
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
		<cfset var xmlDoc = 0>
		<cfset var i = 0>
		<cfset var xpathExpr = "">
		<cfset var dataURL = "">
		<cfset var text = "">
		<cfset var aItems = "">
		<cfset var type = "">
		<cfset var user = getContentTag().getAttribute("user")>
		<cfset var search = getContentTag().getAttribute("search")>
	
		<!--- if no account name given, then default to public timeline --->
		<cfif user neq "">
			<cfset dataURL = "http://twitter.com/statuses/user_timeline/" & urlEncodedFormat(user) & ".xml">
			<cfset type = "xml">
			<cfset xpathExpr = "//status">
		<cfelseif search neq "">
			<cfset dataURL = "http://search.twitter.com/search.rss?q=" & urlEncodedFormat(search)>
			<cfset type = "rss">
			<cfset xpathExpr = "//item">
		<cfelse>
			<cfset dataURL = "http://twitter.com/statuses/public_timeline.xml">
			<cfset type = "xml">
			<cfset xpathExpr = "//status">
		</cfif>

		<cfset xmlDoc = retrieveData(dataURL)>

		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<cfset aItems = xmlSearch(xmlDoc,xpathExpr)>
				<cfloop from="1" to="#min(arrayLen(aItems),val(maxItems))#" index="i">
					<cfif type eq "xml">
						<cfset text = aItems[i].text.xmlText>
						<cfset author = aItems[i].user.screen_name.xmlText>
					<cfelse>
						<cfset text = aItems[i].title.xmlText>
						<cfset author = listFirst(aItems[i].author.xmlText,"@")>
					</cfif>
					<cfset text = reReplace(text, "((http|ftp|https)://[A-Za-z0-9._/]+)", "<a href='\1' title='\1'>\1</a>","ALL")>
					<cfset text = reReplace(text, "(\##([A-Za-z0-9._/]+))", "<a href='http://twitter.com/search?q=%23\2' title='\1'>\1</a>","ALL")>
					<cfset text = reReplace(text, "(@([A-Za-z0-9._/]+))", "<a href='http://twitter.com/\2' title='\1'>\1</a>","ALL")>
					<div style="font-size:12px;margin-bottom:10px;padding-bottom:10px;border-bottom:1px dotted silver;">
						&raquo;	
						<a href="http://www.twitter.com/#author#"><b>#author#:</b></a>
						#text#<br />
					</div>
				</cfloop>
				
				<div>
					<cfif user neq "">
						<a href="http://www.twitter.com/#urlEncodedFormat(user)#" style="font-weight:bold;font-size:14px;">Follow @#user#</a>
					<cfelseif search neq "">
						<a href="http://twitter.com/search?q=#urlEncodedFormat(search)#" style="font-weight:bold;font-size:14px;">'#search#' @ twitter</a>
					<cfelse>
						<a href="http://www.twitter.com" style="font-weight:bold;font-size:14px;">twitter.com</a>
					</cfif>
				</div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn tmpHTML>
	</cffunction>	


	<cffunction name="retrieveData" access="private" returntype="any">
		<cfargument name="srcURL" type="string" required="true">
		<cfset var xmlData = 0>
		<cfset var oCache = getCache()>
		<cfset var key = getContentTag().getAttribute("search", getContentTag().getAttribute("user","public_timeline"))>

		<cftry>
			<cfset xmlData = oCache.retrieve(key)>
			
			<cfcatch type="homePortals.cacheService.itemNotFound">
				<cfset xmlData = xmlParse(arguments.srcURL)>
				<cfset oCache.store(key, xmlData)>
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
