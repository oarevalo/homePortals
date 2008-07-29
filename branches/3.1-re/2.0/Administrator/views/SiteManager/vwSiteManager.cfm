<cfscript>
	userID = getValue("UserID","");
	stAccountInfo = getValue("stAccountInfo");
	qryAccount = getValue("qryAccount");
	siteTitle = getValue("siteTitle");
	accountDir = getValue("accountDir");
	aPages = getValue("aPages");
	accountSize = getValue("accountSize");
</cfscript>

<cfoutput>
	<h2>Accounts > #qryAccount.username#</h2>
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr valign="top">
			<td style="width:375px;">

				<div class="cp_sectionBox" 
					 style="margin:0px;padding:0px;width:375px;margin-left:7px;margin-top:5px;overflow:hidden;">
					<form name="frmTitle" method="post" action="index.cfm" style="padding:0px;margin:0px;">
						<input type="hidden" name="event" value="ehSite.doSetSiteTitle">
						<input type="hidden" name="userID" value="#userID#">
						<table style="margin:5px;" cellpadding="0" cellspacing="0">
							<tr>
								<td><strong>Site Title:</strong></td>
								<td>
									&nbsp;
									<input type="text" 
											name="title" 
											value="#siteTitle#" 
											style="width:185px;padding:2px;">
									<input type="submit" name="btnChangeTitle" value="Change">
								</td>
							</tr>
						</table>
					</form>
				</div>


				<div class="cp_sectionTitle" style="width:375px;padding:0px;margin-bottom:0px;">
					<div style="margin:2px;">
						<img src="images/chart_organisation.png" align="absmiddle"> Site Map
					</div>
				</div>
				<div class="cp_sectionBox" style="margin-top:0px;height:290px;padding:0px;margin-bottom:0px;width:375px;border-top:0px;">

					<table class="cp_dataTable" cellspacing="0" border="0" style="border-bottom:0px;">
						<tr>
							<th width="20">&nbsp;</th>
							<th colspan="6">&nbsp;Page Title</th>
						</tr>
						<cfloop from="1" to="#arrayLen(aPages)#" index="i">
							<tr <cfif i mod 2>style="background-color:##f3f3f3;"</cfif> align="right" valign="middle">
								<cfset pageAttributes = aPages[i]>
								<cfset pageHREF = "#stAccountInfo.accountsRoot#/#qryAccount.username#/layouts/#pageAttributes.href#">
								<cfset pageHPURL = "#stAccountInfo.homeRoot#/?currentHome=#pageHREF#">
								
								<cfparam name="pageAttributes.private" default="false">
								<cfparam name="pageAttributes.default" default="false">		
								<cfparam name="pageAttributes.title" default="#pageAttributes.href#">		
								<cfparam name="pageAttributes.showInNav" default="true">		
								
								<td align="center">
									<input type="checkbox" 
											style="border:0px;"
											name="btnInNavMap" 
											onclick="document.location='?event=ehSite.doSetPageNavStatus&userID=#userID#&href=#pageAttributes.href#&status='+this.checked"
											<cfif pageAttributes.showInNav>checked</cfif>
											value="1">
								</td>
										
								<td align="left">&nbsp;
									<cfif pageAttributes.default>
										<img src="images/defaultPage_on.gif" border="0" alt="Default page" title="Default page"></a>
									<cfelse>
										<a href="?event=ehSite.doSetDefaultPage&userID=#userID#&href=#pageAttributes.href#">
											<img src="images/defaultPage_off.gif" border="0" alt="Set this page as default page" title="Set this page as default page"></a>
									</cfif>
									<a href="?event=ehPage.doLoadPage&href=#pageHREF#">#pageAttributes.title#</a>
								</td>
								<td style="width:10px;">
									<cfif i gt 1>
										<a href="?event=ehSite.doMovePageUp&userID=#userID#&href=#pageAttributes.href#"><img src="images/arrowUp.gif" border="0" alt="Move Page Up"></a>
									</cfif>
								</td>
								<td style="width:10px;">
									<cfif i lt arrayLen(aPages)>
										<a href="?event=ehSite.doMovePageDown&userID=#userID#&href=#pageAttributes.href#"><img src="images/arrowDown.gif" border="0" alt="Move Page Down"></a>
									</cfif>
								</td>
								<td style="width:10px;">
				 					<cfif pageAttributes.private>
					 					<a href="?event=ehSite.doSetPagePrivacyStatus&userID=#userID#&href=#pageAttributes.href#&status=false">
											<img src="images/lock.png" border="0" alt="This is a private page. Click to set as public page." title="This is a private page. Click to set as public page."></a>
									<cfelse>
					 					<a href="?event=ehSite.doSetPagePrivacyStatus&userID=#userID#&href=#pageAttributes.href#&status=true">
											<img src="images/padlock_open.gif" border="0" alt="This is a public page. Click to set as private." title="This is a public page. Click to set as private."></a>
									</cfif>
								</td>
								<td style="width:10px;">
									<a href="?event=ehPage.doLoadPage&href=#pageHREF#"><img src="images/edit-page-yellow.gif" border="0" alt="Edit Page" title="Edit Page"></a>
								</td>
								<td style="width:10px;">
				 					<a href="javascript:doDeletePage('#pageAttributes.href#')"><img src="images/waste_small.gif" border="0" alt="Delete" title="Delete page"></a>
								</td>
							</tr>
						</cfloop>
					</table>

				</div>

			</td>
			<td rowspan="2">
				<div class="cp_sectionTitle" id="cp_pd_moduleProperties_Title" 
						style="width:200px;padding:0px;margin:0px;margin-left:2px;margin-top:5px;">
					<div style="margin:2px;">
						<img src="images/status_online.png" align="absmiddle"> Account Info
					</div>
				</div>
				<div class="cp_sectionBox" 
					style="margin-top:0px;width:200px;padding:0px;height:140px;margin-left:2px;margin-right:0px;border-top:0px;">
					<div style="margin:4px;">
						<strong>Username:</strong> 	#qryAccount.username#<br>
						<a href="?event=ehAccounts.dspProfile&userID=#userID#" style="color:blue !important;">[Edit Profile / Change Password]</a>

						<p>
							<strong>Account Directory:</strong><br>
							/Accounts/#qryAccount.username#/<br>
							<a href="?event=ehAccounts.dspFileManager&userID=#userID#" style="color:blue !important;">[View Files]</a>
						</p>

						<p>
							<strong>Space Used:</strong> #numberformat(accountSize,",")# bytes
						</p>
					</div>
				</div>
				<div class="cp_sectionBox" 
					style="width:200px;margin-top:4px;padding:0px;margin-left:2px;margin-right:0px;height:213px;margin-bottom:0px;">
					<div style="margin:4px;">
						<div>
							<img src="images/defaultPage_on.gif" border="0" alt="Default page" title="Default page"> 
							<strong>Default page.</strong> This is the first page that is displayed 
							when this site is visited.
						<div>
						<div style="margin-top:4px;">
							<img src="images/arrowUp.gif" border="0" align="absmiddle">
							<strong>Move page up on sitemap.</strong>
						<div>
						<div style="margin-top:4px;">
							<img src="images/arrowDown.gif" border="0" align="absmiddle">
							<strong>Move page down on sitemap.</strong>
						<div>
						<div style="margin-top:4px;">
							<img src="images/lock.png" border="0" align="absmiddle">
							<strong>Private page.</strong> Click to set as a public page.
						<div>
						<div style="margin-top:4px;">
							<img src="images/padlock_open.gif" border="0" align="absmiddle">
							<strong>Public page.</strong> Click to set as a private page.
						<div>
						<div style="margin-top:4px;">
							<img src="images/edit-page-yellow.gif" border="0" alt="Edit" title="Edit page" align="absmiddle"> 
							<strong>Edit page.</strong>
						<div>
						<div style="margin-top:4px;">
							<img src="images/waste_small.gif" border="0" alt="Delete" title="Delete page" align="absmiddle"> 
							<strong>Delete page.</strong>
						<div>
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<td valign="bottom">
				<div class="cp_sectionBox" 
					 style="margin:0px;padding:0px;width:375px;margin-left:6px;margin-top:2px;">
					<div style="margin:4px;">
						<a href="?event=ehAccounts.doSetAccount&userID=#userID#"><img src="images/arrow_rotate_clockwise.png" border="0" alt="Refresh Site" title="Refresh Site" align="absmiddle"></a>
						<a href="?event=ehAccounts.doSetAccount&userID=#userID#">Refresh</a>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="?event=ehSite.dspAddPage"><img src="images/add.png" align="absmiddle" border="0"></a>
						<a href="?event=ehSite.dspAddPage">Add Page</a>
					</div>
				</div>
			</td>
		</tr>
	</table>	
</cfoutput>

	<p>
		<input type="button" name="btnCancel" value="Return To Search" onClick="document.location='?event=ehAccounts.dspMain'">
	</p>
