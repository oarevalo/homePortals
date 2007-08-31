<cfprocessingdirective pageencoding="utf-8">
<cfparam name="searchTerm" default="">

<cfset siteOwner = variables.oPage.getOwner()>
<cfset qryResources = getResourcesForAccount("content")>

<!--- order resources --->
<cfquery name="qryResources" dbtype="query">
	SELECT *
		FROM qryResources
		<cfif searchTerm neq "">
			WHERE  upper(id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">
					OR upper(package) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">  
					OR upper(name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">  
		</cfif>
		ORDER BY package, name
</cfquery>

<!--- get owner's resources --->
<cfquery name="qryMyResources" dbtype="query">
	SELECT *
		FROM qryResources
		WHERE owner = <cfqueryparam cfsqltype="cf_sql_varchar" value="#siteOwner#">
</cfquery>


<!---- Styles --->
<style type="text/css">
	#rd_searchBar {
		font-size:10px;
		margin:10px;
	}
	#rd_searchBar input {
		font-size:10px;
	}
	#rd_footer {
		margin:10px;
		border:1px solid #ccc;
		background-color:#ebebeb;
	}
</style>



<cfset setControlPanelTitle("Content Directory","page_white_text")>

<cfoutput>
	<div id="rd_searchBar">
		<div style="float:right;">
			<input type="text" name="txtSearch" id="h_txtSearchFeed" value="#searchTerm#">
			<input type="button" name="btnSearch" value="Search" onclick="controlPanel.getView('Content',{searchTerm:$('h_txtSearchFeed').value})">
		</div>
		Click on category to view available content
	</div>
</cfoutput>

<div style="width:490px;margin-top:5px;">
	<div style="width:150px;height:320px;border:1px solid silver;float:left;margin-left:5px;background-color:#fff;overflow:auto;">

		<div style="margin:3px;line-height:16px;font-size:11px;">
			<div class="rd_packageTitle" style="color:#990000;">
				<cfoutput><a href="##" onclick="Element.toggle('cp_feedGroup0');return false;" style="color:##990000;font-weight:bold;">&raquo; My Content (#qryMyResources.recordCount#)</a></cfoutput>
			</div>
			<div id="cp_feedGroup0" style="display:none;margin-left:10px;margin-bottom:8px;">
				<cfoutput query="qryMyResources">
					<cfif qryMyresources.name eq "">
						<cfset tmpName = qryMyResources.id>
					<cfelse>
						<cfset tmpName = qryMyResources.name>
					</cfif>
					<a href="##" 
						onclick="controlPanel.getPartialView('ContentInfo',{resourceID:'#jsstringFormat(qryMyResources.id)#'},'cp_resourceInfo')" 
						style="color:##333;margin-bottom:5px;font-size:10px;line-height:11px;">#tmpName#</a><br>
				</cfoutput>
			</div>
		
			<cfoutput query="qryResources" group="package">
				<cfif qryResources.owner neq siteOwner>
					<div class="rd_packageTitle">
						<a href="##" onclick="Element.toggle('cp_feedGroup#qryResources.currentRow#');return false;" style="color:##333;font-weight:bold;">&raquo; #qryResources.package#</a>
					</div>
					<div style="display:none;margin-left:10px;margin-bottom:8px;" id="cp_feedGroup#qryResources.currentRow#"> 
						<cfoutput>
							<cfif qryResources.name eq "">
								<cfset tmpName = qryResources.id>
							<cfelse>
								<cfset tmpName = qryResources.name>
							</cfif>
							<a href="##" 
								onclick="controlPanel.getPartialView('ContentInfo',{resourceID:'#jsstringFormat(qryResources.id)#'},'cp_resourceInfo')" 
								style="color:##333;margin-bottom:5px;font-size:10px;line-height:11px;white-space:nowrap;">#tmpName#</a><br>
						</cfoutput>
					</div>
				</cfif>
			</cfoutput>
		</div>

	</div>
	<div style="width:320px;height:320px;border:1px solid silver;margin-left:160px;background-color:#fff;">
		<div id="cp_resourceInfo_BodyRegion" style="margin:10px;line-height:18px;font-size:12px;">	
			Select from the directory the content element you wish to add to your page.
		</div>
	</div>
</div>
<br style="clear:both;" />
<fieldset id="rd_footer">
	<input type="button" name="btnSave" value="Create Custom Content" onclick="controlPanel.getView('CreateContentResource')"><br />
</fieldset>


