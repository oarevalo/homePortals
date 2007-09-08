<cfcomponent displayname="RSSService" hint="provides rss retrieval, parsing and caching functionality">

	<!--- this is the directory where the service will cache the retrieved rss feeds --->
	<cfset variables.cacheDir = "/RSSReaderCache">
	<!--- the time to live in minutes for a retrieved feed on the caceh --->
	<cfset variables.timeToLive = 30>

	<!-------------------------------------->
	<!--- init                           --->
	<!-------------------------------------->	
	<cffunction name="init" access="public" returnType="RSSService">
		<cfargument name="cacheDir" type="string" required="false" default="">
		<cfargument name="timeToLive" type="numeric" required="false" default="30">
		
		<cfif arguments.cacheDir neq "">
			<cfset variables.cacheDir = arguments.cacheDir>
		</cfif>
		<cfset variables.timeToLive = arguments.timeToLive>
		
		<cfreturn this>
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
		<cfset var cacheValid = false>
		<cfset var cacheFileName = "">
		<cfset var cacheFile = "">
		<cfset var txtDoc = "">
		
		<!--- replace "feed://" with "http://" --->
		<cfset arguments.url = ReplaceNoCase(arguments.url,"feed://","http://")> 
			
		<!--- Check if feed is on cache--->
		<cfset cacheValid = false>
		<cfset cacheFileName = ReplaceList(arguments.url,"/,:,?","_,_,_") & ".xml">
		<cfset cacheFile = ExpandPath(variables.cacheDir & "/" & cacheFileName)> 
		
		<!--- check if cache directory exists, otherwise create it --->
		<cfif not DirectoryExists(expandPath(variables.cacheDir))>
			<cfdirectory action="create" directory="#expandPath(variables.cacheDir)#" mode="777">
		</cfif>
		
		<!--- if there is a cache then check if it is less than 30 minutes old --->
		<cfif fileExists(cacheFile)>
			<cfdirectory action="list" directory="#ExpandPath(variables.cacheDir)#" name="qryDir" filter="#cacheFileName#">
			<cfif DateDiff("n", qryDir.dateLastModified, now()) lt variables.timeToLive>
				<cfset cacheValid = true>
			</cfif>
		</cfif>

		<!--- check if a forced refresh was requested --->
		<cfif arguments.forceRefresh>
			<cfset cacheValid = false>
		</cfif>

		<!--- if cached data is valid, get it from there, otherwise, get from web --->
		<cfif cacheValid>
			<cffile action="read" file="#cacheFile#" variable="txtDoc">
			<cfset xmlDoc = XMLParse(txtDoc)>
		<cfelse>
			<cfhttp method="get" url="#arguments.url#" 
					resolveurl="yes" redirect="yes" 
					throwonerror="true" timeout="10"></cfhttp>
			<!---
			<cfif Not IsXML(cfhttp.FileContent)>
				<cfthrow message="A problem ocurred while processing the requested link [<a href='#arguments.url#' target='_blank'>#arguments.url#</a>]. Check that the resource is available and is a valid RSS or Atom feed.">
			</cfif>
			--->
			<cfset xmlDoc = XMLParse(cfhttp.FileContent)>
			
			<!--- cache the retrieved document --->
			<cffile action="write" file="#cacheFile#" output="#toString(xmlDoc)#">	
		</cfif>		
		
		<cfreturn xmlDoc>
	</cffunction>
	
	
</cfcomponent>


	
