<cfsilent>
	<cfscript>
		oHP = application.homePortals;
		oAccountsService = oHP.getAccountsService();
		
		appRoot = oHP.getConfig().getAppRoot();
		currentPage = request.oPageRenderer.getPageHREF();

		// create page object
		request.oPage = CreateObject("component", "Home.Components.page").init(currentPage);

		// get page owner
		siteOwner = request.oPage.getOwner();
		pageAccess = request.oPage.getAccess();
		
		// create site object
		request.oSite = CreateObject("component", "Home.Components.site").init(siteOwner, oAccountsService);


		// Get information on any currently logged-in user
		oUserRegistry = createObject("Component","Home.Components.userRegistry").init();
		request.userInfo = oUserRegistry.getUserInfo();	// information about the logged-in user
		bUserLoggedIn = (request.userInfo.userName neq "");
		bIsOwner = (request.userInfo.userName eq siteOwner); 
		
		pageTitle = request.oPage.getPageTitle();
		qryLocations = request.oPage.getLocations();
		siteTitle = request.oSite.getSiteTitle();
		
	</cfscript>	
	
	<!--- make a js struct with page locations --->
	<cfset lstLocations = "">
	<cfoutput query="qryLocations">
		<cfset tmp = "#id#: { id:'#id#', name:'#name#', type:'#type#', theClass:'#class#' }">
		<cfset lstLocations = listAppend(lstLocations, tmp)>
	</cfoutput>
</cfsilent>

<!--- if current user is not owner, then get out
<cfif Not stUser.isOwner>
	<cflocation url="/index.cfm">
</cfif> 
--->

<!--- display site map --->	
<cfoutput>
	<!--- include css and javascript --->
	<cfsavecontent variable="tmpHTML">
		<script type="text/javascript">
			// initialize control panel client
			stLocations = {#lstLocations#};
			_pageHREF = "#currentPage#";
			
			var controlPanel = new controlPanelClient();
			controlPanel.init(stLocations);
			
			<cfif bIsOwner>
			// setup UI
			addEvent(window, 'load', startDragDrop);
			addEvent(window, 'load', attachModuleIcons);
			addEvent(window, 'load', attachLayoutHolders);
			</cfif>
		</script>
	</cfsavecontent>
	<cfhtmlhead text="#tmpHTML#">

	<div id="navMenu" style="padding-top:10px;">
		<div id="anchorAddContent" style="float:right;margin-top:5px;">
			<div id="anchorAddContent_BodyRegion" style="padding-right:10px;">
				<cfif bUserLoggedIn>
					<b>Logged in as:</b> #request.userInfo.username#
					(<a href="##" onclick="controlPanel.doLogoff('side_status')" style="text-decoration:underline;color:##fff;font-size:9px;">Log Off</a>)
					<div style="margin-top:10px;font-size:12px;text-align:right;">
						<cfif not bIsOwner>
							<a href="/Accounts/#request.userInfo.userName#" style="text-decoration:underline;color:##fff;font-size:11px;">My Workarea</a> &nbsp;|&nbsp;
						</cfif>
						<a href="#request.homePagePath#/index.cfm?event=ehProfile.dspProfile" style="text-decoration:underline;color:##fff;font-size:11px;">My Account</a>
					</div>
				<cfelse>
					<a href="#request.homePagePath#/index.cfm?event=ehGeneral.dspLogin" style="color:##fff;">Click Here to Log In</a>
				</cfif>
			</div>
		</div>
	</div>
	<div id="navMenuTitles">
		<cfif pageAccess eq "owner">
			<img src="/xilya/includes/images/lock.png" 
					alt="This is a private page" 
					title="This is a private page" 
					border="0" align="absbottom"
					style="padding-left:5px;padding-bottom:2px;">		
		</cfif>

		<div id="siteMapStatusBar_BodyRegion"></div>
		<span id="siteMapTitle" <cfif bIsOwner>onclick="controlPanel.rename('siteMapTitle','#siteTitle#','Site')"</cfif> title="Click to rename workarea">#siteTitle#</span>
		 : 
		<span id="pageTitle" <cfif bIsOwner>onclick="controlPanel.rename('pageTitle','#pageTitle#','Page')"</cfif> title="Click to rename workspace">#pageTitle#</span>

	</div>
</cfoutput>

