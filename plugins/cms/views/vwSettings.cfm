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
				<td colspan="2" class="cms-formFieldTip">Enter the path of the page you wish to use as homepage</td>
				<td>&nbsp;</td>
				<td nowrap="nowrap"><strong>Confirm Password:</strong></td>
				<td><input type="password" name="newPassword2" value="" class="cms-formField"></td>
			</tr>
		</table>
		<br />
		<input type="button" value="Apply Changes" onclick="controlPanel.updateSettings(this.form)">
		<input type="button" value="Reload Site" onclick="controlPanel.resetApp()">
		&nbsp;&nbsp;
		<input type="button" value="Close" onclick="controlPanel.closePanel()">
	</form>

	<br /><br />

	<cfinclude template="vwPluginSettings.cfm">
	
</cfoutput>