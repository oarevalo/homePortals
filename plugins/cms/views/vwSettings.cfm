<cfset hp = variables.homePortals>
<cfset defaultPage = hp.getConfig().getDefaultPage()>

<cfoutput>
	<form name="frm" method="post" action="##">
		<div class="cms-panelTitle">
			General Settings
		</div>
		<table>
			<tr valign="top">
				<td><strong>Homepage:</strong></td>
				<td><input type="text" name="defaultPage" value="#defaultPage#" class="cms-formField"></td>
				<td style="width:30px;">&nbsp;</td>
				<td nowrap="nowrap"><strong>New Password:</strong></td>
				<td><input type="password" name="newPassword" value="" class="cms-formField"></td>
			</tr>
			<tr valign="top">
				<td colspan="2" style="font-size:10px;">Enter the path of the page you wish to use as homepage</td>
				<td>&nbsp;</td>
				<td nowrap="nowrap"><strong>Confirm Password:</strong></td>
				<td><input type="password" name="newPassword2" value="" class="cms-formField"></td>
			</tr>
		</table>
		<br />
		<input type="button" value="Apply Changes" onclick="controlPanel.updateSettings(this.form)">
		<input type="button" value="Reload Site" onclick="controlPanel.resetApp()">
		&nbsp;
	<a href="##" onclick="controlPanel.closePanel();">Close</a>
	</form>

	<br /><br />

	<cfinclude template="vwPluginSettings.cfm">
	
</cfoutput>