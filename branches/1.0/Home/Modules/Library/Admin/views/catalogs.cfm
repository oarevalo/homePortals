<cfinclude template="../../udf.cfm"> 

<!--- get reference to library object --->
<cfset libraryCFCPath = appState.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
<cfset oLibrary = createInstance(libraryCFCPath)>
<cfset qryCatalogs = oLibrary.getCatalogs()>

<cfoutput>
	<h1>Library Manager - Catalogs</h1>
	
	<p>The following table lists all catalogs registered in this installation of HomePortals. Catalogs
	are documents that list resources that can be used to build HomePortals pages. Catalog resources
	are things like modules, skins and published pages. From this screen you can create new catalogs or
	register existing ones.</p>
	
	<table class="tblGrid" width="600">
		<tr>
			<th width="10">&nbsp;</th>
			<th>Name</th>
			<th>href</th>
			<th>Description</th>
			<th>&nbsp;</th>
		</tr>
		<cfloop query="qryCatalogs">	
			<tr>
				<td><strong>#qryCatalogs.currentRow#</strong></td>
				<td>#name#</td>
				<td>#href# (<a href="#href#" target="_blank">link</a>)</td>
				<td>#description#</td>
				<td align="center" width="75">
					<a href="javascript:doDeleteCatalog(#qryCatalogs.currentRow#);">Delete</a>&nbsp;
					<a href="javascript:doRemoveCatalog(#qryCatalogs.currentRow#);">Remove</a>&nbsp;
					<a href="home.cfm?view=libraryManager/catalog_edit&Index=#qryCatalogs.currentRow#">Edit</a>
				</td>
			</tr>
		</cfloop>
		<cfif qryCatalogs.recordCount eq 0>
			<tr><td colspan="5"><em>There are no registered catalogs.</em></tr>
		</cfif>
	</table>
	<p>
		<input type="button" name="btnCreate" value="Create Catalog" onclick="document.location='home.cfm?view=libraryManager/catalog_edit'" />
		<input type="button" name="btnRegister" value="Register Catalog" onclick="document.location='home.cfm?view=libraryManager/catalog_register'" />
	</p>
</cfoutput>



<!--- Javascript Functions --->
<cfsavecontent variable="tmpHead">
	<script type="text/javascript">
		function doDeleteCatalog(catalogIndex) {
			if(confirm('Are you sure you wish to DELETE this catalog? \nWARNING: This operation will delete the actual catalog file.'))
				document.location = 'home.cfm?event=libraryManager.doDeleteCatalog&DeleteFile=true&Index=' + catalogIndex;	
		}
		function doRemoveCatalog(catalogIndex) {
			if(confirm('Are you sure you wish to remove this catalog from the list of registered catalogs?'))
				document.location = 'home.cfm?event=libraryManager.doDeleteCatalog&Index=' + catalogIndex;	
		}
	</script>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">