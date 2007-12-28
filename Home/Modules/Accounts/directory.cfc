<!--- Directory.cfm
This modules produces a directory of all accounts,
with links to their public pages
---->

<cfcomponent displayname="directory" extends="Home.Components.baseModule">
	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			cfg.setModuleClassName("directory");
			cfg.setView("default", "directory/main");
			cfg.setModuleRoot("/Home/Modules/Accounts/");

			// get handle fo accounts object --->
			variables.oAccounts = CreateObject("Component", "accounts");
		</cfscript>	
	</cffunction>
</cfcomponent>

