<cfcomponent displayname="contentBox" extends="htmlBox">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setModuleClassName("contentBox");
			cfg.setView("default", "main");
			
			variables.resourceType = "content";
		</cfscript>	
	</cffunction>
	
</cfcomponent>