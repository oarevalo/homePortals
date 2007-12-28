<cfscript>
	cfg =  this.controller.getModuleConfigBean();
	moduleID = this.controller.getModuleID();

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
	
	stUser = this.controller.getUserInfo();	

	// get settings
	src = cfg.getPageSetting("src","");
	href = cfg.getPageSetting("href","");
	label = cfg.getPageSetting("label","");

</cfscript>

<cfoutput>
	<p align="center">
		<cfif src neq "">
			<cfif href neq "">
				<a href="#href#"><img src="#src#" title="#label#" alt="#label#" border="0"></a>
			<cfelse>
				<img src="#src#" title="#label#" alt="#label#" border="0">
			</cfif>
		<cfelse>
			<b><em>No image set</em></b>
		</cfif>
	</p>

	<!--- set module title --->
	<cfif label neq "">
		<script>
			h_setModuleContainerTitle("#moduleID#", "#label#");
		</script>
	</cfif>
	
	<cfif stUser.isOwner>
		<div class="SectionToolbar">
			<a href="javascript:#moduleID#.getView('configImage');"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
			<a href="javascript:#moduleID#.getView('configImage');">Settings</a>
		</div>
	</cfif>		
</cfoutput>
	