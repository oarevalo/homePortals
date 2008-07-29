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
		
	<!--- include javascript --->
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
	<cfoutput><div id="anchorAddContent"><div id="anchorAddContent_BodyRegion"></div></div></cfoutput>

	<!--- check if this is a private page --->
	<cfloop from="1" to="#ArrayLen(aPages)#" index="i">
		<cfset thisPage = aPages[i].xmlAttributes>
	
		<cfparam name="thisPage.private" default="false">

		<cfset isPrivate = thisPage.private>
		<cfset thisPageHREF = "home.cfm?currentHome=#obj.baseDir##thisPage.href#">

		<!--- if this is a private page and current user is not owner, then get out --->
		<cfif isPrivate and Not stUser.isOwner and thisPage.href eq currentPage>
			<cflocation url="/">
		</cfif>
	</cfloop>
	
	<cfcatch type="any">
		<cfoutput>SiteMap Error: #cfcatch.Message#</cfoutput>
	</cfcatch>
</cftry>
