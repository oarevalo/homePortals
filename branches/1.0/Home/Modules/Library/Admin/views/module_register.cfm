<cfparam name="CatalogIndex" type="numeric" default="0">

<cfoutput>
	<h1>Library Manager - Register Module</h1>

	<p><a href="home.cfm?view=libraryManager/modules&catalogIndex=#catalogIndex#"><< Return To Catalogs</a></p>
	
	<p>Use the space below to enter the path to the resource descriptor file for this module.</p>
	
	<form name="frm" action="home.cfm" method="post">
		<input type="hidden" name="event" value="libraryManager.doRegisterModule" />
		<input type="hidden" name="CatalogIndex" value="#CatalogIndex#" />
		<input type="text" style="width:300px;" name="href" value="" />
		<p>
		<input type="submit" name="btnRegister" value="Register Module" />
		</p>
	</form>
	
</cfoutput>