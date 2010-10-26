<cfset accounts = getHomePortals().getPluginManager().getPlugin("accounts").getAccountsService()>
<cfset qryAccounts = accounts.getAccounts()>

<cfquery name="qryAccounts" dbtype="query" maxrows="100">
	SELECT *
		FROM qryAccounts
		ORDER BY createdOn DESC
</cfquery>

<table width="100%" cellpadding="5">
	<tr>
	<cfoutput query="qryAccounts">
		<cfset avatarHREF = "http://www.gravatar.com/avatar/" & lcase(hash(trim(qryAccounts.email))) & "?s=30">
		<cfset userHREF = "index.cfm?account=#qryAccounts.accountName#">
		<td width="33%">
			<a href="#userHREF#"><img src="#avatarHREF#" style="margin:5px;" align="left"></a>
			<b><a href="#userHREF#" style="line-height:30px;">#qryAccounts.accountName#</a></b>
		</td>
		<cfif qryAccounts.currentRow mod 3 eq 0></tr><tr></cfif>
	</cfoutput>
	</tr>
</table>