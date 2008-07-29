<cfinclude template="../../udf.cfm"> 

<cfparam name="CatalogIndex" type="numeric" default="0">

<!--- get reference to library object --->
<cfset libraryCFCPath = appState.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
<cfset oLibrary = createInstance(libraryCFCPath)>
<cfset qryCatalogs = oLibrary.getCatalogs()>

<!--- by default select first catalog --->
<cfif CatalogIndex eq 0 and qryCatalogs.recordCount gt 0>
	<cfset CatalogIndex = 1>
</cfif>

<cfif CatalogIndex gt 0>
	<cfset qryPages = oLibrary.getCatalogPages(CatalogIndex)>
</cfif>

<cfoutput>
	<h1>Library Manager - Published Pages</h1>

	<p>Select the catalog for which you wish to manage the published pages stored in it.</p>

	<select name="CatalogIndex" style="width:200px;" onchange="document.location='home.cfm?view=libraryManager/pages&CatalogIndex='+this.value">
		<option value="0">--- Select a Catalog ---</option>
		<cfloop query="qryCatalogs">
			<option value="#qryCatalogs.currentRow#" <cfif qryCatalogs.currentRow eq catalogIndex>selected</cfif>>#qryCatalogs.name#</option>
		</cfloop>
	</select><br><br>
	
	<cfif CatalogIndex gt 0>
		<table class="tblGrid" width="600">
			<tr>
				<th width="10">&nbsp;</th>
				<th>Account</th>
				<th>Name</th>
				<th>Title</th>
				<th>&nbsp;</th>
			</tr>
			<cfloop query="qryPages">	
				<tr>
					<td rowspan="2"><strong>#qryPages.currentRow#</strong></td>
					<td>#AccountName#</td>
					<td><a href="#appState.stConfig.homePortalsPath#/?currentHome=#href#" target="_blank">#Name#</a></td>
					<td>#title#</td>
					<td align="center" width="75" rowspan="2">
						<a href="javascript:doDeletePage(#CatalogIndex#,'#qryPages.id#')">Remove</a>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<b>Description:</b><br>
						<cfif description neq "">
							#qryPages.description#<br>
						<cfelse>
							<em>N/A</em><br>
						</cfif>
					</td>
				</tr>
			</cfloop>
			<cfif qryPages.recordCount eq 0>
				<tr><td colspan="5"><em>There are no published pages in this catalog.</em></tr>
			</cfif>
		</table>
		<p>
			<input type="button" name="btnPublish" value="Publish Page" onclick="document.location='home.cfm?view=libraryManager/page_publish&CatalogIndex=#CatalogIndex#'" />
		</p>
	</cfif>
</cfoutput>


<!--- Javascript Functions --->
<cfsavecontent variable="tmpHead">
	<script type="text/javascript">
		function doDeletePage(catalogIndex, pageID) {
			if(confirm('Are you sure you wish to remove this page from the catalog?'))
				document.location = 'home.cfm?event=libraryManager.doDeletePage&ID=' + pageID + '&CatalogIndex=' + catalogIndex;	
		}
	</script>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">