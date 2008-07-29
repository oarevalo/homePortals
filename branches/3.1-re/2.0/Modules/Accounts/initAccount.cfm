<cftry>
	<cfsilent>
		<cfscript>
		hpRoot = application.homePortalsRoot;
		currentPage = cookie.hp_currentHome;
		siteOwner = ListGetAt(currentPage, 2, "/");
		moduleLibraryPath = hpRoot & "/Modules/";
		
		// get account info
		qryAccount = application.accountsManager.getAccountByUsername(siteOwner);
		
		// create site object
		oSite = CreateObject("component", hpRoot & "/Components/site");
		oSite.init(qryAccount.userID, application.accountsManager);
		
		// check if there is any user logged in
		if(structKeyExists(session, "homeConfig") and structKeyExists(session, "User")) {
			if(isStruct(session.user) and structKeyExists(session.user, "qry")) {
				stUser.username = session.user.qry.username;
				stUser.isOwner = (session.user.qry.username eq siteOwner);
			}
		}	
		
		// get accounts settings
		stAccountsConfig = application.accountsManager.getConfig(); 
		accountsRoot = stAccountsConfig.accountsRoot;
		
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
	
	<div id="anchorAddContent"><div id="anchorAddContent_BodyRegion"></div></div>

	<cfloop from="1" to="#ArrayLen(aPages)#" index="i">
		<cfset thisPage = aPages[i]>
		<cfparam name="thisPage.private" default="false">
		<cfparam name="thisPage.showInNav" default="true">
		<cfset isPrivate = thisPage.private>

		<!--- if this is a private page and current user is not owner, then get out --->
		<cfif isPrivate and Not stUser.isOwner and thisPage.href eq currentPage>
			<cflocation url="#hpRoot#/Common/Templates/noaccess.cfm">
		</cfif>
	</cfloop>
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


