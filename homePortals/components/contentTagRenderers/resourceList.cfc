<cfcomponent extends="homePortals.components.contentTagRenderer" hint="Displays a list of available resources.">
	<cfproperty name="resourceType" type="string" required="true" displayname="Resource Type">
	<cfproperty name="orderBy" type="list" values="A to Z,Z to A,Older first,Newer first" hint="Indicates the sorting order for content entries. By default entries are displayed in alphabetical order (A to Z)" />
	<cfproperty name="pagingHREF" type="numeric" hint="URL format to use for paging. Use %pageNumber for the page number value" />
	<cfproperty name="itemsPerPage" type="numeric" default="10" required="false" hint="The maximum number of entries to display on the list" />
	<cfproperty name="itemHREF" type="string" hint="Use this field to provide an optional URL to trigger when selecting an item from the list. To indicate the ID of the selected entry, use the token %id" />
	<cfproperty name="startRow" type="numeric" default="1" hint="URL format to use for paging. Use %pageNumber for the page number value" />

	<!---
	<cfproperty name="labelProperty" type="string" hint="Resource property to use as label" />
	<cfproperty name="showDescription" type="boolean" hint="Display a description for each item?" />
	<cfproperty name="showCreateDate" type="boolean" hint="Display the creation date for each item?" />
	<cfproperty name="descriptionProperty" type="string" hint="Resource property to use as item description" />
	<cfproperty name="properties" type="string" hint="List of resource properties to display for each item" />
	<cfproperty name="showFileAsThumbnail" type="boolean" hint="Display the resource file as a thumbnail?" />
	<cfproperty name="thumbnail_width" type="numeric" />
	<cfproperty name="thumbnail_height" type="numeric" />
	<cfproperty name="thumbnail_path" type="string" />
	<cfproperty name="thumbnail_position" type="list" values="left,right,item" />

	<cfproperty name="itemsPerPage" type="numeric" hint="Number of items to display at a time" />
	
	<cfproperty name="displayType" type="list" values="list,grid,fluidgrid" default="list">
	<cfproperty name="grid_items_per_row" type="numeric" default="4" hint="number of items to display on a row">
	--->
	
	<cfset variables.MAX_ITEMS_TO_DISPLAY = 1000>
	<cfset variables.DEFAULT_ITEMS_TO_DISPLAY = 10>
	<cfset variables.DEFAULT_ORDER_BY_STR = "A to Z">
	<cfset variables.DEFAULT_ORDER_BY = "id">
	<cfset variables.READ_MORE_TEXT = "more">
	<cfset variables.DATE_FORMAT_MASK = "long">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfscript>
			var tmpHTML = "";
			var moduleID = getContentTag().getAttribute("id");
			var resourceType = getContentTag().getAttribute("resourceType");
			var oCatalog = getPageRenderer().getHomePortals().getCatalog();
			var qryRes = oCatalog.getIndex(resourceType);
			var orderBy = getContentTag().getAttribute("orderBy",variables.DEFAULT_ORDER_BY_STR);
			
			if(val(itemsPerPage) eq 0) itemsPerPage = variables.DEFAULT_ITEMS_TO_DISPLAY;
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
				ORDER BY #sqlOrderBy#
		</cfquery>
		
		<cfset tmpHTML = renderList(qryRes)>
		
		<cfset arguments.bodyContentBuffer.set( tmpHTML )>
	</cffunction>			
	
	<cffunction name="renderList" access="private" returntype="string">
		<cfargument name="qryData" type="query" required="true">
		<cfset var tmpHTML = "">
		<cfset var href = "">
		<cfset var showIntro = getContentTag().getAttribute("showIntro",false)>
		<cfset var itemHREF = getContentTag().getAttribute("itemHREF")>
		<cfset var pagingHREF = getContentTag().getAttribute("pagingHREF")>
		<cfset var itemsPerPage = getContentTag().getAttribute("itemsPerPage")>
		<cfset var startRow = getContentTag().getAttribute("startRow")>
		<cfset var oCatalog = getPageRenderer().getHomePortals().getCatalog()>
		<cfset var resource = 0>
		<cfset var pageNumber = 0>
		<cfset var totalPages = 0>

		<cfsavecontent variable="tmpHTML">
			<cfoutput query="arguments.qryData" startrow="#startRow#" maxrows="#itemsPerPage#">
				<cfif itemHREF neq "">
					<cfset href = replaceNoCase(itemHREF,"%id",urlEncodedFormat(arguments.qrydata.id),"ALL")>
					<cfset href = replaceNoCase(href,"%package",urlEncodedFormat(arguments.qrydata.package),"ALL")>
				</cfif>
				<cfif showIntro>
					<p>
						<cfif href neq "">
							<a href="#href#" style="font-size:14px;font-weight:bold">#arguments.qrydata.id#</a> <br/>
						<cfelse>
							<b>#arguments.qrydata.id#</b> <br/>
						</cfif>
						<span style="border-bottom:1px dotted black;">
							#lsDateFormat(arguments.qryData.createdOn, variables.DATE_FORMAT_MASK)#
						</span><br /><br />
						#arguments.qryData.description#
					</p>
				<cfelse>
					<cfif href neq "">
						<a href="#href#">#arguments.qryData.id#</a> <br/>
					<cfelse>
						#arguments.qryData.id# <br/>
					</cfif>
				</cfif>
			</cfoutput>
			<cfif pagingHREF neq "">
				Page #pageNumber# of #totalPages# | 
				<a href="">Prev #itemsPerPage#</a> 
				<a href="">Next #itemsPerPage#</a>
			</cfif>
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>

</cfcomponent>