<cfcomponent extends="homePortals.plugins.accounts.components.lib.DAOFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("sites")>
		<cfset setPrimaryKey("siteID","cf_sql_varchar")>
		
		<cfset addColumn("accountID", "cf_sql_varchar")>
		<cfset addColumn("title", "cf_sql_varchar")>
		<cfset addColumn("defaultPage", "cf_sql_varchar")>
		<cfset addColumn("createdOn", "cf_sql_timestamp")>
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
				`siteID` INT(11) NOT NULL AUTO_INCREMENT,
				`accountID` VARCHAR(500) NOT NULL,
				`title` VARCHAR(500) NULL,
				`defaultPage` VARCHAR(1000) NULL,
				`createdOn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			  PRIMARY KEY  (`siteID`)
			) ENGINE=InnoDB DEFAULT CHARSET=latin1;
		</cfquery>				
	</cffunction>
	  
</cfcomponent>
