<cfcomponent displayname="google" extends="Home.Components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();

			cfg.setModuleClassName("Google");
			cfg.setView("default", "main");
		</cfscript>	
	</cffunction>


</cfcomponent>