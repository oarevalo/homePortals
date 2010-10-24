<cfparam name="url._statusMessage" default="">

<cfsilent>
	<cfscript>
		oHP = application.homePortals;
		oAccountsService = oHP.getPluginManager().getPlugin("accounts").getAccountsService();
		
		currentPage = request.oPageRenderer.getPageHREF();

		// create page object
		request.oPage = request.oPageRenderer.getPage();

		// get page owner
		siteOwner = "";
		if(request.oPage.hasProperty("owner")) siteOwner = request.oPage.getProperty("owner");
		
		// create site object
		if(siteOwner neq "") {
			request.oSite = oAccountsService.getSite(siteOwner);
			siteTitle = request.oSite.getSiteTitle();	
			aPages = request.oSite.getPages();
		} else {
			siteTitle = "StartPage";
			aPages = [{title="Home",href="default"}];
			request.oSite = 0;
		}
		
		// Get information on any currently logged-in user
		oUserRegistry = createObject("Component","homePortals.components.userRegistry").init();
		request.userInfo = oUserRegistry.getUserInfo();	// information about the logged-in user
		bUserLoggedIn = (request.userInfo.userName neq "");
		bIsOwner = (request.userInfo.userName eq siteOwner); 
		
		pageTitle = request.oPage.getTitle();
		aLayoutRegions = request.oPage.getLayoutRegions();
		
		// if this page doesnt have any layout, it could be that we are inheriting the layout from a parent page
		if(arrayLen(aLayoutRegions) eq 0) {
			if(getPage().hasProperty("extends") and getPage().getProperty("extends") neq "") {
				p = getParsedPageData();
				for(tmp in p.layout) {
					aLayoutRegions.addAll(p.layout[tmp]);
				}
			}
		}

		// make a js struct with page locations
		lstLocations = "";
		for(i=1;i lte arrayLen(aLayoutRegions);i++) {
			tmp = "#aLayoutRegions[i].id#: { id:'#aLayoutRegions[i].id#', name:'#aLayoutRegions[i].name#', type:'#aLayoutRegions[i].type#', theClass:'#aLayoutRegions[i].class#'}";
			lstLocations = listAppend(lstLocations, tmp);
		}

		// make a js struct with modules on this page
		aModules = request.oPage.getModules();
		lstModules = "";
		for(i=1;i lte arrayLen(aModules);i++) {
			lstModules = listAppend(lstModules, "'" & aModules[i].getid() & "'");
		}
	</cfscript>	
</cfsilent>


<!--- display site map --->	
<cfoutput>
	<!--- include css and javascript --->
	<cfsavecontent variable="tmpHTML">
		<script type="text/javascript">
			// initialize control panel client
			stLocations = {#lstLocations#};
			stModules = [#lstModules#];
			
			var controlPanel = new controlPanelClient();
			controlPanel.init("includes/controlPanelGateway.cfm", stLocations);
			
			<cfif bUserLoggedIn and bIsOwner>
			// setup UI
			jQuery(function() {
				controlPanel.setStatusMessage("attaching module handles...",700);
				for(var i=0;i<stModules.length;i++) {
					jQuery("##"+stModules[i]+"_Head")
						.addClass("cms-moduleHandleBar");
				}

				controlPanel.setStatusMessage("enabling drag and drop...",700);
				for(loc in controlPanel.locations) {
					jQuery("##"+controlPanel.locations[loc].id)
						.addClass("cms-layoutRegion")
				}

				jQuery(".cms-layoutRegion").sortable({
					connectWith: '.cms-layoutRegion',
				    forcePlaceholderSize: true,
				    placeholder: 'cms-layoutRegionPlaceHolder',
				    opacity: 0.6,
				    delay:100,
				    distance:5,
				    handle: '.cms-moduleHandleBar',
				    tolerance: 'pointer',
				    
				    start: function(event,ui) {
						jQuery(".cms-layoutRegion")
							.addClass("cms-layoutRegionHighlighted");
					},
				    stop: function(event,ui) {
						jQuery(".cms-layoutRegion")
							.removeClass("cms-layoutRegionHighlighted");
						controlPanel.updateLayout();
					}
				
				});	
				jQuery(".cms-layoutRegion").disableSelection();
				attachModuleIcons();
				attachLayoutHolders();
			});
			</cfif>
		</script>
	</cfsavecontent>
	<cfhtmlhead text="#tmpHTML#">

	<div id="navMenu" style="padding-top:5px;">
		<div id="anchorAddContent" style="float:right;padding-right:10px;padding-top:3px;">
			<cfif bUserLoggedIn and bIsOwner>
				<a href="##" onclick="navCmdAddPage()"><img src="images/btnAddPage.gif" align="absmiddle" style="margin-left:5px;" border="0" alt="Add Page" title="Add Page"></a>
				<a href="##" onclick="navCmdAddContent()"><img src="images/btnAddContent.gif" align="absmiddle" style="margin-left:5px;" alt="Add Content" title="Add Content" border="0"></a>
				<a href="##" onclick="navCmdSetLayout()"><img src="images/layout.png" align="absmiddle" style="width:13px;margin-left:5px;padding:3px;background-color:##fff;" alt="Change page layout" title="Change page layout" border="0"></a>
				<a href="includes/controlPanelGateway.cfm?method=doLogout&_pageHREF=#currentPage#"><img src="images/btnLogOff.gif" align="absmiddle" style="margin-left:5px;" alt="Log Off" border="0" title="Log Off"></a>
			<cfelseif bUserLoggedIn>
				<a href="index.cfm?account=#request.userInfo.userName#" style="color:##fff;">My Site</a>
				<a href="includes/controlPanelGateway.cfm?method=doLogout&_pageHREF=#currentPage#"><img src="images/btnLogOff.gif" align="absmiddle" style="margin-left:5px;" alt="Log Off" border="0" title="Log Off"></a>
			<cfelse>
				<form name="frmLogin" action="includes/controlPanelGateway.cfm" method="post">
					<input type="hidden" name="method" value="doLogin">
					<input type="hidden" name="_pageHREF" value="#currentPage#">
					User: <input type="text" name="username" value="" style="font-size:10px;width:100px;">
					Password: <input type="password" name="password" value="" style="font-size:10px;width:100px;">
					<input type="submit" value="Login" name="btnLogin" style="font-size:10px;">
				</form>
			</cfif>
		</div>
		<span id="siteMapTitle">
			<span id="siteMapTitle_label" <cfif bUserLoggedIn and bIsOwner>onclick="controlPanel.rename('siteMapTitle','#siteTitle#','Site')" title="Click to rename site"</cfif>>#siteTitle#</span>
		</span>
	</div>
	<div id="navMenuTitles">
		<div id="siteMapStatusBar"></div>
		
		<cfloop from="1" to="#arrayLen(aPages)#" index="i">
			<cfset thisPageHREF = "index.cfm?account=" & siteOwner & "&page=" & replace(aPages[i].href,".xml","")>
			<cfset thisPageHREF = replace(thisPageHREF, "//", "/", "ALL")> <!--- get rid of duplicate forward slash (will cause problems for sites at webroot)--->
			&nbsp;&nbsp;
			<cfif aPages[i].href eq getFileFromPath(currentPage)>
				<span id="pageTitle" <cfif bUserLoggedIn and bIsOwner>title="Click to rename or delete page"</cfif>>
					<span id="pageTitle_label" <cfif bUserLoggedIn and bIsOwner>onclick="controlPanel.rename('pageTitle','#pageTitle#','Page')"</cfif>>#pageTitle#</span>
				</span>
			<cfelse>
				<a href="#thisPageHREF#" class="pageTitle">#aPages[i].title#</a>
			</cfif>
		</cfloop>
	</div>
	
	<cfif url._statusMessage neq "">
		<script>
			controlPanel.setStatusMessage("#jsstringformat(url._statusMessage)#");
			alert("#jsstringformat(url._statusMessage)#");
		</script>
	</cfif>
	
</cfoutput>


