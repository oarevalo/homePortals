<cfsetting enablecfoutputonly="yes">
<cftry>
	<cfsilent>
		<!--- initialize main object --->
		<cfset obj = CreateObject("Component", "controlPanel")>
		<cfset obj.initContext()>
	
		<!--- check for cookie login --->
		<cfif isDefined("cookie.homeportals_username") and isDefined("cookie.homeportals_userKey")>
			<cfset obj.doCookieLogin(cookie.homeportals_username, cookie.homeportals_userKey)>
		</cfif>
	
		<!--- get path to module library --->
		<cflock scope="application" type="readonly" timeout="10">
			<cfset moduleLibraryPath = application.homeSettings.moduleLibraryPath>
			<cfset accountsRoot = application.HomePortalsAccountsConfig.accountsRoot>
			<cfset allowRegisterAccount = application.HomePortalsAccountsConfig.allowRegisterAccount>
		</cflock>
		
		<!--- get user info --->
		<cfset stUser = obj.getUserInfo()>
	
		<!--- get info on current location --->
		<cfset currentPage = GetFileFromPath(session.homeconfig.href)>
	
		<!--- read site definition --->	
		<cffile action="read" file="#expandpath(obj.siteURL)#" variable="txtDoc">
		<cfset xmlDoc = xmlParse(txtDoc)>
		<cfset aPages = xmlDoc.site.pages.xmlChildren>
	</cfsilent>
		
	<!--- display site map --->	
	<cfoutput>
		<cfset moduleLibraryPath = "/Home/Modules">
		
		<!--- include css and javascript --->
		<cfsavecontent variable="tmpHTML">
			<script type="text/javascript">
				// initialize control panel client
				var controlPanel = new controlPanelClient();
				controlPanel.init('#moduleLibraryPath#');
			</script>
			
			<!--- include Javascript files for drag/drop only if signed in as owner --->
			<cfif stUser.isOwner>
				<script type="text/javascript" src="#moduleLibraryPath#/Accounts/scripts/coordinates.js"></script>
				<script type="text/javascript" src="#moduleLibraryPath#/Accounts/scripts/drag.js"></script>
				<script type="text/javascript" src="#moduleLibraryPath#/Accounts/scripts/dragdrop.js"></script>
			</cfif>
		</cfsavecontent>
		<cfhtmlhead text="#tmpHTML#">


		<div id="navMenu">
			<table border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td colspan="3" align="right" style="color:##FFFFFF;font-size:11px;padding-right:20px;height:25px;">&nbsp;
						<cfif stUser.username neq "">
							Your are logged in as <a href="#accountsRoot#/#stUser.username#"><strong>#stUser.username#</strong></a>
						</cfif>
					</td>
				</tr>
				<tr valign="top" style="color:##FFFFFF;">
					<td width="100" style="padding-left:10px;padding-right:10px;">
						<span id="siteMapTitle">#GetToken(obj.siteURL,2,"/")#</span>
					</td>
					<td>
						<cfloop from="1" to="#ArrayLen(aPages)#" index="i">
							<cfset thisPage = aPages[i].xmlAttributes>
						
							<cfparam name="thisPage.private" default="false">
				
							<cfset isPrivate = thisPage.private>
							<cfset thisPageHREF = "#obj.baseDir##thisPage.href#">
							<cfif thisPage.title eq "">
								<cfset tmpTitle = listFirst(thisPage.href,".")>
							<cfelse>
								<cfset tmpTitle = thisPage.title>
							</cfif>
										
							<!--- display public pages or private pages only if owner is logged in --->
							<cfif Not isPrivate or (isPrivate and stUser.isOwner)>
								<cfif thisPage.href eq currentPage>
									<a href="#thisPageHREF#"><strong>#tmpTitle#</strong></a>
								<cfelse>
									<a href="#thisPageHREF#">#tmpTitle#</a>
								</cfif>
								&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
							</cfif>
				
							<!--- if this is a private page and current user is not owner, then get out --->
							<cfif isPrivate and Not stUser.isOwner and thisPage.href eq currentPage>
								<cflocation url="#accountsRoot#/default/noaccess.cfm">
							</cfif>
						</cfloop>
						
						<!--- Show link to add page --->
						<cfif stUser.isOwner>
							<a href="javascript:controlPanel.getView('AddPage');">
								<img src="#accountsRoot#/default/btnAddPage.gif" 
										border="0" align="absmiddle" 
										alt="Add a new page" 
										title="Add a new page"></a>
						</cfif>
					</td>
					<td align="right" nowrap="nowrap">
						<div id="anchorAddContent">
							<div id="anchorAddContent_BodyRegion" style="padding-right:20px;">
								<cfif stUser.isOwner>
									<a href="javascript:controlPanel.getView('Page')">
										<img src="#accountsRoot#/default/btnAddContent2.gif" 
												border="0" align="absmiddle" 
												alt="Add page content" 
												title="Add page content"></a>&nbsp;&nbsp;|&nbsp;
									<a href="javascript:controlPanel.getView('Site')">Settings</a>&nbsp;&nbsp;|&nbsp;
									<a href="javascript:controlPanel.doLogoff('anchorAddContent')">Logoff</a>
								<cfelseif stUser.username neq "">
									<a href="javascript:controlPanel.doLogoff('anchorAddContent')">Logoff</a>
								<cfelse>
									<a href="javascript:controlPanel.getLogin()">Login</a>
									<cfif IsBoolean(allowRegisterAccount) and allowRegisterAccount>
										&nbsp;&nbsp;|&nbsp;
										<a href="javascript:controlPanel.getCreateAccount()">Register</a>
									</cfif>
								</cfif>
							</div>
						</div>
					</td>
				</tr>
			</table>
		</div>
	</cfoutput>
		
	<cfcatch type="any">
		<cfoutput>
			<!-- SiteMap Error: 
				Message: #cfcatch.Message# 
				Detail: #cfcatch.Detail#
			-->
		</cfoutput>
	</cfcatch>
</cftry>
