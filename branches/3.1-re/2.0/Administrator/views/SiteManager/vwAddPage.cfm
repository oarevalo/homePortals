<cfscript>
	qryAccount = getValue("qryAccount");
	aPages = getValue("aPages");
	aCatalogPages = getValue("aCatalogPages");
</cfscript>

<cfoutput>
	<h2>Accounts > #qryAccount.username# > Add Page</h2>

	<p>
	<fieldset class="formEdit">
		<legend><b>Add a blank page</b></legend>
		<p>
			This option allows you to add an empty blank page. Enter
			the name for the new page and click GO.
		</p>
		<form name="frmAdd" action="index.cfm" method="post" style="margin-left:20px;">
			<input type="hidden" name="event" value="ehSite.doAddPage">
			Name: 
			<input type="text" name="pageName" value="" style="width:150px;">
			<input type="submit" value="Go">
		</form>
	</fieldset>
	</p>
	
	<p>
	<fieldset class="formEdit">
		<legend><b>Copy existing page</b></legend>
		<p>
			This option creates a duplicate of an existing page on your site. 
			Select from the dropdown menu the page you wish to copy and 
			then click GO.
		</p>
		<form name="frmCopy" action="index.cfm" method="post" style="margin-left:20px;">
			<input type="hidden" name="event" value="ehSite.doCopyPage">
			Select page to copy:
			<select name="pageHREF">
				<cfloop from="1" to="#arrayLen(aPages)#" index="i">
					<option value="#aPages[i].href#">#aPages[i].title#</option>
				</cfloop>
			</select>
			<input type="submit" value="Go">
		</form>
	</fieldset>
	</p>

	<p>
	<fieldset class="formEdit">
		<legend><b>Add page from catalog</b></legend>
		<p>
			This option adds a new page to a site from a page stored in the catalog. 
			Select from the dropdown menu the page you wish to add and 
			then click GO.
		</p>
		<form name="frmCatalog" action="index.cfm" method="post" style="margin-left:20px;">
			<input type="hidden" name="event" value="ehSite.doCopyPage">
			Select page to add:
			<select name="pageHREF">
				<cfloop from="1" to="#arrayLen(aCatalogPages)#" index="i">
					<option value="#aCatalogPages[i].href#">#aCatalogPages[i].id#</option>
				</cfloop>
			</select>
			<input type="submit" value="Go">
		</form>
	</fieldset>
	</p>
	
	<p>
		<input type="button" name="btnCancel" value="Return" onClick="document.location='?event=ehSite.dspSiteManager'">
	</p>
</cfoutput>