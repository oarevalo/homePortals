<cfset stResources = getValue("stResources",structNew())>
<cfset resourceIndex = getValue("resourceIndex","")>
<cfset resourceType = getValue("resourceType","")>

<cfset lstResourceTypes = "script,style,header,footer">
<cfif resourceIndex gt 0>
	<cfset selResourceHREF = stResources[resourceType][resourceIndex]>
	<cfset formLabel = "Edit Page Resource">
<cfelse>
	<cfset selResourceHREF = "">
	<cfset formLabel = "Add Page Resource">
</cfif>

<div class="sectionMenu">
	<a href="?event=ehSettings.dspMain"><strong>General</strong></a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="?event=ehSettings.dspAccounts">Accounts</a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="?event=ehSettings.dspChangePassword">Change Password</a>
</div>

<cfoutput>
	<h2>Page Resources</h2>
	
	<p>The following resources are included in every page rendered.</p>
	
	<cfif resourceIndex gte 0>
		<fieldset class="formEdit">
			<legend><b>#formLabel#</b></legend>
			<form name="frm" action="index.cfm" method="post">
				<input type="hidden" name="resourceIndex" value="#resourceIndex#">
				<input type="hidden" name="resourceType" value="#resourceType#">
				<input type="hidden" name="event" value="ehSettings.doSavePageResource">
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
					<tr>
						<td colspan="2" style="padding-top:5px;">
							<input type="submit" name="btn" value="Save">
							<input type="button" name="btn" value="Cancel" onClick="document.location='?event=ehSettings.dspPageResources'">
						</td>
					</tr>
				</table>
			</form>
		</fieldset>
		<br><hr><br>	
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
			<cfloop from="1" to="#arrayLen(stResources[type])#" index="i">	
				<cfset xfaEdit = "?event=ehSettings.dspPageResources&resourceIndex=#i#&resourceType=#type#">
				<cfset xfaDelete = "?event=ehSettings.doDeletePageResource&resourceIndex=#i#&resourceType=#type#">
				<tr>
					<td><strong>#j#</strong></td>
					<td>#type#</td>
					<td>#stResources[type][i]#</td>
					<td align="center" width="75">
						<a href="#xfaEdit#"><img src="images/edit-page-yellow.gif" alt="edit" border="0"></a>
						<a href="javascript:if(confirm('Delete Resource?')) document.location='#xfaDelete#'"><img src="images/omit-page-orange.gif" alt="delete" border="0"></a>
					</td>
				</tr>
				<cfset j = j + 1>
			</cfloop>
		</cfloop>
	</table>
	<br>
	<input type="button" name="btnAdd" value="Add Resource" onClick="document.location='?event=ehSettings.dspPageResources&resourceIndex=0'">
	<input type="button" name="btnCancel" value="Return To Settings" onClick="document.location='?event=ehSettings.dspMain'">
</cfoutput>
