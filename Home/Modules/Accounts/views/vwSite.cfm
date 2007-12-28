<!--- 
vwSite

Display the view to configure site settings

** This file should be included from addContent.cfc

History:
5/31/06 - oarevalo - created
---->

<cfset initContext()>
<cffile action="read" file="#expandpath(this.siteURL)#" variable="txtDocSite">

<cfset xmlSite = xmlParse(txtDocSite)>
<cfset aPages = xmlSite.xmlRoot.pages.xmlChildren>



<cfoutput>
<div class="cp_sectionTitle" style="width:340px;padding:0px;">
	<table style="width:336px;margin:2px;" cellpadding="0" cellspacing="0">
		<tr> 
			<td>Site Map</td>
			<td align="right">
				<a href="javascript:controlPanel.getView('AddPage');"><img src="#this.accountsRoot#/default/btnAddPage.gif" 
								title="Add Page" alt="Add Page" align="absmiddle" border="0"></a>
			</td>
		</tr>
	</table>
</div>
<div class="cp_sectionBox" style="margin-top:0px;height:310px;padding:0px;margin-bottom:0px;width:340px;">
	<table class="cp_dataTable" cellspacing="0" style="border-bottom:0px;">
		<tr>
			<th>&nbsp;Page Title</th>
			<th width="10" style="text-align:center;">&nbsp;</th>
		</tr>
		<cfloop from="1" to="#arrayLen(aPages)#" index="i">
			<tr <cfif i mod 2>style="background-color:##f3f3f3;"</cfif>>
				<cfset pageAttributes = aPages[i].xmlAttributes>
				<cfparam name="pageAttributes.private" default="false">
				<cfparam name="pageAttributes.default" default="false">		
				<cfparam name="pageAttributes.title" default="#pageAttributes.href#">		
						
				<td>&nbsp;
					<cfif pageAttributes.default>
						<img src="#this.accountsRoot#/default/cp_bullet.gif" border="0" alt="Default page" title="Default page">
					</cfif>
					<a href="index.cfm?currentHome=#this.accountsRoot#/#stUser.username#/layouts/#pageAttributes.href#">#pageAttributes.title#</a>
				</td>
				<td style="text-align:right;">
 					<cfif pageAttributes.private>
						<img src="/Home/Modules/Accounts/images/lock.png" border="0" alt="This is a private page" title="This is a private page">
					</cfif>
 					<a href="javascript:controlPanel.deletePage('#pageAttributes.href#')"><img src="#this.accountsRoot#/default/waste_small.gif" border="0" alt="Delete" title="Delete page"></a>
 					<cfif Not pageAttributes.private>
						<a href="javascript:controlPanel.getPublishPage('#pageAttributes.href#')"><img src="#this.accountsRoot#/default/publish_icon.gif" border="0" alt="Publish" title="Publish page"></a>
					<cfelse>
						&nbsp;&nbsp;&nbsp;	&nbsp;&nbsp;&nbsp;					
					</cfif>
				</td>
			</tr>
		</cfloop>
	</table>
</div>
<div class="cp_sectionBox" style="width:340px;margin-top:0px;height:20px;background-color:##ccc;border-top:0px;padding-bottom:0px;margin-bottom:5px;padding:0px;">
	<div style="margin:2px;">
		<b>Legend:</b> 
		&nbsp;&nbsp;
		<img src="#this.accountsRoot#/default/waste_small.gif" border="0" alt="Delete" align="absmiddle"> Delete Page
		&nbsp;&nbsp;
		<img src="#this.accountsRoot#/default/publish_icon.gif" border="0" alt="Publish" title="Publish page" align="absmiddle"> Publish Page
		&nbsp;&nbsp;
		<img src="#this.accountsRoot#/default/cp_bullet.gif" border="0" alt="Default page" title="Default page"> Default Page
	</div>
</div>

<!---- &nbsp;&nbsp;<A href="##" style="color:##333;"><strong>File Manager</strong></a>&nbsp;&nbsp;| --->
&nbsp;&nbsp;<A href="javascript:controlPanel.getView('Catalogs')" style="color:##333;"><strong>Site Catalogs</strong></a>

</cfoutput>
