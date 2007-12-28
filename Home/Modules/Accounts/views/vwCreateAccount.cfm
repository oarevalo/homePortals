<!--- 
vwCreateAccount

Display a form to create an account

** This file should be included from addContent.cfc

History:
12/8/05 - oarevalo - created
----> 

<cfparam name="arguments.standAlone" default="true" type="boolean">

<cfif not arguments.standAlone>
	<div class="cp_sectionTitle" style="padding:0px;width:340px;"><div style="margin:2px;">Create Account</div></div>
	<div class="cp_sectionBox" style="margin-top:0px;padding:0px;width:340px;">
	<div style="margin:10px;">
</cfif>

<!--- display messages and output here --->
<div style="font-weight:bold;margin-bottom:10px;" id="loginMsg_BodyRegion"></div>
	
<!--- register form --->
<form action="#" method="post" name="frmLogin" id="frmLogin" onSubmit="return false" style="margin:0px;padding:0px;">
	<div style="border-bottom:1px solid #990000;padding-bottom:5px;margin-bottom:5px;">
		Complete the following fields to create 
		your <strong>HomePortals</strong> account:
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

	<div style="font-size:9px;">
		<input type="checkbox" name="agree" style="width:auto;" value="1" />
		I agree to the <a href="javascript:controlPanel.getTermsAndPolicy('terms');">terms of service</a> and <a href="javascript:controlPanel.getTermsAndPolicy('privacy');">privacy policy</a>.
	</div>	

	<p align="center">
		<cfif not arguments.standAlone>
			<input name="AccountAction" type="button" value="Create Account" style="width:auto;" onclick="controlPanel.doCreateAccount(this.form)">
			<br><br>or <a href="##" onClick="controlPanel.getLogin()">Return To Login</a>
		<cfelse>
			<input name="AccountAction" type="button" value="Create Account" style="width:auto;" onclick="loginClient.doCreateAccount(this.form)">
			<br><br>or <a href="##" onClick="loginClient.getLogin()">Return To Login</a>
		</cfif>
		</td>
	</p>

</form>
	
<cfif not arguments.standAlone>
	</div>	
	</div>	
</cfif>