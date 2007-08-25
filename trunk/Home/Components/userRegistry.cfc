<cfcomponent displayname="userRegistry" hint="This is component is responsible for maintaining a registry of the currently logged in user. Using a registry decouples other elements of the framework of having a dependency to whatever scope is used to persist users state. The component itself does not need to be persisted, since it knows how to retrieve its information from a persistent scope">

	<cfset variables.registryVarName = "_hpUserInfo">
	
	<cffunction name="init" access="public" returntype="userRegistry">
		<!--- if the registry doesnt exist, then reset it --->		
		<cfif Not structKeyExists(session, variables.registryVarName)>
			<cfset reinit()>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="reinit" access="package" returntype="void" hint="clears the registry of the logged-in user">
		<cfset session[variables.registryVarName] = getEmptyUserStruct()>
	</cffunction>

	<cffunction name="setUserInfo" access="package" returntype="void" hint="adds a user to the registry">
		<cfargument name="userID" type="string" required="true">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="userData" type="Any" required="false" hint="Any additional data about the user">
		
		<cfset session[variables.registryVarName] = structNew()>
		<cfset session[variables.registryVarName].userID = arguments.userID>
		<cfset session[variables.registryVarName].userName = arguments.userName>
		<cfset session[variables.registryVarName].userData = arguments.userData>
		<cfset session[variables.registryVarName].loginTime = Now()>
	</cffunction>

	<cffunction name="getUserInfo" access="public" returntype="struct" 
				hint="Retrieves information about the current logged-in user for this session">
		<!--- return user information --->
		<cfreturn duplicate(session[variables.registryVarName])>
	</cffunction>

	<cffunction name="getEmptyUserStruct" access="private" returntype="struct">
		<cfset var st = structNew()>
		<cfset st.userID = "">
		<cfset st.userName = "">
		<cfset st.userData = "">
		<cfreturn st>
	</cffunction>

</cfcomponent>