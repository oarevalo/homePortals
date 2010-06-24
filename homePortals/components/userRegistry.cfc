<cfcomponent displayname="userRegistry" hint="This is component is responsible for maintaining a registry of the currently logged in user. Using a registry decouples other elements of the framework of having a dependency to whatever scope is used to persist users state. The component itself does not need to be persisted, since it knows how to retrieve its information from a persistent scope">

	<cfset variables.registryVarName = "_hpUserInfo">
	
	<cffunction name="init" access="public" returntype="userRegistry">
		<cftry>
			<!--- if the registry doesnt exist, then reset it --->		
			<cfif Not structKeyExists(session, variables.registryVarName)>
				<cfset reinit()>
			</cfif>
			<cfcatch type="any">
				<!--- if there is no session scope enabled just return, so that everything doesnt fail
					just because this cfc was instantiated --->
			</cfcatch>
		</cftry>
		<cfreturn this>
	</cffunction>

	<cffunction name="reinit" access="public" returntype="void" hint="clears the registry of the logged-in user">
		<cfset session[variables.registryVarName] = getEmptyUserStruct()>
	</cffunction>

	<cffunction name="setUserInfo" access="public" returntype="void" hint="adds a user to the registry">
		<cfargument name="userID" type="string" required="true">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="userData" type="Any" required="false" hint="Any additional data about the user">
		<cfset var tmp = {
						userID = arguments.userID,
						userName = arguments.userName,
						userData = arguments.userData,
						loginTime = Now()
					}>
		<cfset session[variables.registryVarName] = tmp>
	</cffunction>

	<cffunction name="getUserInfo" access="public" returntype="struct" 
				hint="Retrieves information about the current logged-in user for this session">
		<!--- return user information --->
		<cftry>
			<cfreturn duplicate(session[variables.registryVarName])>
			<cfcatch type="any">
				<cfreturn getEmptyUserStruct()>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getEmptyUserStruct" access="private" returntype="struct">
		<cfset var st = {
						userID = "",
						userName = "",
						userData = ""
					}>
		<cfreturn duplicate(st)>
	</cffunction>

</cfcomponent>