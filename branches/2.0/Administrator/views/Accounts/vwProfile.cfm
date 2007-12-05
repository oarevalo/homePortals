<!--- Accounts Manager Edit View --->
<cfscript>
	userID = getValue("UserID","");
	stAccountInfo = getValue("stAccountInfo");
	qryAccount = getValue("qryAccount");
</cfscript>

<cfoutput>
	<h2>Accounts > #qryAccount.username# > Account Profile</h2>
	
	<form name="frm" action="index.cfm" method="post">
	<table class="dataFormTable">
		<tr>
			<td width="100">Username:</td>
			<td>
				<input type="text" name="username1" value="#qryAccount.username#" class="textField" disabled="yes">
				<input type="hidden" name="username" value="#qryAccount.username#">
			</td>
		</tr>
		<tr>
			<td>First Name:</td>
			<td><input type="text" name="firstName" value="#qryAccount.firstName#" class="textField"></td>
		</tr>
		<tr>
			<td>Middle Name:</td>
			<td><input type="text" name="middleName" value="#qryAccount.middleName#" class="textField"></td>
		</tr>
		<tr>
			<td>Last Name:</td>
			<td><input type="text" name="lastName" value="#qryAccount.lastName#" class="textField"></td>
		</tr>
		<tr>
			<td>Email:</td>
			<td><input type="text" name="email" value="#qryAccount.email#" class="textField"></td>
		</tr>
		<tr>
			<td>Home:</td>
			<td><a href="#stAccountInfo.accountsRoot#/#qryAccount.username#" target="_blank">#stAccountInfo.accountsRoot#/#qryAccount.username#</a></td>
		</tr>
		<tr>
			<td colspan="2" style="font-size:9px;font-weight:bold;">
				<cfif qryAccount.createDate neq "">
					Account Creted On #lsDateFormat(qryAccount.createDate)# #lsTimeFormat(qryAccount.createDate)#
				</cfif>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center" style="padding-top:10px;">
				<input type="hidden" name="UserID" value="#UserID#">
				<input type="hidden" name="event" value="ehAccounts.doSave">
				<input type="submit" name="btnSave" value="Apply Changes">
				<input type="button" name="btnResetPwd" value="Reset Password" onclick="doResetPassword('#UserID#')">
				<input type="button" name="btnCancel" value="Return" onClick="document.location='?event=ehSite.dspSiteManager'">
			</td>
		</tr>
	</table>
	</form>
	
</cfoutput>




