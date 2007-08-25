<cfcomponent displayname="button" extends="Home.Components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			
			cfg.setModuleClassName("button");
			cfg.setView("default", "button");
		</cfscript>	
	</cffunction>
	
	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="label" type="string" default="">
		<cfargument name="onClick" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setPageSetting("label", arguments.label);
			cfg.setPageSetting("onClick", arguments.onClick);

			this.controller.setMessage("Settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
		</cfscript>
	</cffunction>	

</cfcomponent>