<cfoutput>
	<form name="frm" method="post" action="#cgi.SCRIPT_NAME#" enctype="multipart/form-data">
		<input type="hidden" name="resourceType" value="#resourceType#" />
		<input type="hidden" name="method" value="">
		<input type="hidden" name="_pageHREF" value="">
		<input type="hidden" name="prefix" value="res">
		
		<cfinclude template="vwEditResource.cfm">
		
		<br />
		<input type="button" value="Apply Changes" onclick="controlPanel.updateResource(this.form)">
		&nbsp;&nbsp;
		<input type="button" value="Close" onclick="controlPanel.closePanel()">
	</form>
</cfoutput>