<cfparam name="action" default="">
<html>
	<head>
		<title>HomePortals - Cache Manager Tool</title>
	</head>
	<body>
		<h1>Cache Manager</h1>
		
		<p>
			This tool allows to view and perform operations on the content store and rssfeeds
			caches.<br>
			<b>IMPORTANT:</b> To use this tool you must copy this file (cacheManager.cfm) into the application where the cache
			is being used.
		</p>
		

		<form name="frm" action="cacheManager.cfm" method="post">
			<input type="submit" name="action" value="info" />
			<input type="submit" name="action" value="clear" />
			<input type="submit" name="action" value="cleanup" />
			<input type="submit" name="action" value="list" />
		</form>
		<br />
		
		<cfswitch expression="#action#">
		
			<cfcase value="clear">
				<cfset structDelete(application, "rssCacheService")>
		        <cfset structDelete(application, "_hpContentStoreCache")>
		        Caches deleted.
		    </cfcase>
		    
		    <cfcase value="cleanup">
				<cfset feedCache = application.rssCacheService>
		        <cfset csCache = application["_hpContentStoreCache"]>
				<cfset feedCache.cleanup()>    
				<cfset csCache.cleanup()>    
		        Caches cleared.
		    </cfcase>
		    
			<cfcase value="list">
				<cfset feedCache = application.rssCacheService>
		        <cfset csCache = application["_hpContentStoreCache"]>
		        <cfdump var="#feedCache.list()#" label="RSS Feeds Cache">
		        <cfdump var="#csCache.list()#" label="Content Store Cache">
		    </cfcase>
			
			<cfdefaultcase>
				<cfset feedCache = application.rssCacheService>
		        <cfset csCache = application["_hpContentStoreCache"]>
		        <cfoutput>
		            <cfdump var="#feedCache.getStats()#" label="RSS Feeds Cache">
		            <cfdump var="#csCache.getStats()#" label="Content Store Cache">
		        </cfoutput>
		    
		    </cfdefaultcase>
		
		</cfswitch>
		
	</body>
</html>
		