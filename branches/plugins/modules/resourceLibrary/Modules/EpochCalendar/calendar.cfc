<cfcomponent displayname="EpochCalendar" extends="homePortals.plugins.modules.components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();

			cfg.setModuleClassName("EpochCalendar");
			cfg.setView("default", "main");
			cfg.setView("htmlHead", "HTMLHead");
		</cfscript>	
	</cffunction>

</cfcomponent>
