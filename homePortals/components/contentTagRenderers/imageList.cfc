<cfcomponent extends="homePortals.components.contentTagRenderer" hint="Displays a list of available image resources.">

	<cfproperty name="orderBy" type="string" hint="Indicates the sorting order for content entries. By default entries are displayed in alphabetical order by their ID property" />
	<cfproperty name="itemHREF" type="string" hint="Use this field to provide an optional URL to trigger when selecting an item from the list. To indicate the ID of the selected entry, use the token %id" />
	<cfproperty name="pagingHREF" type="numeric" hint="URL format to use for paging. Use %pageNumber for the page number value" />
	<cfproperty name="itemsPerPage" type="numeric" default="10" required="false" hint="The number of resources to display at a time" />
	<cfproperty name="startRow" type="numeric" default="1" />

	<cfproperty name="showLabel" type="boolean" hint="Display a label for each image?" />
	<cfproperty name="groupBy" type="string" />
	<cfproperty name="pagingDelta" type="numeric" />
	<cfproperty name="itemProperties" type="string" hint="List of resource properties to display for each item" />

	<cfproperty name="package" type="string" hint="" />
	<cfproperty name="searchTerm" type="string" hint="" />
	<cfproperty name="searchFields" type="string" hint="" />
	<cfproperty name="searchFilter" type="string" hint="" />
	
	<cfset variables.MAX_ITEMS_TO_DISPLAY = 1000>
	<cfset variables.DEFAULT_RESOURCE_TYPE = "image">
	<cfset variables.DEFAULT_ITEMS_TO_DISPLAY = 10>
	<cfset variables.DEFAULT_ORDER_BY = "id">
	<cfset variables.DEFAULT_GROUP_BY = "">
	<cfset variables.DEFAULT_PAGING_DELTA = 3>
	<cfset variables.DEFAULT_SEARCH_FIELDS = "id,package,description">
	<cfset variables.DEFAULT_SHOW_LABEL = true>
	<cfset variables.DEFAULT_SHOW_RESULTSCOUNT = true>
	<cfset variables.DEFAULT_WIDTH = "100">
	<cfset variables.DEFAULT_HEIGHT = "">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfscript>
			var fld = "";

			var resourceType = getContentTag().getAttribute("resourceType", variables.DEFAULT_RESOURCE_TYPE);
			var orderBy = getContentTag().getAttribute("orderBy",variables.DEFAULT_ORDER_BY);
			var groupBy = getContentTag().getAttribute("groupBy",variables.DEFAULT_GROUP_BY);
			var itemProperties = getContentTag().getAttribute("itemProperties");
			var package = getContentTag().getAttribute("package");
			var searchTerm = getContentTag().getAttribute("searchTerm");
			var searchFields = getContentTag().getAttribute("searchFields", variables.DEFAULT_SEARCH_FIELDS);
			var searchFilter = getContentTag().getAttribute("searchFilter");

			var oCatalog = getPageRenderer().getHomePortals().getCatalog();
			var qryRes = oCatalog.getIndex(resourceType);

			if(groupBy neq "") orderBy = listAppend(groupBy,orderBy);
		</cfscript>
	
		<cfquery name="qryRes" dbtype="query" maxrows="#variables.MAX_ITEMS_TO_DISPLAY#">
			SELECT id,description,createdOn,package,type,label,url,href,libpath
					<cfif itemProperties neq "">,#itemProperties#</cfif>
				FROM qryRes
				WHERE (1=1)
					<cfif package neq "">
						AND package LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#package#">
					</cfif>
					<cfif searchTerm neq "">
						AND (
							(1=0)
							<cfloop list="#searchFields#" index="fld">
								OR #fld# LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#searchTerm#%">
							</cfloop>
						)
					</cfif>
					<cfif searchFilter neq "">
						AND #preserveSingleQuotes(searchFilter)#
					</cfif>
				ORDER BY #orderBy#
		</cfquery>
		
		<cfset arguments.bodyContentBuffer.set( renderList(qryRes) )>
	</cffunction>			
	
	<cffunction name="renderList" access="private" returntype="string">
		<cfargument name="qryData" type="query" required="true">
		<cfset var tmpHTML = "">
		<cfset var href = "">
		<cfset var oCatalog = getPageRenderer().getHomePortals().getCatalog()>
		<cfset var resource = 0>
		<cfset var pageNumber = 0>
		<cfset var totalPages = 0>
		<cfset var prevStart = 0>
		<cfset var nextStart = 0>

		<cfset var itemHREF = getContentTag().getAttribute("itemHREF")>
		<cfset var pagingHREF = getContentTag().getAttribute("pagingHREF")>
		<cfset var startRow = getContentTag().getAttribute("startRow",1)>
		<cfset var pagingDelta = getContentTag().getAttribute("pagingDelta", variables.DEFAULT_PAGING_DELTA)>
		<cfset var itemsPerPage = getContentTag().getAttribute("itemsPerPage",variables.DEFAULT_ITEMS_TO_DISPLAY)>
		<cfset var showLabel = getContentTag().getAttribute("showLabel", variables.DEFAULT_SHOW_LABEL)>
		<cfset var showResultsCount = getContentTag().getAttribute("showResultsCount", variables.DEFAULT_SHOW_RESULTSCOUNT)>
		<cfset var groupBy = getContentTag().getAttribute("groupBy",variables.DEFAULT_GROUP_BY)>
		<cfset var itemProperties = getContentTag().getAttribute("itemProperties")>
		<cfset var searchTerm = getContentTag().getAttribute("searchTerm")>

		<cfif val(itemsPerPage) eq 0>
			<cfset itemsPerPage = variables.DEFAULT_ITEMS_TO_DISPLAY>
		</cfif>
		
		<cfset totalPages = ceiling(arguments.qryData.recordCount/itemsPerPage)>
		<cfset pageNumber = int(startRow/itemsPerPage)+1>
		<cfset prevStart = startRow-itemsPerPage>
		<cfset nextStart = startRow+itemsPerPage>

		<cfsavecontent variable="tmpHTML">
			<style type="text/css">
				.rl_image {
					margin-right:10px;
					margin-bottom:10px;
					float:left;
					width:100px;
					height:150px;
				}
			</style>
			<cfif groupBy eq "">
				<cfoutput query="arguments.qryData" startrow="#startRow#" maxrows="#itemsPerPage#">
					<cfset href = "" />
					<cfif itemHREF neq "">
						<cfset href = replaceNoCase(itemHREF,"%id",urlEncodedFormat(arguments.qrydata.id),"ALL")>
						<cfset href = replaceNoCase(href,"%package",urlEncodedFormat(arguments.qrydata.package),"ALL")>
						<cfset href = replaceNoCase(href,"%startRow",urlEncodedFormat(startRow),"ALL")>
					<cfelse>
						<cfset href = arguments.qryData.url />
					</cfif>
					<div class="rl_image" style="float:left;">
						#renderImage(arguments.qryData.label,
										"/miniblog/" & arguments.qryData.libpath & "/" & arguments.qryData.package& "/" & arguments.qryData.href,
										href)#
						<cfif itemProperties neq "">
							<br />
							<cfif showLabel and arguments.qryData.label neq "">
								<b>#arguments.qryData.label#</b><br />
							</cfif>
							<cfloop list="#itemProperties#" index="prop">
								<strong>#prop#:</strong> #arguments.qryData[prop]#<br />
							</cfloop>
						<cfelseif arguments.qryData.label neq "" and showLabel>
							<br />
							<cfif href neq "">
								<a href="#href#">#arguments.qryData.label#</a>
							<cfelse>
								#arguments.qryData.label#
							</cfif>
							<br />
						</cfif>
					</div>
				</cfoutput>
			<cfelse>
				<cfoutput query="arguments.qryData" startrow="#startRow#" maxrows="#itemsPerPage#" group="#groupBy#">
					<b>#arguments.qrydata[groupBy]#</b><br />
					<cfoutput>
					<cfset href = "" />
					<cfif itemHREF neq "">
						<cfset href = replaceNoCase(itemHREF,"%id",urlEncodedFormat(arguments.qrydata.id),"ALL")>
						<cfset href = replaceNoCase(href,"%package",urlEncodedFormat(arguments.qrydata.package),"ALL")>
						<cfset href = replaceNoCase(href,"%startRow",urlEncodedFormat(startRow),"ALL")>
					<cfelse>
						<cfset href = arguments.qryData.url />
					</cfif>
					<div class="rl_image">
						#renderImage(arguments.qryData.label,
										arguments.qryData.href,
										href)#
						<cfif itemProperties neq "">
							<br />
							<cfif showLabel and arguments.qryData.label neq "">
								<b>#arguments.qryData.label#</b><br />
							</cfif>
							<cfloop list="#itemProperties#" index="prop">
								<strong>#prop#:</strong> #arguments.qryData[prop]#<br />
							</cfloop>
						<cfelseif arguments.qryData.label neq "" and showLabel>
							<br />
							<cfif href neq "">
								<a href="#href#">#arguments.qryData.label#</a>
							<cfelse>
								#arguments.qryData.label#
							</cfif>
							<br />
						</cfif>
					</div>
					</cfoutput>
					<br style="clear:both;" />
				</cfoutput>
			</cfif>
			<cfoutput>
				<br style="clear:both;" />
				<div class="rl_paging">
					<cfif showResultsCount>
						<b>
							#arguments.qryData.recordCount# 
							result<cfif arguments.qryData.recordCount neq 1>s</cfif> 
							found<cfif searchTerm neq ""> for '#searchTerm#'</cfif>
						</b>
					</cfif>
					<cfif pagingHREF neq "" and totalPages gt 1>
						<cfset firstPageHREF = replaceNoCase(pagingHREF,"%startRow",1,"ALL")>
						<cfset lastPageHREF = replaceNoCase(pagingHREF,"%startRow",totalPages*itemsPerPage,"ALL")>
						<cfset prevPageHREF = replaceNoCase(pagingHREF,"%startRow",prevStart,"ALL")>
						<cfset nextPageHREF = replaceNoCase(pagingHREF,"%startRow",nextStart,"ALL")>
		
						<cfif showResultsCount>
							&nbsp;&middot;&nbsp;
						</cfif>
	
						<cfif prevStart gt 0>
							<a href="#prevPageHREF#"><strong>Previous</strong></a> 
							&nbsp;&nbsp;
						</cfif>

						<cfif max(pageNumber-pagingDelta,1) neq 1>
							<a href="#firstPageHREF#">1</a> 
							...
						</cfif>
						<cfloop from="#max(pageNumber-pagingDelta,1)#" to="#min(pageNumber+pagingDelta,totalPages)#" index="i">
							<cfset pageHREF = replaceNoCase(pagingHREF,"%startRow",(i-1)*itemsPerPage+1,"ALL")>
							<cfif i neq pageNumber>
								<a href="#pageHREF#">#i#</a> 
							<cfelse>
								<b>#i#</b>
							</cfif>
							&nbsp;
						</cfloop>
						<cfif min(pageNumber+pagingDelta,totalPages) neq totalPages>
							...						
							<a href="#lastPageHREF#">#totalPages#</a> 
						</cfif>
						
						<cfif nextStart lte arguments.qryData.recordCount>
							&nbsp;&nbsp;
							<a href="#nextPageHREF#"><strong>Next</strong></a> 
						</cfif>
					</cfif>
				</div>
			</cfoutput>
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>

	<cffunction name="renderImage" access="public" returntype="string">
		<cfargument name="label" type="string" required="true">
		<cfargument name="imgHREF" type="string" required="true">
		<cfargument name="linkHREF" type="string" required="true">
		<cfscript>
			var width = getContentTag().getAttribute("width", variables.DEFAULT_WIDTH);
			var height = getContentTag().getAttribute("height", variables.DEFAULT_HEIGHT);
			var tmpHTML = "";
			var alt = arguments.label;
			
			if(alt eq "") alt = getFileFromPath(arguments.imgHREF);
			
			tmpHTML = "<img src=""#arguments.imgHREF#"" border=""0"" alt=""#htmlEditFormat(alt)#"" title=""#htmlEditFormat(alt)#""";
			
			if(width neq "") tmpHTML = tmpHTML & " width='#width#'";
			if(height neq "") tmpHTML = tmpHTML & " height='#height#'";
			tmpHTML = tmpHTML & ">";
			
			if(arguments.linkHREF neq "") tmpHTML = "<a href='#arguments.linkHREF#'>" & tmpHTML & "</a>";

			return tmpHTML;				
		</cfscript>
	</cffunction>


</cfcomponent>