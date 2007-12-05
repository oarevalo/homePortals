<!--- Login.cfm
This module allows users to login to their accounts.  
Also processes cookie logins.
---->

<cfcomponent displayname="login" extends="Home.Components.baseModule">
	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			cfg.setModuleClassName("login");
			cfg.setView("default", "main");
		</cfscript>	
	</cffunction>


	<!---------------------------------------->
	<!--- doLogin        	               --->
	<!---------------------------------------->	
	<cffunction name="doLogin" access="public" output="true">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="rememberMe" default="false" type="boolean" required="no">

		<cfset var qryUser = QueryNew("")>
		<cfset var oAccounts = application.homePortals.getAccountsService()>
		<cfset var accountsRoot = oAccounts.getConfig().getAccountsRoot()>
		<cfset var appRoot = this.controller.getHomePortalsConfigBean().getAppRoot()>	
		
		<cftry>
			<!--- check login --->
			<cfset qryUser = oAccounts.loginUser(arguments.username, Arguments.password)>

			<cfif rememberMe eq 1>
				<cfcookie name="homeportals_username" value="#qryUser.username#" expires="never">			
				<cfcookie name="homeportals_userKey" value="#Hash(localSecret)#" expires="never">			
			</cfif>
			<cfset this.controller.setMessage("Welcome Back!")>

			<cfset this.controller.setScript("document.location='#appRoot#'")>
					
			<cfcatch type="any">
				<cfset this.controller.setMessage(jsstringformat(cfcatch.Message))>
			</cfcatch>
		</cftry>
	</cffunction>
	

	<!---------------------------------------->
	<!--- doCookieLogin        	           --->
	<!---------------------------------------->	
	<cffunction name="doCookieLogin" access="public" output="true">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="userkey" type="string" required="yes">
		<cfthrow message="cookie login is not implemented yet">
		<cfreturn>
	</cffunction>

	<!---------------------------------------->
	<!--- doLogoff        	               --->
	<!---------------------------------------->	
	<cffunction name="doLogoff" access="public" output="true">

		<cfset var oAccounts = application.homePortals.getAccountsService()>
		<cfset var appRoot = this.controller.getHomePortalsConfigBean().getAppRoot()>	

		<cfset oAccounts.logoutUser()>

		<cfcookie name="homeportals_username" value="" expires="now">			
		<cfcookie name="homeportals_userKey" value="" expires="now">

		<cfset this.controller.setScript("document.location='#appRoot#'")>
			
	</cffunction>

	<!---------------------------------------->
	<!--- throw                            --->
	<!---------------------------------------->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string" required="yes">
		<cfthrow message="#arguments.message#">
	</cffunction>
	
</cfcomponent>
	