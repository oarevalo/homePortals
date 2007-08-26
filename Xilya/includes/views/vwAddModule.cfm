<!--- 
vwAddModule

Display information about a single module to add to the page

** This file should be included from addContent.cfc

History:
12/4/05 - oarevalo - created
---->

<cfset oResourceBean = application.homePortals.getCatalog().getResourceNode("module", arguments.moduleID)>
<cfset qryLocations = variables.oPage.getLocations()>

<cfoutput>
	<form name="frmCPAddModule" action="##" method="post" style="margin:0px;padding:0px;">
		<input type="hidden" name="moduleID" value="#arguments.moduleID#">
		<input type="hidden" name="locationID" value="#qryLocations.name#">
		
		<div style="font-size:24px;font-weight:bold;">#oResourceBean.getID()#</div>
		<div style="font-size:10px;margin:0px;margin-bottom:10px;width:315px;overflow:hidden;white-space:nowrap;">
			by #oResourceBean.getAuthorName()#
				<cfif oResourceBean.getAuthorEmail() neq "">
					<a href="mailto:#oResourceBean.getAuthorEmail()#"><img src="#imgRoot#/email.png" border="0" align="absmiddle"></a>
				</cfif>
				<cfif oResourceBean.getAuthorURL() neq "">
					&nbsp;&nbsp;&nbsp;
					<a href="#oResourceBean.getAuthorURL()#" target="_blank"><img src="#imgRoot#/world_link.png" border="0" align="absmiddle"></a>
					<a href="#oResourceBean.getAuthorURL()#" target="_blank" style="font-weight:bold;border-bottom:1px dashed silver;">#oResourceBean.getAuthorURL()#</a>
				</cfif>
		</div>

		<table cellpadding="0" cellspacing="0">
			<tr valign="top">
				<td style="height:180px;width:315px;font-size:12px;overflow:auto;border-bottom:1px solid silver;border-top:1px solid silver;">
					<div style="margin-top:5px;margin-bottom:10px;">
						#oResourceBean.getDescription()#
					</div>

					<cfif oResourceBean.getScreenshot() neq "">
						<b>Screenshot:</b><br>
						<img src="#oResourceBean.getScreenshot()#" style="border:1px solid black;height:80px;">
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

