<cfprocessingdirective pageencoding="utf-8">
<cfparam name="searchTerm" default="">

<cfset siteOwner = variables.oPage.getOwner()>
<cfset qryResources = getResourcesForAccount("content")>

<cfquery name="qryMyResources" dbtype="query">
	SELECT *
		FROM qryResources
		WHERE owner = <cfqueryparam cfsqltype="cf_sql_varchar" value="#siteOwner#">
		<cfif searchTerm neq "">
			 AND (upper(id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">
				OR upper(package) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%"> )
		</cfif>
		ORDER BY package, id
</cfquery>

<cfquery name="qryResources" dbtype="query">
	SELECT *
		FROM qryResources
		WHERE owner <> <cfqueryparam cfsqltype="cf_sql_varchar" value="#siteOwner#">
		<cfif searchTerm neq "">
			 AND ( upper(id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">
				OR upper(package) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">  )
		</cfif>
		ORDER BY package, id
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
	#rd_packagesArea {
		margin:10px;
		border:1px solid #ccc;
		height:280px;
		overflow:auto;
		background-color:#fff;
		line-height:18px;
		margin-top:0px;
	}
	.rd_packageTitle {
		font-weight:bold;
		background-color:#ebebeb;
		padding:0px;
		border-bottom:1px solid #ccc;
		border-top:1px solid #fff;
		font-size:10px;
		line-height:11px;
	}
	.rd_packageTitle a {
		padding:3px;
		display:block;
		outline:none;
	}
	.rd_packageTitle a:link, .rd_packageTitle a:active, .rd_packageTitle a:visited {
		background-color:#ebebeb;
	}
	.rd_packageTitle a:hover {
		background-color:#f5f5f5;
		text-decoration:none;
	}
	#rd_footer {
		margin:10px;
		border:1px solid #ccc;
		background-color:#ebebeb;
	}
</style>



<cfset setControlPanelTitle("Content Directory","page_white_text")>

<div class="cp_sectionBox" 
	 style="padding:0px;margin:0px;width:475px;margin:10px;">
	<div style="margin:4px;">
		Select from the directory below the content element you wish to add to your page.
	</div>
</div>

<cfoutput>
	<div id="rd_searchBar">
		<div style="float:right;">
			<input type="text" name="txtSearch" id="h_txtSearchFeed" value="#searchTerm#">
			<input type="button" name="btnSearch" value="Search" onclick="controlPanel.getView('Content',{searchTerm:$('h_txtSearchFeed').value})">
		</div>
		Click on category to view available content
	</div>
</cfoutput>


<div id="rd_packagesArea">
	<div class="rd_packageTitle" style="color:#990000;">
		<cfoutput><a href="##" onclick="Element.toggle('cp_feedGroup0');return false;" style="color:##990000">&raquo; My Content (#qryMyResources.recordCount#)</a></cfoutput>
				
	</div>
	<div <cfif searchTerm eq "">style="display:none;"</cfif> id="cp_feedGroup0">
		<div style="background-color:#ffffcc;padding:3px;font-size:10px;text-align:center;">
			<cfoutput>
				<img src="#variables.imgRoot#/world.png" align="absmiddle"> 
				<a href="##" onclick="controlPanel.getView('Sharing',{resourceType:'content'})" style="color:##333;">Click here to modify sharing settings for your content</a>
			</cfoutput>
		</div>	

		<table style="margin:0px;width:100%;">
			<cfoutput query="qryMyResources">
				<tr valign="top" style="border-bottom:1px solid ##f5f5f5">
					<td style="padding-left:5px;" width="150">
						<a href="##" 
							onclick="controlPanel.addContent('#jsstringFormat(qryMyResources.id)#')" 
							style="color:##333;">#qryMyResources.id#</a>
					</td>
					<td style="font-size:10px;color:##666;">
						<a href="##"
							onclick="controlPanel.removeFromMyContent('#jsstringFormat(qryMyResources.id)#')"><img src="/Home/Modules/Accounts/images/waste_small.gif"
							 alt="Remove from my feeds" title="Remove from my feeds" 
							 align="right" width="14" height="14" border="0" /></a>
						#qryMyResources.description#
						<div>
							<b>Shared With: </b> <a href="##" onclick="controlPanel.getView('Sharing',{resourceType:'content'})" style="color:##333;font-size:10px;">#replaceList(qryMyResources.access,"general,friend,owner","Everyone,Friends,Nobody")#</a>
						</div>
					</td>
				</tr>
			</cfoutput>
			<tr><td colspan="2">&nbsp;</td></tr>
		</table>
	</div>

	<cfoutput query="qryResources" group="package">
		<div class="rd_packageTitle">
			<a href="##" onclick="Element.toggle('cp_feedGroup#qryResources.currentRow#');return false;" style="color:##333">&raquo; #qryResources.package#</a>
		</div>
		<div <cfif searchTerm eq "">style="display:none;"</cfif> id="cp_feedGroup#qryResources.currentRow#"> 
			<table style="margin:0px;width:100%;">
				<cfoutput>
				<tr valign="top" style="border-bottom:1px solid ##f5f5f5">
					<td style="padding-left:5px;" width="150">
						<a href="##" 
							onclick="controlPanel.addContent('#jsstringFormat(qryResources.id)#')" 
							style="color:##333;">#qryResources.id#</a>
					</td>
					<td style="font-size:10px;color:##666;">
						#qryResources.description#
					</td>
				</tr>
				</cfoutput>
				<tr><td colspan="2">&nbsp;</td></tr>
			</table>
		</div>
	</cfoutput>
</div>

<fieldset id="rd_footer">
	<input type="button" name="btnSave" value="Create Custom Content" onclick="controlPanel.getView('CreateContentResource')"><br />
</fieldset>


