<cfset moduleID = this.controller.getModuleID()>
<cfset appRoot = this.controller.getHomePortalsConfigBean().getAppRoot()>	

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
			<b>Welcome, #stUser.username#</b>
			<p>
				&bull; <a href="#appRoot#/?account=#stUser.username#">Go to my homepage</a><br /><br />
				&bull; <a href="javascript:#moduleID#.doAction('doLogoff')"><strong>Log Out</strong></a><br />
			</p>
		</div>
	<cfelse>
		<!--- There is no one logged in --->
		<b>Enter your username and password:</b><Br><br>
		
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
					</td>
				</tr>
			</table>
		</form>
	</cfif>
</cfoutput>
