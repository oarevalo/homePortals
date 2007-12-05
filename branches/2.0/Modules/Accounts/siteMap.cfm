<cftry>
	<cfsilent>
		<cfscript>
			hpRoot = application.homePortalsRoot;
			currentPage = cookie.hp_currentHome;
			siteOwner = ListGetAt(currentPage, 2, "/");
			bUserLoggedIn = false;
			moduleLibraryPath = hpRoot & "/Modules/";
			stUser = structNew();
			stUser.username = "";
			stUser.isOwner = false;
			
			// get account info
			qryAccount = application.accountsManager.getAccountByUsername(siteOwner);
			
			// create site object
			oSite = CreateObject("component", hpRoot & "/Components/site");
			oSite.init(qryAccount.userID, application.accountsManager);
			
			// check if there is any user logged in
			if(structKeyExists(session, "homeConfig") and structKeyExists(session, "User")) {
				if(isStruct(session.user) and structKeyExists(session.user, "qry")) {
					bUserLoggedIn = true;
					stUser.username = session.user.qry.username;
					stUser.isOwner = (session.user.qry.username eq siteOwner);
				}
			}	
			
			// get accounts settings
			stAccountsConfig = application.accountsManager.getConfig(); 
			accountsRoot = stAccountsConfig.accountsRoot;
			accountPagesRoot = accountsRoot & "/" & siteOwner & "/layouts/";
			allowRegisterAccount = stAccountsConfig.allowRegisterAccount;
			
			aPages = oSite.getPages();
		</cfscript>	
	</cfsilent>
		
	<!--- display site map --->	
	<cfoutput>
		<!--- include css and javascript --->
		<cfsavecontent variable="tmpHTML">
			<script type="text/javascript">
				// initialize control panel client
				var controlPanel = new controlPanelClient();
				controlPanel.init('#moduleLibraryPath#');
			</script>
			
			<!--- include Javascript files for drag/drop only if signed in as owner --->
			<script type="text/javascript" src="#moduleLibraryPath#/Accounts/scripts/coordinates.js"></script>
			<script type="text/javascript" src="#moduleLibraryPath#/Accounts/scripts/drag.js"></script>
			<script type="text/javascript" src="#moduleLibraryPath#/Accounts/scripts/dragdrop.js"></script>
		</cfsavecontent>
		<cfhtmlhead text="#tmpHTML#">

		<div id="navMenu">
			<table border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td>
						<h1 id="siteMapTitle">#oSite.getSiteTitle()#</h1>
					</td>
					<td align="right" style="color:##FFFFFF;font-size:11px;padding-right:20px;height:25px;">&nbsp;
						<cfif bUserLoggedIn>
							Your are logged in as <a href="#accountsRoot#/#stUser.username#"><strong>#stUser.username#</strong></a>
						</cfif>
					</td>
				</tr>
				<tr valign="top" style="color:##FFFFFF;">
					<td valign="middle" style="padding-left:10px;line-height:20px;height:20px;">
						<cfloop from="1" to="#ArrayLen(aPages)#" index="i">
							<cfset thisPage = aPages[i]>
						
							<cfparam name="thisPage.private" default="false">
							<cfparam name="thisPage.showInNav" default="true">
				
							<cfset isPrivate = thisPage.private>
							<cfset thisPageHREF = cgi.SCRIPT_NAME & "/" & siteOwner & "/" & replace(thisPage.href,".xml","")>
							<cfif thisPage.title eq "">
								<cfset tmpTitle = listFirst(thisPage.href,".")>
							<cfelse>
								<cfset tmpTitle = thisPage.title>
							</cfif>
										
							<cfif thisPage.showInNav>
								<!--- display public pages or private pages only if owner is logged in --->
								<cfif Not isPrivate or (isPrivate and bUserLoggedIn and stUser.isOwner)>
									<cfif thisPage.href eq getFileFromPath(currentPage)>
										<a href="#thisPageHREF#"><strong>#tmpTitle#</strong></a>
									<cfelse>
										<a href="#thisPageHREF#">#tmpTitle#</a>
									</cfif>
									<cfif i neq ArrayLen(aPages)>
										&nbsp;&nbsp;&middot;&nbsp;&nbsp;
									</cfif>
								</cfif>
							</cfif>
				
							<!--- if this is a private page and current user is not owner, then get out --->
							<cfif isPrivate and Not stUser.isOwner and thisPage.href eq getFileFromPath(currentPage)>
								<cflocation url="#hpRoot#/Common/Templates/noaccess.cfm">
							</cfif>
						</cfloop>
						<!--- Show link to add page --->
						<cfif bUserLoggedIn and stUser.isOwner>
							&nbsp;&nbsp;
							<a href="javascript:controlPanel.addPage('New Page');">
								<img src="#moduleLibraryPath#/Accounts/images/btnAddPage.gif" 
										border="0" align="absmiddle" 
										alt="Add a new page" 
										title="Add a new page"></a>
						</cfif>
					</td>
					<td align="right" nowrap="nowrap">
						<div id="anchorAddContent">
							<div id="anchorAddContent_BodyRegion" style="padding-right:20px;">
								<cfif bUserLoggedIn and stUser.isOwner>
									<a href="javascript:controlPanel.openAddContentPanel()">
										<img src="#moduleLibraryPath#/Accounts/images/btnAddContent.gif" 
												border="0" align="absmiddle"
												id="btnAddContent" 
												alt="Add page content" 
												title="Add page content"></a>&nbsp;
									<a href="javascript:controlPanel.getView('Page')">
										<img src="#moduleLibraryPath#/Accounts/images/btnSettings.gif" 
												border="0" align="absmiddle" 
												alt="Settings" 
												title="Settings"></a>&nbsp;
									<a href="javascript:controlPanel.doLogoff('anchorAddContent')">
										<img src="#moduleLibraryPath#/Accounts/images/btnLogOff.gif"
												border="0" align="absmiddle" 
												alt="Log Off"
												title="Log Off"></a>
								<cfelseif bUserLoggedIn and stUser.username neq "">
									<a href="javascript:controlPanel.doLogoff('anchorAddContent')">
										<img src="#moduleLibraryPath#/Accounts/images/btnLogOff.gif"
												border="0" align="absmiddle" 
												alt="Log Off"
												title="Log Off"></a>
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


