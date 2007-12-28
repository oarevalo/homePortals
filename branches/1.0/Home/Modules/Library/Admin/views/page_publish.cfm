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
	<h1>Library Manager - Publish Page</h1>

	<p><a href="home.cfm?view=libraryManager/pages"><< Return To Catalogs</a></p>

	<p>Enter the full path of the page you wish to publish and a brief description.</p>

	<form name="frm" action="home.cfm" method="post">
		<input type="hidden" name="event" value="libraryManager.doPublishPage" />
		<input type="hidden" name="catalogIndex" value="#CatalogIndex#" />
		HREF: <input type="text" style="width:300px;" name="href" value="" />
		<div style="margin-left:50px;margin-bottom:10px;font-size:9px;">Example: /accounts/default/layouts/default.xml</div>

		Description:<br>
		<textarea name="description" rows="5" style="width:300px;"></textarea>

		<p>
		<input type="submit" name="btnPublish" value="Publish Page" />
		</p>
	</form>
</cfoutput>