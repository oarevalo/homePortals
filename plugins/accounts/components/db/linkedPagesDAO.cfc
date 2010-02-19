<cfcomponent extends="homePortals.plugins.accounts.components.lib.DAOFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("linkedPages")>
		<cfset setPrimaryKey("linkedPageID","cf_sql_varchar")>
		
		<cfset addColumn("siteID", "cf_sql_varchar")>
		<cfset addColumn("name", "cf_sql_varchar")>
		<cfset addColumn("linkPath", "cf_sql_varchar")>
	</cffunction>

</cfcomponent>
