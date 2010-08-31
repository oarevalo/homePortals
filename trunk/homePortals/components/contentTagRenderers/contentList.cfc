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
			SELECT id,description,createdOn,package,type
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
		<cfset var tmpBody = "">
		<cfset var showIntro = getContentTag().getAttribute("showIntro",false)>
		<cfset var itemHREF = getContentTag().getAttribute("itemHREF")>
		<cfset var oCatalog = getPageRenderer().getHomePortals().getCatalog()>
		<cfset var resource = 0>
		<cfset var hasMore = false>

		<cfsavecontent variable="tmpHTML">
			<cfoutput query="arguments.qryData">
				<cfif itemHREF neq "">
					<cfset href = replaceNoCase(itemHREF,"{id}",arguments.qrydata.id,"ALL")>
					<cfset href = replaceNoCase(href,"{package}",arguments.qrydata.package,"ALL")>
				</cfif>
				<cfif showIntro>
					<p>
						<cfif href neq "">
							<a href="#href#" style="font-size:14px;font-weight:bold">#arguments.qrydata.id#</a> <br/>
						<cfelse>
							<b>#arguments.qrydata.id#</b> <br/>
						</cfif>
						<cfif arguments.qryData.description neq "">
							<cfset tmpBody = arguments.qryData.description>
						<cfelse>
							<cfset resource = oCatalog.getResourceNode(arguments.qrydata.type, arguments.qrydata.id)>
							<cfif resource.targetFileExists()>
								<cfset tmpBody = resource.readFile()>
								<cfset tmpBody = reReplace(tmpBody, "</?\w+(\s*[\w:]+\s*=\s*(""[^""]*""|'[^']*'))*\s*/?>", " ", "all") />
								<cfset tmpBody = reReplace(trim( tmpBody ),"\s+"," ","all") />
								<cfset tmpBody = reMatch("([^\s]+\s?){1,50}", tmpBody ) />
								<cfif !arrayLen( tmpBody )>
									<cfset tmpBody = [ "" ] />
								</cfif>
								<cfset tmpBody = tmpBody[1] />
								<cfset hasMore = len(tmpBody) lt len(resource.readFile())>
							</cfif>
						</cfif>
						<span style="border-bottom:1px dotted black;">
							#lsDateFormat(arguments.qryData.createdOn, "long")#
						</span><br /><br />
						#tmpBody#
						<cfif hasMore>
							...
							<cfif href neq "">
								<a href="#href#">(more)</a>
							</cfif>
						</cfif>
					</p>
				<cfelse>
					<cfif href neq "">
						<a href="#href#">#arguments.qryData.id#</a> <br/>
					<cfelse>
						#arguments.qryData.id# <br/>
					</cfif>
				</cfif>
			</cfoutput>
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>

</cfcomponent>