<cfcomponent displayname="image" extends="Home.Components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			
			cfg.setModuleClassName("image");
			cfg.setView("default", "image");
		</cfscript>	
	</cffunction>
	
	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="src" type="string" default="">
		<cfargument name="href" type="string" default="">
		<cfargument name="label" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setPageSetting("src", arguments.src);
			cfg.setPageSetting("href", arguments.href);
			cfg.setPageSetting("label", arguments.label);

			this.controller.setMessage("Settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
		</cfscript>
	</cffunction>	

</cfcomponent>