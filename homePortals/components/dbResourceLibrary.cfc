<cfcomponent implements="homePortals.components.resourceLibrary" hint="Implements a resource library that stores resources in a database. The library creates a table for each resource type and each resource is stored as a row on the corresponding table for its type. Files associated with resources are still stored on the filesystem.">

	<cfscript>
		variables.dsn = "";
		variables.resourcesRoot = "";
		variables.resourceTypeRegistry = 0;
		variables.resLibID = "";
		variables.username = "";
		variables.password = "";
		variables.dbType = "";
		variables.tblPrefix = "";
		variables.resFilesPath = "";
	</cfscript>
	
	<!------------------------------------------------->
	<!--- init				                	   ---->
	<!------------------------------------------------->
	<cffunction name="init" returntype="homePortals.components.resourceLibrary" access="public" hint="This is the constructor">
		<cfargument name="resourceLibraryPath" type="string" required="true">
		<cfargument name="resourceTypeRegistry" type="homePortals.components.resourceTypeRegistry" required="true">
		<cfargument name="configStruct" type="struct" required="true">
		<cfargument name="appRoot" type="string" required="false" default="">
		<cfscript>
			variables.resourcesRoot = arguments.resourceLibraryPath;
			variables.resourceTypeRegistry = arguments.resourceTypeRegistry;
			variables.resLibID = arguments.resourceLibraryPath;

			if(find("://",arguments.resourceLibraryPath)) {
				variables.resLibID = mid(
										arguments.resourceLibraryPath,
										find("://",arguments.resourceLibraryPath)+3,
										len(arguments.resourceLibraryPath)
									);
			}
			
			if(structKeyExists(arguments.configStruct,"dsn")) 
				variables.dsn = arguments.configStruct.dsn;
			else 
				variables.dsn = resLibID;

			if(structKeyExists(arguments.configStruct,"username")) variables.username = arguments.configStruct.username;
			if(structKeyExists(arguments.configStruct,"password")) variables.password = arguments.configStruct.password;
			if(structKeyExists(arguments.configStruct,"dbtype")) variables.dbtype = arguments.configStruct.dbtype;
			if(structKeyExists(arguments.configStruct,"tblPrefix")) variables.tblPrefix = arguments.configStruct.tblPrefix;
			if(structKeyExists(arguments.configStruct,"resFilesPath")) variables.resFilesPath = arguments.configStruct.resFilesPath;
		</cfscript>

		<!--- if no dbtype explicitly given, then get it from the driver --->		
		<cfif variables.dbtype eq "">
			<cfdbinfo type="version" datasource="#dsn#" name="qryDBInfo">
			<cfif findNoCase("mysql",qryDBInfo.driver_name) or findNoCase("mysql",qryDBInfo.driver_name)>
				<cfset variables.dbtype = "mysql">
			</cfif>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!------------------------------------------------->
	<!--- getResourceTypeRegistry              	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypeRegistry" access="public" returntype="homePortals.components.resourceTypeRegistry" hint="returns a reference to the registry for resource types">
		<cfreturn variables.resourceTypeRegistry>
	</cffunction>

	<!---------------------------------------->
	<!--- getResourcePackagesList		   --->
	<!---------------------------------------->	
	<cffunction name="getResourcePackagesList" returntype="query" access="public" hint="returns a query with the names of all resource packages">
		<cfargument name="resourceType" type="string" required="false" default="">
		<cfscript>
			var qry = QueryNew("ResType,Name");
			var reg = getResourceTypeRegistry();
			var res = "";
			var aItems = arrayNew(1);
			var i = 0;
			var j = 0;
			var aResTypes = arrayNew(1);
		
			if(arguments.resourceType neq "")
				aResTypes[1] = arguments.resourceType;
			else
				aResTypes = reg.getResourceTypes();

			for(i=1;i lte arrayLen(aResTypes);i=i+1) {
				res = aResTypes[i];
				rt = reg.getResourceType(res);
				tblName = getResourceTableName( reg.getResourceType(res) );
				
				if(resourceTableExists(rt)) {
					aItems = getPackagesFromResourceTable(rt);
					
					for (j=1;j lte arraylen(aItems); j=j+1){
				   		queryAddRow(qry);
				   		querySetCell(qry,"resType",res);
				   		querySetCell(qry,"name", aItems[j] );
					}
				}
			}
			
			return qry;		
		</cfscript>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResourcesInPackage                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourcesInPackage" access="public" returntype="Array" hint="returns all resources on a package">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfset var rt = getResourceTypeRegistry().getResourceType(arguments.resourceType)>
		<cfset var rtProps = rt.getProperties()>
		<cfset var qry = queryFromResourceTable(arguments.resourceType, arguments.packageName)>
		<cfset var oResourceBean = 0>
		<cfset var aResBeans = arrayNew(1)>
		<cfset var prop = "">

		<!--- an empty package means resources at the root level, so we pass a dummy value so that 
			empty package is not interpreted as all packages --->
		<cfif arguments.packageName eq "">
			<cfset arguments.packageName = "_ROOT_">
		</cfif>
		<cfset qry = queryFromResourceTable(arguments.resourceType, arguments.packageName)>

		<cfloop query="qry">
			<cfset oResourceBean = getNewResource(arguments.resourceType)>
			<cfset oResourceBean.setID(qry.id)>
			<cfset oResourceBean.setPackage(qry.package)>
			<cfset oResourceBean.setHREF(qry.href)>
			<cfset oResourceBean.setDescription(qry.description)>
			<cfif qry.createdOn neq "">
				<cfset oResourceBean.setCreatedOn(qry.createdOn)>
			</cfif>
			<cfloop collection="#rtProps#" item="prop">
				<cfset oResourceBean.setProperty(rtProps[prop].name, qry[prop][currentRow])>
			</cfloop>
			<cfset arrayAppend(aResBeans, oResourceBean)>
		</cfloop>

		<cfreturn aResBeans>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResource		                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResource" access="public" returntype="homePortals.components.resourceBean" hint="returns the resource bean for the given resource">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfargument name="resourceID" type="string" required="true">
		<cfset var rt = getResourceTypeRegistry().getResourceType(arguments.resourceType)>
		<cfset var rtProps = rt.getProperties()>
		<cfset var oResourceBean = 0>
		<cfset var qry = queryFromResourceTable(arguments.resourceType, arguments.packageName, arguments.resourceID)>

		<cfif qry.recordCount gt 0>
			<cfset oResourceBean = getNewResource(arguments.resourceType)>
			<cfset oResourceBean.setID(qry.id)>
			<cfset oResourceBean.setPackage(qry.package)>
			<cfset oResourceBean.setHREF(qry.href)>
			<cfset oResourceBean.setDescription(qry.description)>
			<cfif qry.createdOn neq "">
				<cfset oResourceBean.setCreatedOn(qry.createdOn)>
			</cfif>
			<cfloop collection="#rtProps#" item="prop">
				<cfset oResourceBean.setProperty(rtProps[prop].name, qry[prop][1])>
			</cfloop>
		<cfelse>
			<cfthrow message="The requested resource [#arguments.packageName#][#arguments.resourceID#] was not found"
						type="homePortals.resourceLibrary.resourceNotFound">
		</cfif>

		<cfreturn oResourceBean>
	</cffunction>

	<!------------------------------------------------->
	<!--- saveResource	                       	   ---->
	<!------------------------------------------------->
	<cffunction name="saveResource" access="public" returntype="void" hint="Adds or updates a resource in the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true" hint="the resource to add or update"> 		
		<cfscript>
			var reg = getResourceTypeRegistry();
			var rb = arguments.resourceBean;
			var resType = rb.getType(); // resource type string
			var rt = 0;
			var resTypeDir = "";
			var tableName = "";

			// validate bean			
			if(rb.getID() eq "") throw("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(rb.getType() eq "") throw("No resource type has been specified for the resource","homePortals.resourceLibrary.validation");
			if(rb.getPackage() eq "") throw("No package has been specified for the resource","homePortals.resourceLibrary.validation");

			rt = reg.getResourceType(resType); // resource type object
			tableName = getResourceTableName(rt);
			lstFields = getResourceTableColumnList(rt);
			if(not reg.hasResourceType(resType)) throw("The resource type is invalid or not supported","homePortals.resourceLibrary.invalidResourceType");
		
			// make sure resource table exists
			if(!resourceTableExists(rt))
				createResourceTable(rt);
		</cfscript>

		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#" maxrows="1">
			SELECT id
				FROM #tableName#
				WHERE package = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getPackage()#">
					AND id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getID()#"> 
		</cfquery>		
		
		<cfif qry.recordCount eq 0>
			<cfset rb.setCreatedOn(now())>
			<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#" maxrows="1">
				INSERT INTO #tableName# (#lstFields#)
					VALUES (
						<cfloop list="#lstFields#" index="fld">
							<cfswitch expression="#fld#">
								<cfcase value="id">
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getID()#">
								</cfcase>
								<cfcase value="package">
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getPackage()#">
								</cfcase>
								<cfcase value="href">
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getHREF()#">
								</cfcase>
								<cfcase value="description">
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getDescription()#">
								</cfcase>
								<cfcase value="createdOn">
									<cfqueryparam cfsqltype="cf_sql_timestamp" value="#rb.getCreatedOn()#">
								</cfcase>
								<cfdefaultcase>
									<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#rb.getProperty(fld)#">
								</cfdefaultcase>
							</cfswitch>
							<cfif fld neq listlast(lstFields)>,</cfif>
						</cfloop>
					)
			</cfquery>
		<cfelse>
			<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#" maxrows="1">
				UPDATE #tableName# 
					SET
						<cfloop list="#lstFields#" index="fld">
							<cfswitch expression="#fld#">
								<cfcase value="id">
									id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getID()#">
								</cfcase>
								<cfcase value="package">
									package = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getPackage()#">
								</cfcase>
								<cfcase value="href">
									href = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getHREF()#">
								</cfcase>
								<cfcase value="description">
									description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getDescription()#">
								</cfcase>
								<cfcase value="createdOn">
									<!--- ignore this one --->
									createdOn = createdOn
								</cfcase>
								<cfdefaultcase>
									#fld# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getProperty(fld)#">
								</cfdefaultcase>
							</cfswitch>
							<cfif fld neq listlast(lstFields)>,</cfif>
						</cfloop>
					WHERE package = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getPackage()#">
						AND id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rb.getID()#"> 
			</cfquery>
		</cfif>
	</cffunction>

	<!------------------------------------------------->
	<!--- deleteResource	                       ---->
	<!------------------------------------------------->
	<cffunction name="deleteResource" access="public" returntype="void" hint="Removes a resource from the library. If the resource has a related file then the file is deleted">
		<cfargument name="ID" type="string" required="true">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="package" type="string" required="true">
		<cfset var tableName = getResourceTableName( getResourceTypeRegistry().getResourceType(arguments.resourceType) )>
		<cfset var resBean = getResource(arguments.resourceType, arguments.package, arguments.id)>
		
		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#" maxrows="1">
			DELETE
				FROM #tableName#
				WHERE package = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.package#">
					AND id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#"> 
		</cfquery>		
		
		<!--- remove resource file --->
		<cfif resourceFileExists(resBean)>
			<cffile action="delete" file="#getResourceFilePath(resBean)#">
		</cfif>
	</cffunction>	

	<!------------------------------------------------->
	<!--- getNewResource	                       ---->
	<!------------------------------------------------->
	<cffunction name="getNewResource" access="public" returntype="homePortals.components.resourceBean" hint="creates a new empty instance of a given resource type for this library">
		<cfargument name="resourceType" type="string" required="true">
		<cfset var rt = getResourceTypeRegistry().getResourceType(arguments.resourceType)>
		<cfset var oResBean = rt.createBean(this)>
		<cfreturn oResBean>
	</cffunction>

	<!------------------------------------------------->
	<!--- getPath			                	   ---->
	<!------------------------------------------------->
	<cffunction name="getPath" access="public" returntype="string" hint="returns the path for this library">
		<cfreturn variables.resourcesRoot>
	</cffunction>
	

	<!------------------------------------------------->
	<!--- Resource (Target) File Operations   	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceFileHREF" access="public" returntype="string" hint="returns the full (web accessible) path to a file object on the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfset var href = arguments.resourceBean.getHref()>
		
		<cfif right(variables.resFilesPath,1) neq "/">
			<cfset href = variables.resFilesPath & "/" & href />
		<cfelse>
			<cfset href = variables.resFilesPath & href />
		</cfif>
		
		<cfreturn href>
	</cffunction>

	<cffunction name="getResourceFilePath" access="public" returntype="string" hint="If the object can be reached through the file system, then returns the absolute path on the file system to a file object on the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true">
		<cfreturn expandPath(getResourceFileHREF(arguments.resourceBean))> 
	</cffunction>
	
	<cffunction name="resourceFileExists" access="public" output="false" returntype="boolean" hint="Returns whether the file associated with a resource exists on the local file system or not.">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfreturn arguments.resourceBean.getHref() neq "" and fileExists(getResourceFilePath(arguments.resourceBean))>
	</cffunction>
	
	<cffunction name="readResourceFile" access="public" output="false" returntype="any" hint="Reads the file associated with a resource. If there is no associated file then returns a missingTargetFile error. This only works for target files stored within the resource library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfargument name="readAsBinary" type="boolean" required="false" default="false" hint="Reads the file as a binary document">
		<cfset var href = getResourceFilePath(arguments.resourceBean)>
		<cfset var doc = "">
		
		<cfif resourceFileExists(arguments.resourceBean)>
			<cfif arguments.readAsBinary>
				<cffile action="readbinary" file="#href#" variable="doc">
			<cfelse>
				<cffile action="read" file="#href#" variable="doc">
			</cfif>
		<cfelse>
			<cfthrow message="Resource has no associated file or file does not exists" type="homePortals.resourceBean.missingTargetFile">
		</cfif>
		
		<cfreturn doc>
	</cffunction>
	
	<cffunction name="saveResourceFile" access="public" output="false" returntype="void" hint="Saves a file associated to this resource">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfargument name="fileContent" type="any" required="true" hint="File contents">
		<cfargument name="fileName" type="string" required="false" hint="filename to use" default="">
		<cfargument name="contentType" type="string" required="false" hint="MIME content type of the resource file" default="">
		<cfscript>
			var rb = arguments.resourceBean;
			var rt = getResourceTypeRegistry().getResourceType( rb.getType() );
			var defaultExtension = listFirst(rt.getFileTypes());
			var href = "";
			
			// get default filename and extension
			if(arguments.fileName eq "") {
				arguments.fileName = rb.getID();
			}

			if(listLen(arguments.fileName,".") eq 0
					and defaultExtension neq "") {
				arguments.fileName  = arguments.fileName 
										& "." 
										& defaultExtension;
			}	
			
			if(listLen(arguments.fileName,"_") gte 3 
					and listFirst(arguments.fileName,"_") eq rb.getType()
					and listGetAt(arguments.fileName,2,"_") eq rb.getPackage()) {
				href = arguments.fileName;
			} else {
				href = rb.getType() 
						& "_" 
						& rb.getPackage() 
						& "_" 
						& arguments.fileName;	
			}
					
			rb.setHREF(href);
		</cfscript>
		
		<cfif not directoryExists(expandPath(variables.resFilesPath))>
			<cfdirectory action="create" directory="#expandPath(variables.resFilesPath)#">
		</cfif>

		<cffile action="write" file="#expandPath(rb.getFullHREF())#" output="#arguments.fileContent#">

		<cfset saveResource(rb)>
	</cffunction>

	<cffunction name="addResourceFile" access="public" output="false" returntype="void" hint="Copies an existing file to the resource library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfargument name="filePath" type="string" required="true" hint="absolute location of the file">
		<cfargument name="fileName" type="string" required="false" hint="filename to use" default="">
		<cfargument name="contentType" type="string" required="false" hint="MIME content type of the resource file" default="">
		<cfset var rb = arguments.resourceBean>
		<cfset var rt = getResourceTypeRegistry().getResourceType( rb.getType() )>
		<cfset var defaultExtension = listFirst(rt.getFileTypes())>
		<cfset var href = "">
		
		<cfscript>
			// get default filename and extension
			if(arguments.fileName eq "") {
				arguments.fileName = rb.getID();
			}

			if(listLen(arguments.fileName,".") eq 0
					and defaultExtension neq "") {
				arguments.fileName  = arguments.fileName 
										& "." 
										& defaultExtension;
			}	
			
			href = rb.getType()
					& "_" 
					& rb.getPackage() 
					& "_" 
					& arguments.fileName;	
					
			rb.setHREF(href);
		</cfscript>

		<cfif not directoryExists(expandPath(variables.resFilesPath))>
			<cfdirectory action="create" directory="#expandPath(variables.resFilesPath)#">
		</cfif>

		<cffile action="copy" source="#arguments.filePath#" destination="#expandPath(rb.getFullHREF())#">

		<cfset saveResource(rb)>
	</cffunction>

	<cffunction name="deleteResourceFile" access="public" output="false" returntype="void" hint="Deletes the file associated with a resource">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfif resourceFileExists(arguments.resourceBean)>
			<cffile action="delete" file="#getResourceFilePath(arguments.resourceBean)#">
		</cfif>
		<cfset arguments.resourceBean.setHREF("")>
		<cfset saveResource(arguments.resourceBean)>
	</cffunction>



	<!------------- Private Methods ----------------------->

	<cffunction name="resourceTableExists" access="private" returntype="boolean">
		<cfargument name="resourceType" type="any" required="true">
		<cfset var qry = 0>
		<cfset var tblName = getResourceTableName(arguments.resourceType)>
		
		<cfdbinfo datasource="#variables.dsn#" 
					username="#variables.username#" 
					password="#variables.password#" 
					type="tables" 
					name="qry" 
					pattern="#tblName#" />

		<cfreturn (qry.recordCount gt 0)>
	</cffunction>

	<cffunction name="getPackagesFromResourceTable" access="private" returntype="array">
		<cfargument name="resourceType" type="any" required="true">
		<cfset var tblName = getResourceTableName(arguments.resourceType)>
		<cfset var qry = 0>

		<cfif !resourceTableExists(arguments.resourceType)>
			<cfset qry = queryNew("package")>
		<cfelse>
			<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				SELECT DISTINCT package
					FROM #tblName#
			</cfquery>			
		</cfif>
			
		<cfreturn listToArray(valueList(qry.package))>
	</cffunction>

	<cffunction name="queryFromResourceTable" access="private" returntype="query">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="false" default="">
		<cfargument name="resourceID" type="string" required="false" default="">

		<cfset var rt = getResourceTypeRegistry().getResourceType(arguments.resourceType)>
		<cfset var qry = 0>
		<cfset var tableName = getResourceTableName(rt)>
		<cfset var lstFields = getResourceTableColumnList(rt)>
	
		<cfif !resourceTableExists(rt)>
			<cfset qry = queryNew(lstFields)>
		<cfelse>
			<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				SELECT #lstFields#
					FROM #tableName#
					WHERE 1 = 1
						<cfif arguments.packageName eq "_ROOT_">
							AND package = <cfqueryparam cfsqltype="cf_sql_varchar" value="">
						<cfelseif arguments.packageName neq "">
							AND package = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.packageName#">
						</cfif>
						<cfif arguments.resourceID neq "">
							AND id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.resourceID#"> 
						</cfif>
			</cfquery>				
		</cfif>

		<cfreturn qry>
	</cffunction>

	<cffunction name="getResourceTableColumnList" access="private" returntype="string">
		<cfargument name="resourceType" type="any" required="true">
		<cfset var lstFields = "id,package,href,description,createdOn">
		<cfset var lstPropFields = "">
		<cfset var rtProps = arguments.resourceType.getProperties()>
		<cfloop collection="#rtProps#" item="prop">
			<cfset lstPropFields = listAppend(lstPropFields,prop)>
		</cfloop>
		<cfif lstPropFields neq "">
			<cfset lstFields = listAppend(lstFields, lstPropFields)>
		</cfif>
		<cfreturn lstFields>
	</cffunction>

	<cffunction name="getResourceTableName" access="private" returntype="string">
		<cfargument name="resourceType" type="any" required="true">
		<cfreturn variables.tblPrefix & arguments.resourceType.getName()>
	</cffunction>

	<cffunction name="createResourceTable" access="private" returntype="void">
		<cfargument name="resourceType" type="any" required="true">
		<cfset var tableName = getResourceTableName(arguments.resourceType)>
		<cfset var lstFields = getResourceTableColumnList(arguments.resourceType)>
		<cfset var qry = 0>
		<cfset var fld = "">

		<cfswitch expression="#variables.dbType#">
			<cfcase value="mysql">
				<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
					CREATE TABLE  `#tableName#` (
						<cfloop list="#lstFields#" index="fld">
							<cfswitch expression="#fld#">
								<cfcase value="id">
									`id` VARCHAR(250) NOT NULL,
								</cfcase>
								<cfcase value="package">
									`package` VARCHAR(500) NOT NULL,
								</cfcase>
								<cfcase value="href">
									`href` VARCHAR(1000) default NULL,
								</cfcase>
								<cfcase value="description">
									`description` VARCHAR(1000) default NULL,
								</cfcase>
								<cfcase value="createdOn">
									`createdOn` DATETIME default NULL,
								</cfcase>
								<cfdefaultcase>
									`#fld#` VARCHAR(1000) default NULL,
								</cfdefaultcase>
							</cfswitch>
						</cfloop>
					  PRIMARY KEY  (`id`)
					) ENGINE=InnoDB DEFAULT CHARSET=latin1;
				</cfquery>				
			</cfcase>
			<cfcase value="mssql">
				<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
					CREATE TABLE  [#tableName#] (
						<cfloop list="#lstFields#" index="fld">
							<cfswitch expression="#fld#">
								<cfcase value="id">
									[id] VARCHAR(250) NOT NULL,
								</cfcase>
								<cfcase value="package">
									[package] VARCHAR(500) NOT NULL,
								</cfcase>
								<cfcase value="href">
									[href] VARCHAR(1000) NULL,
								</cfcase>
								<cfcase value="description">
									[description] VARCHAR(1000) NULL,
								</cfcase>
								<cfcase value="createdOn">
									[createdOn] DATETIME NULL,
								</cfcase>
								<cfdefaultcase>
									[#fld#] VARCHAR(1000) NULL,
								</cfdefaultcase>
							</cfswitch>
						</cfloop>
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
				<cfthrow message="Database type not supported" type="dbResourceLibrary.dbTypeNotSupported">
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="removeFile" access="private" hint="deletes a file">
		<cfargument name="path" type="string" hint="full path to file">
		<cffile action="delete" file="#arguments.path#">
	</cffunction>	
	
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="type" type="string" default="homePortals.resourceLibrary.exception"> 
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>

</cfcomponent>