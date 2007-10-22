<cfcomponent displayname="RSSService" hint="provides rss retrieval, parsing and caching functionality">

	<!--- this is the directory where the service will cache the retrieved rss feeds --->
	<cfset variables.cacheDir = "/RSSReaderCache">
	<!--- the time to live in minutes for a retrieved feed on the cache, this is the minumum time to wait before retrieving the feed from the source again --->
	<cfset variables.timeToLive = 30>
	<!--- number of feeds to cache in memory --->
	<cfset variables.memCacheSize = 50>
	<!--- time to live in minutes for feeds cached in memory --->
	<cfset variables.memCacheTTL = 20>
	<!--- name of the lock to use when accessing the memory cache service --->
    <cfset variables.lockName = "hp_rssService_cache">
    <!--- seconds to wait when retrieving a feed with an HTTP request --->
    <cfset variables.httpTimeout = 10>
    
    
	<!-------------------------------------->
	<!--- init                           --->
	<!-------------------------------------->	
	<cffunction name="init" access="public" returnType="RSSService">
		<cfargument name="cacheDir" type="string" required="false" default="">
		<cfargument name="timeToLive" type="numeric" required="false" default="#variables.timeToLive#">
		<cfargument name="memCacheSize" type="numeric" required="false" default="#variables.memCacheSize#">
		<cfargument name="memCacheTTL" type="numeric" required="false" default="#variables.memCacheTTL#">
		<cfargument name="reloadCache" type="boolean" required="false" default="false">

		<!--- set instance variables --->
		<cfif arguments.cacheDir neq "">
			<cfset variables.cacheDir = arguments.cacheDir>
		</cfif>
		<cfset variables.timeToLive = arguments.timeToLive>
		<cfset variables.memCacheSize = arguments.memCacheSize>
		<cfset variables.memCacheTTL = arguments.memCacheTTL>
		
		<!--- create memcache structure if not exists --->
		<cfif Not structKeyExists(application, "rssCacheService") or arguments.reloadCache>
			<cfset oCacheService = createObject("component","cacheService").init(variables.memCacheSize, variables.memCacheTTL)>
			<cflock type="exclusive" name="#variables.lockName#" timeout="30">
				<cfset application.rssCacheService = oCacheService>
			</cflock>
		</cfif>
		
		<cfreturn this>
	</cffunction>

	<!-------------------------------------->
	<!--- getCacheService                --->
	<!-------------------------------------->	
	<cffunction name="getCacheService" access="public" returnType="cacheService">
		<cfreturn application.rssCacheService>
	</cffunction>
	
	<!-------------------------------------->
	<!--- getRSS                         --->
	<!-------------------------------------->	
	<cffunction name="getRSS" access="public" returntype="struct">
		<cfargument name="url"  type="string" required="yes">
		<cfargument name="forceRefresh" type="boolean" required="false" default="false" hint="use this to force a refresh of the cache">
		<cfscript>
			var feed = StructNew();
			var isRSS1 = false;
			var isRSS2 = false;
			var isAtom = false;
			var xmlDoc = 0;

			// get feed document
			xmlDoc = retrieveFeedXML(arguments.url, arguments.forceRefresh);
			
			// parse feed
			feed.title = "";
			feed.link = "";
			feed.description = "";
			feed.date = "";
			feed.image = StructNew();
			feed.image.url = "";
			feed.image.title = "";
			feed.image.link = "##";
			feed.items = ArrayNew(1);
			
			// get feed type
			isRSS1 = StructKeyExists(xmlDoc.xmlRoot,"item");
			isRSS2 = StructKeyExists(xmlDoc.xmlRoot,"channel") and StructKeyExists(xmlDoc.xmlRoot.channel,"item");
			isAtom = StructKeyExists(xmlDoc.xmlRoot,"entry");
			
			// get title
			if(isRSS1 or isRSS2) {
				if(isRSS1) feed.items = xmlDoc.xmlRoot.item;
				if(isRSS2) feed.items = xmlDoc.xmlRoot.channel.item;
				
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"title")) feed.Title = xmlDoc.xmlRoot.channel.title.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"link")) feed.Link = xmlDoc.xmlRoot.channel.link.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"description")) feed.Description = xmlDoc.xmlRoot.channel.description.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"lastBuildDate")) feed.Date = xmlDoc.xmlRoot.channel.lastBuildDate.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"image")) {
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"url")) feed.Image.URL = xmlDoc.xmlRoot.channel.image.url.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"title")) feed.Image.Title = xmlDoc.xmlRoot.channel.image.title.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"link")) feed.Image.Link = xmlDoc.xmlRoot.channel.image.link.xmlText;
				}
			}
			if(isAtom) {
				if(isAtom) feed.items = xmlDoc.xmlRoot.entry;
				if(StructKeyExists(xmlDoc.xmlRoot,"title")) feed.Title = xmlDoc.xmlRoot.title.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot,"link")) feed.Link = xmlDoc.xmlRoot.link.xmlAttributes.href;
				if(StructKeyExists(xmlDoc.xmlRoot,"info")) feed.Description = xmlDoc.xmlRoot.info.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot,"modified")) feed.Date = xmlDoc.xmlRoot.modified.xmlText;
			}
		</cfscript>
		<cfreturn feed>
	</cffunction>

	<!-------------------------------------->
	<!--- getRSSPost                     --->
	<!-------------------------------------->	
	<cffunction name="getRSSPost" access="public" returntype="any"
				hing="Searches the given RSS feed for the given post identified by the post's link attribute">
		<cfargument name="rssURL" type="string" required="true">
		<cfargument name="link" type="string" required="true">

		<cfset var feed = getRSS(arguments.rssURL)>
		<cfset var bFound = false>
		<cfset var stRet = structNew()>
		<cfset var thisLink = "">
		<cfset var i = 1>
		<cfset var tmpPostURL = "">
		<cfset var resultIndex = 0>
		<cfset var numPosts = ArrayLen(feed.items)>
	
		<cfloop from="1" to="#numPosts#" index="i">
			<cfif StructKeyExists(feed.items[i],"link")> 
				<cfset tmpPostURL = thisLink>
				<cfset thisLink = tostring(feed.items[i].link.xmlText)>
			</cfif>

			<cfset feed.items[i].xmlAttributes.postIndex = i>
			<cfset feed.items[i].xmlAttributes.prevPostURL = tmpPostURL>
			<cfset feed.items[i].xmlAttributes.nextPostURL = "">
			<cfset feed.items[i].xmlAttributes.numPosts = numPosts>
	
			<cfif i gt 1>
				<cfset feed.items[i-1].xmlAttributes.nextPostURL = thisLink>
			</cfif>
	
			<cfif thisLink eq arguments.link>
				<cfset resultIndex = i>
			</cfif>
		</cfloop>
		
		<cfif resultIndex gt 0>
			<cfreturn feed.items[resultIndex]>
		<cfelse>
			<cfthrow message="Not found!">
		</cfif>
		<cfreturn structNew()>
	</cffunction>
	

	<!-------------------------------------->
	<!--- retrieveFeed                   --->
	<!-------------------------------------->	
	<cffunction name="retrieveFeedXML" access="public" returntype="xml"
				hing="Returns the xml document for the feed, if the feed is not on the cache or cached version is no longer valid then retrieves it from the source">
		<cfargument name="url" type="string" required="true">
		<cfargument name="forceRefresh" type="boolean" required="false" default="false" hint="use this to force a refresh of the cache">
		
		<cfset var xmlDoc = 0>
		<cfset var xmlDoc_Cache = 0>
		<cfset var fileCacheValid = false>
		<cfset var memCacheValid = false>
		<cfset var cacheFileName = "">
		<cfset var cacheFile = "">
		<cfset var txtDoc = "">
		<cfset var oCacheService = application.rssCacheService>
		
		<!--- replace "feed://" with "http://" --->
		<cfset arguments.url = ReplaceNoCase(arguments.url,"feed://","http://")> 
		
		<!--- set values for cache check--->
		<cfset memCacheKey = hash(arguments.url)>
		<cfset cacheFileName = ReplaceList(arguments.url,"/,:,?","_,_,_") & ".xml">
		<cfset cacheFile = ExpandPath(variables.cacheDir & "/" & cacheFileName)> 
		
		<!---retrieve the feed from the memory cache if it exists is still valid --->
		<cfif not arguments.forceRefresh>
			<cftry>
				<cfset xmlDoc_Cache = oCacheService.retrieve(memCacheKey)>
				<cfset memCacheValid = true>

				<cfcatch type="homePortals.cacheService.itemNotFound">
					<cfset memCacheValid = false>
				</cfcatch>
			</cftry>
		</cfif>


		<!--- if the mem cache is valid, then retrieve data from the memcache --->
		<cfif memCacheValid>
			<cfset xmlDoc = xmlDoc_Cache>
		<cfelse>	
			<!--- check if file cache directory exists, otherwise create it --->
			<cfif not DirectoryExists(expandPath(variables.cacheDir))>
				<cfdirectory action="create" directory="#expandPath(variables.cacheDir)#" mode="777">
			</cfif>

			<cfif not arguments.forceRefresh>
				<!---check if the feed exists in the file cache and if it is still valid --->
				<cfif fileExists(cacheFile)>
					<cfdirectory action="list" directory="#ExpandPath(variables.cacheDir)#" name="qryDir" filter="#cacheFileName#">
					<cfif DateDiff("n", qryDir.dateLastModified, now()) lt variables.timeToLive>
						<cfset fileCacheValid = true>
					</cfif>
				</cfif>
			</cfif>
			
			<!--- if file cached data is valid, get it from there, otherwise, get from web --->
			<cfif fileCacheValid>
				<cfset xmlDoc = XMLParse(cacheFile)>
			<cfelse>
				<cfset xmlDoc = getFromSource(arguments.url)>
				
				<!--- cache the retrieved document --->
				<cffile action="write" file="#cacheFile#" output="#toString(xmlDoc)#">	
			</cfif>		

			<!--- update in-memory cache --->
            <cflock type="exclusive" name="#variables.lockName#" timeout="30">
	            <cfset oCacheService.store(memCacheKey, xmlDoc)>
            </cflock>

		</cfif>
		
		<cfreturn xmlDoc>
	</cffunction>
	
	<cffunction name="getFromSource" access="private" returntype="xml" hint="reads an rss feed from the source URL">
		<cfargument name="url" type="string" required="true">
		<cfhttp method="get" 
        		url="#arguments.url#" 
				resolveurl="yes" 
                redirect="yes" 
				throwonerror="true" 
                timeout="#variables.httpTimeout#"></cfhttp>
		<cfreturn XMLParse(cfhttp.FileContent)>
	</cffunction>
	
</cfcomponent>


	
