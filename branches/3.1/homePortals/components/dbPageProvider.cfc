<cfcomponent implements="pageProvider">

	<cfset variables.dsn = "">
	<cfset variables.contentRoot = "">
	<cfset variables.tableName = "hpContent">
	<cfset variables.username = "">
	<cfset variables.password = "">
	<cfset variables.dbtype = "">

	<cffunction name="init" access="public" returntype="pageProvider" hint="constructor">
		<cfargument name="config" type="homePortalsConfigBean" hint="main configuration bean for the application">
		<cfset variables.contentRoot = arguments.config.getContentRoot()>
		<cfif left(variables.contentRoot,1) neq "/">
			<cfset variables.contentRoot = arguments.config.getAppRoot() & variables.contentRoot>
		</cfif>
		<cfset variables.dsn = getSetting(config,"dsn")>
		<cfset variables.tableName = getSetting(config,"tableName", variables.tableName)>
		<cfset variables.username = getSetting(config,"username")>
		<cfset variables.password = getSetting(config,"password")>
		<cfset variables.dbtype = getSetting(config,"dbtype")>

		<!--- if no dbtype explicitly given, then get it from the driver --->		
		<cfif variables.dbtype eq "">
			<cfdbinfo type="version" datasource="#dsn#" name="qryDBInfo">
			<cfif findNoCase("mysql",qryDBInfo.driver_name) or findNoCase("mysql",qryDBInfo.driver_name)>
				<cfset variables.dbtype = "mysql">
			<cfelseif findNoCase("mssql",qryDBInfo.driver_name) or findNoCase("mssql",qryDBInfo.driver_name)>
				<cfset variables.dbtype = "mssql">
			</cfif>
		</cfif>
	
		<!--- initialize content table if needed --->
		<cfset checkContentTable()>
	
		<cfreturn this>
	</cffunction>

	<cffunction name="getInfo" access="public" returntype="struct" hint="returns a struct with information about a page">
		<cfargument name="path" type="string" hint="the location of the page document">

		<cfscript>
			var filePath = resolvePath(normalizeFilePath(arguments.path));
			var stInfo = structNew();
			var qry = 0;

			qry = queryFromContentTable(filePath,false,true);

			stInfo.lastModified = qry.updatedOn;
			stInfo.size = len(qry.content);
			stInfo.readOnly = false;
			stInfo.createdOn = qry.createdOn;
			stInfo.path = qry.path;
			stInfo.exists = (qry.isFolder eq 0 and qry.recordCount gt 0);
			
			return stInfo;
		</cfscript>
	</cffunction>

	<cffunction name="pageExists" access="public" returntype="boolean" hint="returns whether the page exists in the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfset var filePath = resolvePath(normalizeFilePath(arguments.path))>
		<cfset var qry = queryFromContentTable(filePath)>
		<cfreturn (qry.isFolder eq 0 and qry.recordCount gt 0)>
	</cffunction>

	<cffunction name="load" access="public" returntype="pageBean" hint="loads a page from the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfset var oPage = 0>
		<cfset var filePath = resolvePath(normalizeFilePath(arguments.path))>
		<cfset var qry = queryFromContentTable(filePath,false,true)>

		<cfif not (qry.isFolder eq 0 and qry.recordCount gt 0)>
			<cfthrow message="Page not found. [#arguments.path#]" type="pageProvider.pageNotFound">
		</cfif>

		<cfset oPage = createObject("component","pageBean").init(qry.content)>

		<cfreturn oPage>
	</cffunction>

	<cffunction name="save" access="public" returntype="void" hint="stores a page in the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfargument name="page" type="pageBean" hint="the page to save">
		<cfset var xmlDoc = arguments.page.toXML()>
		<cfset var filePath = resolvePath(normalizeFilePath(arguments.path))>
		<cfset var qry = queryFromContentTable(filePath,false,true)>

		<cfif qry.isFolder eq 0 and qry.recordCount gt 0>
			<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				UPDATE #variables.tableName#
					SET updatedOn = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, 
						content = <cfqueryparam cfsqltype="cf_sql_varchar" value="#xmlDoc#">
					WHERE id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#qry.id#">
			</cfquery>
		<cfelse>
			<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				INSERT INTO #variables.tableName#(createdOn, path, isFolder, content)
					VALUES (
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#filePath#">,
						0,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#xmlDoc#">
					)
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="delete" access="public" returntype="void" hint="deletes a page from the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfset var filePath = resolvePath(normalizeFilePath(arguments.path))>
		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			DELETE FROM #variables.tableName#
				WHERE path = <cfqueryparam cfsqltype="cf_sql_varchar" value="#filePath#">
					AND isFolder = 0
		</cfquery>
	</cffunction>

	<cffunction name="move" access="public" returntype="void" hint="moves a page from one location to another">
		<cfargument name="srcpath" type="string" hint="the source location of the page document">
		<cfargument name="tgtpath" type="string" hint="the target location of the page document">
		<cfset var srcFilePath = resolvePath(normalizeFilePath(arguments.srcpath))>
		<cfset var tgtFilePath = resolvePath(normalizeFilePath(arguments.tgtpath))>
		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			UPDATE #variables.tableName#
				SET path = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tgtFilePath#">
				WHERE path = <cfqueryparam cfsqltype="cf_sql_varchar" value="#srcFilePath#">
					AND isFolder = 0
		</cfquery>
	</cffunction>
	
	<cffunction name="createFolder" access="public" returntype="void" hint="creates a folder that can contain other pages or folders">
		<cfargument name="path" type="string" hint="the location where to create the folder">
		<cfargument name="name" type="string" hint="folder name">
		<cfset var newPath = resolvePath(normalizeFilePath(arguments.path & "/" & arguments.name))>
		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			INSERT INTO #variables.tableName#(createdOn, path, isFolder)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#newPath#">,
					1
				)
		</cfquery>
	</cffunction>
	
	<cffunction name="deleteFolder" access="public" returntype="void" hint="deletes a folder">
		<cfargument name="path" type="string" hint="the location of the folder to delete">
		<cfset var filePath = resolvePath(normalizeFilePath(arguments.path))>
		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			DELETE FROM #variables.tableName#
				WHERE path like <cfqueryparam cfsqltype="cf_sql_varchar" value="#filePath#%">
		</cfquery>	
	</cffunction>

	<cffunction name="listFolder" access="public" returntype="query" hint="lists the contents of a folder. Returns a query with the following fields: name,type; where type is either 'folder' or 'page'">
		<cfargument name="path" type="string" hint="the location of the folder to delete">
		<cfset var qryDir = 0>
		<cfset var qryRet = queryNew("name,type")>
		<cfset var filePath = resolvePath(normalizeFilePath(arguments.path))>
		<cfset var qryDir = queryFromContentTable(filePath, true, false)>
		
		<cfloop query="qryDir">
			<cfif not qryDir.isFolder>
				<cfset queryAddRow(qryRet)>
				<cfset querySetCell(qryRet,"type","page")>
				<cfset querySetCell(qryRet,"name",getFileFromPath(qryDir.path))>
			<cfelse>
				<cfset queryAddRow(qryRet)>
				<cfset querySetCell(qryRet,"type","folder")>
				<cfset querySetCell(qryRet,"name",getFileFromPath(qryDir.path))>
			</cfif>
		</cfloop>
		
		<cfreturn qryRet>
	</cffunction>

	<cffunction name="renameFolder" access="public" returntype="void" hint="changes the name of a folder">
		<cfargument name="path" type="string" hint="the location of the folder to be renamed">
		<cfargument name="name" type="string" hint="the new folder name">
		<cfset var srcFilePath = resolvePath(normalizeFilePath(arguments.path))>
		<cfset var tgtFilePath = replace(srcFilePath,getFileFromPath(srcFilePath),arguments.name)>
		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			UPDATE #variables.tableName#
				SET path = replace(path,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#srcFilePath#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#tgtFilePath#">)
				WHERE path like <cfqueryparam cfsqltype="cf_sql_varchar" value="#srcFilePath#%">
		</cfquery>
	</cffunction>

	<cffunction name="folderExists" access="public" returntype="boolean" hint="returns whether a folder exists in the storage">
		<cfargument name="path" type="string" hint="the location of the folder">
		<cfset var filePath = resolvePath(normalizeFilePath(arguments.path))>
		<cfset var qry = queryFromContentTable(filePath)>
		<cfreturn (qry.isFolder eq 1 and qry.recordCount gt 0)>
	</cffunction>	
	

	<!------------- Private Methods ----------------------->

	<cffunction name="checkContentTable" access="private" returntype="void">
		<cfif not contentTableExists()>
			<cfset createContentTable()>
		</cfif>
	</cffunction>

	<cffunction name="contentTableExists" access="private" returntype="boolean">
		<cfset var qry = 0>
		<cfdbinfo datasource="#variables.dsn#" 
					username="#variables.username#" 
					password="#variables.password#" 
					type="tables" 
					name="qry" 
					pattern="#variables.tableName#" />

		<cfreturn (qry.recordCount gt 0)>
	</cffunction>
				
	<cffunction name="resolvePath" access="private" returntype="string">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfset var newPath = variables.contentRoot & arguments.path>
		<cfreturn reReplace(newPath,"/+","/","all")>
	</cffunction>
	
	<cffunction name="normalizeFilePath" access="private" returntype="string">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfif right(arguments.path,4) eq ".xml">
			<cfreturn left(arguments.path,len(arguments.path)-4)>
		<cfelse>
			<cfreturn arguments.path>
		</cfif>
	</cffunction>

	<cffunction name="getSetting" access="public" returntype="string">
		<cfargument name="config" type="any">
		<cfargument name="settingName" type="string" required="true">
		<cfargument name="defaultValue" type="string" required="false" default="">
		<cfset var propValue = arguments.defaultValue>
		<cfset var stProps = arguments.config.getPageProperties()>
		<cfif structKeyExists(stProps,"pageProvider.db." & arguments.settingName)>
			<cfset propValue = stProps["pageProvider.db." & arguments.settingName]>
		</cfif>
		<cfreturn propValue>
	</cffunction>

	<cffunction name="queryFromContentTable" access="private" returntype="query">
		<cfargument name="path" type="string" required="true">
		<cfargument name="folderContents" type="boolean" required="false" default="false">
		<cfargument name="getContent" type="boolean" required="false" default="false">

		<cfset var qry = 0>
		
		<cfif arguments.folderContents and right(arguments.path,1) neq "/">
			<cfset arguments.path = arguments.path & "/">
		</cfif>

		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT id, createdOn, coalesce(updatedOn,createdOn) as updatedOn, path, isFolder <cfif arguments.getContent>, content</cfif>
				FROM #variables.tableName#
				WHERE 
					<cfif arguments.folderContents>
						path like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.path#%">
						AND path not like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.path#%/%">
						AND path not like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.path#">
					<cfelse>
						path = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.path#">
					</cfif>
		</cfquery>				

		<cfreturn qry>
	</cffunction>
			
	<cffunction name="createContentTable" access="private" returntype="void">
		<cfset var qry = 0>

		<cfswitch expression="#variables.dbType#">
			<cfcase value="mysql">
				<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
					CREATE TABLE  `#variables.tableName#` (
						`id` INT(11) NOT NULL AUTO_INCREMENT,
						`createdOn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
						`updatedOn` DATETIME default NULL,
						`path` VARCHAR(1000) NOT NULL,
						`isFolder` INT(11) NOT NULL DEFAULT 0,
						`content` VARCHAR(5000) DEFAULT NULL,
					  PRIMARY KEY  (`id`)
					) ENGINE=InnoDB DEFAULT CHARSET=latin1;
				</cfquery>				
			</cfcase>
			<cfcase value="mssql">
				<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
					CREATE TABLE  [#variables.tableName#] (
						[id] INT(11) NOT NULL,
						[createdOn] DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
						[updatedOn] DATETIME default NULL,
						[path] VARCHAR(1000) NOT NULL,
						[isFolder] INT(11) NOT NULL DEFAULT 0,
						[content] VARCHAR(5000) DEFAULT NULL
					)
					ON [PRIMARY]	
					GO
					ALTER TABLE [#tableName#]
						ADD
						CONSTRAINT [PK_#tableName#]
						PRIMARY KEY
						([id])
						ON [PRIMARY]	
					GO				
				</cfquery>				
			</cfcase>			
			<cfdefaultcase>
				<cfthrow message="Database type not supported" type="dbPageProvider.dbTypeNotSupported">
			</cfdefaultcase>
		</cfswitch>
	</cffunction>
		
</cfcomponent>
