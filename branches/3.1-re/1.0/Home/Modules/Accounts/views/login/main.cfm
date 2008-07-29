<!--- Process autologin (when user has clicked on remember me before) --->
<cfif isDefined("cookie.homeportals_username") and isDefined("cookie.homeportals_userKey") 
		and cookie.homeportals_username neq ""
		and cookie.homeportals_userKey neq "">
	<cfinvoke component="controlPanel" method="doCookieLogin">
		<cfinvokeargument name="username" value="#cookie.homeportals_username#">
		<cfinvokeargument name="userKey" value="#cookie.homeportals_userKey#">
	</cfinvoke>
</cfif>

<script>
	<cfif isDefined("session.user") and isDefined("session.user.id") and session.user.id neq "">
		loginClient.getAccountWelcome();
	<cfelse>
		loginClient.getLogin();
	</cfif>
</script>
