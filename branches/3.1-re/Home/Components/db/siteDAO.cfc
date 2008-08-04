<cfcomponent extends="Home.Components.lib.DAOFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("page")>
		<cfset setPrimaryKey("pageID","cf_sql_varchar")>
		
		<cfset addColumn("accountID", "cf_sql_varchar")>
		<cfset addColumn("title", "cf_sql_varchar")>
		<cfset addColumn("pageURI", "cf_sql_varchar")>
		<cfset addColumn("access", "cf_sql_varchar")>
		<cfset addColumn("createdOn", "cf_sql_varchar")>
	</cffunction>

</cfcomponent>
