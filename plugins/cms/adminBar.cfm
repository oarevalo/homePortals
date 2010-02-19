<cfparam name="url._statusMessage" default="">

<cfif structKeyExists(url,"admin")>
	<cfcookie name="cmsShowAdminBar" value="1">
<cfelseif structKeyExists(url,"noadmin")>
	<cfcookie name="cmsShowAdminBar" expires="now" value="">
</cfif>

<cfif not structKeyExists(cookie,"cmsShowAdminBar") or cookie.cmsShowAdminBar eq "">
	<cfoutput><script>jQuery.noConflict();</script></cfoutput>
	<cfexit method="exittemplate">
</cfif>

<cfsilent>
	<cfscript>
		oHP = getHomePortals();
		appRoot = oHP.getConfig().getAppRoot();
		cmsRoot = oHP.getPluginManager().getPlugin("cms").getCMSRoot();
		gateway = oHP.getPluginManager().getPlugin("cms").getCMSGateway();

		// get page object
		currentPage = getPageHREF();
		currentPath = getDirectoryFromPath(currentPage);

		// Get information on any currently logged-in user
		oUserRegistry = createObject("Component","homePortals.components.userRegistry").init();
		userInfo = oUserRegistry.getUserInfo();	// information about the logged-in user
		bUserLoggedIn = (userInfo.userName neq "");
		
		pageTitle = getPage().getTitle();
		aLayoutRegions = getPage().getLayoutRegions();
		
		// make a js struct with page locations
		lstLocations = "";
		for(i=1;i lte arrayLen(aLayoutRegions);i++) {
			tmp = "#aLayoutRegions[i].id#: { id:'#aLayoutRegions[i].id#', name:'#aLayoutRegions[i].name#', type:'#aLayoutRegions[i].type#', theClass:'#aLayoutRegions[i].class#' }";
			lstLocations = listAppend(lstLocations, tmp);
		}
		
		// make a js struct with modules on this page
		aModules = getPage().getModules();
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
			_pageHREF = "#currentPage#";
			_pageFileName = "#getFileFromPath(currentPage)#";
			
			var controlPanel = new controlPanelClient();
			controlPanel.init("#appRoot#/#gateway#", "#cmsRoot#", stLocations);
			
			<cfif bUserLoggedIn>
				// setup UI
				jQuery(function() {
					controlPanel.setStatusMessage("attaching module icons...",700);
					for(var i=0;i<stModules.length;i++) {
						jQuery("##"+stModules[i])
							.prepend("<div class='cms-moduleHandleBar'>" + stModules[i] + controlPanel.getModuleIconsHTML(stModules[i]) + "</div>");
					}
				
					controlPanel.setStatusMessage("enabling drag and drop...",700);
					for(loc in controlPanel.locations) {
						jQuery("##"+controlPanel.locations[loc].id)
							.addClass("cms-layoutRegion")
							.prepend("<div class='cms-layoutRegionHandleBar'>" + controlPanel.locations[loc].name + controlPanel.getLocationIconsHTML(controlPanel.locations[loc].name) + "</div>");
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
					jQuery("##cms-btnEditPage").click(function(){ controlPanel.getView("PageProperties"); });
					jQuery("##cms-btnSitemap").click(function(){ controlPanel.getView("SiteMap"); });
					jQuery("##cms-btnSettings").click(function(){ controlPanel.getView("Settings"); });
					jQuery("##cms-btnAddContent").click(function(){ controlPanel.getView("AddContent"); });
					jQuery("##cms-btnLogout").click(function(){ navCmdLogout(); });
				});
			</cfif>
		</script>
	</cfsavecontent>
	<cfhtmlhead text="#tmpHTML#">

	<!--- check if there are users created --->
	<cfset qryUserCheck = getHomePortals().getCatalog().getResourcesByType("cmsUser")>
	<cfif qryUserCheck.recordCount eq 0>
		<cfinclude template="views/vwCreateUser.cfm">
		<cfexit method="exittemplate">
	</cfif>
			
	<script>jQuery.noConflict();</script>		
			
	<div id="cms-adminBar" style="padding-top:5px;">
		<div id="cms-adminBarActions">
			<cfif bUserLoggedIn>
				<a href="##" onclick="navCmdAddPage('#currentPath#')"><img src="#cmsRoot#/images/btnAddPage.gif" align="absmiddle" alt="Add Page" title="Add Page"></a>
				<a href="##" id="cms-btnAddContent"><img src="#cmsRoot#/images/btnAddContent.gif" align="absmiddle" alt="Add Content" title="Add Content"></a>
				<a href="##" id="cms-btnLogout"><img src="#cmsRoot#/images/btnLogOff.gif" align="absmiddle" alt="Log Off" title="Log Off"></a>
				<a href="##" id="cms-btnSettings"><img src="#cmsRoot#/images/cog.png" align="absmiddle" alt="Settings" title="Settings"></a>
				<a href="#cgi.script_name#?noadmin"><img src="#cmsRoot#/images/closePanel.gif" align="absmiddle" alt="Hide admin controls" title="Hide admin controls"></a>
			<cfelse>
				<form name="frmLogin" action="##" method="post">
					User: <input type="text" name="username" value="" style="width:100px;">
					Password: <input type="password" name="password" value="" style="width:100px;">
					<input type="button" value="Login" name="btnLogin" onclick="navCmdLogin(this.form)">
				</form>
			</cfif>
		</div>
		<span id="cms-mainTitle">#application.applicationName#</span>
	</div>
	<div id="cms-adminSubBar" style="margin-bottom:5px;padding-left:4px;">
		<div id="cms-statusMessage"></div>
		Current Page: <span style="font-size:13px;font-weight:bold;">#currentPage#</span>
		<cfif bUserLoggedIn>
			&nbsp;|&nbsp;
			<a href="##" id="cms-btnEditPage">Page Settings</a>
			&nbsp;&nbsp;
			<a href="##" id="cms-btnSitemap">Site Pages</a>
		</cfif>
	</div>
	<div id="cms-navMenuContentPanel" class="cms-panel" style="display:none;">
	</div>
	
	<cfif url._statusMessage neq "">
		<script>
			controlPanel.setStatusMessage("#jsstringformat(url._statusMessage)#");
		</script>
	</cfif>
	
</cfoutput>

