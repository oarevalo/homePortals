<!--- 
vwCreateAccount

Display a form to create an account

** This file should be included from addContent.cfc

History:
12/8/05 - oarevalo - created
----> 

<div class="cp_sectionTitle" style="padding:0px;width:340px;margin-bottom:0px;margin-left:80px;margin-top:50px;">
	<div style="margin:2px;">Create Account</div>
</div>

<div class="cp_sectionBox" style="margin-top:0px;padding:0px;width:340px;border-top:0px;margin-left:80px;">
	<div style="margin:10px;">
		<!--- display messages and output here --->
		<div style="font-weight:bold;margin-bottom:10px;" id="loginMsg_BodyRegion"></div>
			
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
			  <td><strong>Confirm Password:</strong></td>
			  <td><input name="password2" type="password" id="password2" style="width:100px;"></td>
			</tr>
			<tr>
			  <td><strong>Email:</strong></td>
			  <td><input name="email" type="text" id="email" style="width:100px;"></td>
			</tr>
		  </table>
		
			<div style="font-size:9px;margin-top:10px;">
				<input type="checkbox" name="agree" style="width:auto;border:0px;" value="1" />
				I agree to the <a href="javascript:controlPanel.getTermsAndPolicy('terms');">terms of service</a> and <a href="javascript:controlPanel.getTermsAndPolicy('privacy');">privacy policy</a>.
			</div>	
		
			<p align="center">
				<input name="AccountAction" type="button" value="Create Account" style="width:auto;" onclick="controlPanel.doCreateAccount(this.form)">
				<br><br><a href="##" onClick="controlPanel.getLogin()">Return To Login</a>
			</p>
		</form>
	</div>	
</div>	
