<cfcomponent extends="homePortals.plugins.accounts.components.lib.DAOFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("friends")>
		<cfset setPrimaryKey("friendID","cf_sql_varchar")>
		
		<cfset addColumn("accountName", "cf_sql_varchar")>
		<cfset addColumn("accountName_friend", "cf_sql_varchar")>
		<cfset addColumn("requestDate", "cf_sql_date")>
		<cfset addColumn("confirmed", "cf_sql_boolean")>
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
				`friendID` INT(11) NOT NULL AUTO_INCREMENT,
				`accountName` VARCHAR(500) NOT NULL,
				`accountName_friend` VARCHAR(500) NOT NULL,
				`confirmed` INT NOT NULL,
				`requestDate` DATETIME NOT NULL,
			  PRIMARY KEY  (`friendID`)
			) ENGINE=InnoDB DEFAULT CHARSET=latin1;
		</cfquery>				
	</cffunction>
	
</cfcomponent>
