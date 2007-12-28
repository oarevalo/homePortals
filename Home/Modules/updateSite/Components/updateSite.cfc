<cfcomponent name="updateSite" displayname="updateSite" hint="Create and manage a HomePortals Update Site">

	<cffunction name="init" access="public" hint="Initializes the component.">
		<cfargument name="homeRoot" type="string" required="true" default="/Home/">
		<cfargument name="modulesRoot" type="string" required="true" default="/Home/Modules/">
		<cfscript>
			var tmpXML = "";

			this.xmlDoc = 0;
			this.packagesFile = ExpandPath(arguments.homeRoot & "Config/updateSite-config.xml");
			this.packageRepository = modulesRoot & "updateSite/packages/";
		
			// check if updateSite configuration file exists, if not create it
			if(Not FileExists(this.packagesFile)) {
				this.xmlDoc	= xmlNew();
				this.xmlDoc.xmlRoot = xmlElemNew(this.xmlDoc,"packageDistribution");
				writeFile(this.packagesFile, toString(this.xmlDoc));
			} else {
				tmpXML = readFile(this.packagesFile);
				if(Not IsXML(tmpXML)) throw("The given packages file is not a valid XML document.");
				this.xmlDoc = xmlParse(tmpXML);
			}
		</cfscript>
	</cffunction>

	<cffunction name="getPackagesList" hint="Retrieves a list of packages available for download" access="public" output="false" returntype="query">
		<cfscript>
			var qry = QueryNew("href,name,description,version,dateAdded");
			
			if(StructKeyExists(this.xmlDoc.xmlRoot,"packageList")) {
				aRes = this.xmlDoc.xmlRoot.packageList.xmlChildren;
				for(i=1;i lte ArrayLen(aRes);i=i+1) {
					QueryAddRow(qry);
					QuerySetCell(qry,"href",aRes[i].xmlAttributes.href);
					QuerySetCell(qry,"name",aRes[i].xmlAttributes.name);
					QuerySetCell(qry,"description",aRes[i].xmlText);
					QuerySetCell(qry,"dateAdded",aRes[i].xmlAttributes.dateAdded);
					QuerySetCell(qry,"version",aRes[i].xmlAttributes.version);
				}
			}
		</cfscript>
		<cfreturn qry />
	</cffunction>	

	<cffunction name="getPackageInfo" hint="Retrieves package information" access="public" output="false" returntype="query">
		<cfargument name="href" type="string" required="true">
		
		<cfset var qry = getPackagesList()>
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qry
				WHERE href = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.href#">
		</cfquery>

		<cfreturn qry />
	</cffunction>	
	
	<cffunction name="getInfo" hint="Returns information about this Update site" access="public" output="true" returntype="struct">
		<cfset var stInfo = StructNew()>
		
		<cfif StructKeyExists(this.xmlDoc.xmlRoot,"info")>
			<cfset stInfo.name = this.xmlDoc.xmlRoot.info.name.xmlText>
			<cfset stInfo.description = this.xmlDoc.xmlRoot.info.description.xmlText>
		<cfelse>
			<cfset stInfo.name = "">
			<cfset stInfo.description = "">
		</cfif>

		<cfreturn stInfo />
	</cffunction>

	<cffunction name="saveInfo" hint="Saves information about this Update site" access="public" output="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="description" type="string" required="true">
		
		<!--- if Info node doesnt exist, then create it --->
		<cfif Not StructKeyExists(this.xmlDoc.xmlRoot,"info")>
			<cfset ArrayAppend(this.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(this.xmlDoc,"info"))>
			<cfset ArrayAppend(this.xmlDoc.xmlRoot.info.xmlChildren, xmlElemNew(this.xmlDoc,"name"))>
			<cfset ArrayAppend(this.xmlDoc.xmlRoot.info.xmlChildren, xmlElemNew(this.xmlDoc,"description"))>
		</cfif>

		<cfset this.xmlDoc.xmlRoot.info.name.xmlText = arguments.name>
		<cfset this.xmlDoc.xmlRoot.info.description.xmlText = arguments.description>

		<cfset writeFile(this.packagesFile, toString(this.xmlDoc))>
	</cffunction>
	
	<cffunction name="updatePackageInfo" hint="Updates information about a published package" access="public">
		<cfargument name="href" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="description" type="string" required="true">
		<cfargument name="version" type="string" required="true">
		
		<cfscript>
			if(StructKeyExists(this.xmlDoc.xmlRoot,"packageList")) {
				aRes = this.xmlDoc.xmlRoot.packageList.xmlChildren;
				for(i=1;i lte ArrayLen(aRes);i=i+1) {
					if(aRes[i].xmlAttributes.href eq arguments.href) {
						aRes[i].xmlAttributes.name = arguments.name;
						aRes[i].xmlText = arguments.description;
						aRes[i].xmlAttributes.version = arguments.version;
					}
				}

				writeFile(this.packagesFile, toString(this.xmlDoc));
			}
		</cfscript>
	</cffunction>	

	<cffunction name="deletePackage" hint="removes a package" access="public">
		<cfargument name="href" type="string" required="true">
		<cfscript>
			var bFound = false;
			
			if(StructKeyExists(this.xmlDoc.xmlRoot,"packageList")) {

				// remove from list
				aRes = this.xmlDoc.xmlRoot.packageList.xmlChildren;
				for(i=1;i lte ArrayLen(aRes);i=i+1) {
					if(aRes[i].xmlAttributes.href eq arguments.href) {
						arrayDeleteAt(this.xmlDoc.xmlRoot.packageList.xmlChildren, i);
						bFound = true;
						break;
					}
				}

				if(bFound) {
					// delete package file (if exists, maybe it was deleted manually)
					tmpFilePath = ExpandPath(this.packageRepository & arguments.href);
					if(fileExists(tmpFilePath))
						delete_File(tmpFilePath);
	
					// save package list
					writeFile(this.packagesFile, toString(this.xmlDoc));
				}
			}
		</cfscript>
	</cffunction>

	<cffunction name="publishPackage" hint="Publishes a package for distribution" access="public">
		<cfargument name="PackageDir" type="string" required="true" hint="Directory where the package is located">
		<cfargument name="name" type="string" required="true">
		<cfargument name="description" type="string" required="true">
		<cfargument name="version" type="string" required="true">
				
		<cfscript>
			var objZip = CreateObject("component","Zip");
			var packageName = "";
			var srcPackagePath = "";
			var tgtPackagePath = "";
			var tempDir = "";
			
			packageName = listLast(arguments.packageDir,"/") & ".zip";
			srcPackagePath = expandPath(arguments.packageDir);
			tgtPackagePath = ExpandPath(this.packageRepository & packageName);
			tempDir = arguments.packageDir & "/../" & createUUID() & "/";
			tempPackagePath = ExpandPath(tempDir & packageName);
			
			// check that this same package is not already registered
			if(StructKeyExists(this.xmlDoc.xmlRoot,"packageList")) {
				for(i=1;i lte ArrayLen(this.xmlDoc.xmlRoot.packageList.xmlChildren);i=i+1) {
					tmpNode = this.xmlDoc.xmlRoot.packageList.xmlChildren[i];
					if(tmpNode.xmlAttributes.href eq packageName) {
						throw("This package has already been published. To republish a package first remove it.");
					}
				}
			}
			
			// add package to list
			// append packageList section if doesn't exist
			if(Not StructKeyExists(this.xmlDoc.xmlRoot, "packageList"))
				ArrayAppend(this.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(this.xmlDoc,"packageList"));
			
			// append node for new package
			ArrayAppend(this.xmlDoc.xmlRoot.packageList.xmlChildren, xmlElemNew(this.xmlDoc,"package"));
			newNode = this.xmlDoc.xmlRoot.packageList.xmlChildren[ArrayLen(this.xmlDoc.xmlRoot.packageList.xmlChildren)];
			newNode.xmlAttributes["href"] = packageName;
			newNode.xmlAttributes["name"] = arguments.name;
			newNode.xmlAttributes["dateAdded"] = lsDateFormat(now());
			newNode.xmlAttributes["version"] = arguments.version;
			newNode.xmlText = arguments.description;

		</cfscript>
		
		<!--- check that temp directory exists --->
		<cfif Not DirectoryExists(ExpandPath(tempDir))>
			<cfdirectory action="create" directory="#ExpandPath(tempDir)#">
		</cfif>

		<!--- Create package file in temp location --->
		<cftry>
			<cfinvoke component="#objZip#" 
					  method="addFiles" 
					  returnvariable="rtnZip">
				<cfinvokeargument name="zipFilePath" value="#tempPackagePath#">
				<cfinvokeargument name="directory" value="#srcPackagePath#">
				<cfinvokeargument name="recurse" value="yes">
			</cfinvoke>		
			<cfcatch type="any">
				<cfthrow message="An error ocurred while creating the package. Please check that source directory exists and write permission is enabled on package repository.">
			</cfcatch>
		</cftry>
		
		<!--- check that package repository exists --->
		<cfif Not DirectoryExists(ExpandPath(this.packageRepository))>
			<cfdirectory action="create" directory="#ExpandPath(this.packageRepository)#">
		</cfif>

		<!--- move package to repository --->
		<cffile action="move" source="#tempPackagePath#" destination="#tgtPackagePath#">		

		<!--- delete temp directory --->
		<cfif DirectoryExists(ExpandPath(tempDir))>
			<cfdirectory action="delete" directory="#ExpandPath(tempDir)#">
		</cfif>
		
		<cfscript>
			// save package list
			writeFile(this.packagesFile, toString(this.xmlDoc));		
		</cfscript>
	</cffunction>



	<!--- /*************************** Private Methods **********************************/ --->

	<!--- ************************************ --->
	<!--- * readFile						 * --->
	<!--- ************************************ --->
	<cffunction name="readFile" returntype="string" access="private" hint="reads a file from the filesystem and returns its contents">
		<cfargument name="file" type="string">
		<cftry>
			<cffile action="read" file="#arguments.file#" variable="tmp"> 
			
			<cfcatch type="any">
				<cfif cfcatch.Type eq "Application" and FindNoCase("FileNotFound",cfcatch.Detail)>
					<cfset throw("The requested file [#arguments.file#] does not exist.")>
				<cfelse>
					<cfrethrow>
				</cfif>
			</cfcatch>
		</cftry>
		<cfreturn tmp>
	</cffunction>

	<!--- ************************************ --->
	<!--- * writeFile					   * --->
	<!--- ************************************ --->
	<cffunction name="writeFile" access="private" hint="writes a file to the filesystem">
		<cfargument name="file" type="string">
		<cfargument name="content" type="string">
		<cffile action="write" output="#arguments.content#" file="#arguments.file#">
	</cffunction>

	<!--- ************************************ --->
	<!--- * deleteFile					   * --->
	<!--- ************************************ --->
	<cffunction name="delete_File" access="private" hint="deletes a file from the filesystem">
		<cfargument name="file" type="string">
		<cffile action="delete" file="#arguments.file#">
	</cffunction>

	<!--- ************************************ --->
	<!--- * throw						 	 * --->
	<!--- ************************************ --->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>
	
</cfcomponent>