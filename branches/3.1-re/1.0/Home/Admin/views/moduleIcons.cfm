<!--- page parameters --->
<cfparam name="moduleIconIndex" default="-1">

<cfscript>
	// get settings
	stConfig = appState.stConfig;
	
	lstKeys = "defaultPage,homePortalsPath,moduleLibraryPath,SSLRoot";

	stConfigHelp = structNew();
	stConfigHelp.moduleIcons = "This section contains the icons that appear on top of each container.<br>The current ModuleID will be passed as the only parameter to the function given in the onClickFunction attribute";

	if(IsDefined("event") and event neq "")
		moduleIconIndex = -1;

	if(moduleIconIndex gt 0) 
		selModuleIcon = stConfig.moduleIcons[moduleIconIndex];
	else {
		selModuleIcon = StructNew();
		selModuleIcon.image = "";
		selModuleIcon.alt = "";
		selModuleIcon.onClickFunction = "";
	}
</cfscript>

<cfoutput>
	<h1>Settings - Module Icons</h1>

	<p><a href="home.cfm?view=settings"><< Return To Settings</a></p>

	<p>#stConfigHelp.moduleIcons#</p>

	<cfif moduleIconIndex gte 0>
		<br>
		<cfif moduleIconIndex gt 0>
			<b>Edit Module Icon</b>
		<cfelse>
			<b>Add Module Icon</b>
		</cfif>
		<br><br>
		<form name="frm" action="home.cfm" method="post">
			<table>
				<tr>
					<td width="100" style="color:##000000;">Image URL:</td>
					<td><input type="text" name="image" value="#selModuleIcon.image#" 
								style="width:400px;font-size:11px;border:1px solid black;padding:3px;"></td>
				</tr>
				<tr>
					<td width="100" style="color:##000000;">Alt Text:</td>
					<td><input type="text" name="alt" value="#selModuleIcon.alt#" 
								style="width:400px;font-size:11px;border:1px solid black;padding:3px;"></td>
				</tr>
				<tr>
					<td width="100" style="color:##000000;">onClickFunction:</td>
					<td><input type="text" name="onClickFunction" value="#selModuleIcon.onClickFunction#" 
								style="width:400px;font-size:11px;border:1px solid black;padding:3px;"></td>
				</tr>
			</table>
			<br>
			<input type="hidden" name="event" value="saveModuleIcon">
			<input type="hidden" name="view" value="moduleIcons">
			<input type="hidden" name="moduleIconIndex" value="#moduleIconIndex#">
			<input type="submit" name="btn" value="Save">
			<input type="button" name="btn" value="Cancel" onClick="document.location='home.cfm?view=moduleIcons'">
		</form>
		<br><br><hr><br>
	</cfif>
	
	<table class="tblGrid" width="600">
		<tr>
			<th width="10">&nbsp;</th>
			<th width="40">Image</th>
			<th>URL</th>
			<th>alt</th>
			<th>onClickFunction</th>
			<th>&nbsp;</th>
		</tr>
		<cfloop from="1" to="#arrayLen(stConfig.moduleIcons)#" index="i">	
			<tr>
				<td><strong>#i#</strong></td>
				<td align="center"><img src="#stConfig.moduleIcons[i].image#" /></td>
				<td>#stConfig.moduleIcons[i].image#</td>
				<td>#stConfig.moduleIcons[i].alt#</td>
				<td>#stConfig.moduleIcons[i].onClickFunction#</td>
				<td align="center" width="75">
					<a href="home.cfm?view=moduleIcons&moduleIconIndex=#i#">Edit</a> | 
					<a href="home.cfm?event=deleteModuleIcon&view=moduleIcons&moduleIconIndex=#i#">Delete</a>
				</td>
			</tr>
		</cfloop>
	</table>
	<br><input type="button" name="btn" value="Add Module Icon" onClick="document.location='home.cfm?view=moduleIcons&moduleIconIndex=0'">
</cfoutput>