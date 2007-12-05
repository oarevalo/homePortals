<!--- 
vwPageDesigner

Displays a semi wysiwyg editor to design the current page

** This file should be included from addContent.cfc

History:
5/25/06 - oarevalo - created
---->
<cfscript>
	selectTab("Page");

	aLocationTypes = oPage.getLocationTypes();
	qryLocations = oPage.getLocations();
	stLocationsByType = structNew();
	for(i=1;i lte ArrayLen(aLocationTypes);i=i+1) {
		stLocationsByType[aLocationTypes[i]] = oPage.getLocationsByType(aLocationTypes[i]);
	}
	
	numColumns = qryLocations.recordCount;
	colWidth = 150;
	if(numColumns gt 0)	colWidth = 150 / numColumns;
	
	aSkins = variables.oCatalog.getSkins();
	
	pageName = getFileFromPath(variables.oPage.getHREF());
</cfscript>

<cfoutput>
<table id="tblPageDesigner" cellspacing="0" cellpadding="0">
	<tr valign="top">
		<td colspan="2" style="padding:0px;height:90px;">
			<div class="cp_sectionBox" 
				 style="margin:0px;padding:0px;width:325px;margin-left:7px;margin-top:5px;overflow:hidden;">
				<form name="frm" method="post" action="##" style="padding:0px;margin:0px;">
				<table style="margin:5px;" cellpadding="0" cellspacing="0">
					<tr>
						<td><strong>Title:</strong> </td>
						<td colspan="2">
							<cfset tmpName = replaceNoCase(pageName,".xml","")>
							<input type="text" name="pageName" value="#tmpName#" style="width:190px;">
							<input type="button" value="Change" style="width:auto;" onclick="controlPanel.renamePage(this.form)">
						</td>
					</tr>
					<tr>
						<td style="padding-top:10px;"><strong>Skin:</strong></td>
						<td colspan="2" style="padding-top:10px;">
							<select name="skin" onchange="controlPanel.selectSkin(this.value)">
								<option value="">--- Select Skin ---</option>
								<cfloop from="1" to="#arrayLen(aSkins)#" index="i">
									<option value="#aSkins[i].href#">#aSkins[i].id#</option>
								</cfloop>
							</select>
							&nbsp;&nbsp;&nbsp;
							<a href="javascript:controlPanel.selectSkin()" style="font-weight:normal;border-bottom:1px dashed silver;">Remove Current Skin</a>
						</td>
					</tr>
				</table>
				</form>
			</div>
		</td>

		<td rowspan="3">
			<!--- Add Content --->
			<div class="cp_sectionTitle" id="cp_pd_moduleProperties_Title" 
					style="width:150px;padding:0px;margin:0px;margin-left:2px;margin-top:5px;">
				<div style="margin:2px;">
					<img src="#imgRoot#/brick_add.png" align="absmiddle"> Add Content
				</div>
			</div>
			<div class="cp_sectionBox" 
				style="margin-top:0px;width:150px;padding:0px;height:360px;margin-left:2px;margin-right:0px;border-top:0px;">
				<div id="catalogModules_BodyRegion" style="margin:5px;">
					<cfinclude template="vwCatalogModules.cfm">
				</div>
			</div>
		</td>
	</tr>
	<tr valign="top">

		<td style="height:210px;padding:0px;margin:0px;">
			<!--- layout preview --->
			<div style="font-size:11px;margin-left:7px;"><b>Layout Preview:</b></div>
			<table id="tblLayoutPreview" border="1" align="center" style="margin-left:7px;margin-right:0px;">
				
				<!--- display headers --->
				<cfset qry = stLocationsByType["header"]>
				<cfloop query="qry">
					<cfset aModules = variables.oPage.getModulesByLocation(name)>				
					<tr valign="top">
						<td colspan="#numColumns#" style="height:17px;">
							<ul id="#name#" class="layoutPreviewList">
							<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
								<cfset tmpModuleID = aModules[j].id>
								<li id="#tmpModuleID#_lp" class="layoutListItem"><div>#tmpModuleID#</div></li>
							</cfloop>
							</ul>
						</td>	
					</tr>
				</cfloop>
				
				<!--- display columns --->
				<tr valign="top">
					<cfset qry = stLocationsByType["column"]>
					<cfloop query="qry">					
						<cfset aModules = variables.oPage.getModulesByLocation(name)>
						<td>
							<ul id="#name#" class="layoutPreviewList" style="width:#colWidth#px;height:98%;">
							<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
								<cfset tmpModuleID = aModules[j].id>
								<li id="#tmpModuleID#_lp" class="layoutListItem"><div>#tmpModuleID#</div></li>
							</cfloop>
							</ul>
						</td>
					</cfloop>
				</tr>
				
				<!--- display footers --->
				<cfset qry = stLocationsByType["footer"]>
				<cfloop query="qry">
					<cfset aModules = variables.oPage.getModulesByLocation(name)>	
					<tr valign="top">
						<td colspan="#numColumns#" style="height:17px;">
							<ul id="#name#" class="layoutPreviewList">	
							<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
								<cfset tmpModuleID = aModules[j].id>
								<li id="#tmpModuleID#_lp" class="layoutListItem"><div>#tmpModuleID#</div></li>
							</cfloop>
							</ul>
						</td>	
					</tr>
				</cfloop>
			</table>			
		</td>
		<td align="right">
			<!--- module properties  --->
			<div style="font-size:11px;"><b>&nbsp;</b></div>
			<div class="cp_sectionTitle" id="cp_pd_moduleProperties_Title" 
					style="width:160px;padding:0px;margin:0px;margin-right:5px;margin-top:5px;">
				<div style="margin:2px;text-align:left;">
					<img src="#imgRoot#/brick_edit.png" align="absmiddle">
					Module Properties
				</div>
			</div>
			<div class="cp_sectionBox" 
				style="margin-top:0px;width:160px;padding:0px;height:177px;margin-right:5px;margin-top:0px;border-top:0px;">
				<div id="cp_pd_moduleProperties_BodyRegion" style="margin:2px;margin-top:5px;text-align:left;">
					<p align="center"><bR>
						Drag boxes to accomodate modules.<br>
						Click box to edit properties.
					</p>
				</div>
			</div>
		</td>
	</tr>
	

	<tr valign="bottom">
		<td colspan="2">
			<div class="cp_sectionBox" 
				 style="margin:0px;padding:0px;width:325px;margin-left:7px;margin-bottom:5px;">
				<div style="margin:4px;">
					<img src="#imgRoot#/cog.png" align="Absmiddle">
					<a href="javascript:controlPanel.getView('Events')">Events Handlers</a>
					&nbsp;&nbsp;&nbsp;
					<img src="#imgRoot#/css.png" align="Absmiddle">
					<a href="javascript:controlPanel.getView('PageCSS')">Edit StyleSheet</a>
				</div>
			</div>
		</td>
	</tr>
</cfoutput>	
</table>


<!--- reserve space to display module info --->
<div id="catalogModuleInfo_BodyRegion" 
	 style="display:none;bottom:45px;"></div>


