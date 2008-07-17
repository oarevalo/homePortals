<cfcomponent displayname="dbStorage" extends="storage">

	<cfset variables.lstStorageSettings = "datasource,username,password,accountsTable,dbtype">

	<!--------------------------------------->
	<!----  isInitialized				  ----->
	<!--------------------------------------->
	<cffunction name="isInitialized" returntype="boolean" access="public" hint="Returns whether the account storage has been initialized properly">
		<cfset var bRetVal = true>

		<cftry>
			<cfif oAccountsConfigBean.getDatasource() neq "">
				<!--- check for user table --->
				<cfquery name="qry" 
						datasource="#oAccountsConfigBean.getDatasource()#" 
						username="#oAccountsConfigBean.getUsername()#" 
						password="#oAccountsConfigBean.getPassword()#"
						maxrows="1" timeout="5">
					SELECT UserID, Username, Password, Email, CreateDate, FirstName, MiddleName, LastName 
						FROM #oAccountsConfigBean.getAccountsTable()#
				</cfquery>
			<cfelse>
				<!--- datasource not set --->
				<cfset bRetVal = false>
			</cfif>
			<cfcatch type="any">
				<!--- errors indicate account tables not setup properly --->
				<cfset bRetVal = false>
			</cfcatch>
		</cftry>
		
		<cfreturn bRetVal>
	</cffunction>
	
	<!--------------------------------------->
	<!----  initializeStorage 		  ----->
	<!--------------------------------------->
	<cffunction name="initializeStorage" access="public" hint="initializes the account storage">
		
		<cfif oAccountsConfigBean.getDatasource() neq "">
			<cfswitch expression="#oAccountsConfigBean.getDBType()#">
				<cfcase value="MSSQL">
					<!--- setup for MS SQL Server --->
					<cfset setupAccountsDB_MSSQLServer()>
				</cfcase>
				<cfcase value="MySQL">
					<!--- setup for MySQL --->
					<cfset setupAccountsDB_MySQL()>
				</cfcase>
				<cfdefaultcase>
					<cfthrow message="You have indicated a type of database not supported for automatic setup. Account table must be set manually">
				</cfdefaultcase>
			</cfswitch>
		<cfelse>
			<cfthrow message="Account information has not setup properly. Please enter configuration settings before creating the tables.">
		</cfif>
	</cffunction>

	<!--------------------------------------->
	<!----  search   				  ----->
	<!--------------------------------------->
	<cffunction name="search" access="public" returntype="query" hint="Searches account records.">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="username" type="string" required="no" default="">
		<cfargument name="lastname" type="string" required="no" default="">
		<cfargument name="email" type="string" required="no" default="">
		<cfargument name="orderBy" type="string" required="no" default="Username">
		<cfset var qry = QueryNew("")>

		<cfquery name="qry"
					datasource="#oAccountsConfigBean.getDatasource()#" 
					username="#oAccountsConfigBean.getUsername()#" 
					password="#oAccountsConfigBean.getPassword()#">
			SELECT *
				FROM #oAccountsConfigBean.getAccountsTable()# 
				
				<cfif arguments.userID neq "">
					WHERE UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UserID#">
				<cfelse>
					WHERE 1=1
						<cfif arguments.username neq "">AND Username LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#"></cfif>
						<cfif arguments.lastname neq "">AND lastname LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.lastname#"></cfif>
						<cfif arguments.email neq "">AND email LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#"></cfif>
				</cfif>

				ORDER BY #arguments.orderBy#
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<!--------------------------------------->
	<!----  create					  ----->
	<!--------------------------------------->
	<cffunction name="create" access="public" hint="Creates a new account record." returntype="string">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="FirstName" type="string" required="no" default="">
		<cfargument name="MiddleName" type="string" required="no" default="">
		<cfargument name="LastName" type="string" required="no" default="">
		<cfargument name="Email" type="string" required="no" default="">

		<cfset var newUserID = createUUID()>
		
		<!--- insert record --->
		<cfquery name="qry" datasource="#oAccountsConfigBean.getDatasource()#" 
						username="#oAccountsConfigBean.getUsername()#" 
						password="#oAccountsConfigBean.getPassword()#">
			INSERT INTO #oAccountsConfigBean.getAccountsTable()# (UserID, Username, Password, Email, firstName, middleName, lastName, CreateDate)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#newUserID#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Hash(Arguments.Password)#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Email#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.firstName#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.middleName#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.lastName#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
					)
		</cfquery>
		
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

		<cfquery name="qry"
					datasource="#oAccountsConfigBean.getDatasource()#" 
						username="#oAccountsConfigBean.getUsername()#" 
						password="#oAccountsConfigBean.getPassword()#">
			UPDATE #oAccountsConfigBean.getAccountsTable()# 
				SET FirstName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FirstName#">,
					MiddleName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.MiddleName#">,
					LastName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LastName#">,
					Email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Email#">
				WHERE UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UserID#">
		</cfquery>
		
	</cffunction>

	<!--------------------------------------->
	<!----  delete          			  ----->
	<!--------------------------------------->
	<cffunction name="delete" access="public" hint="Deletes an account record.">
		<cfargument name="userID" type="string" required="yes">

		<!--- delete record in table --->
		<cfquery name="qry"
					datasource="#oAccountsConfigBean.getDatasource()#" 
						username="#oAccountsConfigBean.getUsername()#" 
						password="#oAccountsConfigBean.getPassword()#">
			DELETE FROM #oAccountsConfigBean.getAccountsTable()# 
				WHERE UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UserID#">
		</cfquery>
	</cffunction>

	<!--------------------------------------->
	<!----  changePassword   		      ----->
	<!--------------------------------------->
	<cffunction name="changePassword" access="public" hint="Change accont password.">
		<cfargument name="UserID" type="string" required="yes">
		<cfargument name="NewPassword" type="string" required="yes">

		<cfquery name="qry"
					datasource="#oAccountsConfigBean.getDatasource()#" 
						username="#oAccountsConfigBean.getUsername()#" 
						password="#oAccountsConfigBean.getPassword()#">
			UPDATE #oAccountsConfigBean.getAccountsTable()# 
				SET Password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.NewPassword)#">
				WHERE UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UserID#">
		</cfquery>
	</cffunction>


	<!------------  P R I V A T E      M E T H O D S ------------------>
	
	<!--------------------------------------->
	<!----  setupAccountsDB_MSSQLServer ----->
	<!--------------------------------------->
	<cffunction name="setupAccountsDB_MSSQLServer" access="private" 
				hint="SQL Code to Create account table for MS SQL Server">

		<!--- drop users table --->
		<cfquery name="qry" datasource="#oAccountsConfigBean.getDatasource()#" 
						username="#oAccountsConfigBean.getUsername()#" 
						password="#oAccountsConfigBean.getPassword()#">
			if exists (select * from dbo.sysobjects where id = object_id(N'dbo.#this.AccountsTable#') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
			drop table dbo.#oAccountsConfigBean.getAccountsTable()#
		</cfquery>
		
		<!--- create users table --->
		<cfquery name="qry" datasource="#oAccountsConfigBean.getDatasource()#" 
						username="#oAccountsConfigBean.getUsername()#" 
						password="#oAccountsConfigBean.getPassword()#">
			CREATE TABLE dbo.[#oAccountsConfigBean.getAccountsTable()#] (
				[userID] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
				[username] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
				[password] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
				[firstName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
				[middleName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
				[lastName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
				[email] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
				[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_cfe_user_CreateDate] DEFAULT (getdate()),
				CONSTRAINT [PK__cfe_user__4E5E8EA2] PRIMARY KEY  CLUSTERED 
				(
					[userID]
				)  ON [PRIMARY] 
			) ON [PRIMARY]
		</cfquery>
	</cffunction>

	<!--------------------------------------->
	<!----  setupAccountsDB_MySQL    	  ----->
	<!--------------------------------------->
	<cffunction name="setupAccountsDB_MySQL" access="private" 
				hint="SQL Code to Create account table for MySQL">

		<!--- drop users table --->
		<cfquery name="qry" datasource="#oAccountsConfigBean.getDatasource()#" 
						username="#oAccountsConfigBean.getUsername()#" 
						password="#oAccountsConfigBean.getPassword()#">
			DROP TABLE IF EXISTS `#oAccountsConfigBean.getAccountsTable()#`
		</cfquery>
		
		<!--- create users table --->
		<cfquery name="qry" datasource="#oAccountsConfigBean.getDatasource()#" 
						username="#oAccountsConfigBean.getUsername()#" 
						password="#oAccountsConfigBean.getPassword()#">
			CREATE TABLE `#oAccountsConfigBean.getAccountsTable()#` (
				`userID` varchar(35) NOT NULL default '',
				`username` varchar(20) NOT NULL default '' ,
				`password` varchar(50) NOT NULL default '' ,
				`firstName` varchar(100) NULL ,
				`middleName` varchar(100) NULL ,
				`lastName` varchar(100) NULL ,
				`email` varchar(100) NOT NULL ,
				`CreateDate` datetime NOT NULL default '0000-00-00 00:00:00',
				PRIMARY KEY (`userID`)
			) ENGINE=InnoDB
		</cfquery>
	</cffunction>

	
</cfcomponent>