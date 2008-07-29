<cfoutput>
	<h1>Library Manager - Register Catalog</h1>

	<p><a href="home.cfm?view=libraryManager/catalogs"><< Return To Catalogs</a></p>

	<p>Registering a catalog allows to manage modules in an already existing catalog. Use the space below to enter
	the path to the catalog file.</p>
	
	<form name="frm" action="home.cfm" method="post">
		<input type="hidden" name="event" value="libraryManager.doRegisterCatalog" />
		<input type="text" style="width:300px;" name="href" value="" />
		<p>
		<input type="submit" name="btnRegister" value="Register Catalog" />
		</p>
	</form>
	
</cfoutput>