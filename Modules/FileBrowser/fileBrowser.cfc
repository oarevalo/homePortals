<cfcomponent displayname="fileBrowser" extends="Home.Components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			cfg.setModuleClassName("fileBrowser");
			cfg.setView("default", "main");
			cfg.setView("htmlHead", "htmlHead");
		</cfscript>	
	</cffunction>


	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="root" type="string" default="">
		<cfargument name="filter" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var tmpStructName = "_" & moduleID;
			
			cfg.setPageSetting("root", arguments.root);
			cfg.setPageSetting("filter", arguments.filter);
			this.controller.setMessage("Settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
			
			// delete temp session
			StructDelete(session, tmpStructName);
		</cfscript>
	</cffunction>	
		
</cfcomponent>