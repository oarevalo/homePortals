<cfcomponent extends="homePortals.components.plugin">

	<cfset variables.oAccounts = 0>

	<cffunction name="onAppInit" access="public" returntype="void">
		<cfset variables.oAccounts = createObject("component","homePortals.plugins.accounts.components.accounts").init( getHomePortals() )>
	</cffunction>

	<cffunction name="onBeforePageLoad" access="public" returntype="string">
		<cfargument name="eventArg" type="string" required="true" hint="the page to load">	
		<cfset var account = "">
		<cfset var page = "">
		<cfset var newPageHREF = "">
		<cfset var accRoot = getAccountsService().getConfig().getAccountsRoot()>
		<cfset var numSegmentsPage = 0>
		<cfset var numSegmentsAccRoot = 0>
		<cfset var eventArgWithSlash = arguments.eventArg>

		<cfif right(accRoot,1) neq "/">
			<cfset accRoot = accRoot & "/">
		</cfif>
		<cfif right(eventArgWithSlash,1) neq "/">
			<cfset eventArgWithSlash = eventArgWithSlash & "/">
		</cfif>

		<cfset numSegmentsPage = listLen(arguments.eventArg,"/")>
		<cfset numSegmentsAccRoot = listLen(accRoot,"/")>
		
		<cfif left(arguments.eventArg,len(accRoot)) eq accRoot 
				or (accRoot eq "/" and eventArgWithSlash eq "/")>

			<cfif accRoot eq eventArgWithSlash>
				<!--- 1. page requested is the accounts root, so load default account and default page --->
				<cfset account = "">
				<cfset page = "">
				
			<cfelseif (accRoot eq getDirectoryFromPath(arguments.eventArg) 
					or arguments.eventArg eq getDirectoryFromPath(arguments.eventArg))
					and numSegmentsPage-numSegmentsAccRoot eq 1>
				<!--- 2. page requested is the accounts root and the account name, so load default page on that account --->
				<cfset account = listGetAt(arguments.eventArg,numSegmentsAccRoot+1,"/")>
				<cfset page = "">

			<cfelse>
				<!--- 3. page requested is a page within an account, so load account and page --->
				<cfset account = listGetAt(arguments.eventArg,numSegmentsAccRoot+1,"/")>
				<cfset page = replace(arguments.eventArg, accRoot & account & "/", "")>
			</cfif>

			<cfset newPageHREF = getAccountsService().getAccountPageHREF(account,page)>
			<cfif newPageHREF neq "">
				<cfset arguments.eventArg = newPageHREF>
			</cfif>
		</cfif>
		
		<cfreturn arguments.eventArg>
	</cffunction>

	<cffunction name="onAfterPageLoad" access="public" returntype="homePortals.components.pageRenderer" hint="this method is executed right before the call to loadPage() returns.">
		<cfargument name="eventArg" type="homePortals.components.pageRenderer" required="true" hint="a pageRenderer object intialized for the requested page">	

		<!--- validate access to page --->
		<cfset getAccountsService().validatePageAccess( arguments.eventArg.getPage() )>

		<cfreturn arguments.eventArg>
	</cffunction>
		

	<cffunction name="getAccountsService" access="public" returntype="accounts">
		<cfreturn variables.oAccounts>
	</cffunction>		
	
</cfcomponent>