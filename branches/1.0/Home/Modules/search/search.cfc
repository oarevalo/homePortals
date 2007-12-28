<cfcomponent displayname="webSearch">

	<cffunction name="doSearch" access="remote">
		<cfargument name="instanceName" type="string" required="yes">
		<cfargument name="engine" type="string" required="no" default="google">
		<cfargument name="query" type="string" required="yes" default="">
		<cfargument name="start" type="numeric" required="no" default="1">
		<cfargument name="maxResults" type="numeric" required="no"  default="10">
		
		<cfset var stResults = structNew()>
		
		<cftry>
			<cfswitch expression="#arguments.engine#">
				<cfcase value="google">
					<cfinvoke component="home.modules.search.google" method="search" returnvariable="stResults">
						<cfinvokeargument name="key" value="xZK/9GFQFHIuy+HTKulGAeWUUw2H1AM8">
						<cfinvokeargument name="q" value="#arguments.query#"> 
						<cfinvokeargument name="start" value="#arguments.start#"> 
						<cfinvokeargument name="maxResults" value="#arguments.maxResults#"> 
					</cfinvoke>
				</cfcase>
				<cfdefaultcase>
					<cfthrow message="Currently the only engine supported is Google">
				</cfdefaultcase>
			</cfswitch>
			
			<cfparam name="stResults.results" type="array" default="#arrayNew(1)#">
			<cfparam name="stResults.count" type="numeric" default="#arrayLen(stResults.results)#">
			
			<cfoutput>
				<b>#NumberFormat(stResults.count,"999,999,999,999,999")# results found.</b> Displaying #arguments.start# to #arguments.start+9#<br /><br/>
				<cfloop from="1" to="#arrayLen(stResults.results)#" index="i">
					<cfif stResults.results[i].title neq "">
						<a href="#stResults.results[i].url#">#stResults.results[i].title#</a><br>
					<cfelse>
						<a href="#stResults.results[i].url#">#stResults.results[i].url#</a><br>
					</cfif>
					
					<cfif stResults.results[i].summary neq "">
						#stResults.results[i].summary#<br/>
					</cfif>
					<a href="#stResults.results[i].url#" style="font-size:9px;">#stResults.results[i].url#</a><br/>
					<br/>
				</cfloop>
				<p>
					<cfif arguments.start gt 1><a href="javascript:#instanceName#.doSearch2('#arguments.engine#','#JSStringFormat(arguments.query)#',#arguments.start-10#)"><strong>Previous 10</strong></a></cfif>
					<cfif arguments.start+10 lt stResults.count>&nbsp;&nbsp;<a href="javascript:#instanceName#.doSearch2('#arguments.engine#','#JSStringFormat(arguments.query)#',#arguments.start+10#)"><strong>Next 10</strong></a></cfif>
				</p>
			</cfoutput>
			
			
			<cfcatch type="any">
				<cfoutput>
					#cfcatch.Message#<br>
					#cfcatch.Detail#
				</cfoutput>
			</cfcatch>
		</cftry>
		
	</cffunction>

</cfcomponent> 