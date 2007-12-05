<cfcomponent displayname="EpochCalendar" extends="Home.Components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();

			cfg.setModuleClassName("EpochCalendar");
			cfg.setView("default", "main");
			cfg.setView("htmlHead", "HTMLHead");
		</cfscript>	
	</cffunction>

</cfcomponent>
