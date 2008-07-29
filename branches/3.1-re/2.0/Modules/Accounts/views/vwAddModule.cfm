<!--- 
vwAddModule

Display information about a single module to add to the page

** This file should be included from addContent.cfc

History:
12/4/05 - oarevalo - created
---->

<cfset xmlModule = oCatalog.getResourceNode("module", arguments.moduleID)>
<cfset qryLocations = variables.oPage.getLocations()>

<cfset tmpScreenshot = "">
<cfset tmpAuthorName = "">
<cfset tmpAuthorEmail = "">
<cfset tmpAuthorURL = "">

<cfif StructKeyExists(xmlModule, "moduleInfo")>
	<cfif StructKeyExists(xmlModule.moduleInfo, "screenshot")>
		<cfset tmpScreenshot = xmlModule.moduleInfo.screenshot.xmlText>
	</cfif>
	<cfif StructKeyExists(xmlModule.moduleInfo, "authorName")>
		<cfset tmpAuthorName = xmlModule.moduleInfo.authorName.xmlText>
	</cfif>
	<cfif StructKeyExists(xmlModule.moduleInfo, "authorEmail")>
		<cfset tmpAuthorEmail = xmlModule.moduleInfo.authorEmail.xmlText>
	</cfif>
	<cfif StructKeyExists(xmlModule.moduleInfo, "authorURL")>
		<cfset tmpAuthorURL = xmlModule.moduleInfo.authorURL.xmlText>
	</cfif>
</cfif>



<cfoutput>
	<form name="frmCPAddModule" action="##" method="post" style="margin:0px;padding:0px;">
		<input type="hidden" name="moduleID" value="#arguments.moduleID#">
		<input type="hidden" name="locationID" value="#qryLocations.name#">
		
		<div style="font-size:24px;font-weight:bold;">#xmlModule.xmlattributes.id#</div>
		<div style="font-size:10px;margin:0px;margin-bottom:10px;width:315px;overflow:hidden;white-space:nowrap;">
			by #tmpAuthorName#
				<cfif tmpAuthorEmail neq "">
					<a href="mailto:#tmpAuthorEmail#"><img src="#imgRoot#/email.png" border="0" align="absmiddle"></a>
				</cfif>
				<cfif tmpAuthorURL neq "">
					&nbsp;&nbsp;&nbsp;
					<a href="#tmpAuthorURL#" target="_blank"><img src="#imgRoot#/world_link.png" border="0" align="absmiddle"></a>
					<a href="#tmpAuthorURL#" target="_blank" style="font-weight:bold;border-bottom:1px dashed silver;">#tmpAuthorURL#</a>
				</cfif>
		</div>

		<table cellpadding="0" cellspacing="0">
			<tr valign="top">
				<td style="height:180px;width:315px;font-size:12px;overflow:auto;border-bottom:1px solid silver;border-top:1px solid silver;">
					<div style="margin-top:5px;margin-bottom:10px;">
						#xmlModule.description.xmlText#
					</div>

					<cfif tmpScreenshot neq "">
						<b>Screenshot:</b><br>
						<img src="#tmpScreenshot#" style="border:1px solid black;height:80px;">
					</cfif>
				</td>
			</tr>
		</table> 
	
		<div style="text-align:center;margin-top:10px;">
			<a href="javascript:controlPanel.addModule(document.frmCPAddModule)"><img src="#imgRoot#/add.png" border="0" align="absmiddle"></a>
			<a href="javascript:controlPanel.addModule(document.frmCPAddModule)"><strong>Add Module</strong></a>
			&nbsp;&nbsp;&nbsp;
			<a href="javascript:controlPanel.closeAddModule()"><img src="#imgRoot#/cross.png" border="0" align="absmiddle"></a>
			<a href="javascript:controlPanel.closeAddModule()"><strong>Close</strong></a>
		</div>
	</form>		
</cfoutput>	

