<div class="sectionMenu">
	<a href="?event=ehSettings.dspMain">General</a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="?event=ehSettings.dspAccounts">Accounts</a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="?event=ehSettings.dspChangePassword"><strong>Change Password</strong></a>
</div>

<cfoutput>
	<form name="frm" action="index.cfm" method="post">
		<table class="dataFormTable">
			<tr>
				<td width="100" style="color:##000000;">Current Password:</td>
				<td>
					<input type="password" name="oldPwd" value="" 
							 class="textField">
				</td>
			</tr>
			<tr>
				<td width="100" style="color:##000000;">New Password:</td>
				<td><input type="password" name="newPwd" value="" 
							 class="textField"></td>
			</tr>
			<tr>
				<td width="100" style="color:##000000;">Confirm New Password:</td>
				<td><input type="password" name="newPwd2" value="" 
							 class="textField"></td>
			</tr>
		</table>
		<p align="center">
			<input type="hidden" name="event" value="ehSettings.doChangePassword">
			<input type="submit" name="btn" value="Change Password">
		</p>
	</form>
</cfoutput>
