<cfcomponent hint="Provides access to YouTube API">
	
	<cfset variables.apiURL = "http://www.youtube.com/api2_rest">
	<cfset variables.DeveloperID = "y1VTEbSEUZI">

	<cffunction name="init" access="public" returntype="youTubeService">
		<cfargument name="developerID" type="string" required="true">
		<cfif arguments.developerID neq "">
			<cfset variables.DeveloperID = arguments.DeveloperID>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getDetails" access="public" returntype="any"
				hint="Returns the details of a video">
		<cfargument name="video_id" type="string" required="yes">
		
		<cfhttp url="#variables.apiURL#" method="get">
			<cfhttpparam type="url" name="method" value="youtube.videos.get_details">
			<cfhttpparam type="url" name="dev_id" value="#variables.DeveloperID#">
			<cfhttpparam type="url" name="video_id" value="#arguments.video_id#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset xmlResponse = xmlParse(cfhttp.FileContent)>
		<cfelse>
			<cfthrow message="Invalid response">
		</cfif>
		
		<cfreturn xmlResponse>
	</cffunction>
	
	
	<cffunction name="searchByTag" access="public" returntype="any"
				hint="Returns videos that match a given tag">
		<cfargument name="tag" type="string" required="yes">
		<cfargument name="page" type="string" required="no" default="1">
		<cfargument name="per_page" type="string" required="no" default="20">
		
		<cfhttp url="#variables.apiURL#" method="get">
			<cfhttpparam type="url" name="method" value="youtube.videos.list_by_tag">
			<cfhttpparam type="url" name="dev_id" value="#variables.DeveloperID#">
			<cfhttpparam type="url" name="tag" value="#arguments.tag#">
			<cfhttpparam type="url" name="page" value="#arguments.page#">
			<cfhttpparam type="url" name="per_page" value="#arguments.per_page#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset xmlResponse = xmlParse(cfhttp.FileContent)>
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
		
		<cfhttp url="#variables.apiURL#" method="get">
			<cfhttpparam type="url" name="method" value="youtube.videos.list_by_user">
			<cfhttpparam type="url" name="dev_id" value="#variables.DeveloperID#">
			<cfhttpparam type="url" name="user" value="#arguments.user#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset xmlResponse = xmlParse(cfhttp.FileContent)>
		<cfelse>
			<cfthrow message="Invalid response">
		</cfif>
		
		<cfreturn xmlResponse>
	</cffunction>
	
	
	<cffunction name="searchRelated" access="public" returntype="any"
				hint=" Lists all videos that match any of the specified tags.">
		<cfargument name="tag" type="string" required="yes">
		<cfargument name="page" type="string" required="no" default="1">
		<cfargument name="per_page" type="string" required="no" default="20">
		
		<cfhttp url="#variables.apiURL#" method="get">
			<cfhttpparam type="url" name="method" value="youtube.videos.list_by_related">
			<cfhttpparam type="url" name="dev_id" value="#variables.DeveloperID#">
			<cfhttpparam type="url" name="tag" value="#arguments.tag#">
			<cfhttpparam type="url" name="page" value="#arguments.page#">
			<cfhttpparam type="url" name="per_page" value="#arguments.per_page#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset xmlResponse = xmlParse(cfhttp.FileContent)>
		<cfelse>
			<cfthrow message="Invalid response">
		</cfif>
		
		<cfreturn xmlResponse>
	</cffunction>
		
	<cffunction name="searchByPlaylist" access="public" returntype="any"
				hint="Lists all videos in the specified playlist.">
		<cfargument name="id" type="string" required="yes">
		<cfargument name="page" type="string" required="no" default="1">
		<cfargument name="per_page" type="string" required="no" default="20">
		
		<cfhttp url="#variables.apiURL#" method="get">
			<cfhttpparam type="url" name="method" value="youtube.videos.list_by_playlist">
			<cfhttpparam type="url" name="dev_id" value="#variables.DeveloperID#">
			<cfhttpparam type="url" name="id" value="#arguments.id#">
			<cfhttpparam type="url" name="page" value="#arguments.page#">
			<cfhttpparam type="url" name="per_page" value="#arguments.per_page#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset xmlResponse = xmlParse(cfhttp.FileContent)>
		<cfelse>
			<cfthrow message="Invalid response">
		</cfif>
		
		<cfreturn xmlResponse>
	</cffunction>
		
	<cffunction name="listFeatured" access="public" returntype="any"
				hint="Lists the most recent 25 videos that have been featured on the front page of the YouTube site.">
		
		<cfhttp url="#variables.apiURL#" method="get">
			<cfhttpparam type="url" name="method" value="youtube.videos.list_featured">
			<cfhttpparam type="url" name="dev_id" value="#variables.DeveloperID#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset xmlResponse = xmlParse(cfhttp.FileContent)>
		<cfelse>
			<cfthrow message="Invalid response">
		</cfif>
		
		<cfreturn xmlResponse>
	</cffunction>		

	<cffunction name="listPopular" access="public" returntype="any"
				hint="Lists all videos in the specified time_range. ">
		<cfargument name="time_range" type="string" required="true" hint="the time_range to list by (e.g. 'day', 'week', 'month', 'all')">
		
		<cfhttp url="#variables.apiURL#" method="get">
			<cfhttpparam type="url" name="method" value="youtube.videos.list_popular">
			<cfhttpparam type="url" name="dev_id" value="#variables.DeveloperID#">
			<cfhttpparam type="url" name="time_range" value="#arguments.time_range#">
		</cfhttp>
		
		<cfif IsXML(cfhttp.FileContent)>
			<cfset xmlResponse = xmlParse(cfhttp.FileContent)>
		<cfelse>
			<cfthrow message="Invalid response">
		</cfif>
		
		<cfreturn xmlResponse>
	</cffunction>		
	
</cfcomponent>