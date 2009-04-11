<cfcomponent extends="homePortalsAccounts.components.lib.DAOFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("friends")>
		<cfset setPrimaryKey("friendID","cf_sql_varchar")>
		
		<cfset addColumn("accountName", "cf_sql_varchar")>
		<cfset addColumn("accountName_friend", "cf_sql_varchar")>
		<cfset addColumn("requestDate", "cf_sql_date")>
		<cfset addColumn("confirmed", "cf_sql_boolean")>
	</cffunction>

</cfcomponent>
