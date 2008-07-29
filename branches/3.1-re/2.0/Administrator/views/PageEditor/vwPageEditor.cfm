<cfscript>
	oSite = getValue("oSite");
	oPage = getValue("oPage");
	oCatalog = getValue("oCatalog");

	aPages = oSite.getPages();
	owner = oSite.getOwner();
	title = oPage.getPageTitle();
	
	aLocationTypes = oPage.getLocationTypes();
	qryLocations = oPage.getLocations();
	stLocationsByType = structNew();
	for(i=1;i lte ArrayLen(aLocationTypes);i=i+1) {
		stLocationsByType[aLocationTypes[i]] = oPage.getLocationsByType(aLocationTypes[i]);
	}
	
	numColumns = qryLocations.recordCount;
	colWidth = 200;
	if(numColumns gt 0)	colWidth = 200 / numColumns;

	oAccounts = oSite.getAccount();
	stAccountInfo = oAccounts.getConfig();
	
	thisPageHREF = oPage.getHREF();
	
	aSkins = oCatalog.getSkins();
	aPageTemplates = oCatalog.getPageTemplates();
	aStyles = oPage.getStylesheets();
</cfscript>


<cfsavecontent variable="tmpHTML">
	<script type="text/javascript" src="includes/prototype-1.4.0.js"></script>
	<script type="text/javascript" src="includes/coordinates.js"></script>
	<script type="text/javascript" src="includes/drag.js"></script>
	<script type="text/javascript" src="includes/dragdrop.js"></script>
	<script>
		window.onload = initLayoutPreview;
	</script>
</cfsavecontent>
<cfhtmlhead text="#tmpHTML#">


<cfoutput>

<h2>Accounts > #owner# > Page Editor</h2>

<table id="tblPageDesigner" cellspacing="0" cellpadding="0">
	<tr valign="top">
		<td colspan="3" style="padding:0px;">
			<div class="cp_sectionBox" 
				 style="margin:0px;padding:0px;width:630px;margin-top:5px;overflow:hidden;">
				<table style="margin:5px;width:620px;" cellpadding="0" cellspacing="0">
					<tr>
						<td>
							<form name="frm" method="post" action="index.cfm" style="padding:0px;margin:0px;">
								<strong>Title:</strong> 
								<input type="hidden" name="event" value="ehPage.doRenamePage">
								<input type="text" name="pageTitle" value="#title#" style="width:180px;">
								<input type="submit" value="Change" style="width:auto;">
							</form>
						</td>

						<td align="center">
							<strong>Skin:</strong>
							<select name="skin" style="width:120px;" onchange="document.location='?event=ehPage.doApplySkin&href='+this.value">
								<option value="">--- Select Skin ---</option>
								<option value="">--- None ---</option>
							
								<cfloop from="1" to="#arrayLen(aSkins)#" index="j">
									<cfset bSkinFound = false>
									<cfloop from="1" to="#arrayLen(aStyles)#" index="k">
										<cfif aSkins[j].href eq aStyles[k]>
											<cfset bSkinFound = true>
										</cfif>
									</cfloop>
									<option value="#aSkins[j].href#"
											<cfif bSkinFound>selected</cfif>>#aSkins[j].id#</option>
								</cfloop>
							</select>
						</td>
						<td align="right">
							<strong>Page:</strong>
							<select name="page" style="width:120px;" onchange="document.location='?event=ehPage.doLoadPage&href=#stAccountInfo.accountsRoot#/'+this.value">
								<cfloop from="1" to="#arrayLen(aPages)#" index="i">
									<cfset pageAttributes = aPages[i]>
									<cfset pageHREF = "/#owner#/layouts/#pageAttributes.href#">
									<option value="#pageHREF#"
											<cfif getFileFromPath(pageHREF) eq getFileFromPath(thisPageHREF)>selected</cfif>>#pageAttributes.href#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	<tr valign="top">
	
		<td rowspan="2">
			<!--- Add Content --->
			<div class="cp_sectionTitle" id="cp_pd_moduleProperties_Title" 
					style="width:150px;padding:0px;margin:0px;margin-top:5px;">
				<div style="margin:2px;">
					<img src="images/brick_add.png" align="absmiddle"> Add Content
				</div>
			</div>
			<div class="cp_sectionBox" 
				style="margin-top:0px;width:150px;padding:0px;height:422px;margin-right:0px;margin-left:0px;border-top:0px;">
				<div id="catalogModules_BodyRegion" style="margin:5px;">

					<cfset aModules = oCatalog.getModules()>
					
					<!--- put modules into a query and sort them --->
					<cfset lstModules = "">
					<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
						<cfset lstModules = ListAppend(lstModules, aModules[j].id)>
					</cfloop>
					<cfset lstModules = ListSort(lstModules, "textnocase")>
			
					<cfloop from="1" to="#ListLen(lstModules)#" index="j">
						<cfset tmpItem = ListGetAt(lstModules, j)>
						<img src="images/add.png" align="absmiddle">
						<a href="javascript:addModule('#jsstringformat(tmpItem)#')" 
							class="cpListLink" 
							style="font-weight:normal;" 
							>#tmpItem#</a><br>
					</cfloop>
					<br>

				</div>
			</div>
		</td>

		<td style="padding:0px;margin:0px;" align="Center">
			<!--- layout preview --->
			<div style="text-align:left;font-size:11px;margin:5px;margin-left:30px;margin-top:30px;"><b>Layout Preview:</b></div>
			
			<div style="background-color:##ebebeb;height:300px;margin:10px;border:1px dashed ##000;margin-right:0px;margin-top:5px;margin-left:30px;">
			
			<table id="tblLayoutPreview" border="1" align="center" style="margin:0px;margin-top:10px;">
				
				<!--- display headers --->
				<cfset qry = stLocationsByType["header"]>
				<cfloop query="qry">
					<cfset aModules = oPage.getModulesByLocation(name)>
					<tr valign="top">
						<td colspan="#numColumns#" style="height:17px;">
							<div class="layoutSectionLabel" style="display:none;" id="#name#_title">
								<table style="width:100%;" border="0">
									<td style="border:0px !important;" align="left">
										<a href="javascript:document.location='?event=ehPage.dspPageEditor&editLayoutSection=#name#'">#name#</a>
									</td>
									<td align="right" style="border:0px !important;">
										<a href="javascript:document.location='?event=ehPage.doDeleteLayoutLocation&locationName=#name#'"><img src="images/cross.png" align="absmiddle" border="0"></a>
									</td>
								</table>
							</div>
							<ul id="#name#" class="layoutPreviewList">
							<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
								<cfset tmpModuleID = aModules[j].id>
								<li id="#tmpModuleID#" class="layoutListItem"><div>#tmpModuleID#</div></li>
							</cfloop>
							</ul>
						</td>	
					</tr>
				</cfloop>
				
				<!--- display columns --->
				<tr valign="top">
					<cfset qry = stLocationsByType["column"]>
					<cfloop query="qry">
						<cfset aModules = oPage.getModulesByLocation(name)>
						<td style="width:#colWidth#px;">
							<div class="layoutSectionLabel" style="display:none;" id="#name#_title">
								<table style="width:100%;" border="0">
									<td style="border:0px !important;" align="left">
										<a href="javascript:document.location='?event=ehPage.dspPageEditor&editLayoutSection=#name#'">#name#</a>
									</td>
									<td align="right" style="border:0px !important;">
										<a href="javascript:document.location='?event=ehPage.doDeleteLayoutLocation&locationName=#name#'"><img src="images/cross.png" align="absmiddle" border="0"></a>
									</td>
								</table>
							</div>
							<ul id="#name#" class="layoutPreviewList">
							<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
								<cfset tmpModuleID = aModules[j].id>
								<li id="#tmpModuleID#" class="layoutListItem"><div>#tmpModuleID#</div></li>
							</cfloop>
							</ul>
						</td>
					</cfloop>
				</tr>
				
				<!--- display footers --->
				<cfset qry = stLocationsByType["footer"]>
				<cfloop query="qry">
					<cfset aModules = oPage.getModulesByLocation(name)>
					<tr valign="top">
						<td colspan="#numColumns#" style="height:17px;">
							<div class="layoutSectionLabel" style="display:none;" id="#name#_title">
								<table style="width:100%;" border="0">
									<td style="border:0px !important;" align="left">
										<a href="javascript:document.location='?event=ehPage.dspPageEditor&editLayoutSection=#name#'">#name#</a>
									</td>
									<td align="right" style="border:0px !important;">
										<a href="javascript:document.location='?event=ehPage.doDeleteLayoutLocation&locationName=#name#'"><img src="images/cross.png" align="absmiddle" border="0"></a>
									</td>
								</table>
							</div>
							<ul id="#name#" class="layoutPreviewList">	
							<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
								<cfset tmpModuleID = aModules[j].id>
								<li id="#tmpModuleID#" class="layoutListItem"><div>#tmpModuleID#</div></li>
							</cfloop>
							</ul>
						</td>	
					</tr>
				</cfloop>
			</table>
			<input type="button" name="btnUpdateModuleOrder" id="btnUpdateModuleOrder"
					onclick="updateModuleOrder()"
					value="Apply Changes"
					style="display:none;margin-top:5px;">
			</div>
			
			<p align="center" style="font-size:9px;">Double-click on module to view/edit properties.</p>
		</td>
		<td align="right">
			<!--- module properties --->
			<div class="cp_sectionTitle" 
					style="width:190px;padding:0px;margin:0px;margin-top:5px;">
				<div style="margin:2px;text-align:left;">
					<img src="images/brick_edit.png" align="absmiddle">
					Module Properties
				</div>
			</div>
			<div class="cp_sectionBox" 
				style="margin-top:0px;width:190px;padding:0px;height:100px;margin-top:0px;margin-right:0px;border-top:0px;">
				<div id="moduleProperties" style="margin:0px;text-align:left;">
					<p align="center"><bR>
						Drag boxes to accomodate modules.<br>
						Click box to edit properties.
					</p>
				</div>
			</div>

			<!--- Page Templates --->
			<div class="cp_sectionTitle" 
					style="width:190px;padding:0px;margin:0px;margin-top:5px;">
				<div style="margin:2px;text-align:left;">
					&nbsp;Page Templates
				</div>
			</div>
			<div class="cp_sectionBox" 
				style="margin-top:0px;width:190px;padding:0px;height:100px;margin-top:0px;margin-right:0px;border-top:0px;">
				<div id="moduleProperties" style="margin:0px;text-align:left;">
					<p align="center">
						Select a page template to apply to this page:<br><br>
						<select name="pageTemplate" style="width:170px;" onchange="document.location='?event=ehPage.doApplyPageTemplate&href='+this.value">
							<option value="">--- None ---</option>
							<cfloop from="1" to="#arrayLen(aPageTemplates)#" index="j">
								<option value="#aPageTemplates[j].href#">#aPageTemplates[j].id#</option>
							</cfloop>
						</select>
					</p>
				</div>
			</div>
			
			<!--- Layout Sections --->
			<div class="cp_sectionTitle" 
					style="width:190px;padding:0px;margin:0px;margin-top:5px;">
				<div style="margin:2px;text-align:left;">
					&nbsp;Layout Sections
				</div>
			</div>
			<div class="cp_sectionBox" 
				style="margin-top:0px;width:190px;padding:0px;height:130px;margin-top:0px;margin-right:0px;border-top:0px;">
				<div id="layoutSections" style="margin:5px;margin-top:5px;text-align:left;">
					<cfparam name="editLayoutSection" default="">

					<cfif editLayoutSection eq "">
						<div style="border:1px solid silver;background-color:##fefcd8;">
							<div style="margin:2px;">
								Add Section:<br>
								<a href="?event=ehPage.doAddLayoutLocation&locationType=header">Header</a>	
								&nbsp;&nbsp;<a href="?event=ehPage.doAddLayoutLocation&locationType=column">Column</a>			
								&nbsp;&nbsp;<a href="?event=ehPage.doAddLayoutLocation&locationType=footer">Footer</a>			
							</div>
						</div>
						<div style="border:1px solid silver;background-color:##fefcd8;margin-top:5px;">
							<div style="margin:2px;">
								Edit/Delete Section:<br>
								<select name="layoutSection" 
										style="width:140px;"
										onchange="document.location='?event=ehPage.dspPageEditor&editLayoutSection='+this.value">
									<option value=""></option>
									<cfloop query="qryLocations">
										<option value="#qryLocations.name#"
												<cfif qryLocations.name eq editLayoutSection>selected</cfif>
												>#qryLocations.name#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div style="border:1px solid silver;background-color:##fefcd8;margin-top:5px;">
							<div style="margin:2px;font-size:11px;">
								<input type="checkbox" name="chkShowLayoutSectionTitles" 
										onclick="showLayoutSectionTitles(this.checked)" value="1">
								Show Section Titles
							</div>
						</div>
					<cfelse>
						<cfquery name="qryThisLocation" dbtype="query">
							SELECT *
								FROM qryLocations
								WHERE name = <Cfqueryparam value="#editLayoutSection#" cfsqltype="cf_sql_varchar">
						</cfquery>

						<div style="border:1px solid silver;background-color:##fefcd8;margin-top:5px;">
							<div style="margin:2px;">
								<form name="frmEditLayoutSection" method="post" action="index.cfm">
									<table>
										<tr>
											<td>Name:</td>
											<td><input type="text" name="locationNewName" value="#qryThisLocation.name#" style="width:90px;"></td>
										</tr>
										<tr>
											<td>Type:</td>
											<td>
												<select name="locationType" style="width:90px;">
													<cfloop from="1" to="#arrayLen(aLocationTypes)#" index="i">
														<option value="#aLocationTypes[i]#"
																<cfif aLocationTypes[i] eq qryThisLocation.type>selected</cfif>
																>#aLocationTypes[i]#</option>
													</cfloop>
												</select>
										</tr>
										<tr>
											<td>Class:</td>
											<td><input type="text" name="locationClass" value="#qryThisLocation.class#" style="width:90px;"></td>
										</tr>
									</table>
									<p align="center">
										<input type="hidden" name="event" value="ehPage.doSaveLayoutLocation">
										<input type="hidden" name="locationOriginalName" value="#qryThisLocation.name#">
										<input type="submit" name="btnSave" value="Save">
										<input type="button" name="btnDelete" value="Delete" onclick="document.location='?event=ehPage.doDeleteLayoutLocation&locationName=#qryThisLocation.name#'">
										<input type="button" name="btnCancel" value="Cancel" onclick="document.location='?event=ehPage.dspPageEditor'">
									</p>
								</form>
							</div>
						</div>
					</cfif>

					<table>
					</table>
				</div>
			</div>
		</td>
	</tr>
	

	<tr valign="bottom">
		<td colspan="2">
			<div class="cp_sectionBox" 
				 style="margin:0px;padding:0px;width:470px;margin-left:7px;margin-bottom:5px;margin-right:0px;">
				<div style="margin:4px;">
					<img src="images/animLoading.gif" id="loadingImage" style="display:none;float:right;">

					<img src="images/cog.png" align="Absmiddle">
					<a href="?event=ehPage.dspEventHandlers">Event Handlers</a>
					&nbsp;&nbsp;&nbsp;
					<img src="images/xml.gif" align="Absmiddle">
					<a href="?event=ehPage.dspEditXML">Edit XML</a>
					&nbsp;&nbsp;&nbsp;
					<img src="images/css.png" align="Absmiddle">
					<a href="?event=ehPage.dspEditCSS">Edit StyleSheet</a>
					&nbsp;&nbsp;&nbsp;
					<img src="images/page_link.png" align="Absmiddle">
					<a href="../?currentHome=#thisPageHREF#&refresh=true" target="previewPage">Preview</a>

				</div>
			</div>
		</td>
	</tr>
</cfoutput>	
</table>

<p>
	<input type="button" 
			name="btnCancel" 
			value="Return To Site Manager" 
			onClick="document.location='?event=ehSite.dspSiteManager'">
</p>
