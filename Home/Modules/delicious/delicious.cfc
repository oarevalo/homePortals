<cfcomponent>
	
	<cffunction name="doSearch" access="remote" hint="Searches delicous social bookmarking system" output="true">
		<cfargument name="user" type="string" default="">
		<cfargument name="tags" type="string" default="">
		
		<cftry>
			<cfscript>
				tmpTags = replace(arguments.tags,",","+","ALL");
				tmpTags = replace(tmpTags," ","+","ALL");
			
				deliciousURL = "http://del.icio.us/rss";
				
				if(arguments.user eq "" and tmpTags neq "") arguments.user = "tag";
				
				if(arguments.user neq "") deliciousURL = ListAppend(deliciousURL, arguments.user, "/");
				if(tmpTags neq "") deliciousURL = ListAppend(deliciousURL, tmpTags, "/");
				
				objRSS = createObject("component","home.modules.RSSReader.RSSReader");
				feed = objRSS.getRSS(deliciousURL);
			</cfscript>
			
			<cfloop from="1" to="#arrayLen(feed.items)#" index="i">
				<li><a href="#feed.items[i].link.xmlText#" target="_blank"><b>#feed.items[i].title.xmlText#</b></a></li>
			</cfloop>
					
			<cfcatch type="any">
				An error ocurred while trying to access del.icio.us.<br>
				<b>Message:</b> #cfcatch.Message#
			</cfcatch>
		</cftry>
	</cffunction>
	
</cfcomponent>