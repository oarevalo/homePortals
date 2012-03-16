<!--- Login.cfm
This module allows users to login to their accounts.  
Also processes cookie logins.
---->

<cfcomponent displayname="login" extends="homePortals.plugins.modules.components.baseModule">
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
		<cfset var oHP = this.controller.getHomePortals()>
		<cfset var oAccountsPlugin = 0>
		<cfset var oAccountsService = 0>
		<cfset var appRoot = oHP.getConfig().getAppRoot()>	
		
		<cftry>
			<cfif not oHP.getPluginManager().hasPlugin("accounts")>
				<cfthrow message="Accounts plugin not found!">
			</cfif>
			
			<cfset oAccountsPlugin = oHP.getPluginManager().getPlugin("accounts")>
			<cfset oAccountsService = oAccountsPlugin.getAccountsService()>

			<!--- check login --->
			<cfset qryUser = oAccountsService.loginUser(arguments.username, Arguments.password)>

			<cfif rememberMe eq 1>
				<cfset userKey = encrypt(qryUser.accountID, getLocalSecret())>
				<cfcookie name="homeportals_username" value="#qryUser.accountname#" expires="never">			
				<cfcookie name="homeportals_userKey" value="#userKey#" expires="never">			
			</cfif>

			<cfset this.controller.setMessage("Welcome Back!")>
			<cfset this.controller.setScript("document.location='#appRoot#/?account=#qryUser.accountname#'")>
					
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

		<cfset var oHP = this.controller.getHomePortals()>
		<cfset var oAccountsPlugin = oHP.getPluginManager().getPlugin("accounts")>
		<cfset var oAccountsService = oAccountsPlugin.getAccountsService()>
		<cfset var decKey = "">
		<cfset var qry = 0>
		
		<cftry>
			<cfset decKey = decrypt(arguments.userKey, getLocalSecret())>
			<cfset qry = oAccountsService.getAccountByName(arguments.username)>
	
			<cfif decKey eq qry.accountID>
				<cfset qryUser = oAccountsService.loginUser(arguments.username, "", qry.password)>
			</cfif>

			<cfcatch type="any">
				<!--- if something happens, the clear cookies and abort login --->
				<cfset doLogoff()>
			</cfcatch>
		</cftry>
		
		<cfreturn>
	</cffunction>

	<!---------------------------------------->
	<!--- doLogoff        	               --->
	<!---------------------------------------->	
	<cffunction name="doLogoff" access="public" output="true">
		<cfset var oHP = this.controller.getHomePortals()>
		<cfset var oAccountsPlugin = oHP.getPluginManager().getPlugin("accounts")>
		<cfset var oAccountsService = oAccountsPlugin.getAccountsService()>
		<cfset var appRoot = oHP.getConfig().getAppRoot()>	

		<cfset oAccountsService.logoutUser()>

		<cfcookie name="homeportals_username" value="" expires="now">			
		<cfcookie name="homeportals_userKey" value="" expires="now">

		<cfset this.controller.setScript("document.location='#appRoot#'")>
			
	</cffunction>

	<!---------------------------------------->
	<!--- getLocalSecret   	               --->
	<!---------------------------------------->	
	<cffunction name="getLocalSecret" returntype="string">
		<cfset var localSecret = "En su grave rincon, los jugadores "
							& "rigen las lentas piezas. El tablero "
							& "los demora hasta el alba en su severo "
							& "ambito en que se odian dos colores. ">
		<cfreturn localSecret>
	</cffunction>
	
	<!---------------------------------------->
	<!--- throw                            --->
	<!---------------------------------------->
	<cffunction name="throwException" access="private">
		<cfargument name="message" type="string" required="yes">
		<cfthrow message="#arguments.message#">
	</cffunction>
	
</cfcomponent>
	