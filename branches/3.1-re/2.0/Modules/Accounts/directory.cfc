<!--- Directory.cfm
This module produces a directory of all accounts,
with links to their public pages
---->

<cfcomponent displayname="directory" extends="Home.Components.baseModule">
	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			cfg.setModuleClassName("directory");
			cfg.setView("default", "directory/main");

			// get handle fo accounts object --->
			variables.oAccounts = this.controller.getAPIObject("accounts");
			variables.oAccounts.init();
		</cfscript>	
	</cffunction>
</cfcomponent>

