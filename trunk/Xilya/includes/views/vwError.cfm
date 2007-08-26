<cfparam name="arguments.errMessage" default="" type="string">

<div class="cp_sectionTitle" style="padding:0px;width:340px;">
	<div style="margin:2px;">Not Authorized</div>
</div>
<div class="cp_sectionBox" style="margin-top:0px;padding:0px;width:340px;">
	<div style="margin:10px;">
		<p>An unexpected problem ocurred:</p>
		<p>
			<b>Diagnostic Information:</b><br>
			<cfoutput>#arguments.errMessage#</cfoutput>
		</p>
		<p>
			Please contact the system administrator to report this issue. You
			may reach HomePortals technical support by sending an email to
			<a href="mailto:support@cfempire.com">support@cfempire.com</a>
		</p>
		<p>We apologize for the inconvenience.</p>
	</div>
</div>