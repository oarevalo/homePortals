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
	<cfset qryModules = oLibrary.getCatalogModules(CatalogIndex)>
	<cfquery name="qryModules" dbtype="query">
		SELECT *
			FROM qryModules
			ORDER BY ID, Name
	</cfquery>
</cfif>

<cfoutput>
	<h1>Library Manager - Catalog Modules</h1>

	<p>Select the catalog for which you wish to manage the modules stored in it.</p>

	<select name="CatalogIndex" style="width:200px;" onchange="document.location='home.cfm?view=libraryManager/modules&CatalogIndex='+this.value">
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
				<th>Name</th>
				<th>Access</th>
				<th>&nbsp;</th>
			</tr>
			<cfloop query="qryModules">	
				<tr>
					<td><strong>#qryModules.currentRow#</strong></td>
					<td>#ID#</td>
					<td>#Name#</td>
					<td align="center">#Access#</td>
					<td align="center" width="75">
						<a href="javascript:doDeleteModule(#CatalogIndex#,'#qryModules.ID#');">Remove</a>&nbsp;
						<a href="home.cfm?view=libraryManager/module_view&CatalogIndex=#CatalogIndex#&ModuleID=#qryModules.ID#">View</a>
					</td>
				</tr>
			</cfloop>
			<cfif qryModules.recordCount eq 0>
				<tr><td colspan="5"><em>There are no modules in this catalog.</em></tr>
			</cfif>
		</table>
		<p>
			<input type="button" name="btnRegister" value="Add Module" onclick="document.location='home.cfm?view=libraryManager/module_register&CatalogIndex=#CatalogIndex#'" />
		</p>
	</cfif>
</cfoutput>



<!--- Javascript Functions --->
<cfsavecontent variable="tmpHead">
	<script type="text/javascript">
		function doDeleteModule(catalogIndex, moduleID) {
			if(confirm('Are you sure you wish to remove this module from the catalog?'))
				document.location = 'home.cfm?event=libraryManager.doDeleteModule&ModuleID=' + moduleID + '&CatalogIndex=' + catalogIndex;	
		}
	</script>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">