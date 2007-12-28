<!--- 
vwLogin

Display a login form

** This file should be included from addContent.cfc

History:
12/4/05 - oarevalo - created
----> 
<cfparam name="arguments.standAlone" default="true" type="boolean">

<cflock scope="application" type="readonly" timeout="10">
	<cfset allowRegister = application.HomePortalsAccountsConfig.allowRegisterAccount>
</cflock>

<cfoutput>

<cfif not arguments.standAlone>
	<div class="cp_sectionTitle" style="padding:0px;width:340px;"><div style="margin:2px;">Account Login</div></div>
	<div class="cp_sectionBox" style="margin-top:0px;padding:0px;width:340px;">
	<div style="margin:10px;">
</cfif>

<div style="font-weight:bold;margin-bottom:10px;" id="loginMsg_BodyRegion"></div>
<b>Enter your HomePortals username and password:</b><Br><br>

<form name="frm" action="##" method="post" onSubmit="return false" style="padding:0px;margin:0px;">
<table>
	<tr>
		<td>Username:</td>
		<td><input name="username" type="text" id="username" style="width:100px;"></td>
	</tr>
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
			<cfif IsBoolean(allowRegister) and allowRegister>
				<cfif not arguments.standAlone>
					<input name="btnRegister" type="button" value="Register" onClick="controlPanel.getCreateAccount()">
				<cfelse>
					<input name="btnRegister" type="button" value="Register" onClick="loginClient.getCreateAccount()">
				</cfif>
			</cfif>
		</td>
	</tr>
</table>
</form>

<cfif not arguments.standAlone>
	</div>
	</div>
</cfif>
</cfoutput>
