<cfparam name="arguments.rss" default="">
<cfparam name="arguments.refresh" default="false">

<cfscript>
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	execMode = this.controller.getExecMode();	

	// reader settings
	rssURL = cfg.getPageSetting("rss");
	
	// user info
	stUser = this.controller.getUserInfo();

	// this is to allow overriding of the page setting
	if(arguments.rss neq "") rssURL = arguments.rss;

	// get images path
	imgRoot = tmpModulePath & "/images";
</cfscript>

<cfoutput>
	<cfif rssURL neq "">
		<cfif execMode neq "local">
			#this.controller.renderView(view = 'feed', useLayout=false)#
		<cfelse>
			<p style="font-size:10px;">Loading feed. Please wait...</p>
			
			<script>
				#moduleID#.attachIcon("#imgRoot#/refresh.gif","#moduleID#.getView('feed','',{rss:'#rssURL#',useLayout:false,refresh:true})","Refresh content");
				#moduleID#.attachIcon("#imgRoot#/feed-icon16x16.gif","window.open('#rssURL#')","View feed source");
				#moduleID#.getView("feed");
			</script>
	
			<cfif stUser.isOwner>
				<div class="SectionToolbar">
					<a href="javascript:#moduleID#.getView('config');"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
					<a href="javascript:#moduleID#.getView('config');">Settings</a>
					<a href="javascript:#moduleID#.getPopupView('directory');"><img src="#imgRoot#/page_white_text.png" border="0" align="absmiddle"></a>
					<a href="javascript:#moduleID#.getPopupView('directory');">Feed Directory</a>&nbsp;&nbsp;
				</div>
			</cfif>
		</cfif>
	<cfelse>
		<cfif stUser.isOwner>
			#this.controller.renderView(view = 'config', useLayout=false)#
		<cfelse>
			<em>No RSS feed has been set.</em>
		</cfif>
	</cfif>
</cfoutput>
