<cfcomponent displayname="youTubeSearch" extends="youTubeModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			
			cfg.setModuleClassName("youTubeSearch");
			cfg.setView("default", "search");
		</cfscript>	
	</cffunction>
	
	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="onClickGotoURL" type="boolean" default="false">
		<cfargument name="mode" type="string" default="">
		<cfargument name="term" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setPageSetting("onClickGotoURL", arguments.onClickGotoURL);
			cfg.setPageSetting("mode", arguments.mode);
			cfg.setPageSetting("term", term);

			this.controller.setMessage("Settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
		</cfscript>
	</cffunction>	

</cfcomponent>