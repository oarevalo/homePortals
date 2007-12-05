<cfset moduleID = this.controller.getModuleID()>

<!--- register form --->
<form action="#" method="post" name="frmLogin" id="frmLogin" onSubmit="return false" style="margin:0px;padding:0px;">
	<div style="border-bottom:1px solid #990000;padding-bottom:5px;margin-bottom:5px;">
		Complete the following fields to create 
		your account:
	</div>
	<table border="0" style="width:auto;">
		<tr>
			<td><strong>Username:</strong></td>
			<td width="100"><input name="username" type="text" id="username" style="width:100px;"></td>
		</tr>
		<tr>
			<td><strong>Password:</strong></td>
			<td><input name="password" type="password" id="password" style="width:100px;"></td>
		</tr>
		<tr>
			<td><strong>Confirm<br>Password:</strong></td>
			<td><input name="password2" type="password" id="password2" style="width:100px;"></td>
		</tr>
		<tr>
			<td><strong>Email:</strong></td>
			<td><input name="email" type="text" id="email" style="width:100px;"></td>
		</tr>
	</table>
	
	<cfoutput>
		<div style="font-size:9px;">
			<input type="checkbox" name="agree" style="width:auto;" value="1" />
				I agree to the <a href="javascript:controlPanel.getTermsAndPolicy('terms');">terms of service</a> 
				and <a href="javascript:controlPanel.getTermsAndPolicy('privacy');">privacy policy</a>.
		</div>	
		
		<p align="center">
			<input name="AccountAction" type="button" value="Create Account" style="width:auto;" onclick="#moduleID#.doFormAction('doCreateAccount',this.form)">
			<br><br>or <a href="##" onClick="#moduleID#.getView('login/main')">Return To Login</a>
		</p>
	</cfoutput>	
</form>

