<!--- 
vwPageDesigner

Displays a semi wysiwyg editor to design the current page

** This file should be included from addContent.cfc

History:
5/25/06 - oarevalo - created
---->

<cfset initContext()>
<cfset xmlDoc = objHomePortals.readPage(this.pageURL)>
<cfset aLocations_headers =  xmlSearch(xmlDoc,"//layout/location[@type='header']")>
<cfset aLocations_columns =  xmlSearch(xmlDoc,"//layout/location[@type='column']")>
<cfset aLocations_footers =  xmlSearch(xmlDoc,"//layout/location[@type='footer']")>

<cfset aLocations = ArrayNew(1)>
<cfset ArrayAppend(aLocations,aLocations_headers)>
<cfset ArrayAppend(aLocations,aLocations_columns)>
<cfset ArrayAppend(aLocations,aLocations_footers)>

<cfset numColumns = arrayLen(aLocations_columns)>
<cfset colWidth = 150 / numColumns>

<cfset aCatalogs = getCatalogs()>

<style type="text/css">
	#tblPageDesigner  form {
		margin:0px;
		padding:2px;
	}
	#tblLayoutPreview {
		border-collapse:collapse;
		height:200px;
		width:150px !important;
		background-color:#ffffff;
		margin-top:5px;
	}
	#tblLayoutPreview td {
		padding:0px;
		margin:0px;
		width:auto;
	}
	ul.layoutPreviewList li {
		position: relative;
	}
	ul.layoutPreviewList {
		list-style-type: none;
		padding: 2px;
		margin: 0px;
		font-size: 9px;
		font-family: Arial, sans-serif;
		min-height:17px;
	}
	ul.layoutPreviewList li {
		cursor:move;
		margin-bottom: 2px;
		padding: 2px 2px;
		border: 1px solid #ccc;
		background-color: #eee;
		width:39px;;
		overflow:hidden;
	}
</style>

<cfoutput>

<table id="tblPageDesigner" cellspacing="0" cellpadding="0" style="width:340px;">
	<tr valign="top">
		<td>
			<!--- layout preview --->
			<table id="tblLayoutPreview" border="1" align="center">
				
				<!--- display headers --->
				<cfloop from="1" to="#arrayLen(aLocations_headers)#" index="i">
					<cfset tmpLocName = aLocations_headers[i].xmlAttributes.name>
					<cfset aModules = xmlSearch(xmlDoc,"//modules/module[@location='#tmpLocName#']")>
					<tr valign="top">
						<td colspan="#numColumns#" style="height:17px;">
							<ul id="#tmpLocName#" class="layoutPreviewList">
							<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
								<cfset tmpModuleID = aModules[j].xmlattributes.id>
								<li id="#tmpModuleID#">#tmpModuleID#</li>
							</cfloop>
							</ul>
						</td>	
					</tr>
				</cfloop>
				
				<!--- display columns --->
				<tr valign="top">
					<cfloop from="1" to="#arrayLen(aLocations_columns)#" index="i">
						<cfset tmpLocName = aLocations_columns[i].xmlAttributes.name>
						<cfset aModules = xmlSearch(xmlDoc,"//modules/module[@location='#tmpLocName#']")>
						<td>
							<ul id="#tmpLocName#" class="layoutPreviewList" style="width:#colWidth#px;height:98%;">
							<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
								<cfset tmpModuleID = aModules[j].xmlattributes.id>
								<li id="#tmpModuleID#">#tmpModuleID#</li>
							</cfloop>
							</ul>
						</td>
					</cfloop>
				</tr>
				
				<!--- display footers --->
				<cfloop from="1" to="#arrayLen(aLocations_footers)#" index="i">
					<cfset tmpLocName = aLocations_footers[i].xmlAttributes.name>
					<cfset aModules = xmlSearch(xmlDoc,"//modules/module[@location='#tmpLocName#']")>
					<tr valign="top">
						<td colspan="#numColumns#" style="height:17px;">
							<ul id="#tmpLocName#" class="layoutPreviewList">	
							<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
								<cfset tmpModuleID = aModules[j].xmlattributes.id>
								<li id="#tmpModuleID#">#tmpModuleID#</li>
							</cfloop>
							</ul>
						</td>	
					</tr>
				</cfloop>
			</table>			
		</td>
		<td width="190">
			<!--- module properties --->
			<div class="cp_sectionTitle" id="cp_pd_moduleProperties_Title">Module Properties</div>
			<div class="cp_sectionBox" style="margin-top:0px;height:170px;" id="cp_pd_moduleProperties_BodyRegion">
				<p align="center">
					Drag boxes to accomodate modules.<br>
					Click box to edit properties.
				</p>
			</div>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!--- content catalog --->
			<div class="cp_sectionTitle" id="cp_pd_addContentMenu_Title" style="width:100%;">
				<table cellpadding="0" cellspacing="0" style="padding:0px;margin:0px;">
					<tr>
						<td><strong>Add Content</strong></td>
						<td width="152" align="right">
							<!--- Display menu with available catalogs --->
							<cfif arrayLen(aCatalogs) gt 1>
								<select name="selCatalog" onchange="controlPanel.getCatalogModules(this.value)" style="width:130px;">
									<cfloop from="1" to="#arrayLen(aCatalogs)#" index="i">
										<option value="#aCatalogs[i].href#">"#aCatalogs[i].name#" catalog</option>
									</cfloop>
								</select>
								<a href="javascript:;" onclick="alert('Select the catalog from which to add the module,\n or select Add New to enter a new catalog.')"><img src="#this.accountsRoot#/default/info.gif" border="0" align="absmiddle" /></a>
							<cfelseif arrayLen(aCatalogs) eq 1>
								<input type="hidden" name="selCatalog" value="#aCatalogs[1].href#">
							</cfif>	
						</td>
					</tr>
				</table>
			</div>
			<div class="cp_sectionBox" style="height:130px;margin-top:0px;width:100%;" id="cp_pd_addContentMenu_BodyRegion">
				<!--- display catalog modules --->
				<div id="catalogModules_BodyRegion"></div>
				
				<!--- reserve space to display module info --->
				<div id="catalogModuleInfo_BodyRegion" style="display:none;"></div>
			</div>
		</td>
	</tr>
</table>

</cfoutput>
