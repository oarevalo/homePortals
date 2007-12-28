<cfcomponent displayname="gmail">

	<cffunction name="init" access="remote">
		<cfargument name="instanceName" type="string" default="gmail">
		<cfargument name="username" type="string" default="">
		<cfargument name="password" type="string" default="">
		<cfargument name="numItems" type="string" default="5">		
		
		<cfset session[arguments.instanceName] = StructNew()>
		<cfset session[arguments.instanceName].username = arguments.username>
		<cfset session[arguments.instanceName].password = arguments.password>
		<cfset session[arguments.instanceName].numItems = arguments.numItems>
	</cffunction>

	<cffunction name="getMail" access="remote" output="true">
		<cfargument name="instanceName" type="string" default="gmail">

		<cfset var args = "">
		<cfset var xmlMail = "">
		<cfset var aEntries = ArrayNew(1)>
		<cfset var urlGMail = "https://mail.google.com/mail">
		<cfset var hasMessages = false>
		<cfset var stUser = getUserInfo()>
		
		<cftry>
			<cfif Not StructKeyExists(session, arguments.instanceName)>
				<cfset session[arguments.instanceName] = StructNew()>
				<cfset session[arguments.instanceName].username = "">
				<cfset session[arguments.instanceName].password = "">
				<cfset session[arguments.instanceName].numItems = "5">
			</cfif>
		
			<cfset args = session[arguments.instanceName]>
			
			<cfif stUser.isOwner>
				<!--- check that there is a username and password --->
				<cfif trim(args.username) neq "" and trim(args.password) neq "">
					<cfhttp method="get" url="https://mail.google.com/mail/feed/atom" username="#args.username#" password="#args.password#">
					</cfhttp>
					<cfset xmlMail = xmlParse(cfhttp.FileContent)>
					<cfset aEntries = xmlMail.xmlRoot.xmlChildren>
					<cfset urlGMail = urlGMail & "?account_id=" & URLEncodedFormat(args.username)>
					
					<cfoutput>
						<cfloop from="1" to="#arraylen(aEntries)#" index="i">
							<cfset thisEntry = aEntries[i]>
							<cfif thisEntry.xmlName eq "entry">
								<a href="#thisEntry.link.xmlAttributes.href#" target="_blank"><b>#thisEntry.title.xmlText#</b></a> - <a href="mailto:#thisEntry.author.email.xmlText#">#thisEntry.author.name.xmlText#</a><br>
								#thisEntry.summary.xmlText#
								<hr />
								<cfset hasMessages = true>
							</cfif>
						</cfloop>
						<cfif Not hasMessages>
							<em>There are no new email messages.</em>
							<hr />
						</cfif>
					</cfoutput>	
				<cfelse>
					<!--- if there is no username/password, display friendly message --->	
					<cfset getLogin(arguments.instanceName)>
				</cfif>
			<cfelse>
				<p>To preserve your privacy, you must be logged in and be the page owner to display 
				your emails. Otherwise if this is not a private page
				others will be able to look at your email extracts.</p>
			</cfif>
		
			<cfcatch type="any">
				<cfoutput>
					#cfcatch.message#
				</cfoutput>
			</cfcatch>
		</cftry>
	</cffunction>


	<cffunction name="getLogin" access="remote" output="true">
		<cfargument name="instanceName" type="string" default="gmail">
		<form name="frm" action="##" method="post" onSubmit="return false">
			Username:<br>
			<input type="text" name="user" value=""><br><br>
			Password:<br>
			<input type="password" name="password" value=""><br><br>
			<br><input type="checkbox" name="remember" value="1">Remember Me
			<input type="button" name="btn" onclick="#instanceName#.doLogin(this.form)" value="Sign-In">
		</form>
	</cffunction>
	
	
	<cffunction name="doLogin" access="remote">
		<cfargument name="instanceName" type="string" default="gmail">
		<cfargument name="username" type="string" default="">
		<cfargument name="password" type="string" default="">
		<cfargument name="remember" type="string" default="false">		
		
		<cfset var pwd = ""> 
		
		<cftry>
			<cfif Not StructKeyExists(session, arguments.instanceName)>
				<cfset session[arguments.instanceName] = StructNew()>
				<cfset session[arguments.instanceName].numItems = "5">
			</cfif>
		
			<cfset session[arguments.instanceName].username = arguments.username>
			<cfset session[arguments.instanceName].password = arguments.password>
			
			<cfoutput>
				<b>Login OK</b>
				<script>
					#arguments.instanceName#.getMail();
				</script>
			</cfoutput>

			<cfcatch type="any">
				<cfoutput>
					<strong>Error:</strong> #cfcatch.Message#<br>#cfcatch.Detail#
				</cfoutput>
			</cfcatch>
		</cftry>
		
	</cffunction>	


	<cffunction name="decryptText" access="private" returntype="string">
		<cfargument name="theText" type="string" required="yes">
		<cfscript>
			var output = "";
			var Temp = ArrayNew(1);
			var Temp2 = ArrayNew(1);
			var TextSize = len(theText);
			for (i = 1; i lte TextSize; i=i+1) {
				Temp[i] = asc(mid(theText,i,1)) mod 256;
				Temp2[i] = asc(mid(theText,i+1,1)) mod 256;
				writeoutput("[" & Temp[i] & "] [" & Temp2[i] & "]<br>");
			}
			for (i = 1; i lte TextSize; i=i+2) {
				output = output & chr(abs(Temp[i] - Temp2[i]));
				writeoutput(abs(Temp[i] - Temp2[i]) & "<br>");
			}		
		</cfscript>
		
		<cfreturn output>
	</cffunction>

	<!-------------------------------------->
	<!---                                --->
	<!--- getUserInfo                    --->
	<!---                                --->
	<!-------------------------------------->
	<cffunction name="getUserInfo" returntype="struct" hint="returns info about the current logged in user">
		<cfset var stRet = StructNew()>
		<cfset stRet.username = "">
		<cfset stRet.isOwner = false>
		
		<cfif IsDefined("Session.homeConfig")>
			<cfif IsDefined("Session.User.qry")>
				<cfset stRet.username = session.user.qry.username>
				<cfset stRet.isOwner = (session.user.qry.username eq ListGetAt(session.homeConfig.href, 2, "/"))>
			</cfif>
		</cfif>
		
		<cfreturn stRet>
	</cffunction>	

</cfcomponent>