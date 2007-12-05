<cfset moduleID = this.controller.getModuleID()>
<cfset thisPageURL = "index.cfm?currentHome=#this.controller.getModuleConfigBean().getPageHREF()#&refresh=true&#RandRange(1,100)#">
<cfset allowRegister = application.HomePortalsAccountsConfig.allowRegisterAccount>

<!--- Process autologin (when user has clicked on remember me before) --->
<cfif isDefined("cookie.homeportals_username") and isDefined("cookie.homeportals_userKey") 
		and cookie.homeportals_username neq ""
		and cookie.homeportals_userKey neq "">
	<cfset doCookieLogin(cookie.homeportals_username, cookie.homeportals_userKey)>
</cfif>

<!--- get user info --->
<cfset stUser = this.controller.getUserInfo()>

<cfoutput>
	<cfif stUser.username neq "">
	<!--- There is a user logged in --->
		<div style="font-size:11px;">
			<b>Welcome, #Session.User.qry.username#</b>
			<p>
				<b>What do you want to do?</b>
				<li><a href="/Accounts/#stUser.username#/">Go to my homepage</a></li>
				<li><a href="#thisPageURL#">Refresh this page</a></li>
				<li><a href="javascript:#moduleID#.doAction('doLogoff')"><strong>Log Out</strong></a></li>
			</p>
		</div>
	<cfelse>
		<!--- There is no one logged in --->
		<b>Enter your HomePortals username and password:</b><Br><br>
		
		<form name="frm" action="##" method="post" onSubmit="return false" style="padding:0px;margin:0px;">
			<table cellpading="0" cellspacing="0">
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
						<input name="btnLogin" type="button" value="Login" onClick="#moduleID#.doFormAction('doLogin',this.form)">&nbsp;
						<cfif IsBoolean(allowRegister) and allowRegister>
							<input name="btnRegister" type="button" value="Register" onClick="#moduleID#.getView('login/createAccount')">
						</cfif>
					</td>
				</tr>
			</table>
		</form>
	</cfif>
</cfoutput>
