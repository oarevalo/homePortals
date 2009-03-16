<cfcomponent extends="Home.components.lib.DAOFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("sites")>
		<cfset setPrimaryKey("siteID","cf_sql_varchar")>
		
		<cfset addColumn("accountID", "cf_sql_varchar")>
		<cfset addColumn("title", "cf_sql_varchar")>
		<cfset addColumn("defaultPage", "cf_sql_varchar")>
		<cfset addColumn("createdOn", "cf_sql_varchar")>
	</cffunction>

</cfcomponent>
