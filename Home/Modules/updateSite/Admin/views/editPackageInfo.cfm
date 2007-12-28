<cfinclude template="../../udf.cfm"> 

<cfparam name="href" default="">

<!--- get reference to updateSite object --->
<cfset cfcPath = appState.stConfig.moduleLibraryPath & "updateSite/Components/updateSite.cfc">
<cfset oUpdateSite = createInstance(cfcPath)>
<cfset oUpdateSite.init(appState.stConfig.homePortalsPath, appState.stConfig.moduleLibraryPath)>
<cfset qryPackage = oUpdateSite.getPackageInfo(href)>


<cfoutput>
	<h1>Library Manager - Update Package Information</h1>
	
	<p><a href="home.cfm?view=distManager/publish"><< Return</a></p>
	
	<p>Edit package information. This information will be displayed to other servers when trying to download this package.</p>

	<form name="frmUpdate" method="post" action="home.cfm">
		<table>
			<tr>
				<td><strong>Filename:</strong></td>
				<td>#qryPackage.href#</td>
			</tr>
			<tr>
				<td><strong>Date:</strong></td>
				<td>#lsDateFormat(qryPackage.dateAdded)#</td>
			</tr>
			<tr>
				<td><strong>Name:</strong></td>
				<td><input type="text" name="name" value="#qryPackage.name#" style="width:300px;"></td>
			</tr>
			<tr>
				<td><strong>Version:</strong></td>
				<td><input type="text" name="version" value="#qryPackage.version#" style="width:300px;"></td>
			</tr>
			<tr valign="top">
				<td><strong>Description:</strong></td>
				<td><textarea name="description" style="width:300px;" rows="4">#qryPackage.description#</textarea></td>
			</tr>
		</table>
		
		<p>
			<input type="hidden" name="event" value="distManager.doSavePackageInfo">
			<input type="hidden" name="href" value="#qryPackage.href#">
			<input type="submit" name="btnUpdate" value="Apply Changes">
		</p>
	</form>
</cfoutput>