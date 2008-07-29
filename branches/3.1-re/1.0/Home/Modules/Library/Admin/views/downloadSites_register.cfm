<cfoutput>
	<h1>Library Manager - Register Update Site</h1>

	<p><a href="home.cfm?view=libraryManager/catalogs"><< Return To Update Sites</a></p>

	<p>Registering a new update site allows you to download modules and other content to extend
		HomePortals.</p>
	
	<form name="frm" action="home.cfm" method="post">
		<input type="hidden" name="event" value="libraryManager.doRegisterSite" />
		<input type="text" style="width:300px;" name="url" value="" />
		<p>
		<input type="submit" name="btnRegister" value="Register Update Site" />
		</p>
	</form>
	
</cfoutput>