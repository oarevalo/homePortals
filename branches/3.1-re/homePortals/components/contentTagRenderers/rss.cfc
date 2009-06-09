<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="This content renderer displays the contents of an RSS feed.">
	<cfproperty name="rssurl" default="" type="string" displayname="RSS URL" hint="The URL for the RSS feed">
	<cfproperty name="maxitems" default="10" type="numeric" displayname="Max Items" hint="Maximum number of feed items to display">
	<cfproperty name="titlesonly" default="true" type="boolean" displayname="Titles Only" hint="Determines whether to display only the title and link for each item, or to display an excerpt along with the title">


	<!---------------------------------------->
	<!--- renderContent	                   --->
	<!---------------------------------------->		
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">

		<cfscript>
			var moduleID = getContentTag().getAttribute("id");

			try {
				arguments.bodyContentBuffer.set( renderFeed() );
				
			} catch(any e) {
				tmpHTML = "<b>An unexpected error ocurred while retrieving content for content module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				arguments.bodyContentBuffer.set( tmpHTML );
			}
		</cfscript>
	</cffunction>

	<cffunction name="renderFeed" access="private" returntype="string" >
		<cfset var tmpHTML = "">
		<cfset var rssurl = getContentTag().getAttribute("rssurl")>
		<cfset var maxitems = getContentTag().getAttribute("maxitems",10)>	
		<cfset var titlesonly = getContentTag().getAttribute("titlesonly",true)>	
		<cfset var data = 0>
		<cfset var i = 0>

		<cfset titlesonly = isBoolean(titlesonly) and titlesonly>

		<cffeed action="read" source="#rssurl#" name="data">

		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<h2>#data.title#</h2>
				<a href="#data.link#">#data.link#</a><br /><br />
				<cfloop from="1" to="#min(arrayLen(data.item),val(maxItems))#" index="i">
					<li>
						<a href="#data.item[i].link#" <cfif not titlesonly>style="font-weight:bold;"</cfif>>#data.item[i].title#</a>
						<cfif not titlesonly>
							<br />
							#data.item[i].description.value#
						</cfif>
					</li>
					<br />
				</cfloop>
			</cfoutput>
		</cfsavecontent>

		<cfreturn tmpHTML>
	</cffunction>	
	
</cfcomponent>