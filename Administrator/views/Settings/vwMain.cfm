<cfscript>
	defaultAccount = getValue("defaultAccount","");
	homePortalsPath = getValue("homePortalsPath",""); 
	moduleLibraryPath = getValue("moduleLibraryPath","");
	SSLRoot = getValue("SSLRoot","");
	mailServer = getValue("mailServer","");
	mailUsername = getValue("mailUsername","");
	mailPassword = getValue("mailPassword","");
</cfscript>

<div class="sectionMenu">
	<a href="?event=ehSettings.dspMain"><strong>General</strong></a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="?event=ehSettings.dspAccounts">Accounts</a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="?event=ehSettings.dspChangePassword">Change Password</a>
</div>

<cfoutput>
	<form name="frm" method="post" action="index.cfm">
		<table class="dataFormTable">
			<tr valign="top">
				<td>Default Account:</td>
				<td>
					<input type="text" name="defaultAccount" value="#defaultAccount#" class="textField">
					<!--- <input type="button" name="btnSearchAccount" value="..."><br> --->
					<div class="formFieldTip">
						This is the account that will be loaded by default when
						no page is explicitly given to HomePortals. This value
						must be the account name of an already existing account.
					</div>
				</td>
			</tr>
			<tr valign="top">
				<td>HomePortals Path:</td>
				<td>
					<input type="text" name="homePortalsPath" value="#homePortalsPath#" class="textField">
					<div class="formFieldTip">
						The path where HomePortals is installed. By default is "/Home".
					</div>
				</td>
			</tr>
			<tr valign="top">
				<td>Module Library Path:</td>
				<td>
					<input type="text" name="moduleLibraryPath" value="#moduleLibraryPath#" class="textField">
					<div class="formFieldTip">
						Default path where to look for module components. By default is "Home.Modules.".
					</div>
				</td>
			</tr>
			<tr valign="top">
				<td>SSL Root:</td>
				<td>
					<input type="text" name="SSLRoot" value="#SSLRoot#" class="textField">
					<div class="formFieldTip">
						SSLRoot is the root path to be prepended to all page calls when using HTTPS.
					</div>
				</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr><td colspan="2"><b>Mail Settings:</b></td></tr>
			<tr><td colspan="2">Leave these settings blank to use ColdFusion default settings.</td></tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td>Mail Server:</td>
				<td><input type="text" name="mailServer" value="#mailServer#" class="textField"></td>
			</tr>
			<tr>
				<td>Username:</td>
				<td><input type="text" name="mailUsername" value="#mailUsername#" class="textField"></td>
			</tr>
			<tr>
				<td>Password:</td>
				<td><input type="text" name="mailPassword" value="#mailPassword#" class="textField"></td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr><td colspan="2"><b>Page Resources:</b></td></tr>
			<tr><td colspan="2"><a href="?event=ehSettings.dspPageResources">Click Here to Add/Edit Page Resources</a></td></tr>
		</table>
		<p align="center">
			<input type="hidden" name="event" value="ehSettings.doSaveSettings">
			<input type="submit" name="btnSave" value="Apply Changes">
		</p>
		<p>&nbsp;</p>
	</form>
</cfoutput>
