<!--- Plugins view 

This view allows to manage plugins
--->
<cfinclude template="../udf.cfm">

<!--- get plugins --->
<cfset oPlugins = createInstance("components/plugins.cfc")>
<cfset qryPlugins = oPlugins.getAll()>
			
<cfoutput>
	<h1>Plugins</h1>
	<table border="0" width="600">
		<tr>
			<td colspan="3">
				Plugins allow you to extend the functionality of the HomePortals Administrator.
				Use this screen to add or remove plugins.
			</td>
		</tr>
		<tr><td colspan="3">&nbsp;</td></tr>
	</table>
	
	<cfif IsDefined("newPlugin") and newPlugin eq "true">
		<form name="frm" action="home.cfm" method="post">
			<table>
				<tr>
					<td width="100" style="color:##000000;">Plugin Source:</td>
					<td>
						<input type="text" name="src" value="" 
								style="width:400px;font-size:11px;border:1px solid black;padding:3px;">
						<div style="font-size:10px;margin-top:6px;">
							Example: /Home/Modules/Accounts/Admin/plugin.xml
						</div>
					</td>
				</tr>
			</table>
			<br>
			<input type="hidden" name="event" value="addPlugin">
			<input type="hidden" name="view" value="plugins">
			<input type="submit" name="btn" value="Save">
			<input type="button" name="btn" value="Cancel" onClick="document.location='home.cfm?view=plugins'">
		</form>
		<br><br><hr><br>
	</cfif>

	<table class="tblGrid" width="600">
		<tr>
			<th width="10">&nbsp;</th>
			<th width="50">ID</th>
			<th>Source</th>
			<th>Version</th>
			<th>Description</th>
			<th>&nbsp;</th>
		</tr>
		<cfloop query="qryPlugins">	
			<tr>
				<td><strong>#qryPlugins.currentRow#</strong></td>
				<td>#id#</td>
				<td>#src#</td>
				<td align="center">#version#</td>
				<td>#Description#</td>
				<td align="center" width="75">
					<a href="javascript:removePlugin('#id#')">Remove</a>
				</td>
			</tr>
		</cfloop>
		<cfif qryPlugins.recordCount eq 0>
			<tr><td colspan="6"><em>There are no plugins installed.</em></tr>
		</cfif>
	</table>
	<br><input type="button" name="btn" value="Install Plugin" onClick="document.location='home.cfm?view=plugins&newPlugin=true'">
</cfoutput>