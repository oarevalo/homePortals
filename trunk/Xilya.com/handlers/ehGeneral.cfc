<cfcomponent name="ehGeneral" extends="eventhandler">	<cffunction name="onApplicationStart">	</cffunction>	<cffunction name="onRequestStart" access="public">	</cffunction>	<cffunction name="onRequestEnd" access="public">	</cffunction>	<cffunction name="dspHome" access="public" returntype="string">		<cfscript>			try {				// Process autologin (when user has clicked on remember me before)				if(isDefined("cookie.homeportals_username") 						and isDefined("cookie.homeportals_userKey") 						and cookie.homeportals_username neq ""						and cookie.homeportals_userKey neq "") {					doCookieLogin(cookie.homeportals_username, cookie.homeportals_userKey);				}								setView("vwHome");								} catch(any e) {				getService("bugTracker").notifyService(e.message, e);			}		</cfscript>	</cffunction>	<cffunction name="dspAbout" access="public" returntype="string">		<cfset setView("vwAbout")>	</cffunction>		<cffunction name="dspLogin" access="public" returntype="string">		<cfset setView("vwLogin")>	</cffunction>	<cffunction name="dspRegister" access="public" returntype="string">		<cfset setView("vwRegister")>	</cffunction>	<cffunction name="dspNoAccess" access="public" returntype="string">		<cfset setView("vwNoAccess")>	</cffunction>	<cffunction name="doCheckAccountName" access="public" returntype="string">		<cfscript>			var accountName = getValue("accountName","");			var oAccountsService = 0;			var qry = 0;					try {				if(accountName eq "") 					throw("Please select a name for your workarea","xilya.validation");									oAccountsService = getAccountsService();							// get info on requested user 				qry = oAccountsService.getAccountByUsername(accountName);							if(qry.recordCount gt 0) 					throw("The workarea name you selected is already taken. Please select a different name","xilya.validation");				else					setNextEvent("ehGeneral.dspRegister","accountName=#accountName#");						} catch(xilya.validation e) { 				setMessage("warning", e.message);				setNextEvent("ehGeneral.dspHome");						} catch(any e) {				setMessage("error", e.message);				getService("bugTracker").notifyService(e.message, e);				setNextEvent("ehGeneral.dspHome");			}		</cfscript>			</cffunction>	<cffunction name="doLogin" access="public" returntype="string">		<cfset var qryUser = QueryNew("")>		<cfset var oAccountsService = 0>		<cfset var accountName = getValue("accountName","")>		<cfset var password = getValue("password","")>		<cfset var rememberMe = getValue("rememberMe",0)>		<cfset var localSecret = getLocalSecret()>				<cftry>			<cfset oAccountsService = getAccountsService()>			<cfset qryUser = oAccountsService.loginUser(accountName,password)>						<cfif rememberMe eq 1>				<cfcookie name="homeportals_username" value="#qryUser.username#" expires="never">							<cfcookie name="homeportals_userKey" value="#Hash(localSecret)#" expires="never">						</cfif>						<cflocation url="/accounts/#qryUser.username#">			<cfcatch type="any">				<cfset setMessage("error", cfcatch.message)>				<cfset getService("bugTracker").notifyService(cfcatch.message, cfcatch)>				<cfset setNextEvent("ehGeneral.dspLogin")>			</cfcatch>		</cftry>	</cffunction>	<cffunction name="doLogOff" access="public" returntype="void">		<cftry>			<cfset oAccountsService = getAccountsService()>			<cfset oAccountsService.logoutUser()>				<cfcookie name="homeportals_username" value="" expires="now">						<cfcookie name="homeportals_userKey" value="" expires="now">				<cfset setNextEvent("ehGeneral.dspHome")>			<cfcatch type="any">				<cfset setMessage("error", cfcatch.message)>				<cfset getService("bugTracker").notifyService(cfcatch.message, cfcatch)>				<cfset setNextEvent("ehGeneral.dspHome")>			</cfcatch>		</cftry>	</cffunction>	<cffunction name="doRegister" access="public" returntype="string">		<cfscript>			var o = 0;			var accountID = 0;			var hpRoot = "/Home";			var accountName = getValue("accountName","");			var password = getValue("password","");			var password2 = getValue("password2","");			var email = getValue("email","");			var firstName = getValue("firstName","");			var lastName = getValue("lastName","");			var agree = getValue("agree",false);			var args = structNew();			var memberID = "";			var oAccountsService = 0;			try {				// validate form				if(accountName eq "") throw("The workarea cannot be empty. Please correct.","xilya.validation");				if(reFind("[^A-Za-z0-9_]",accountName)) throw("The selected workarea name is invalid","xilya.validation");				if(len(accountName) lt 5) throw("The workarea name must be at least 5 characters long","xilya.validation");				if(email eq "") throw("Please enter your email address.","xilya.validation");				if(reReplace(email,"^.+@[^\.].*\.[a-z]{2,}$","OK") neq "OK") throw("Please enter a valid email address.","xilya.validation");				if(password eq "") throw("Password cannot be empty","xilya.validation");				if(len(password) lt 6) throw("Passwords must be at least 6 characters long","xilya.validation");				if(password neq password2) throw("The password confirmation does not match the selected passwords. Please correct.","xilya.validation");				if(not agree) throw("You must agree to the terms and conditions before creating an account","xilya.validation");								// create and initialize account object				oAccountsService = getAccountsService();									// create HomePortals account				accountID = oAccountsService.createAccount(accountName, password, email);										// crate and initialize members object				o = createObject("component","xilya.components.members");				o.init();					args.ID = "";				args.firstName = firstName;				args.middleName = "";				args.lastName = lastName;				args.email = email;				args.password = password;				args.type = "general";				args.accountID = accountID;				memberID = o.save(argumentCollection = args);				o.commit();								// send confirmation email				sendConfirmationEmail(accountName, args);								// login to account				doLogin();			} catch(xilya.validation e) { 				setMessage("warning", e.message);				setView("vwRegister");						} catch(any e) {				setMessage("error", e.message);				getService("bugTracker").notifyService(e.message, e);				setView("vwRegister");			}		</cfscript>	</cffunction>	<!---------------------------------------->	<!--- doCookieLogin        	           --->	<!---------------------------------------->		<cffunction name="doCookieLogin" access="public" output="true">		<cfargument name="username" type="string" required="yes">		<cfargument name="userkey" type="string" required="yes">		<cfset var realKey = "">		<cfset var qry = "">		<cfset var hpRoot = "/Home">		<cfset var oAccountsService = 0>		<cfset var localSecret = getLocalSecret()>		<cftry>			<cfset oAccountsService = getAccountsService()>						<!--- get info on requested user --->			<cfset qry = oAccountsService.getAccountByUsername(arguments.username)>			<!--- if user found, then authenticate user --->			<cfif qry.RecordCount gt 0>				<!--- build the real key that the user needs to authenticate --->				<cfset realKey = Hash(localSecret)>								<!--- if provided key is the same as the real key, then user is authenticated --->				<cfif arguments.userkey eq realkey>					<cfset qryUser = oAccountsService.loginUser(arguments.username, "", qry.password)>										<!--- take user to his homepage --->					<cflocation url="/Accounts/#qry.username#">				<cfelse>					<cfthrow message="Invalid key">				</cfif>			<cfelse>				<cfthrow message="Account not found">			</cfif>			<cfcatch type="any">				<cfset setMessage("error", cfcatch.message)>				<cfset getService("bugTracker").notifyService(cfcatch.message, cfcatch)>				<cfset setNextEvent("ehGeneral.dspLogin")>			</cfcatch>		</cftry>	</cffunction>	<cffunction name="getLocalSecret" returntype="string">		<cfset var localSecret = "En su grave rincon, los jugadores "							& "rigen las lentas piezas. El tablero "							& "los demora hasta el alba en su severo "							& "ambito en que se odian dos colores. ">		<cfreturn localSecret>	</cffunction>	<cffunction name="sendConfirmationEmail" access="private" output="true">		<cfargument name="accountName" type="string" required="yes">		<cfargument name="memberStruct" type="struct" required="true">		<cfmail from="info@xilya.com" 				to="#arguments.memberStruct.email#"				subject="Welcome To Xilya.com"				type="html">			<a href="http://www.xilya.com"><img src="http://xilya.homeportals.net/images/xilya_email_header.jpg" 					border="0" alt="Xilya.com - Your space, your work"					width="501" height="75"></a>			<p>			Hi #arguments.memberStruct.firstName#, welcome to 			<a href="http://www.xilya.com">Xilya.com</a>. Xilya is 			an experiment in personal online workspaces. It is currently under			active development so hiccups may happen from time to time. Please			do not hesitate to contact me at 			<a href="mailto:oarevalo@xilya.com">oarevalo@xilya.com</a> if you have			any questions or suggestions.			</p>			<p>				<b>Username:</b> #arguments.accountName#<br />				<b>Password:</b> #arguments.memberStruct.password#			</p>			<p>Oscar A.</p>		</cfmail>				<cfmail from="info@xilya.com" 				to="info@xilya.com"				subject="Xilya.com: New Registration"				type="html">							<b>New Registration Info:</b><br>						<table>				<tr><td><b>Account Name:</b></td><td>#arguments.accountName#</td></tr>				<tr><td><b>Account ID:</b></td><td>#arguments.memberStruct.accountID#</td></tr>				<tr><td><b>Email:</b></td><td>#arguments.memberStruct.email#</td></tr>				<tr><td><b>Name:</b></td><td>#arguments.memberStruct.firstName# #arguments.memberStruct.lastName#</td></tr>				<tr><td><b>Type:</b></td><td>#arguments.memberStruct.type#</td></tr>			</table>						</cfmail>	</cffunction>		<cffunction name="getAccountsService" returntype="Home.Components.accounts" access="package">		<cfscript>			var	configFilePath_Xilya = "/xilya/config/homePortals-config.xml";			var	configFilePath_HomePortals = "/Home/Config/homePortals-config.xml";			var oHomePortalsConfigBean = 0;			var oAccountsService  = 0;					// create an empty config bean			oHomePortalsConfigBean = createObject("component", "Home.Components.homePortalsConfigBean").init();									// load default config			oHomePortalsConfigBean.load(expandPath(configFilePath_HomePortals));						// load config for xilya			oHomePortalsConfigBean.load(expandPath(configFilePath_Xilya));			oAccountsService = CreateObject("component", "Home.Components.accounts").init(oHomePortalsConfigBean);			return oAccountsService;		</cfscript>		</cffunction>	</cfcomponent>