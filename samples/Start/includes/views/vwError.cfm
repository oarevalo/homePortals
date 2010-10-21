<cfparam name="arguments.errMessage" default="" type="string">

<div style="margin:10px;">
	<p>An unexpected problem ocurred:</p>
	<p>
		<b>Diagnostic Information:</b><br>
		<cfoutput>#arguments.errMessage#</cfoutput>
	</p>
	<p>
		Please contact the system administrator to report this issue.
	</p>
	<p>We apologize for the inconvenience.</p>
</div>
