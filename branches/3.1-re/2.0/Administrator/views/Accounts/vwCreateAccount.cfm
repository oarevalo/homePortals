<!--- Accounts Manager Create Account View --->

<cfscript>
	username = getValue("username","");
	password = getValue("password","");
	firstName = getValue("firstName","");
	middleName = getValue("middleName","");
	lastName = getValue("lastName","");
	email = getValue("email","");
</cfscript>

<h2>Create Account</h2>

<cfoutput>
	<form name="frm" action="index.cfm" method="post">
	<table class="dataFormTable">
		<tr>
			<td width="100">Username:</td>
			<td><input type="text" name="username" value="#username#" class="textField"></td>
		</tr>
		<tr>
			<td width="100">Password:</td>
			<td><input type="text" name="password" value="#password#" class="textField"></td>
		</tr>
		<tr>
			<td>First Name:</td>
			<td><input type="text" name="firstName" value="#firstName#" class="textField"></td>
		</tr>
		<tr>
			<td>Middle Name:</td>
			<td><input type="text" name="middleName" value="#middleName#" class="textField"></td>
		</tr>
		<tr>
			<td>Last Name:</td>
			<td><input type="text" name="lastName" value="#lastName#" class="textField"></td>
		</tr>
		<tr>
			<td>Email:</td>
			<td><input type="text" name="email" value="#email#" class="textField"></td>
		</tr>
		<tr>
			<td colspan="2" align="center" style="padding-top:5px;">
				<input type="hidden" name="event" value="ehAccounts.doSave">
				<input type="submit" name="btnSave" value="Create Account">
				<input type="button" name="btnCancel" value="Return To Search" onClick="document.location='?event=ehAccounts.dspMain'">
			</td>
		</tr>
	</table>
	</form>
	
</cfoutput>




