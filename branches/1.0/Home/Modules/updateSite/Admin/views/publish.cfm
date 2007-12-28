<cfinclude template="../../udf.cfm"> 

<!--- get reference to updateSite object --->
<cfset cfcPath = appState.stConfig.moduleLibraryPath & "updateSite/Components/updateSite.cfc">
<cfset oUpdateSite = createInstance(cfcPath)>
<cfset oUpdateSite.init(appState.stConfig.homePortalsPath, appState.stConfig.moduleLibraryPath)>
<cfset stInfo = oUpdateSite.getInfo()>
<cfset qryPackages = oUpdateSite.getPackagesList()>
<cfset distURL = "http://#cgi.SERVER_NAME##appState.stConfig.moduleLibraryPath#updateSite/update.cfc?wsdl">

<cfoutput>
	<h1>Library Manager - Update Site</h1>
	
	<p>Publish existing modules and other resources to share with other HomePortals servers.</p>

	<form name="frmUpdate" method="post" action="home.cfm">
		<table>
			<tr>
				<td><strong>Name:</strong></td>
				<td><input type="text" name="name" value="#stInfo.name#" style="width:300px;"></td>
			</tr>
			<tr valign="top">
				<td><strong>Description:</strong></td>
				<td><textarea name="description" style="width:300px;" rows="4">#stInfo.description#</textarea></td>
			</tr>
			<tr>
				<td><strong>URL:</strong></td>
				<td><a href="#distURL#" target="_blank" style="font-size:11px;"><b>#distURL#</b></a></td>
			</tr>
		</table>
		<br>
		<input type="hidden" name="event" value="distManager.doSaveInfo">
		<input type="submit" name="btnUpdate" value="Update Site Information">
	</form>

	<br><br>
	
	<table class="tblGrid" width="600">
		<tr>
			<th width="10">&nbsp;</th>
			<th>Name</th>
			<th>Description</th>
			<th>Version</th>
			<th>Date</th>
			<th>&nbsp;</th>
		</tr>	
			<cfloop query="qryPackages">	
				<tr>
					<td>#qryPackages.currentRow#</td>
					<td>#qryPackages.name#</td>
					<td>#qryPackages.Description#</td>
					<td align="center">#qryPackages.Version#</td>
					<td align="center">#qryPackages.DateAdded#</td>
					<td align="center" width="75">
						<a href="javascript:doDeletePackage('#qryPackages.href#')">Remove</a>&nbsp;&nbsp;
						<a href="home.cfm?view=distManager/editPackageInfo&href=#qryPackages.href#">Edit</a>
					</td>
				</tr>
			</cfloop>
			<cfif qryPackages.recordCount eq 0>
				<tr><td colspan="6"><em>There are no published packages.</em></tr>
			</cfif>
		</table>
		<p>
			<input type="button" name="btnAdd" value="Publish Package" onclick="document.location='home.cfm?view=distManager/addPackage'" />
		</p>
	</form>
</cfoutput>


<!--- Javascript Functions --->
<cfsavecontent variable="tmpHead">
	<script type="text/javascript">
		function doDeletePackage(href) {
			if(confirm('Are you sure you wish to delete this package?'))
				document.location = 'home.cfm?event=distManager.doRemovePackage&href=' + href;	
		}
	</script>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">		
