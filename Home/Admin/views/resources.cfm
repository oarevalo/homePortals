<!--- page parameters --->
<cfparam name="resourceIndex" default="-1">
<cfparam name="resourceType" default="">

<cfscript>
	// get settings
	stConfig = appState.stConfig;
	lstKeys = "defaultPage,homePortalsPath,moduleLibraryPath,SSLRoot";

	stConfigHelp = structNew();
	stConfigHelp.resources = "The following resources are included in every page rendered.";

	if(IsDefined("event") and event neq "")
		resourceIndex = -1;

	if(resourceIndex gt 0) 
		selResourceHREF = stConfig.resources[resourceType][resourceIndex];
	else 
		selResourceHREF = "";
		
	lstResourceTypes = "script,style,header,footer";
</cfscript>


<cfoutput>
	<h1>Settings - Resources</h1>

	<p><a href="home.cfm?view=settings"><< Return To Settings</a></p>

	<p>#stConfigHelp.resources#</p>

	<cfif resourceIndex gte 0>
		<br>
		<cfif resourceIndex gt 0>
			<b>Edit Page Resource</b>
		<cfelse>
			<b>Add Page Resource</b>
		</cfif>
		<br><br>
		<form name="frm" action="home.cfm" method="post">
			<table>
				<tr>
					<td width="100" style="color:##000000;">Type:</td>
					<td>
						<select name="type" style="width:200px;font-size:11px;padding:3px;">
							<cfloop list="#lstResourceTypes#" index="tmpItem">
								<option value="#tmpItem#" <cfif resourceType eq tmpItem>selected</cfif>>#tmpItem#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td width="100" style="color:##000000;">HREF:</td>
					<td><input type="text" name="href" value="#selResourceHREF#" 
								style="width:400px;font-size:11px;border:1px solid black;padding:3px;"></td>
				</tr>
			</table>
			<br>
			<input type="hidden" name="resourceIndex" value="#resourceIndex#">
			<input type="hidden" name="resourceType" value="#resourceType#">
			<input type="hidden" name="event" value="saveResource">
			<input type="hidden" name="view" value="resources">
			<input type="submit" name="btn" value="Save">
			<input type="button" name="btn" value="Cancel" onClick="document.location='home.cfm?view=resources'">
		</form>
		<br><br><hr><br>
	</cfif>

	<table class="tblGrid" width="600">
		<tr>
			<th width="10">&nbsp;</th>
			<th width="50">Type</th>
			<th>Href</th>
			<th>&nbsp;</th>
		</tr>
		<cfset j = 1>
		<cfloop list="#lstResourceTypes#" index="type">
			<cfloop from="1" to="#arrayLen(stConfig.resources[type])#" index="i">	
				<tr>
					<td><strong>#j#</strong></td>
					<td>#type#</td>
					<td>#stConfig.resources[type][i]#</td>
					<td align="center" width="75">
						<a href="home.cfm?view=resources&resourceIndex=#i#&resourceType=#type#">Edit</a> | 
						<a href="home.cfm?event=deleteResource&view=resources&resourceIndex=#i#&resourceType=#type#">Delete</a>
					</td>
				</tr>
				<cfset j = j + 1>
			</cfloop>
		</cfloop>
	</table>
	<br><input type="button" name="btn" value="Add Resource" onClick="document.location='home.cfm?view=resources&resourceIndex=0'">
</cfoutput>