<cfoutput>
	<form name="frm" method="post" action="#cgi.SCRIPT_NAME#" enctype="multipart/form-data">
		<input type="hidden" name="resourceType" value="#resourceType#" />
		<input type="hidden" name="method" value="">
		<input type="hidden" name="_pageHREF" value="">
		<input type="hidden" name="prefix" value="res">
		
		<cfinclude template="vwEditResource.cfm">
		
		<br />
		
		<cfif isEditable>
			<input type="button" value="Apply Changes" onclick="cms.updateResource(this.form)">
			&nbsp;&nbsp;
		</cfif>
		<input type="button" value="Close" onclick="cms.closePanel()">
	</form>
</cfoutput>