<cfcomponent displayname="google" extends="homePortals.plugins.modules.components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();

			cfg.setModuleClassName("Google");
			cfg.setView("default", "main");
			cfg.setView("htmlhead", "HTMLHead");
		</cfscript>	
	</cffunction>

	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="searchers" type="string" default="">
		<cfargument name="localSearchCenterPoint" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setPageSetting("searchers", arguments.searchers);
			cfg.setPageSetting("localSearchCenterPoint", arguments.localSearchCenterPoint);

			this.controller.setMessage("Google Search settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
		</cfscript>
	</cffunction>	

</cfcomponent>