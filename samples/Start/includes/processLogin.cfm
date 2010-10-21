<!--- processLogin.cfm 

This template checks the login information 

--->

<cfparam name="username" default="">
<cfparam name="password" default="">
<cfparam name="rememberMe" default="0">

<cfset localSecret = "En su grave rincon, los jugadores "
							& "rigen las lentas piezas. El tablero "
							& "los demora hasta el alba en su severo "
							& "ambito en que se odian dos colores. ">

<cftry>
	<cfset oAccountsService = application.homePortals.getPluginManager().getPlugin("accounts").getAccountsService()>

	<!--- check login --->
	<cfset qryAccount = oAccountsService.loginUser(username, password)>

	<cfif rememberMe eq 1>
		<cfset userKey = encrypt(qryAccount.accountID, localSecret)>
		<cfcookie name="homeportals_username" value="#qryAccount.accountName#" expires="never">			
		<cfcookie name="homeportals_userKey" value="#userKey#" expires="never">			
	</cfif>

	<cflocation url="../index.cfm?account=#qryAccount.accountName#">
			
	<cfcatch type="homePortals.accounts.invalidLogin">
		<cflocation url="../index.cfm?_statusMessage=Invalid%20Login">
	</cfcatch>		
	<cfcatch type="any">
		<cflocation url="../index.cfm?_statusMessage=#cfcatch.message#">
	</cfcatch>
</cftry>
