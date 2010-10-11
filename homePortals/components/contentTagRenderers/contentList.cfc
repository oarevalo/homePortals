<cfcomponent extends="homePortals.components.contentTagRenderer"
			hint="Displays a list of available Content resources with a customizable URL.">
	<cfproperty name="orderBy" type="list" values="A to Z,Z to A,Older first,Newer first" hint="Indicates the sorting order for content entries. By default entries are displayed in alphabetical order (A to Z)" />
	<cfproperty name="showIntro" type="boolean" default="false" hint="Toggles whether to display a small intro paragraph for each entry" />
	<cfproperty name="itemHREF" type="string" hint="Use this field to provide an optional URL to trigger when selecting an item from the list. To indicate the ID of the selected entry, use the token %id" />
	<cfproperty name="pagingHREF" type="numeric" hint="URL format to use for paging. Use %pageNumber for the page number value" />
	<cfproperty name="itemsPerPage" type="numeric" default="10" required="false" hint="The number of resources to display at a time" />
	<cfproperty name="startRow" type="numeric" default="1" />
	<cfproperty name="package" type="string" hint="Use this to show only content resources from a given package" />
	
	<cfset variables.MAX_ITEMS_TO_DISPLAY = 1000>
	<cfset variables.DEFAULT_ITEMS_TO_DISPLAY = 10>
	<cfset variables.DEFAULT_ORDER_BY_STR = "A to Z">
	<cfset variables.DEFAULT_ORDER_BY = "id">
	<cfset variables.CONTENT_RES_TYPE = "content">
	<cfset variables.READ_MORE_TEXT = "more">
	<cfset variables.DATE_FORMAT_MASK = "long">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfscript>
			var tmpHTML = "";
			var moduleID = getContentTag().getAttribute("id");
			var package = getContentTag().getAttribute("package");
			var resourceType = getContentTag().getAttribute("resourceType",variables.CONTENT_RES_TYPE );
			var oCatalog = getPageRenderer().getHomePortals().getCatalog();
			var qryRes = oCatalog.getIndex(resourceType);
			var orderBy = getContentTag().getAttribute("orderBy",variables.DEFAULT_ORDER_BY_STR);
			var pagingHREF = getContentTag().getAttribute("pagingHREF");
			var startRow = getContentTag().getAttribute("startRow",1);
			var itemsPerPage = getContentTag().getAttribute("itemsPerPage",variables.DEFAULT_ITEMS_TO_DISPLAY);
			
			if(val(itemsPerPage) eq 0) maxItems = variables.DEFAULT_ITEMS_TO_DISPLAY;
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

		<cfquery name="qryRes" dbtype="query" maxrows="#variables.MAX_ITEMS_TO_DISPLAY#">
			SELECT id,description,createdOn,package,type
				FROM qryRes
				WHERE (1=1)
					<cfif package neq "">
						AND package LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#package#">
					</cfif>
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
		<cfset var pagingHREF = getContentTag().getAttribute("pagingHREF")>
		<cfset var oCatalog = getPageRenderer().getHomePortals().getCatalog()>
		<cfset var resource = 0>
		<cfset var hasMore = false>
		<cfset var startRow = getContentTag().getAttribute("startRow",1)>
		<cfset var itemsPerPage = getContentTag().getAttribute("itemsPerPage",variables.DEFAULT_ITEMS_TO_DISPLAY)>

		<cfif val(itemsPerPage) eq 0>
			<cfset itemsPerPage = variables.DEFAULT_ITEMS_TO_DISPLAY>
		</cfif>

		<cfset prevStart = startRow-itemsPerPage>
		<cfset nextStart = startRow+itemsPerPage>
		<cfset totalPages = ceiling(arguments.qryData.recordCount/itemsPerPage)>

		<cfsavecontent variable="tmpHTML">
			<cfoutput query="arguments.qryData" startrow="#startRow#" maxrows="#itemsPerPage#">
				<cfif itemHREF neq "">
					<cfset href = replaceNoCase(itemHREF,"%id",urlEncodedFormat(arguments.qrydata.id),"ALL")>
					<cfset href = replaceNoCase(href,"%package",urlEncodedFormat(arguments.qrydata.package),"ALL")>
					<cfset href = replaceNoCase(href,"%startRow",urlEncodedFormat(startRow),"ALL")>
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
							<cfset resource = oCatalog.getResource(arguments.qrydata.type, arguments.qrydata.package & "/" & arguments.qrydata.id)>
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
							#lsDateFormat(arguments.qryData.createdOn, variables.DATE_FORMAT_MASK)#
						</span><br /><br />
						#tmpBody#
						<cfif hasMore and len(tmpBody) gt 0>
							...
							<cfif href neq "">
								<a href="#href#">#variables.READ_MORE_TEXT#</a>
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
			<cfoutput>
				<br />
				<div class="rl_paging">
					<cfif pagingHREF neq "" and totalPages gt 1>
						<cfset firstPageHREF = replaceNoCase(pagingHREF,"%startRow",1,"ALL")>
						<cfset prevPageHREF = replaceNoCase(pagingHREF,"%startRow",prevStart,"ALL")>
						<cfset nextPageHREF = replaceNoCase(pagingHREF,"%startRow",nextStart,"ALL")>
			
						<cfif prevStart gt 0>
							<a href="#prevPageHREF#"><strong>Previous</strong></a> 
						</cfif>
						&nbsp;&nbsp;
						<cfif nextStart lte arguments.qryData.recordCount>
							<a href="#nextPageHREF#"><strong>Next</strong></a> 
						</cfif>
					</cfif>
				</div>
			</cfoutput>
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>

</cfcomponent>