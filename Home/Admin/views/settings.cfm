<!--- page parameters --->
<cfparam name="resourceIndex" default="-1">
<cfparam name="resourceType" default="">
<cfparam name="moduleIconIndex" default="-1">



<!--- get settings --->
<cfset stConfig = appState.stConfig>

<cfscript>
	lstKeys = "defaultPage,homePortalsPath,moduleLibraryPath,SSLRoot,adminEmail";

	stConfigHelp = structNew();
	stConfigHelp.version = "HomePortals version";
	stConfigHelp.initialEvent = "Event raised when a HomePortals page finishes loading";
	stConfigHelp.defaultPage = "HomePortal page to load when no page has been provided";
	stConfigHelp.homePortalsPath = "Base path for the HomePortals installation";
	stConfigHelp.moduleLibraryPath = "Default directory where HomePortals will look for modules, unless a relative path or external URL is given in the Name attribute of a module.";
	stConfigHelp.SSLRoot = "SSLRoot is the root path to be prepended to all page calls when using HTTPS";
	stConfigHelp.resources = "The following resources are included in every page rendered.";
	stConfigHelp.moduleIcons = "This section contains the icons that appear on top of each container.<br>The module id will be passed as the only parameter to the function given in the onClickFunction attribute";
	stConfigHelp.adminEmail = "Contact email address for administrator";
</cfscript>

<cfoutput>
	<h1>Settings</h1>
	<form name="frm" action="home.cfm" method="post">
		<table border="0" width="600">
			<cfloop list="#lstKeys#" index="item">
				<tr>
					<td width="100" style="color:##000000;">#item#:</td>
					<td width="230">
						<input type="text" value="#stConfig[item]#" name="#item#" 
								style="width:230px;font-size:11px;border:1px solid black;padding:3px;">
					</td>
					<td width="200" style="font-size:11px;">
						#stConfigHelp[item]#
					</td>
				</tr>
				<tr><td colspan="3">&nbsp;</td></tr>
			</cfloop>
		</table>
		<p align="center">
			<input type="hidden" name="view" value="settings">
			<input type="hidden" name="event" value="saveSettings">
			<input type="submit" value="Save Changes" name="btn">
		</p>
	</form>

	<br><hr>
	
	<h3>Page Resources</h3>
	<a href="home.cfm?view=resources">Add/Edit Page Resource</a>

	<br><br><hr>
	
	<h3>Module Icons</h3>
	<a href="home.cfm?view=moduleIcons">Add/Edit Module Icons</a>

	<br><br><hr>
	
	<h3>Administrator Password</h3>
	<a href="home.cfm?view=changePassword">Change Administrator Password</a>

</cfoutput>
