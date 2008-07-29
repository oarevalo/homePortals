<!--- 
vwSite

Display the view to configure site settings

** This file should be included from addContent.cfc

History:
5/31/06 - oarevalo - created
---->
<cfset selectTab("Site")>

<cfset stUser = getUserInfo()>
<cfset accountDir = this.accountsRoot & "/" & stUser.username>

<cfset aPages = variables.oSite.getPages()>

<!--- get site title ---->
<cfset tmpSiteTitle = variables.oSite.getSiteTitle()>

<cfdirectory action="list" directory="#expandPath(accountDir)#" name="qryDir" recurse="true">

<cfoutput>
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr valign="top">
			<td style="width:325px;">

				<div class="cp_sectionBox" 
					 style="margin:0px;padding:0px;width:325px;margin-left:7px;margin-top:5px;overflow:hidden;">
					<form name="frm" method="post" action="##" style="padding:0px;margin:0px;">
					<table style="margin:5px;" cellpadding="0" cellspacing="0">
						<tr>
							<td><strong>Site Title:</strong> </td>
							<td colspan="2">
								<input type="text" 
										name="siteTitle" 
										value="#tmpSiteTitle#" 
										onkeyup="$('siteMapTitle').innerHTML=this.value"
										onchange="controlPanel.setSiteTitle(this.value)"
										style="width:185px;padding:2px;">
								<input type="button" name="btnChange" value="Change" onclick="controlPanel.setSiteTitle(this.form.siteTitle.value)">
							</td>
						</tr>
					</table>
					</form>
				</div>


				<div class="cp_sectionTitle" style="width:325px;padding:0px;margin-bottom:0px;">
					<div style="margin:2px;">
						<img src="#imgRoot#/chart_organisation.png" align="absmiddle"> Site Map
					</div>
				</div>
				<div class="cp_sectionBox" style="margin-top:0px;height:290px;padding:0px;margin-bottom:0px;width:325px;border-top:0px;">

					<table class="cp_dataTable" cellspacing="0" border="0" style="border-bottom:0px;">
						<tr>
							<th width="20">&nbsp;</th>
							<th colspan="5">&nbsp;Page Title</th>
						</tr>
						<cfloop from="1" to="#arrayLen(aPages)#" index="i">
							<tr <cfif i mod 2>style="background-color:##f3f3f3;"</cfif> align="right" valign="middle">
								<cfset pageAttributes = aPages[i]>
								<cfparam name="pageAttributes.private" default="false">
								<cfparam name="pageAttributes.default" default="false">		
								<cfparam name="pageAttributes.title" default="#pageAttributes.href#">		
								<cfparam name="pageAttributes.showInNav" default="true">		
								
								<td align="center">
									<input type="checkbox" 
											style="border:0px;"
											name="btnInNavMap" 
											onclick="controlPanel.setPageNavStatus('#pageAttributes.href#',this.checked)"
											<cfif pageAttributes.showInNav>checked</cfif>
											value="1">
								</td>
										
								<td align="left">&nbsp;
									<cfif pageAttributes.default>
										<img src="#imgRoot#/defaultPage_on.gif" border="0" alt="Default page" title="Default page"></a>
									<cfelse>
										<a href="javascript:controlPanel.setDefaultPage('#pageAttributes.href#')">
											<img src="#imgRoot#/defaultPage_off.gif" border="0" alt="Set this page as default page" title="Set this page as default page"></a>
									</cfif>
									<a href="index.cfm?currentHome=#this.accountsRoot#/#stUser.username#/layouts/#pageAttributes.href#">#pageAttributes.title#</a>
								</td>
								<td style="width:10px;">
									<cfif i gt 1>
										<a href="javascript:controlPanel.movePageUp('#pageAttributes.href#')"><img src="#imgRoot#/arrowUp.gif" border="0" alt="Move Page Up"></a>
									</cfif>
								</td>
								<td style="width:10px;">
									<cfif i lt arrayLen(aPages)>
										<a href="javascript:controlPanel.movePageDown('#pageAttributes.href#')"><img src="#imgRoot#/arrowDown.gif" border="0" alt="Move Page Down"></a>
									</cfif>
								</td>
								<td style="width:10px;">
				 					<cfif pageAttributes.private>
					 					<a href="javascript:controlPanel.setPagePrivacyStatus('#pageAttributes.href#',false)">
											<img src="#imgRoot#/lock.png" border="0" alt="This is a private page. Click to set as public page." title="This is a private page. Click to set as public page."></a>
									<cfelse>
					 					<a href="javascript:controlPanel.setPagePrivacyStatus('#pageAttributes.href#',true)">
											<img src="#imgRoot#/padlock_open.gif" border="0" alt="This is a public page. Click to set as private." title="This is a public page. Click to set as private."></a>
									</cfif>
								</td>
								<td style="width:10px;">
				 					<a href="javascript:controlPanel.deletePage('#pageAttributes.href#')"><img src="#imgRoot#/waste_small.gif" border="0" alt="Delete" title="Delete page"></a>
								</td>
								<!---
								<td style="width:10px;">
				 					<cfif Not pageAttributes.private>
										<a href="javascript:controlPanel.getPublishPage('#pageAttributes.href#')"><img src="#imgRoot#/publish_icon.gif" border="0" alt="Publish" title="Publish page"></a>
									</cfif>
								</td>
								---->
							</tr>
						</cfloop>
					</table>

				</div>

			</td>
			<td rowspan="2">
				<div class="cp_sectionTitle" id="cp_pd_moduleProperties_Title" 
						style="width:150px;padding:0px;margin:0px;margin-left:2px;margin-top:5px;">
					<div style="margin:2px;">
						<img src="#imgRoot#/status_online.png" align="absmiddle"> Account Info
					</div>
				</div>
				<div class="cp_sectionBox" 
					style="margin-top:0px;width:150px;padding:0px;height:140px;margin-left:2px;margin-right:0px;border-top:0px;">
					<div style="margin:4px;">
						<p>
							<strong>Username:</strong><br>
							#stUser.username#
						</p>

						<p>
							<strong>Account Directory:</strong><br>
							/Accounts/#stUser.username#/
						</p>

						<p>
							<strong>Space Used:</strong><br>
							<cfset aSizes = listToArray(valueList(qryDir.size))>
							<cfset tmpTotalSize = arraySum(aSizes)>
							#numberformat(tmpTotalSize,",")# bytes
						</p>
						
						<!---
						<hr>
						<p>
							<li><a href="javascript:controlPanel.getView('Profile');">Edit Profile</a></li>
							<li><a href="javascript:controlPanel.getView('ChangePassword');">Change Password</a></li>
						</p>
						---->
					</div>
				</div>
				<div class="cp_sectionBox" 
					style="width:150px;margin-top:5px;padding:0px;margin-left:2px;margin-right:0px;height:213px;margin-bottom:0px;">
					<div style="margin:4px;">
						<div>
							<img src="#imgRoot#/defaultPage_on.gif" border="0" alt="Default page" title="Default page"> 
							<strong>Default page.</strong> This is the first page that is displayed 
							when this site is visited.
						<div>
						<div style="margin-top:5px;">
							<img src="#imgRoot#/arrowUp.gif" border="0" align="absmiddle">
							<strong>Move page up.</strong>
						<div>
						<div style="margin-top:5px;">
							<img src="#imgRoot#/arrowDown.gif" border="0" align="absmiddle">
							<strong>Move page down.</strong>
						<div>
						<div style="margin-top:5px;">
							<img src="#imgRoot#/lock.png" border="0" align="absmiddle">
							<strong>Private page.</strong> Click to set as a public page.
						<div>
						<div style="margin-top:5px;">
							<img src="#imgRoot#/padlock_open.gif" border="0" align="absmiddle">
							<strong>Public page.</strong> Click to set as a private page.
						<div>
						<div style="margin-top:5px;">
							<img src="#imgRoot#/waste_small.gif" border="0" alt="Publish" title="Publish page" align="absmiddle"> 
							<strong>Delete page.</strong>
						<div>
						<!---
						<div style="margin-top:5px;">
							<img src="#imgRoot#/publish_icon.gif" border="0" alt="Publish" title="Publish page" align="absmiddle"> 
							<strong>Publish page.</strong>
						<div>
						---->
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<td valign="bottom">
				<div class="cp_sectionBox" 
					 style="margin:0px;padding:0px;width:325px;margin-left:6px;margin-top:2px;">
					<div style="margin:4px;">
						<a href="javascript:controlPanel.getView('AddPage');"><img src="#imgRoot#/add.png" align="absmiddle" border="0"></a>
						<a href="javascript:controlPanel.getView('AddPage');">Add Page</a>
					</div>
				</div>
			</td>
		</tr>
	</table>	
</cfoutput>
