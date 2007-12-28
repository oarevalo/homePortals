<!--- Login.cfm
This module allows users to login to their accounts. Displays
a login/register form on the page. Also processes cookie logins.
---->

<cfcomponent displayname="login" extends="Home.Components.baseModule">
	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			cfg.setModuleClassName("login");
			cfg.setView("default", "login/main");
			cfg.setView("htmlhead", "login/htmlHead");
			cfg.setModuleRoot("/Home/Modules/Accounts/");

			// get handle fo accounts object --->
			variables.oAccounts = CreateObject("Component", "accounts");
		</cfscript>	
	</cffunction>
</cfcomponent>
	