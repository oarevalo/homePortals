<cfsilent>
<cfscript>
	oHP = application.homePortals;
	oAccountsService = oHP.getAccountsService();
	oCatalog = oHP.getCatalog();

	currentPage = request.oPageRenderer.getPageHREF();
				
	siteOwner = request.oPage.getOwner();
	pageAccess = request.oPage.getAccess();
	sectionPrefix = "My";
	qryModules = QueryNew("id,access,name,package,hasAccess");

	// get site owner membership info
	oMembers = CreateObject("component", "xilya.components.members").init();
	qryOwnerAccount = oAccountsService.getAccountByUsername(siteOwner);
	qryOwnerMember = oMembers.getByAccountID(qryOwnerAccount.userID);

	// get account friends
	oFriendsService = oAccountsService.getFriendsService();
	qryFriends = oFriendsService.getFriends(siteOwner);
	
	// get friend requests
	qryFriendRequests = oFriendsService.getFriendRequests(siteOwner);
	
	// check if visitor is a friend of the owner
	isFriend = oFriendsService.isFriend(siteOwner, request.userInfo.username);
	
	// check if visitor is the actual owner
	bIsOwner = (request.userInfo.userName eq siteOwner); 
	
	if(isFriend or bIsOwner) {
	
		// get info about the page and modules	
		qryModules = oCatalog.getResourcesByType("module");
		qryCatalogPages = oCatalog.getResourcesByType("page");
		aPages = request.oSite.getPages();
		pageTitle = request.oPage.getPageTitle();
		aAccess = arrayNew(1);

		// put modules into a query and sort them 
		if(bIsOwner) {
			for(j=1;j lte qryModules.recordCount;j=j+1) {
				aAccess[j] = qryModules.access[j] eq "general"
							or qryModules[j].access eq ""
							or (qryModules.access[j] eq "owner" and qryModules.owner[j] eq siteOwner)
							or (qryModules.access[j] eq "friend" and listFindNoCase(valueList(qryFriends.userName), qryModules.owner[j]));
			}
			queryAddColumn(qryModules, "hasAccess", aAccess);
		}
		
		if(isFriend) 
			sectionPrefix = siteOwner & "'s";
	}
</cfscript>

<cfif bIsOwner>
	<cfquery name="qryModules" dbtype="query">
		SELECT *
			FROM qryModules
			WHERE hasAccess = 1
			ORDER BY package, id
	</cfquery>

	<!--- get requests sent from this account --->
	<cfquery name="qryMyFriendRequests" dbtype="query">
		SELECT *
			FROM qryFriendRequests
			WHERE sender = <cfqueryparam cfsqltype="cf_sql_varchar" value="#siteOwner#">
			ORDER BY recipient
	</cfquery>
	
	<!--- get requests sent to this account --->
	<cfquery name="qryFriendRequests" dbtype="query">
		SELECT *
			FROM qryFriendRequests
			WHERE sender <> <cfqueryparam cfsqltype="cf_sql_varchar" value="#siteOwner#">
			ORDER BY recipient
	</cfquery>
</cfif>
</cfsilent>

<!--- if current user is not owner or a friend of the owner, then get out --->
<cfif Not bIsOwner and Not isFriend>
	<!--- if this is a logged in user, then kick him out to his homepage --->
	<cflocation url="#request.homePagePath#/index.cfm">
</cfif> 

<div id="catalogModuleInfo_BodyRegion" style="display:none;left:300px;top:100px;z-index:1000000"></div>
<div id="side_status_BodyRegion"></div>

<div id="sidePanel">
	<!--- Profile --->
	<cfset imgHREF = "/Accounts/#siteOwner#/avatar.jpg">
	<cfif Not fileExists(expandPath(imgHREF))>
		<cfset imgHREF = "/xilya/includes/images/avatar.jpg">
	</cfif>		
	<cfoutput>
		<div style="margin:3px;margin-top:6px;margin-bottom:6px;height:35px;">
			<a href="/Accounts/#siteOwner#"><img 
				src="#imgHREF#" border="0" align="left" width="30" height="30" style="border:1px solid white;margin:2px;margin-right:5px;"></a>
			<cfif qryOwnerMember.firstName & qryOwnerMember.lastName neq "">
				<span style="font-size:17px;">#qryOwnerMember.firstName# #qryOwnerMember.lastName#</span>
				<div style="font-size:11px;">#siteOwner#</div>
			<cfelse>
				<span style="font-size:17px;">#siteOwner#</span>
			</cfif>
		</div>
		<div class="sidePanelDivider"></div>
	</cfoutput>
	
	<!--- Current Workspace --->
	<cfoutput>
	
	<cfif bIsOwner>
		<div class="sidePanelSectionTitle"><b>Current Workspace</b></div>
		<div class="sidePanelSectionContent" id="sbPnl_workspaceTools" style="line-height:20px;">
		<!--- 	
			<a href="##" onclick="controlPanel.rename('pageTitle','#pageTitle#','Page')"><img src="/xilya/includes/images/edit-page-yellow.gif" alt="Rename" title="Rename" border="0" align="absmiddle"></a> 
			<a href="##" onclick="controlPanel.rename('pageTitle','#pageTitle#','Page')">Rename Workspace</a><br>
		 --->
			<a href="##" onclick="controlPanel.getView('Layout')"><img src="/xilya/includes/images/layout.png" alt="Change Layout" title="Change Layout" border="0" align="absmiddle"></a>
			<a href="##" onclick="controlPanel.getView('Layout')">Change workspace layout</a><br>
			<a href="##" onclick="controlPanel.deletePage('#getFileFromPath(currentPage)#')"><img src="/xilya/includes/images/omit-page-orange.gif" alt="Delete Workspace" title="Delete Worspace" border="0" align="absmiddle"></a>
			<a href="javascript:controlPanel.deletePage('#getFileFromPath(currentPage)#')">Delete workspace</a><br>
	 		<a href="##" onclick="controlPanel.getView('Events')"><img src="/xilya/includes/images/cog.png" alt="Event Handlers" title="Event Handlers" border="0" align="absmiddle"></a>
			<a href="##" onclick="controlPanel.getView('Events')">Widget connectors</a><br>

			<cfif pageAccess eq "owner" or pageAccess eq "friend">
				<a href="##" onclick="controlPanel.setPageAccess('general')"><img src="/xilya/includes/images/lock_open.png" alt="Click to make this workspace public" title="Click to make this workspace public" border="0" align="absmiddle"></a>
				<a href="javascript:controlPanel.setPageAccess('general')">Make public</a><br>
			<cfelse>
				<a href="##" onclick="controlPanel.setPageAccess('owner')"><img src="/xilya/includes/images/lock.png" alt="Click to make this workspace private" title="Click to make this workspace private" border="0" align="absmiddle"></a>
				<a href="javascript:controlPanel.setPageAccess('owner')">Make private</a><br>
			</cfif>
		</div>		
		<div class="sidePanelDivider"></div>
		
		
		<!--- Create Workspace --->
		<div class="sidePanelSectionTitle"><b>Create Workspace</b></div>
		<div class="sidePanelSectionContent" id="sbPnl_createWorkspace">
			<input type="text" name="txtNewPageName" id="txtNewPageName" value="" style="font-size:11px;border:1px solid silver;width:130px;">
			<input type="button" name="btnGo" value="Go" style="font-size:10px;border:1px solid silver;width:30px;" 
					onclick="controlPanel.addPage($('txtNewPageName').value)">
		</div>		
		<div class="sidePanelDivider"></div>
	</cfif>

	<!--- Workspaces list --->
	<div class="sidePanelSectionTitle">#sectionPrefix# Workspaces</div>
	<div class="sidePanelSectionContent" id="sbPnl_myWorkspaces">
		<cfloop from="1" to="#arrayLen(aPages)#" index="i">
			<cfset thisPageHREF = request.appRoot & "/index.cfm?account=" & siteOwner & "&page=" & replace(aPages[i].href,".xml","")>
				<div id="pgName#i#">
					<a href="#thisPageHREF#"
						><cfif aPages[i].href eq getFileFromPath(currentPage)>&raquo; <b>#aPages[i].title#</b><cfelse>#aPages[i].title#</cfif></a>
				</div>
				<div style="clear:both;"></div>
		</cfloop>
		
	</div>		
	<div class="sidePanelDivider"></div>
	</cfoutput>

	<cfif bIsOwner>	
		<!--- Add Feed --->
		<div class="sidePanelSectionTitle">
			<a href="#" onclick="controlPanel.getView('Feeds')">
				<img src="/xilya/includes/images/feed.png" align="absmiddle" border="0">
				<strong>Add Feeds</strong>
			</a>
		</div>
		<div class="sidePanelDivider"></div>
		
		<!--- Add Content --->
		<div class="sidePanelSectionTitle">
			<a href="#" onclick="controlPanel.getView('Content')">
				<img src="/xilya/includes/images/page_white_text.png" align="absmiddle" border="0">
				<strong>Add Content</strong>
			</a>
		</div>
		<div class="sidePanelDivider"></div>
		
		<!--- Add Widget --->
		<div class="sidePanelSectionTitle">
			<a href="##" onclick="Element.toggle('sbPnl_addWidgets');return false;">
				<img src="/xilya/includes/images/brick_add.png" align="absmiddle" border="0">
				<b>Add Widget</b>
			</a>
		</div>
		<div class="sidePanelSectionContent" id="sbPnl_addWidgets" style="display:none;">
			<cfoutput query="qryModules" group="package">
				<div style="margin-bottom:3px;">
				<b>#package#</b><br>
				<cfoutput>
					&nbsp;&nbsp;&bull;&nbsp;<a href="##"
						onclick="controlPanel.getAddModule('#id#')" 
						>#id#</a><br />
				</cfoutput>
				</div>
			</cfoutput>
		</div>
		<div class="sidePanelDivider"></div>
		
		<!--- Add Workspace ---->
		<cfoutput>
		<div class="sidePanelSectionTitle">
			<a href="##" onclick="Element.toggle('sbPnl_addWorkspace');return false;">
				<img src="/xilya/includes/images/package.png" align="absmiddle" border="0">
				<b>Add Workspace</b>
			</a>
		</div>
		<div class="sidePanelSectionContent" id="sbPnl_addWorkspace" style="display:none;">
			<cfloop query="qryCatalogPages">
				&bull;&nbsp;
				<a href="##" onclick="controlPanel.addPageResource('#jsstringformat(qryCatalogPages.id)#')" >#qryCatalogPages.id#</a><br />
			</cfloop>
		</div>		
		</cfoutput>
		<div class="sidePanelDivider"></div>
	</cfif>	
	
	<!--- Friends --->
	<cfoutput>
		<div class="sidePanelSectionTitle">
			<a href="##" onclick="Element.toggle('sbPnl_friends');return false;">
				<img src="/xilya/includes/images/status_online.png" align="absmiddle" border="0"> 
				<b>#sectionPrefix# Friends (#qryFriends.recordCount#)</b>
			</a>
		</div>
		<div class="sidePanelSectionContent" id="sbPnl_friends" style="display:block;">
		
			<!--- Friend requests received --->
			<cfif bIsOwner and qryFriendRequests.recordCount gt 0> 
				<div style="margin-bottom:8px;background-color:##ffffcc;padding:5px;">
				<b>Friend Requests:</b>
				<cfloop query="qryFriendRequests">
					<div style="margin-top:5px;">
						<cfset imgHREF = "/Accounts/#qryFriendRequests.sender#/avatar.jpg">
						<cfif Not fileExists(expandPath(imgHREF))>
							<cfset imgHREF = "/xilya/includes/images/avatar.jpg">
						</cfif>
						<img src="#imgHREF#" border="0" align="left" width="30" height="30" style="border:1px solid white;margin-right:5px;">
						<div style="line-height:15px;">
							#qryFriendRequests.sender#<br>
							<a href="##" onclick="controlPanel.acceptFriendRequest('#qryFriendRequests.sender#')"><b>Accept</b></a> &nbsp;&nbsp;&nbsp;
							<a href="##" onclick="controlPanel.rejectFriendRequest('#qryFriendRequests.sender#')"><b>Reject</b></a>
						</div>
						<br style="clear:both;" />
					</div>
				</cfloop>
				</div>
			</cfif>
		
			<!--- Friends list --->
			<cfloop query="qryFriends">
				<cfset imgHREF = "/Accounts/#qryFriends.userName#/avatar.jpg">
				<cfif Not fileExists(expandPath(imgHREF))>
					<cfset imgHREF = "/xilya/includes/images/avatar.jpg">
				</cfif>
				
				<a href="##"
					onclick="controlPanel.removeFriend('#jsstringFormat(qryFriends.userName)#')"><img src="/xilya/includes/images/waste_small.gif"
					 alt="Remove from my friends" title="Remove from my friends" style="margin-top:10px;" 
					 align="right" width="14" height="14" border="0" /></a>
						 
				<a href="/accounts/#qryFriends.userName#"><img src="#imgHREF#" border="0" align="absmiddle" width="30" height="30" style="border:1px solid white;"></a>
				<a href="/accounts/#qryFriends.userName#">#qryFriends.userName#</a>
				<cfif qryFriends.userName eq request.userInfo.userName><b>(me)</b></cfif>
				<br />
			</cfloop>
			
			<!--- Friend requests sent --->
			<cfif bIsOwner and qryMyFriendRequests.recordCount gt 0> 
				<div style="margin-top:8px;">
					<b>Waiting for approval:</b>
					<cfloop query="qryMyFriendRequests">
						<div style="margin-top:5px;">
							<cfset imgHREF = "/Accounts/#qryMyFriendRequests.sender#/avatar.jpg">
							<cfif Not fileExists(expandPath(imgHREF))>
								<cfset imgHREF = "/xilya/includes/images/avatar.jpg">
							</cfif>

							<a href="##"
								onclick="controlPanel.rejectFriendRequest('#jsstringFormat(qryMyFriendRequests.recipient)#')"><img src="/xilya/includes/images/waste_small.gif"
								 alt="Discard friend request" title="Discard friend request" style="margin-top:10px;" 
								 align="right" width="14" height="14" border="0" /></a>
							
							<img src="#imgHREF#" border="0" align="absmiddle" width="30" height="30" style="border:1px solid white;margin-right:5px;">
							#qryMyFriendRequests.recipient#
								
						</div>
					</cfloop>
				</div>
				<br style="clear:both;" />
			</cfif>
			
			<cfif bIsOwner>	
				<br />
				<a href="##" onclick="controlPanel.getView('AddFriend')" style="font-size:10px;"><b>Add/Invite Friend</b></a>
			</cfif>
		</div>		
		<div class="sidePanelDivider"></div>			
	</cfoutput>
	<br /><br />
</div>
