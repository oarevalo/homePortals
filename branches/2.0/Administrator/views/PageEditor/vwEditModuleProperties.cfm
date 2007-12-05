<cfscript>
	oSite = getValue("oSite");
	oPage = getValue("oPage");
	thisModule = getValue("stModule");
	thisModuleInfo = getValue("xmlModuleInfo",0);

	lstAttribs = "Name,location,id,Title,Container,Output,Display,ShowPrint,style";
	lstAllAttribs = structKeyList(thisModule);
	
	aPages = oSite.getPages();
	owner = oSite.getOwner();
	title = oPage.getPageTitle();
	
	oAccounts = oSite.getAccount();
	stAccountInfo = oAccounts.getConfig();
	
	thisPageHREF = oPage.getHREF();	
</cfscript>

<cfparam name="thisModule.Name" default="">
<cfparam name="thisModule.Location" default="">
<cfparam name="thisModule.ID" default="">
<cfparam name="thisModule.title" default="">
<cfparam name="thisModule.container" default="true">
<cfparam name="thisModule.output" default="true">
<cfparam name="thisModule.Display" default="normal">
<cfparam name="thisModule.ShowPrint" default="true">
<cfparam name="thisModule.style" default="">

<cfoutput>
	<h2>Accounts > #owner# > Page Editor > Edit Module</h2>
	<table id="tblPageDesigner" cellspacing="0" cellpadding="0">
		<tr valign="top">
			<td colspan="3" style="padding:0px;">
				<div class="cp_sectionBox" 
					 style="margin:0px;padding:0px;width:630px;margin-top:5px;overflow:hidden;">
					<table style="margin:5px;width:620px;" cellpadding="0" cellspacing="0">
						<tr>
							<td>
								<strong>Title:</strong> #title#
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
	</table>


	<form name="frmModule" action="index.cfm?event=ehPage.doSaveModule" method="post" style="margin:0px;padding:0px;">
		<input type="hidden" name="event" value="ehPage.doSaveModule" />

		<input type="hidden" name="display" value="#thisModule.Display#" />
		<input type="hidden" name="output" value="#thisModule.output#" />
		<input type="hidden" name="name" value="#thisModule.name#" />
		<input type="hidden" name="location" value="#thisModule.location#" />
		<input type="hidden" name="style" value="#thisModule.style#" />
		<input type="hidden" name="showPrint" value="#thisModule.showPrint#" />
		<input type="hidden" name="id" value="#thisModule.ID#">
		<input type="hidden" name="_baseAttribs" id="_baseAttribs" value="#lstAttribs#">
		<input type="hidden" name="_allAttribs" id="_allAttribs" value="#lstAllAttribs#">

		<br>

		<table width="100%">
			<tr valign="top">
				<td>
				<div class="cp_sectionTitle" style="padding:0px;margin:0px;width:400px;">
					<div style="margin:2px;">General Properties</div>
				</div>
				<div class="cp_sectionBox" 
					style="margin-top:0px;padding:0px;margin-right:0px;margin-left:0px;border-top:0px;width:400px;">
					<table style="margin:5px;">
						<tr>
							<td width="50"><strong>ID:</strong></td>
							<td><b>#thisModule.ID#</b></td>
						</tr>
						<tr>
							<td><strong>Title:</strong></td>
							<td>
								<input type="text" name="title" 
										value="#thisModule.Title#" 
										class="textField">
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<strong>Display Module Container:</strong>
								<input type="checkbox" name="container" 
										style="border:0px;width:auto;"
										value="true" 
										class="textField"	
										<cfif thisModule.container>checked</cfif> style="width:15px;"> 
							</td>
						</tr>
					</table>
				</div>

				<div class="cp_sectionTitle" style="padding:0px;margin:0px;margin-top:15px;width:400px;">
					<div style="margin:2px;">Other Properties</div>
				</div>
				<div class="cp_sectionBox" 
					style="margin-top:0px;padding:0px;margin-right:0px;margin-left:0px;border-top:0px;width:400px;">
					<table style="margin:5px;">
						<cfloop collection="#thisModule#" item="thisAttr">
							<cfif Not ListFindNoCase(lstAttribs,thisAttr)>
								<cfset tmpAttrValue = thisModule[thisAttr]>
								<tr valign="top">
									<td width="50"><strong>#thisAttr#:</strong></td>
									<td>
										<input type="text" 
												name="#thisAttr#" 
												value="#tmpAttrValue#" 
												class="textField">

										<cfif Not IsSimpleValue(thisModuleInfo) and structKeyExists(thisModuleInfo,"attributes")>
											<cfloop from="1" to="#arrayLen(thisModuleInfo.attributes.xmlChildren)#" index="i">
												<cfset tmpNode = thisModuleInfo.attributes.xmlChildren[i]>
												<cfif tmpNode.xmlAttributes.name eq thisAttr>
													<div class="formFieldTip">#tmpNode.xmlAttributes.description#</div>
												</cfif>
											</cfloop>
										</cfif>
									</td>
								</tr>
							</cfif>
						</cfloop>
					</table>
				</div>
				
				</td>
				<td style="width:10px;">&nbsp;</td>
				<cfif structKeyExists(thisModuleInfo, "xmlAttributes")>
					<td style="border:1px solid ##ccc;background-color:##ebebeb;width:250px;">
						<div style="margin:5px;">
							<b>Module:</b><br>
							<cfif structKeyExists(thisModuleInfo.xmlAttributes, "name")>
								#thisModuleInfo.xmlAttributes.name#
							<cfelse>
								N/A
							</cfif>
							<br><br>
							<b>Description:</b><br>
							<cfif structKeyExists(thisModuleInfo, "description")>
								#thisModuleInfo.description.xmlText#
							<cfelse>
								N/A
							</cfif>
							<br><br>
							<cfif structKeyExists(thisModuleInfo, "moduleInfo")>
								<b>Author:</b><br>
								<cfif structKeyExists(thisModuleInfo.moduleInfo, "authorName")>
									#thisModuleInfo.moduleInfo.authorName.xmlText#<br>
								<cfelse>
									N/A<br>
								</cfif>
								<cfif structKeyExists(thisModuleInfo.moduleInfo,"authorEmail")>
									<cfset tmpHREF = thisModuleInfo.moduleInfo.authorEmail.xmlText>
									<a href="mailto:#tmpHREF#" style="white-space:normal">#tmpHREF#<br>
								</cfif>
								<cfif structKeyExists(thisModuleInfo.moduleInfo,"authorURL")>
									<cfset tmpHREF = thisModuleInfo.moduleInfo.authorURL.xmlText>
									<div style="white-space:normal;width:200px;overflow:hidden;">
										<a href="#tmpHREF#" target="_blank" style="white-space:normal">#tmpHREF#<br>
									</div>
								</cfif>
							</cfif>
						</div>
					</td>
				</cfif>
			</tr>
		</table>
		<p>
			<input type="button" 
					name="btnCancel" 
					value="Return To Page Editor" 
					onClick="document.location='?event=ehPage.dspPageEditor'">
			&nbsp;&nbsp;
			<input type="submit" name="btnSave" value="Apply Changes">
		</p>
	</form>
</cfoutput>

