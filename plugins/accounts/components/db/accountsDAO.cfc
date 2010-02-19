<cfcomponent extends="homePortals.plugins.accounts.components.lib.DAOFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("accounts")>
		<cfset setPrimaryKey("accountID","cf_sql_varchar")>
		
		<cfset addColumn("accountName", "cf_sql_varchar")>
		<cfset addColumn("password", "cf_sql_varchar")>
		<cfset addColumn("firstName", "cf_sql_varchar")>
		<cfset addColumn("lastName", "cf_sql_varchar")>
		<cfset addColumn("email", "cf_sql_varchar")>
		<cfset addColumn("createdOn", "cf_sql_varchar")>
	</cffunction>

</cfcomponent>
