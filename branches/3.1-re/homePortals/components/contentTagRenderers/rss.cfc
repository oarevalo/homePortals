<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="This content renderer displays the contents of an RSS feed.">
	<cfproperty name="feedID" type="resource:feed" displayname="Feed Resource" hint="Use this property to select an RSS feed from the resource library">
	<cfproperty name="rssurl" default="" type="string" displayname="RSS URL" hint="The URL for the RSS feed. Use this property to explicitly enter the URL of the feed. This is ignored when indicating a feed from the resource library.">
	<cfproperty name="maxitems" default="10" type="numeric" displayname="Max Items" hint="Maximum number of feed items to display">
	<cfproperty name="titlesonly" default="true" type="boolean" displayname="Titles Only" hint="Determines whether to display only the title and link for each item, or to display an excerpt along with the title">
	<cfproperty name="readMoreURL" default="" type="string" hint="If not empty displays a Read More link pointing to this URL">

	<cfscript>
		variables.RSS_CACHE_NAME = "rssTagCacheService";	// name of the cache instance to use for rss feeds
		variables.DEFAULT_TITLES_ONLY = true;
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

	<cffunction name="renderBody" access="private" returntype="string" >
		<cfset var tmpHTML = "">
		<cfset var maxitems = getContentTag().getAttribute("maxitems",variables.DEFAULT_MAX_ITEMS)>	
		<cfset var titlesonly = getContentTag().getAttribute("titlesonly",variables.DEFAULT_TITLES_ONLY)>	
		<cfset var readMoreURL = getContentTag().getAttribute("readMoreURL")>
		<cfset var showRSSTitle = getContentTag().getAttribute("showRSSTitle",true)>
		<cfset var data = 0>
		<cfset var i = 0>

		<cfset titlesonly = isBoolean(titlesonly) and titlesonly>
		
		<cfset data = retrieveRSSFeed()>

		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<cfif isBoolean(showRSSTitle) and showRSSTitle>
					<cfif structKeyExists(data,"title") and structKeyExists(data,"link")>
						<h3><a href="#data.link#">#data.title#</a></h3>
					</cfif>
				</cfif>
				<cfif structKeyExists(data,"item") and isArray(data.item)>
					<cfloop from="1" to="#min(arrayLen(data.item),val(maxItems))#" index="i">
						<div style="margin-bottom:5px;">
							&raquo;	<a href="#data.item[i].link#" <cfif not titlesonly>style="font-weight:bold;"</cfif>>#data.item[i].title#</a>
						</div>
						<cfif not titlesonly>
							<div style="margin-bottom:15px;">
								<div style="margin-bottom:5px;font-size:10px;">
									Posted 
									
									<cfif structKeyExists(data.item[i],"pubDate")>
										<cftry>
											on #lsDateFormat(data.item[i].pubDate)# 
											<cfcatch type="any">
												on #data.item[i].pubDate#
											</cfcatch>
										</cftry>
										
									</cfif>
									
									<cfif structKeyExists(data.item[i],"category") and isArray(data.item[i].category)>
										<cfset lst = "">
										<cfloop from="1" to="#arrayLen(data.item[i].category)#" index="j">
											<cfset lst = listAppend(lst,data.item[i].category[j].value)>
										</cfloop>
										under #lst#
									</cfif>
								</div>
								
								<cfif structKeyExists(data.item[i],"description") and structKeyExists(data.item[i].description,"value")>
									#data.item[i].description.value#
								<cfelseif structKeyExists(data.item[i],"encoded")>
									#data.item[i].encoded#
								</cfif>
							</div>
						</cfif>
					</cfloop>
				<cfelse>
					&raquo;	This feed is currently unavailable.
				</cfif>
				<cfif readMoreURL neq "">
					<div style="margin-top:10px;font-weight:bold;">
						<a href="#readMoreURL#">Read More...</a>
					</div>
				</cfif>
			</cfoutput>
		</cfsavecontent>

		<cfreturn tmpHTML>
	</cffunction>	

	<cffunction name="renderHead" access="private" returntype="string" >
		<cfset var tmpHTML = "">
		<cfset var id = getContentTag().getAttribute("id")>
		<cfset var titlesonly = getContentTag().getAttribute("titlesonly",variables.DEFAULT_TITLES_ONLY)>
		
		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<cfif titlesonly>
					<style type="text/css">
						.feedReaderContent {
							margin:10px;
							margin-top:0px;
							margin-bottom:20px;
						}
						.feedReaderBodyTitle {
							font-weight:bold;
							margin-bottom:4px;
							color:##fff;
							background-color:##e08c19;
							border-bottom:1px solid silver;
							padding:3px;
						}
						.feedReaderBodyByline {
							font-weight:bold;
							font-size:10px;
							margin-top:3px;
							margin-bottom:3px;
							color:##999;
						}
						.feedReaderSeparator {
							border-top:1px dashed silver;
						}
					</style>
				<cfelse>
					<style type="text/css">
						.feedReaderItem {
						}
						.feedReaderBody {
							margin-bottom:15px;
						}
						.expandedTitle a {
							font-size:16px;
							font-weight:bold;
						}
						.feedReaderBodyByline {
							font-weight:bold;
							font-size:10px;
							margin-top:3px;
							margin-bottom:3px;
							color:##999;
						}
					</style>				
				</cfif>
			</cfoutput>
		</cfsavecontent>

		<cfreturn tmpHTML>
	</cffunction>	


	<cffunction name="retrieveRSSFeed" access="private" returntype="any">
		<cfset var data = 0>
		<cfset var rssurl = getRSSURL()>
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

	<cffunction name="getRSSURL" access="private" returntype="any">
		<cfset var oResourceBean = 0>
		<cfset var resourceID = getContentTag().getAttribute("feedID")>
		<cfset var rssurl = getContentTag().getAttribute("rssurl")>
		<cfset var oCatalog = getPageRenderer().getHomePortals().getCatalog()>

		<cfif resourceID neq "">
			<cfset oResourceBean = oCatalog.getResourceNode("feed", resourceID)>
			<cfif oResourceBean.isExternalTarget()>
				<cfset rssURL = oResourceBean.getHREF()>
			<cfelse>
				<cfset rssURL = oResourceBean.getProperty("rssURL")>
			</cfif>
		</cfif>
	
		<cfreturn rssURL>
	</cffunction>
		
</cfcomponent>