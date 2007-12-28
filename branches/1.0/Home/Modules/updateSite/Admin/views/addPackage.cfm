<cfinclude template="../../udf.cfm"> 

<cfdirectory action="list" directory="#ExpandPath(appState.stConfig.moduleLibraryPath)#" name="qryDirs">

<cfoutput>
	<h1>Library Manager - Publish Package</h1>
	
	<p><a href="home.cfm?view=distManager/publish"><< Return</a></p>
	
	<p>Publish a package to share with others. 
		Select a package from from the HomePortals modules directory below.</p>

	<form name="frmUpdate" method="post" action="home.cfm">
		<table class="tblGrid" width="600">
			<tr>
				<th width="20">&nbsp;</th>
				<th>Name</th>
				<th>Location</th>
				<th>Last Modified</th>
			</tr>	
			<cfloop query="qryDirs">
				<cfif qryDirs.type eq "Dir">
				<cfset tmpHREF = appState.stConfig.moduleLibraryPath & qryDirs.name>
				<tr>
					<td>
						<input type="radio" name="PackageDir" value="#tmpHREF#">
					</td>
					<td>#qryDirs.name#</td>
					<td>#tmpHREF#</td>
					<td align="center">#qryDirs.DateLastModified#</td>
				</tr>
				</cfif>	
			</cfloop>
			<cfif qryDirs.recordCount eq 0>
				<tr><td colspan="4"><em>The modules directory is empty.</em></tr>
			</cfif>
		</table>

		<p>
			<input type="hidden" name="event" value="distManager.doAddPackage">
			<input type="submit" name="btnUpdate" value="Publish Package">
		</p>
	</form>
</cfoutput>