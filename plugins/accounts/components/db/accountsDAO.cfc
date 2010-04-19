<cfcomponent extends="homePortals.plugins.accounts.components.lib.DAOFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("accounts")>
		<cfset setPrimaryKey("accountID","cf_sql_varchar")>
		
		<cfset addColumn("accountName", "cf_sql_varchar")>
		<cfset addColumn("password", "cf_sql_varchar")>
		<cfset addColumn("firstName", "cf_sql_varchar")>
		<cfset addColumn("lastName", "cf_sql_varchar")>
		<cfset addColumn("email", "cf_sql_varchar")>
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
				`accountID` INT(11) NOT NULL AUTO_INCREMENT,
				`accountName` VARCHAR(500) NOT NULL,
				`password` VARCHAR(100) NOT NULL,
				`firstName` VARCHAR(250) NULL,
				`lastName` VARCHAR(250) NULL,
				`email` VARCHAR(250) NULL,
				`createdOn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			  PRIMARY KEY  (`accountID`)
			) ENGINE=InnoDB DEFAULT CHARSET=latin1;
		</cfquery>				
	</cffunction>
	
</cfcomponent>
