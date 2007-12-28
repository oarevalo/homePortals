<cfparam name="arguments.rss" default="">

<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();
		
	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";

	rssURL = cfg.getPageSetting("rss");
	targetID = cfg.getPageSetting("targetID");
	viewPanelID = moduleID & "Content";
	stUser = this.controller.getUserInfo();		
		
	if(arguments.rss neq "") rssURL = arguments.rss;
	
</cfscript>

<cfif rssURL neq "">
	<cfset feed = getRSS(rssURL)>
	<cfoutput>
		<cfif feed.Image.URL neq "">
			<a href="#feed.Image.Link#">
				<img src="#feed.Image.URL#" border="0" id="RSS_Image"
						title="#feed.Image.Title#" 
						alt="#feed.Image.Title#" /></a>
		</cfif>

		<div id="#moduleID#_RSSTitle">
			<a href="#feed.Link#" target="_blank">#feed.Title#</a>
			<a href="javascript:#moduleID#.getView('','#viewPanelID#',{rss:'#rssURL#',useLayout:false})"><img src="#imgRoot#/refresh.gif" alt="Refresh Feed" title="Refresh Feed" border="0" align="baseline"></a>&nbsp;
			<a href="#rssURL#" target="_blank"><img src="#imgRoot#/feed-icon16x16.gif" alt="View Feed XML" title="View Feed" border="0" align="baseline"></a>&nbsp;
		</div>
		
		<div class="#moduleID#_Divider"></div>
		<div id="#moduleID#Content_BodyRegion">
			#this.controller.render(rss = rssURL, useLayout=false)#
		</div>
		<div class="#moduleID#_Divider"></div>

		<cfif stUser.isOwner>
			<div id="#moduleID#_toolbar">
				<a href="javascript:#moduleID#.getView('config','#viewPanelID#',{useLayout:false});"><img src="/Home/Modules/RSSReader/images/edit-page-yellow.gif" border="0" align="absmiddle"></a>
				<a href="javascript:#moduleID#.getView('config','#viewPanelID#',{useLayout:false});">Change Feed URL</a>
			</div>
		</cfif>
	</cfoutput>
</cfif>