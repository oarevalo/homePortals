<cfinclude template="../../udf.cfm"> 

<cfparam name="index" default="0">

<!--- get reference to library object --->
<cfset libraryCFCPath = appState.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
<cfset oLibrary = createInstance(libraryCFCPath)>
<cfset qrySites = oLibrary.getUpdateSites()>

<!--- by default select first catalog --->
<cfif index eq 0 and qrySites.recordCount gt 0>
	<cfset index = 1>
</cfif>

<cfoutput>
	<h1>Library Manager - Update Sites</h1>
	
	<p>Download new modules, skins and other resources from the following HomePortals update servers.</p>
	
	<form name="frm" method="post" action="home.cfm">
		<input type="hidden" name="view" value="libraryManager/download">
		<table class="tblGrid" width="600">
			<tr>
				<th width="20">&nbsp;</th>
				<th>URL</th>
				<th>&nbsp;</th>
			</tr>
			<cfloop query="qrySites">	
				<tr>
					<td>
						<input type="radio" name="Index" value="#qrySites.currentRow#" <cfif index eq qrySites.currentRow>checked</cfif>>
					</td>
					<td>#URL#</td>
					<td align="center" width="75">
						<a href="javascript:doDeleteSite(#qrySites.currentRow#)">Remove</a>
					</td>
				</tr>
			</cfloop>
			<cfif qrySites.recordCount eq 0>
				<tr><td colspan="3"><em>There are no registered update sites.</em></tr>
			</cfif>
		</table>
		<p>
			<input type="button" name="btnRegister" value="Register Update Site" onclick="document.location='home.cfm?view=libraryManager/downloadSites_register'" />
			&nbsp;&nbsp;
			<input type="submit" name="btnContinue" value="Contiue >>" />
		</p>
	</form>
</cfoutput>


<!--- Javascript Functions --->
<cfsavecontent variable="tmpHead">
	<script type="text/javascript">
		function doDeleteSite(index) {
			if(confirm('Are you sure you wish to remove this HomePortals update site?'))
				document.location = 'home.cfm?event=libraryManager.doDeleteSite&index=' + index;	
		}
	</script>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">