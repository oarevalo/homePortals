<cfcomponent extends="homePortals.components.plugin">

	<cfset variables.oAccounts = 0>


	<cffunction name="onAppInit" access="public" returntype="void">
		<cfset variables.oAccounts = createObject("component","accounts").init( getHomePortals() )>
	</cffunction>

	<cffunction name="onBeforePageLoad" access="public" returntype="string">
		<cfargument name="eventArg" type="string" required="true" hint="the page to load">	
		<cfset var account = "">
		<cfset var page = "">
	
		<!--- if there is no default page, then check if the pagehref has the format for an account page 
			or if there is a default account page --->
		<cfif arguments.eventArg eq "" or findNoCase("::",arguments.eventArg)>
			<cfset account = listFirst(arguments.eventArg,"::")>
			<cfif listLen(arguments.eventArg,"::") gt 1>
				<cfset page = listLast(arguments.eventArg,"::")>
			</cfif>
			<cfset arguments.eventArg = getAccountsService().getAccountPageHREF(account,page)>
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