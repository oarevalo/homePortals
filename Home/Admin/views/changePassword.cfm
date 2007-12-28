
<cfoutput>
	<h1>Settings - Change Administrator Password</h1>

	<p><a href="home.cfm?view=settings"><< Return To Settings</a></p>
	
	<form name="frm" action="home.cfm" method="post">
		<table>
			<tr>
				<td width="100" style="color:##000000;">Current Password:</td>
				<td>
					<input type="password" name="oldPwd" value="" 
							style="width:400px;font-size:11px;border:1px solid black;padding:3px;">
				</td>
			</tr>
			<tr>
				<td width="100" style="color:##000000;">New Password:</td>
				<td><input type="password" name="newPwd" value="" 
							style="width:400px;font-size:11px;border:1px solid black;padding:3px;"></td>
			</tr>
			<tr>
				<td width="100" style="color:##000000;">Confirm New Password:</td>
				<td><input type="password" name="newPwd2" value="" 
							style="width:400px;font-size:11px;border:1px solid black;padding:3px;"></td>
			</tr>
		</table>
		<br>
		<input type="hidden" name="event" value="changePassword">
		<input type="hidden" name="view" value="changePassword">
		<input type="submit" name="btn" value="Change Password">
		<input type="button" name="btn" value="Cancel" onClick="document.location='home.cfm?view=settings'">
	</form>
</cfoutput>
