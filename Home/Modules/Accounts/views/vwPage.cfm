<!--- 
vwPageDesigner

Displays a semi wysiwyg editor to design the current page

** This file should be included from addContent.cfc

History:
5/25/06 - oarevalo - created
---->

<cfset initContext()>
<cfset xmlDoc = xmlParse(expandPath(this.pageURL))>
<cfset xmlSite = xmlParse(expandpath(this.siteURL))>
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
<cfset qrySkins = getSkins()>

<cfset bFound = false>
<cfset currFile = getFileFromPath(this.pageURL)>
<cfloop from="1" to="#arrayLen(xmlSite.xmlRoot.pages.xmlChildren)#" index="i">
	<cfset tmpNode = xmlSite.xmlRoot.pages.xmlChildren[i]>
	<cfset tmpPageHREF = getFileFromPath(tmpNode.xmlAttributes.href)>
	<cfif ucase(urldecode(currFile)) eq ucase(urldecode(tmpPageHREF))>
		<cfset pageAttributes = xmlSite.xmlRoot.pages.xmlChildren[i].xmlAttributes>
		<cfparam name="pageAttributes.private" default="false">
		<cfparam name="pageAttributes.default" default="false">
		<cfset bFound = true>
		<cfbreak>
	</cfif>
</cfloop>

<cfif Not bFound>
	<cfthrow message="Page #currFile# not found in local site.xml">
</cfif>
<cfoutput>

<table id="tblPageDesigner" cellspacing="0" cellpadding="0">
	<tr valign="top">
		<td rowspan="2">
			<div class="cp_sectionTitle" id="cp_pd_moduleProperties_Title" 
					style="width:150px;padding:0px;margin:0px;margin-bottom:2px;margin-left:2px;margin-top:5px;">
				<div style="margin:2px;">Add Content</div>
			</div>
			<div class="cp_sectionBox" 
				style="margin-top:0px;width:150px;padding:0px;height:360px;margin-left:2px;margin-right:0px;">

				<cfif arrayLen(aCatalogs) gt 0>
					<div style="margin:5px;">
						<select name="selCatalog" onchange="controlPanel.getCatalogModules(this.value)" style="width:110px;">
							<cfloop from="1" to="#arrayLen(aCatalogs)#" index="i">
								<option value="#aCatalogs[i].href#">"#aCatalogs[i].name#" catalog</option>
							</cfloop>
						</select>
						<a href="javascript:;" onclick="alert('Select the catalog from which to add the module.')"><img src="#this.accountsRoot#/default/info.gif" border="0" align="absmiddle" /></a>
					</div>
				<cfelseif arrayLen(aCatalogs) eq 1>
					<input type="hidden" name="selCatalog" value="#aCatalogs[1].href#">
				</cfif>	

				<!--- display catalog modules --->
				<div id="catalogModules_BodyRegion" style="margin:5px;">
				</div>

			</div>
		</td>

		<td style="height:210px;padding:0px;margin:0px;">
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
								<li id="#tmpModuleID#"><div>#tmpModuleID#</div></li>
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
								<li id="#tmpModuleID#"><div>#tmpModuleID#</div></li>
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
								<li id="#tmpModuleID#"><div>#tmpModuleID#</div></li>
							</cfloop>
							</ul>
						</td>	
					</tr>
				</cfloop>
			</table>			
		</td>
		<td>
			<!--- module properties  --->
			<div class="cp_sectionTitle" id="cp_pd_moduleProperties_Title" 
					style="width:140px;padding:0px;margin:0px;margin-bottom:2px;margin-left:2px;margin-top:5px;">
				<div style="margin:2px;">Module Properties</div>
			</div>
			<div class="cp_sectionBox" 
				style="margin-top:0px;width:140px;padding:0px;height:174px;margin-left:2px;margin-right:0px;">
				<div id="cp_pd_moduleProperties_BodyRegion" style="margin:2px;">
					<p align="center"><bR>
						Drag boxes to accomodate modules.<br>
						Click box to edit properties.
					</p>
				</div>
			</div>
		</td>
	</tr>
</cfoutput>	
	
	<tr valign="top">
		<td colspan="2">
			<div class="cp_sectionTitle" style="width:314px;padding:0px;margin:0px;margin-left:7px;">
				<div style="margin:2px;">Page Properties</div>
			</div>
			<div class="cp_sectionBox" 
				 style="margin:0px;padding:0px;height:155px;width:314px;margin-left:7px;margin-top:2px;">
				<form name="frm" action="##" method="post" style="margin:0px;padding:0px;">
					<table style="width:310px;margin-top:5px;margin-left:2px;" cellpadding="0" cellspacing="0">
						<tr>
							<td><strong>Title:</strong> </td>
							<td colspan="2">
								<cfset tmpName = replaceNoCase(this.pageName,".xml","")>
								<cfoutput>
									<input type="text" name="pageName" value="#tmpName#" style="width:190px;">
									<input type="button" value="Change" style="width:auto;" onclick="controlPanel.renamePage(this.form)">
								</cfoutput>
							</td>
						</tr>
						<tr>
							<td style="padding-top:10px;"><strong>Skin:</strong></td>
							<td colspan="2" style="padding-top:10px;">
								<select name="skin" onchange="controlPanel.selectSkin(this.value)">
									<option value="">--- Select Skin ---</option>
									<option value="">-------------------------</option>
									<option value="-1">Remove Current Skin</option>
									<option value="">-------------------------</option>
									<cfif arrayLen(aCatalogs) gt 1>
										<cfoutput query="qrySkins" group="catalogName">
											<optgroup label="#catalogName#">
												<cfoutput>
													<option value="#href#">#id#</option>
												</cfoutput>
											</optgroup>
										</cfoutput>
									<cfelse>
										<cfoutput query="qrySkins">
											<option value="#href#">#id#</option>
										</cfoutput>
									</cfif>
								</select>
								&nbsp;&nbsp;&nbsp;
								[<a href="javascript:controlPanel.getView('PageCSS')">StyleSheet Editor</a>]
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
							<td colspan="2" style="padding-top:10px;">
								<input type="checkbox" name="isPrivate" value="1" style="width:auto;border:0px;" 
										<cfif pageAttributes.private>checked</cfif>
										onclick="controlPanel.changePrivate(this.form)" /> Private Page
								&nbsp;&nbsp;&nbsp;
								<input type="checkbox" name="isDefault" value="1" style="width:auto;border:0px;" 
										<cfif pageAttributes.default>checked</cfif>
										onclick="controlPanel.changeDefault(this.form)" />	Default Page
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
							<td style="padding-top:10px;"><a href="javascript:controlPanel.getView('Advanced')">Advanced Settings...</a></td>
						</tr>
					</table>
				</form>
			</div>		
			
		</td>
	</tr>
</table>


<!--- reserve space to display module info --->
<div id="catalogModuleInfo_BodyRegion" style="display:none;"></div>


