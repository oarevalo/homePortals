<cfcomponent displayname="EpochCalendar" extends="homePortalsModules.components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();

			cfg.setModuleClassName("EpochCalendar");
			cfg.setView("default", "main");
			cfg.setView("htmlHead", "HTMLHead");
		</cfscript>	
	</cffunction>

</cfcomponent>
