<cfscript>
	cfg =  this.controller.getModuleConfigBean();
	moduleID = this.controller.getModuleID();

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
	
	stUser = this.controller.getUserInfo();	

	// get settings
	label = cfg.getPageSetting("label","");
	onClick = cfg.getPageSetting("onClick","");

</cfscript>

<cfoutput>
	<p align="center">
		<input type="button" name="btn#moduleID#" onclick="#moduleID#.raiseEvent('onClick');#onclick#" value="#label#">
	</p>
	
	<cfif stUser.isOwner>
		<div class="SectionToolbar">
			<a href="javascript:#moduleID#.getView('configButton');"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
			<a href="javascript:#moduleID#.getView('configButton');">Settings</a>
		</div>
	</cfif>		
</cfoutput>
	