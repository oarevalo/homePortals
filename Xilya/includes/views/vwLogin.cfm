<!--- 
vwLogin

Display a login form

** This file should be included from addContent.cfc

History:
12/4/05 - oarevalo - created
----> 

<cfoutput>

<div class="cp_sectionTitle" style="padding:0px;width:340px;margin-bottom:0px;margin-top:100px;margin-left:80px;">
	<div style="margin:2px;">Account Login</div>
</div>

<div class="cp_sectionBox" style="margin-top:0px;padding:0px;width:340px;border-top:0px;margin-left:80px;overflow:hidden;">
	<div style="margin:10px;">
		<div style="font-weight:bold;margin-bottom:10px;" id="loginMsg_BodyRegion"></div>
		<b>Enter your password:</b><Br><br>
		
		<form name="frm" action="##" method="post" onSubmit="return false" style="padding:0px;margin:0px;">
		<table style="margin:0px;padding:0px;">
			<tr>
				<td>Password:</td>
				<td><input name="password" type="password" id="password" style="width:100px;"></td>
			</tr>
			<tr>
				<td colspan="2">
				<input type="checkbox" name="rememberMe" value="1" style="width:auto;border:0px;"> Remember Me.
				</td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<br>
					<input name="btnLogin" type="button" value="Login" onClick="controlPanel.doLogin(this.form)">&nbsp;
				</td>
			</tr>
		</table>
		</form>
	</div>
</div>
</cfoutput>
