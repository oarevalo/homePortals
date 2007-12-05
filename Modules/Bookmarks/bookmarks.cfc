<cfcomponent displayname="bookmarks" extends="Home.Components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			cfg.setModuleClassName("bookmarks");
			cfg.setView("default", "main");
			cfg.setView("htmlHead", "HTMLHead");
		</cfscript>	
	</cffunction>

	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="url" type="string" default="">
		<cfargument name="followLink" type="string" default="false">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var tmpScript = "";
			
			cfg.setPageSetting("url", arguments.url);
			cfg.setPageSetting("followLink", arguments.followLink);
			this.controller.setMessage("Settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
		</cfscript>
	</cffunction>	

</cfcomponent>