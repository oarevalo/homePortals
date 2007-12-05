<!--- Login.cfm
This module allows users to login to their accounts. Displays
a login/register form on the page. Also processes cookie logins.
---->

<cfcomponent displayname="login" extends="Home.Components.baseModule">
	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			cfg.setModuleClassName("login");
			cfg.setView("default", "login/main");
			cfg.setView("htmlhead", "login/htmlHead");

			// get handle for accounts object 
			variables.oAccounts = this.controller.getAPIObject("accounts");
			variables.oAccounts.init();
			variables.accountsRoot = variables.oAccounts.getConfig().accountsRoot;
		</cfscript>	
	</cffunction>


	<!---------------------------------------->
	<!--- doLogin        	               --->
	<!---------------------------------------->	
	<cffunction name="doLogin" access="public" output="true">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="rememberMe" default="false" type="boolean" required="no">

		<cfset var qryUser = QueryNew("")>
		
		<cftry>
			<!--- check login --->
			<cfset qryUser = variables.oAccounts.checkLogin(arguments.username, Arguments.password)>
			
			<cfif qryUser.RecordCount eq 0>
				<cfthrow message="Invalid username/password.">
			<cfelse>
				<cfset session.User = StructNew()>
				<cfset session.User.ID = qryUser.UserID>
				<cfset session.User.LocalKey = Hash(qryUser.email & "-" & qryUser.username)>
				<cfset session.User.qry = qryUser>
			</cfif>

			<cfif arguments.rememberMe eq 1>
				<cfcookie name="homeportals_username" value="#qryUser.username#" expires="never">			
				<cfcookie name="homeportals_userKey" value="#session.User.LocalKey#" expires="never">			
			</cfif>
			
			<cfset this.controller.setMessage("Welcome Back!")>
					
			<cflocation url="#variables.accountsRoot#/#qryUser.username#">
					
			<cfcatch type="any">
				<cfset this.controller.setMessage(jsstringformat(cfcatch.Message))>
			</cfcatch>
		</cftry>
	</cffunction>
	

	<!---------------------------------------->
	<!--- doCookieLogin        	           --->
	<!---------------------------------------->	
	<cffunction name="doCookieLogin" access="public" output="true">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="userkey" type="string" required="yes">

		<cfset var realKey = "">
		<cfset var qry = "">

		<cftry>
			<!--- get info on requested user --->
			<cfset qry = variables.oAccounts.getAccountByUsername(arguments.username)>

			<!--- if user found, then authenticate user --->
			<cfif qry.RecordCount gt 0>
				<!--- build the real key that the user needs to authenticate --->
				<cfset realKey = Hash(qry.email & "-" & qry.username)>
				
				<!--- if provided key is the same as the real key, then user is authenticated --->
				<cfif arguments.userkey eq realkey>
					<cfset session.User = StructNew()>
					<cfset session.User.ID = qry.UserID>
					<cfset session.User.LocalKey = Hash(qry.email & "-" & qry.username)>
					<cfset session.User.qry = qry>
				</cfif>
			</cfif>

			<cfcatch type="any">
				<cfset this.controller.setMessage(jsstringformat(cfcatch.Message))>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- doLogoff        	               --->
	<!---------------------------------------->	
	<cffunction name="doLogoff" access="public" output="true">
		<cfset var username = "">
		
		<cftry>
			<cfif IsDefined("session.user") and IsDefined("Session.user.qry")>
				<cfset username = session.user.qry.username>
				
				<!--- clear user from session --->
				<cfset session.user = "">
				
				<!--- delete cookies (in case autologin was enabled) --->
				<cfcookie name="homeportals_username" value="" expires="never">			
				<cfcookie name="homeportals_userKey" value="" expires="never">	
	
				<!--- redirect to user public homepage --->
				<cflocation url="#variables.accountsRoot#/#username#">
			</cfif>
			
			<cfcatch type="any">
				<!--- redirect to user public homepage --->
				<cflocation url="#variables.accountsRoot#/#username#">
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- doCreateAccount     	           --->
	<!---------------------------------------->	
	<cffunction name="doCreateAccount" access="public" hint="Creates an account and sets up the account environment">
		<cfargument name="username" required="yes" type="string">
		<cfargument name="password" required="yes" type="string">
		<cfargument name="password2" required="yes" type="string">
		<cfargument name="email" required="no" type="string">
		
		<cfset var errMsg = "">
		<cfset var allowRegister = false>
		<cfset var lstFlds = "">
		<cfset var i = 0>
		
		<cftry>
			<cfscript>
				// check that public account creation is enabled 
				allowRegister = application.HomePortalsAccountsConfig.allowRegisterAccount;
				
				if(Not allowRegister) 
					throw("Account creation in this site is not allowed. To create an account please contact the site administrator.");
				
				// validate arguments
				lstFlds = "Email,Password2,Password,Username";
				for(i=1;i lte ListLen(lstFlds);i=i+1) 
					if(Evaluate("arguments." & ListGetAt(lstFlds,i)) eq "") errMsg = ListGetAt(lstFlds,i) & " is required";
	
				if(Arguments.Password neq Arguments.Password2) errMsg = "Both passwords must match.";
				
				if(errMsg neq "") throw(errMsg);

				// create account 
				variables.oAccounts.createAccount(arguments.username, arguments.password, arguments.email);
				
				// login user
				doLogin(Arguments.Username, Arguments.Password);
			</cfscript>

			<cfcatch type="any">
				<cfset tmpHTML = "An error ocurred while creating the account.<br>#cfcatch.Message#<br>#cfcatch.detail#">
				<cfset this.controller.setMessage(jsstringformat(tmpHTML))>
			</cfcatch>
		</cftry>

	</cffunction>


	<!---------------------------------------->
	<!--- throw                            --->
	<!---------------------------------------->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string" required="yes">
		<cfthrow message="#arguments.message#">
	</cffunction>
	
</cfcomponent>
	