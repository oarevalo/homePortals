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
	<cfset qrySkins = oLibrary.getCatalogSkins(CatalogIndex)>
</cfif>

<cfoutput>
	<h1>Library Manager - Catalog Skins</h1>

	<p>Select the catalog for which you wish to manage the skins stored in it.</p>

	<select name="CatalogIndex" style="width:200px;" onchange="document.location='home.cfm?view=libraryManager/skins&CatalogIndex='+this.value">
		<option value="0">--- Select a Catalog ---</option>
		<cfloop query="qryCatalogs">
			<option value="#qryCatalogs.currentRow#" <cfif qryCatalogs.currentRow eq catalogIndex>selected</cfif>>#qryCatalogs.name#</option>
		</cfloop>
	</select><br><br>
	
	<cfif CatalogIndex gt 0>
		<table class="tblGrid" width="600">
			<tr>
				<th width="10">&nbsp;</th>
				<th>ID</th>
				<th>HREF</th>
				<th>Description</th>
				<th>&nbsp;</th>
			</tr>
			<cfloop query="qrySkins">	
				<tr>
					<td><strong>#qrySkins.currentRow#</strong></td>
					<td>#ID#</td>
					<td>#HREF# (<a href="#href#" target="_blank">link</a>)</td>
					<td>#Description#</td>
					<td align="center" width="75">
						<a href="javascript:doDeleteSkin(#CatalogIndex#,'#qrySkins.ID#');">Remove</a>
					</td>
				</tr>
			</cfloop>
			<cfif qrySkins.recordCount eq 0>
				<tr><td colspan="5"><em>There are no skins in this catalog.</em></tr>
			</cfif>
		</table>
		<p>
			<input type="button" name="btnRegister" value="Add Skin" onclick="document.location='home.cfm?view=libraryManager/skin_register&CatalogIndex=#CatalogIndex#'" />
		</p>
	</cfif>
</cfoutput>

<!--- Javascript Functions --->
<cfsavecontent variable="tmpHead">
	<script type="text/javascript">
		function doDeleteSkin(catalogIndex, skinID) {
			if(confirm('Are you sure you wish to remove this skin from the catalog?'))
				document.location = 'home.cfm?event=libraryManager.doDeleteSkin&ID=' + skinID + '&CatalogIndex=' + catalogIndex;	
		}
	</script>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">