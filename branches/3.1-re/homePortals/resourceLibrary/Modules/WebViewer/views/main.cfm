<cfparam name="arguments.url" default="">

<cfscript>
	cfg = this.controller.getModuleConfigBean();
	href = cfg.getPageSetting("url");
	width = cfg.getPageSetting("width");
	height = cfg.getPageSetting("height");
	scrolling = cfg.getPageSetting("scrolling","auto");
	title = cfg.getPageSetting("title");
	if(arguments.url neq "") href = arguments.url;

	if(scrolling eq "") scrolling = "auto";
	if(width eq "") width = "100%";
	if(height eq "") height = "200";
	
	// if url starts with www. then prepend the http:// by default
	if(left(href,4) eq "www.")
		href = "http://" & href;
	
	// get the moduleID
	moduleID = this.controller.getModuleID();

	// get user info
	stUser = this.controller.getUserInfo();	

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
</cfscript>

<cfoutput>
	<cfif href neq "">
		<iframe src="#href#" width="#width#" height="#height#" id="ifr#moduleID#" frameborder="0" scrolling="#scrolling#"></iframe>
		<cfif title eq "" or title eq "WebViewer/WebViewer">
			<script>
				h_setModuleContainerTitle("#moduleID#", "#jsstringformat(href)#");
			</script>
		</cfif>
	<cfelse>
		Website URL not set.
	</cfif>
	<cfif stUser.isOwner>
		<div class="SectionToolbar">
			<a href="javascript:#moduleID#.getView('config','#moduleID#');"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
			<a href="javascript:#moduleID#.getView('config','#moduleID#');">Settings</a>
		</div>
	</cfif>
</cfoutput>
		
