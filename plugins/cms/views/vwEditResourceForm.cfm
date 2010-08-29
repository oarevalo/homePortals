<cfoutput>
	<form name="frm" method="post" action="#cgi.SCRIPT_NAME#">
		<input type="hidden" name="resourceType" value="#resourceType#" />
		
		<cfinclude template="vwEditResource.cfm">
		
		<br />
		<input type="button" value="Apply Changes" onclick="controlPanel.updateResource(this.form,'res')">
		&nbsp;&nbsp;
		<input type="button" value="Close" onclick="controlPanel.closePanel()">
	</form>
</cfoutput>