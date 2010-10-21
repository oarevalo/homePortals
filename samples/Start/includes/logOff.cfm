<!--- logOff.cfm

this template logs out a person from the site

--->

<cftry>
	<cfset oAccounts = application.homePortals.getPluginManager().getPlugin("accounts").getAccountsService()>
	<cfset oAccounts.logoutUser()>

	<cflocation url="../index.cfm">
			
	<cfcatch type="any">
		<cflocation url="../index.cfm">
	</cfcatch>
</cftry>
