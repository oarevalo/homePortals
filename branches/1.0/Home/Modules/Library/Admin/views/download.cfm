<cfinclude template="../../udf.cfm"> 
<cfparam name="index" default="0">
<cfparam name="CatalogIndex" type="numeric" default="0">

<!--- get reference to library object --->
<cfset libraryCFCPath = appState.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
<cfset oLibrary = createInstance(libraryCFCPath)>
<cfset qryContent = oLibrary.getUpdateSitePackages(index)>
<cfset qryCatalogs = oLibrary.getCatalogs()>

<cfquery name="qryContent" dbtype="query">
	SELECT *
		FROM qryContent
		ORDER BY Name, Version
</cfquery>

<!--- by default select first catalog --->
<cfif CatalogIndex eq 0 and qryCatalogs.recordCount gt 0>
	<cfset CatalogIndex = 1>
</cfif>

<h1>Library Manager - Download Content</h1>

<p><a href="home.cfm?view=libraryManager/downloadSites"><< Return To Update Sites</a></p>

<p>Select the package you wish to download and install from following available content.</p>

<p>
Register downloaded content in catalog: 
<select name="CatalogIndex" style="width:200px;" id="CatalogIndex">
	<cfoutput query="qryCatalogs">
		<option value="#qryCatalogs.currentRow#" <cfif qryCatalogs.currentRow eq catalogIndex>selected</cfif>>#qryCatalogs.name#</option>
	</cfoutput>
</select>
</p>

	
<table class="tblGrid" width="600">
	<tr>
		<th width="10">&nbsp;</th>
		<th>Name</th>
		<th>Description</th>
		<th>Version</th>
		<th>Date</th>
		<th>&nbsp;</th>
	</tr>
	<cfoutput query="qryContent">	
		<tr>
			<td>#qryContent.currentRow#</td>
			<td>#qryContent.name#</td>
			<td>#qryContent.description#</td>
			<td align="center">#qryContent.version#</td>
			<td>#LSDateFormat(qryContent.dateAdded)#</td>
			<td align="center" width="75">
				<a href="javascript:doDownload(#index#,'#qryContent.href#')">Download</a>
			</td>
		</tr>
	</cfoutput>
	<cfif qryContent.recordCount eq 0>
		<tr><td colspan="5"><em>There are no packages for download in this update site.</em></tr>
	</cfif>
</table>

<!--- Javascript Functions --->
<cfsavecontent variable="tmpHead">
	<script type="text/javascript">
		function doDownload(index, href) {
			var cat = document.getElementById("CatalogIndex");
			if(cat) catIndex = cat.value;
			if(confirm('Download and Install package?'))
				document.location = 'home.cfm?event=libraryManager.doDownloadPackage&index=' + index + '&href=' + href + "&catalogIndex=" + catIndex;	
		}
	</script>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">