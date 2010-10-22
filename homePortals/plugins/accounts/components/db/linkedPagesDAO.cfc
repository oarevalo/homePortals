<cfcomponent extends="homePortals.plugins.accounts.components.lib.DAOFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("linkedPages")>
		<cfset setPrimaryKey("linkedPageID","cf_sql_varchar")>
		
		<cfset addColumn("siteID", "cf_sql_varchar")>
		<cfset addColumn("name", "cf_sql_varchar")>
		<cfset addColumn("linkPath", "cf_sql_varchar")>
	</cffunction>

	<cffunction name="createTable" access="public" returntype="void">
		<cfset var tableName = getTableName()>
		<cfset var dsn = getDataProvider().getConfig().getDSN()>
		<cfset var username = getDataProvider().getConfig().getUsername()>
		<cfset var password = getDataProvider().getConfig().getPassword()>
		<cfset var dbType = getDataProvider().getConfig().getDBType()>
	
		<cfif dbType neq "mysql">
			<cfthrow message="Creation of table not implemented for this dbtype">
		</cfif>
	
		<cfquery name="qry" datasource="#dsn#" username="#username#" password="#password#">
			CREATE TABLE  `#tableName#` (
				`linkedPageID` INT(11) NOT NULL AUTO_INCREMENT,
				`siteID` VARCHAR(500) NOT NULL,
				`name` VARCHAR(500) NULL,
				`linkPath` VARCHAR(1000) NULL,
			  PRIMARY KEY  (`linkedPageID`)
			) ENGINE=InnoDB DEFAULT CHARSET=latin1;
		</cfquery>				
	</cffunction>
	
</cfcomponent>
