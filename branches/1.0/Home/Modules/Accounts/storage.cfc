<cfcomponent displayname="storage">
	
	<!--- these are the settings that are particular to this type of storage --->
	<cfset this.lstStorageSettings = "">

	<!--------------------------------------->
	<!----  setConfig				  ----->
	<!--------------------------------------->
	<cffunction name="setConfig" access="public" hint="Sets the account settings">
		<cfargument name="configStruct" type="Struct" required="true" hint="Config struct">
		<cfset this.stConfig = duplicate(arguments.configStruct)>
	</cffunction>

	<!--------------------------------------->
	<!----  getStorageSettingsList	  ----->
	<!--------------------------------------->
	<cffunction name="getStorageSettingsList" access="public" hint="Returns the list of settings that are particular to this type of storage" returntype="string">
		<cfreturn this.lstStorageSettings>
	</cffunction>

	<!--------------------------------------->
	<!----  isInitialized				  ----->
	<!--------------------------------------->
	<cffunction name="isInitialized" returntype="boolean" access="public" hint="Returns whether the account storage has been initialized">
		<cfreturn false> 
	</cffunction>
	
	<!--------------------------------------->
	<!----  initializeStorage 				  ----->
	<!--------------------------------------->
	<cffunction name="initializeStorage" access="public" hint="initializes the account storage">
	</cffunction>

	<!--------------------------------------->
	<!----  search   				  ----->
	<!--------------------------------------->
	<cffunction name="search" access="public" returntype="query" hint="Searches account records.">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="lastname" type="string" required="yes">
		<cfargument name="email" type="string" required="yes">
		<cfargument name="maxRows" type="numeric" required="no" default="11">
		<cfset var qry = QueryNew("")>
		<cfreturn qry>
	</cffunction>

	<!--------------------------------------->
	<!----  create					  ----->
	<!--------------------------------------->
	<cffunction name="create" access="public" hint="Creates a new account record." returntype="string">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="email" type="string" required="yes">
		<cfset var newUserID = createUUID()>
		<cfreturn newUserID>
	</cffunction>

	<!--------------------------------------->
	<!----  update					  ----->
	<!--------------------------------------->
	<cffunction name="update" access="public" hint="Updates an account record.">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="firstName" type="string" required="yes">
		<cfargument name="middleName" type="string" required="yes">
		<cfargument name="lastName" type="string" required="yes">
		<cfargument name="email" type="string" required="yes">
	</cffunction>

	<!--------------------------------------->
	<!----  delete          			  ----->
	<!--------------------------------------->
	<cffunction name="delete" access="public" hint="Deletes an account record.">
		<cfargument name="userID" type="string" required="yes">
	</cffunction>

	<!--------------------------------------->
	<!----  changePassword   		      ----->
	<!--------------------------------------->
	<cffunction name="changePassword" access="public" hint="Change accont password.">
		<cfargument name="UserID" type="string" required="yes">
		<cfargument name="NewPassword" type="string" required="yes">
	</cffunction>


</cfcomponent>