<cfcomponent hint="Provides access to YouTube API">

	<cfset variables.apiURL = "http://gdata.youtube.com/feeds/api/videos">
	<cfset variables.timeout = 30>

	<cffunction name="init" access="public" returntype="youTubeService">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getDetails" access="public" returntype="any"
				hint="Returns the details of a video">
		<cfargument name="video_id" type="string" required="yes">
		<cfset var tmpURL = variables.apiURL & "/" & arguments.video_id />
		<cfset var info = structNew() />
		<cfset var xmlResponse = 0 />
		
		<cfhttp url="#tmpURL#" method="get" timeout="#variables.timeout#" result="info" throwonerror="true">
		</cfhttp>
		
		<cfif info.status_code eq "200" and isXML(info.FileContent)>
			<cfset xmlResponse = xmlParse(info.FileContent)>
		<cfelse>
			<cfthrow message="Invalid response">
		</cfif>

		<cfreturn xmlResponse>
	</cffunction>
	
	
	<cffunction name="search" access="public" returntype="any" hint="Does a general search on videos">
		<cfargument name="searchTerm" type="string" required="yes">
		<cfargument name="page" type="string" required="no" default="1">
		<cfargument name="per_page" type="string" required="no" default="20">

		<cfset var info = structNew() />
		<cfset var xmlResponse = 0 />
		<cfset var start = (arguments.page-1)*arguments.per_page+1 />
		
		<cfhttp url="#variables.apiURL#" method="get" timeout="#variables.timeout#" result="info" throwonerror="true">
			<cfhttpparam type="url" name="q" value="#arguments.searchTerm#">
			<cfhttpparam type="url" name="start-index" value="#start#">
			<cfhttpparam type="url" name="max-results" value="#arguments.per_page#">
		</cfhttp>

		<cfif info.status_code eq "200" and isXML(info.FileContent)>
			<cfset xmlResponse = xmlParse(info.FileContent)>
		<cfelse>
			<cfthrow message="Invalid response">
		</cfif>
		
		<cfreturn xmlResponse>
	</cffunction>
			
				
	<cffunction name="searchByTag" access="public" returntype="any"
				hint="Returns videos that match a given tag or category">
		<cfargument name="tag" type="string" required="yes">
		<cfargument name="page" type="string" required="no" default="1">
		<cfargument name="per_page" type="string" required="no" default="20">

		<cfset var tmpURL = variables.apiURL  & "/-/" & urlEncodedFormat(listChangeDelims(arguments.tag,"/"))  />
		<cfset var info = structNew() />
		<cfset var xmlResponse = 0 />
		<cfset var start = (arguments.page-1)*arguments.per_page+1 />
		
		<cfhttp url="#tmpURL#" method="get" timeout="#variables.timeout#" result="info" throwonerror="true">
			<cfhttpparam type="url" name="start-index" value="#start#">
			<cfhttpparam type="url" name="max-results" value="#arguments.per_page#">
		</cfhttp>

		<cfif info.status_code eq "200" and isXML(info.FileContent)>
			<cfset xmlResponse = xmlParse(info.FileContent)>
		<cfelse>
			<cfthrow message="Invalid response">
		</cfif>
		
		<cfreturn xmlResponse>
	</cffunction>
	
				
	<cffunction name="searchByUser" access="public" returntype="any"
				hint="Returns videos uploaded by a given user">
		<cfargument name="user" type="string" required="yes">
		<cfargument name="page" type="string" required="no" default="1">
		<cfargument name="per_page" type="string" required="no" default="5">
		
		<cfset var tmpURL = "http://gdata.youtube.com/feeds/api/users/" & arguments.user & "/uploads" />
		<cfset var info = structNew() />
		<cfset var xmlResponse = 0 />
		<cfset var start = (arguments.page-1)*arguments.per_page+1 />
		
		<cfhttp url="#tmpURL#" method="get" timeout="#variables.timeout#" result="info" throwonerror="true">
			<cfhttpparam type="url" name="start-index" value="#start#">
			<cfhttpparam type="url" name="max-results" value="#arguments.per_page#">
		</cfhttp>
		
		<cfif info.status_code eq "200" and isXML(info.FileContent)>
			<cfset xmlResponse = xmlParse(info.FileContent)>
		<cfelse>
			<cfthrow message="Invalid response">
		</cfif>
		
		<cfreturn xmlResponse>
	</cffunction>
	
	
	<cffunction name="list" access="public" returntype="any"
				hint="Lists all videos in one of the standard video feeds">
		<cfargument name="feedID" type="string" required="true" hint="the video feed to diplsay (top_rated,top_favorites,most_viewed,etc.)">
		<cfargument name="time_range" type="string" required="false" default="" hint="the time_range to list by (e.g. 'day', 'week', 'month', 'all')">
		<cfargument name="page" type="string" required="no" default="1">
		<cfargument name="per_page" type="string" required="no" default="20">
	
		<cfset var tmpURL = "http://gdata.youtube.com/feeds/api/standardfeeds/" & arguments.feedID />
		<cfset var info = structNew() />
		<cfset var xmlResponse = 0 />
		<cfset var start = (arguments.page-1)*arguments.per_page+1 />
	
		<cfhttp url="#tmpURL#" method="get" timeout="#variables.timeout#" result="info" throwonerror="true">
			<cfif arguments.time_range neq "">
				<cfhttpparam type="url" name="time" value="#arguments.time_range#">
			</cfif>
			<cfhttpparam type="url" name="start-index" value="#start#">
			<cfhttpparam type="url" name="max-results" value="#arguments.per_page#">
		</cfhttp>
		
		<cfif info.status_code eq "200" and isXML(info.FileContent)>
			<cfset xmlResponse = xmlParse(info.FileContent)>
		<cfelse>
			<cfthrow message="Invalid response">
		</cfif>
		
		<cfreturn xmlResponse>
	</cffunction>		
	
</cfcomponent>