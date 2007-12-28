<!--- Display Error page --->

<cfoutput>
<p>
	<b>Error Message:</b> #cfcatch.Message#<br>
	<b>Details:</b> #cfcatch.detail#<br>
</p>
<a href="##" onClick="history.go(-1)">Go Back</a>&nbsp;&nbsp;
<a href="#app_basePage#?resetApp=1">Reset Application</a>
</cfoutput>

<cfif cfcatch.type neq "custom">
	<cfdump var="#cfcatch#">
</cfif>