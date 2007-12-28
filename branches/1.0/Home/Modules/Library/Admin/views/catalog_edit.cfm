<cfinclude template="../../udf.cfm"> 

<cfparam name="Index" default="0">


<!--- get reference to library object --->
<cfset libraryCFCPath = appState.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
<cfset oLibrary = createInstance(libraryCFCPath)>
<cfset qryCatalog = oLibrary.getCatalog(index)>

<cfoutput>
	<cfif index gt 0>
		<h1>Library Manager - Edit Catalog</h1>
	<cfelse>
		<h1>Library Manager - Create New Catalog</h1>
	</cfif>

	<p><a href="home.cfm?view=libraryManager/catalogs&catalogIndex=#Index#"><< Return To Catalogs</a></p>


	<form name="frmEdit" action="home.cfm" method="post">
		<input type="hidden" name="event" value="libraryManager.doSaveCatalog">
		<input type="hidden" name="index" value="#index#">
		<table>
			<tr>
				<td>HREF:</td>
				<td>
					<cfif index gt 0>
						<input type="text" name="href0" value="#qryCatalog.href#" style="width:300px;" disabled="true">
						<input type="hidden" name="href" value="#qryCatalog.href#">
					<cfelse>
						<input type="text" name="href" value="#qryCatalog.href#" style="width:300px;">
					</cfif>
				</td>
			</tr>
			<tr>
				<td>Name:</td>
				<td><input type="text" name="name" value="#qryCatalog.name#" style="width:300px;"></td>
			</tr>
			<tr valign="top">
				<td>Description:</td>
				<td><textarea name="description" style="width:300px;" rows="5">#qryCatalog.description#</textarea></td>
			</tr>
		</table>
		<p>
			<input type="submit" name="btnRegister" value="Apply Changes" />
		</p>
	</form>
</cfoutput>