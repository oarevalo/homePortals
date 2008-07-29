
<!--- get account config --->
<cfif Not IsDefined("application.HomePortalsAccountsConfig")>
	<cfset variables.oAccounts.loadConfig()>
	<cflock scope="application" type="exclusive" timeout="10">
		<cfset application.HomePortalsAccountsConfig = duplicate(variables.oAccounts.getConfig())>
	</cflock>
<cfelse>
	<cfset variables.oAccounts.setConfig(application.HomePortalsAccountsConfig)>
</cfif>

<!--- get recent users --->
<cfset qryAccs = variables.oAccounts.GetUsers()>

<!--- get accounts root --->
<cfset accountsRoot = variables.oAccounts.getConfig().accountsRoot>

<b>Recently Created Accounts:</b><br>
<cfoutput query="qryAccs" maxrows="10">
	<li><a href="#accountsRoot#/#Username#">#Username#</a></li>
</cfoutput>

<cfif qryAccs.recordCount eq 0>
	<em>There are no accounts yet.</em>
</cfif>

<cfif qryAccs.recordCount gt 10>
	and more...
</cfif>

