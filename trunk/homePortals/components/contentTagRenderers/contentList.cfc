<cfcomponent extends="homePortals.components.contentTagRenderer">
	<cfproperty name="orderBy" type="list" values="A to Z,Z to A,Older first,Newer first" />
	<cfproperty name="maxItems" type="numeric" default="10" required="false" />
	<cfproperty name="showIntro" type="boolean" default="false" />
	<cfproperty name="itemHREF" type="string" />
	
	<cfset variables.MAX_ITEMS_TO_DISPLAY = 1000>
	<cfset variables.DEFAULT_ITEMS_TO_DISPLAY = 10>
	<cfset variables.DEFAULT_ORDER_BY = "id">
	<cfset variables.CONTENT_RES_TYPE = "content">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfscript>
			var tmpHTML = "";
			var moduleID = getContentTag().getAttribute("id");
			var resourceType = getContentTag().getAttribute("resourceType",variables.CONTENT_RES_TYPE );
			var oCatalog = getPageRenderer().getHomePortals().getCatalog();
			var qryRes = oCatalog.getResourcesByType(resourceType);
			var orderBy = getContentTag().getAttribute("orderBy","A to Z");
			var maxItems = getContentTag().getAttribute("maxItems",10);
			
			if(val(maxItems) eq 0) maxItems = variables.DEFAULT_ITEMS_TO_DISPLAY;
		</cfscript>
				
		<cfswitch expression="#orderBy#">
			<cfcase value="A to Z">
				<cfset sqlOrderBy = "id">
			</cfcase>
			<cfcase value="Z to A">
				<cfset sqlOrderBy = "id desc">
			</cfcase>
			<cfcase value="Older first">
				<cfset sqlOrderBy = "createdon">
			</cfcase>
			<cfcase value="Newer first">
				<cfset sqlOrderBy = "createdon desc">
			</cfcase>
			<cfdefaultcase>
				<cfset sqlOrderBy = variables.DEFAULT_ORDER_BY>
			</cfdefaultcase>
		</cfswitch>

		<cfquery name="qryRes" dbtype="query" maxrows="#min(maxItems,variables.MAX_ITEMS_TO_DISPLAY)#">
			SELECT id,description,createdOn,package
				FROM qryRes
				ORDER BY #sqlOrderBy#
		</cfquery>
		
		<cfset tmpHTML = renderContentList(qryRes)>
		
		<cfset arguments.bodyContentBuffer.set( tmpHTML )>
	</cffunction>			
	
	<cffunction name="renderContentList" access="private" returntype="string">
		<cfargument name="qryData" type="query" required="true">
		<cfset var tmpHTML = "">
		<cfset var href = "">
		<cfset var showIntro = getContentTag().getAttribute("showIntro",false)>
		<cfset var itemHREF = getContentTag().getAttribute("itemHREF")>

		<cfsavecontent variable="tmpHTML">
			<cfoutput query="arguments.qryData">
				<cfif itemHREF neq "">
					<cfset href = replaceNoCase(itemHREF,"{id}",arguments.qrydata.id,"ALL")>
					<cfset href = replaceNoCase(href,"{package}",arguments.qrydata.package,"ALL")>
				</cfif>
				<p>
				<cfif showIntro>
					<cfif href neq "">
						<a href="#href#"><b>#arguments.qrydata.id#</b></a> <br/>
					<cfelse>
						<b>#arguments.qrydata.id#</b> <br/>
					</cfif>
					#arguments.qryData.description#
				<cfelse>
					<cfif href neq "">
						<a href="#href#">#arguments.qryData.id#</a> <br/>
					<cfelse>
						#arguments.qryData.id# <br/>
					</cfif>
				</cfif>
				</p>
			</cfoutput>
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>

</cfcomponent>