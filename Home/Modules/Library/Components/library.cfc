<cfcomponent displayname="library">

	<!--- call constructor --->
	<cfset init()>
	
	<cffunction name="getCatalogs" access="public" returntype="query">
		<cfscript>
			var qryCatalogs = QueryNew("index,href,name,description");
			
			if(StructKeyExists(this.xmlDoc.xmlRoot,"registeredCatalogs")) {
				aCatalogs = this.xmlDoc.xmlRoot.registeredCatalogs.xmlChildren;
				for(i=1;i lte ArrayLen(aCatalogs);i=i+1) {
					QueryAddRow(qryCatalogs);
					if(StructKeyExists(aCatalogs[i].xmlAttributes,"href"))
						QuerySetCell(qryCatalogs,"href",aCatalogs[i].xmlAttributes.href);
					if(StructKeyExists(aCatalogs[i].xmlAttributes,"name"))
						QuerySetCell(qryCatalogs,"name",aCatalogs[i].xmlAttributes.name);
					QuerySetCell(qryCatalogs,"description",aCatalogs[i].xmlText);
					QuerySetCell(qryCatalogs,"index",i);
				}
			}
		</cfscript>

		<cfreturn qryCatalogs>
	</cffunction>

	<cffunction name="getCatalog" access="public" returntype="query">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">
		<cfset var qryCatalogs = this.getCatalogs()>
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qryCatalogs
				WHERE index = #arguments.index#
		</cfquery>
		<cfreturn qry> 
	</cffunction>

	<cffunction name="getCatalogIndex" access="public" returntype="numeric">
		<cfargument name="href" type="string" required="true" hint="Path to the location where the catalog is stored">
		<cfset var index = 0>
		<cfset var qryCatalogs = this.getCatalogs()>

		<cfloop query="qryCatalogs">
			<cfif qryCatalogs.href eq arguments.href>
				<cfset index = qryCatalogs.currentRow>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<cfreturn index>
	</cffunction>

	<cffunction name="registerCatalog" access="public">
		<cfargument name="href" type="string" required="true" hint="Path of the catalog xml file to register">

		<cfscript>
			// read catalog 
			tmpXML = readFile(ExpandPath(arguments.href));
			if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
			xmlCatalogDoc = xmlParse(tmpXML);
			
			// append catalogs section if doesn't exist
			if(Not StructKeyExists(this.xmlDoc.xmlRoot, "registeredCatalogs"))
				ArrayAppend(this.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(this.xmlDoc,"registeredCatalogs"));
			else {
				// check that this same catalog is not already registered
				for(i=1;i lte ArrayLen(this.xmlDoc.xmlRoot.registeredCatalogs.xmlChildren);i=i+1) {
					tmpNode = this.xmlDoc.xmlRoot.registeredCatalogs.xmlChildren[i];
					if(tmpNode.xmlAttributes.href eq arguments.href) {
						throw("This catalog is already registered.");
					}
				}
			}
			
			// append node for new catalog
			ArrayAppend(this.xmlDoc.xmlRoot.registeredCatalogs.xmlChildren, xmlElemNew(this.xmlDoc,"catalog"));
			newNode = this.xmlDoc.xmlRoot.registeredCatalogs.xmlChildren[ArrayLen(this.xmlDoc.xmlRoot.registeredCatalogs.xmlChildren)];
			newNode.xmlAttributes["href"] = arguments.href;
			
			// use catalog name if defined, else use the file name
			if(StructKeyExists(xmlCatalogDoc.xmlRoot.xmlAttributes, "name"))
				newNode.xmlAttributes["name"] = xmlCatalogDoc.xmlRoot.xmlAttributes.name;
			else
				newNode.xmlAttributes["name"] = Replace(GetFileFromPath(arguments.href),".xml","");
			
			// if catalog has a description, use it
			if(StructKeyExists(xmlCatalogDoc.xmlRoot.xmlAttributes, "description"))
				newNode.xmlText = xmlCatalogDoc.xmlRoot.xmlAttributes.description;
			
			// save library
			saveLibrary();
		</cfscript>

	</cffunction>

	<cffunction name="createCatalog" access="public">
		<cfargument name="href" type="string" required="true" hint="Path to the location where to store the file">
		<cfargument name="name" type="string" required="true" hint="Catalog name">
		<cfargument name="description" type="string" required="true" hint="Catalog description">
	
		<cfscript>
			var xmlCatalogDoc = xmlNew();
			
			// create new catalog xml object
			xmlCatalogDoc.xmlRoot = xmlElemNew(xmlCatalogDoc,"catalog");
			xmlCatalogDoc.xmlRoot.xmlAttributes["name"] = arguments.name;
			xmlCatalogDoc.xmlRoot.xmlAttributes["description"] = arguments.description;
			
			// save new catalog 
			writeFile(expandPath(arguments.href), toString(xmlCatalogDoc));
		</cfscript>
	</cffunction>

	<cffunction name="removeCatalog" access="public">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">
		<cfargument name="deleteFile" type="Boolean" required="true" default="false" hint="Flag to determine whether to actually delete the catalog file">

		<cfscript>
			var xmlDoc = this.xmlDoc;
			
			// delete the catalog from the library
			tmpNode = xmlDoc.xmlRoot.registeredCatalogs;
			if(arguments.index lte ArrayLen(tmpNode.xmlChildren)) {
				
				// get href of the catalog to remove
				tmpHREF = tmpNode.xmlChildren[arguments.index].xmlAttributes.href;

				// remove catalog from library
				ArrayDeleteAt(tmpNode.xmlChildren, arguments.index);

				// save library
				saveLibrary();
				
				// delete file (if requested)
				if(arguments.deleteFile)
					delete_File(expandPath(tmpHREF));
			}
		</cfscript>
	</cffunction>

	<cffunction name="updateCatalogInfo" access="public">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">
		<cfargument name="name" type="string" required="true" hint="Catalog name">
		<cfargument name="description" type="string" required="true" hint="Catalog description">
	
		<cfscript>
			var xmlDoc = this.xmlDoc;
			
			// update library info
			tmpNode = xmlDoc.xmlRoot.registeredCatalogs.xmlChildren[arguments.index];
			tmpNode.xmlAttributes.name = arguments.name;
			tmpNode.xmlText = arguments.description;
			
			// save library
			saveLibrary();			
			
			// update actual catalog file
			tmpXML = readFile(expandPath(tmpNode.xmlAttributes.href));
			if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
			xmlCatalogDoc = xmlParse(tmpXML);
			
			xmlCatalogDoc.xmlRoot.xmlAttributes.name = arguments.name;
			xmlCatalogDoc.xmlRoot.xmlAttributes.description = arguments.description;
			
			// save catalog
			writeFile(expandPath(tmpNode.xmlAttributes.href), toString(xmlCatalogDoc));
		</cfscript>
		
	</cffunction>

	<cffunction name="importCatalogResource" access="public">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">
		<cfargument name="href" type="string" required="true" hint="Path of the resource descriptor file">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource. module, skin or page">

		<cfscript>
			var xmlDoc = this.xmlDoc;
			
			tmpNode = xmlDoc.xmlRoot.registeredCatalogs.xmlChildren[arguments.index];
			
			// read catalog
			tmpXML = readFile(expandPath(tmpNode.xmlAttributes.href));
			if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
			xmlCatalogDoc = xmlParse(tmpXML);
						
			// read resource descriptor
			tmpXML = readFile(expandPath(arguments.href));
			if(Not IsXML(tmpXML)) throw("The given descriptor file is not a valid XML document.");
			xmlDescriptorDoc = xmlParse(tmpXML);
		
			// append all resources of the selected type in descriptor file to the catalog
			aResources = xmlSearch(xmlDescriptorDoc,"//#arguments.resourceType#");
			for(i=1;i lte ArrayLen(aResources);i=i+1) {
				// check if this resource exists already in this catalog
				aCheckRes = xmlSearch(xmlCatalogDoc,"//#arguments.resourceType#[@id='#aResources[i].xmlAttributes.id#']");
				if(arrayLen(aCheckRes) eq 0) {
					// copy resource node from descriptor to catalog
					newNode = xmlElemNew(xmlCatalogDoc, arguments.resourceType);
					oldNode = aResources[i];
					copyNode(xmlCatalogDoc, newNode, oldNode);
					ArrayAppend(xmlCatalogDoc.xmlRoot[arguments.resourceType & "s"].xmlChildren, newNode);
				}
			}
			
			// save catalog
			writeFile(expandPath(tmpNode.xmlAttributes.href), toString(xmlCatalogDoc));
		</cfscript>
	</cffunction>

	<cffunction name="removeCatalogResource" access="public">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">
		<cfargument name="resourceID" type="string" required="true" hint="ID of the resource">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource. module, skin or page">
	
		<cfscript>
			var xmlDoc = this.xmlDoc;
			
			tmpNode = xmlDoc.xmlRoot.registeredCatalogs.xmlChildren[arguments.index];
			
			// read catalog
			tmpXML = readFile(expandPath(tmpNode.xmlAttributes.href));
			if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
			xmlCatalogDoc = xmlParse(tmpXML);
			
			aResources = xmlCatalogDoc.xmlRoot[arguments.resourceType & "s"].xmlChildren;
			
			for(i=1;i lte ArrayLen(aResources);i=i+1) {
				if(aResources[i].xmlAttributes.id eq arguments.resourceID) {
					ArrayDeleteAt(aResources, i);
					break;
				}
			}
			
			// save catalog
			writeFile(expandPath(tmpNode.xmlAttributes.href), toString(xmlCatalogDoc));
		</cfscript>
	
	</cffunction>

	<cffunction name="importCatalogResourcePackage" access="public">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">
		<cfargument name="href" type="string" required="true" hint="Path of the resource descriptor file">

		<cfscript>
			var xmlDoc = this.xmlDoc;
			
			tmpNode = xmlDoc.xmlRoot.registeredCatalogs.xmlChildren[arguments.index];
			
			// read catalog
			tmpXML = readFile(expandPath(tmpNode.xmlAttributes.href));
			if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
			xmlCatalogDoc = xmlParse(tmpXML);
						
			// read resource descriptor
			tmpXML = readFile(expandPath(arguments.href));
			if(Not IsXML(tmpXML)) throw("The given descriptor file is not a valid XML document.");
			xmlDescriptorDoc = xmlParse(tmpXML);
		
			// append all resources in descriptor file to the catalog
			for(j=1;j lte arrayLen(xmlDescriptorDoc.xmlRoot.xmlChildren);j=j+1) {
				
				aResources = xmlDescriptorDoc.xmlRoot.xmlChildren[j].xmlChildren;
				resourceTypeGroup = xmlDescriptorDoc.xmlRoot.xmlChildren[j].xmlName;  // plural
				resourceType = left(resourceTypeGroup, len(resourceTypeGroup)-1); // singular

				// create node for resource type if doesnt exist
				if(Not StructKeyExists(xmlCatalogDoc.xmlRoot, resourceTypeGroup)) {
					ArrayAppend(xmlCatalogDoc.xmlRoot.xmlChildren, xmlElemNew(xmlCatalogDoc, resourceTypeGroup));	
				}
				
				for(i=1;i lte ArrayLen(aResources);i=i+1) {
					// check if this resource exists already in this catalog
					aCheckRes = xmlSearch(xmlCatalogDoc,"//#resourceType#[@id='#aResources[i].xmlAttributes.id#']");
					if(arrayLen(aCheckRes) eq 0) {
						// copy resource node from descriptor to catalog
						newNode = xmlElemNew(xmlCatalogDoc, resourceType);
						oldNode = aResources[i];
						copyNode(xmlCatalogDoc, newNode, oldNode);
						ArrayAppend(xmlCatalogDoc.xmlRoot[resourceTypeGroup].xmlChildren, newNode);
					}
				}
			}
			
			// save catalog
			writeFile(expandPath(tmpNode.xmlAttributes.href), toString(xmlCatalogDoc));
		</cfscript>
	</cffunction>

	<cffunction name="getCatalogResource" access="public" returntype="any">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">
		<cfargument name="resourceID" type="string" required="true" hint="ID of the resource">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource. module, skin or page">
	
		<cfscript>
			var xmlDoc = this.xmlDoc;
			var xmlNode = 0;
			
			tmpNode = xmlDoc.xmlRoot.registeredCatalogs.xmlChildren[arguments.index];
			
			// read catalog
			tmpXML = readFile(expandPath(tmpNode.xmlAttributes.href));
			if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
			xmlCatalogDoc = xmlParse(tmpXML);
			
			aResources = xmlSearch(xmlCatalogDoc,"//" & arguments.resourceType);
			
			for(i=1;i lte ArrayLen(aResources);i=i+1) {
				if(aResources[i].xmlAttributes.id eq arguments.resourceID) {
					xmlNode = aResources[i];
					break;
				}
			}
		</cfscript>
	
		<cfreturn xmlNode>
	</cffunction>

	<cffunction name="getCatalogModules" access="public" returntype="query">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">

		<cfscript>
			var qry = QueryNew("id,name,access,description");
			var qryCatalogs = this.getCatalogs();
			
			// read catalog
			tmpXML = readFile(expandPath(qryCatalogs.href[arguments.index]));
			if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
			xmlCatalogDoc = xmlParse(tmpXML);
			
			// get modules
			aModules = xmlSearch(xmlCatalogDoc,"//module");
			for(i=1;i lte ArrayLen(aModules);i=i+1) {
				QueryAddRow(qry);
				QuerySetCell(qry, "id", aModules[i].xmlAttributes.id);
				QuerySetCell(qry, "name", aModules[i].xmlAttributes.name);
				QuerySetCell(qry, "access", aModules[i].xmlAttributes.access);
				if(StructKeyExists(aModules[i],"description")) {
					QuerySetCell(qry, "description", aModules[i].description.xmlText);
				}
			}
		</cfscript>
		
		<cfreturn qry>
	</cffunction>

	<cffunction name="getCatalogSkins" access="public" returntype="query">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">

		<cfscript>
			var qry = QueryNew("id,href,description");
			var qryCatalogs = this.getCatalogs();
			
			// read catalog
			tmpXML = readFile(expandPath(qryCatalogs.href[arguments.index]));
			if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
			xmlCatalogDoc = xmlParse(tmpXML);
			
			// get skins
			aSkins = xmlSearch(xmlCatalogDoc,"//skin");
			for(i=1;i lte ArrayLen(aSkins);i=i+1) {
				QueryAddRow(qry);
				QuerySetCell(qry, "id", aSkins[i].xmlAttributes.id);
				QuerySetCell(qry, "href", aSkins[i].xmlAttributes.href);
				QuerySetCell(qry, "description", aSkins[i].xmlText);
			}
		</cfscript>

		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getCatalogPages" access="public" returntype="query">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">
		<cfscript>
			var qry = QueryNew("id,href,name,description,createdOn,title,accountName");
			var qryCatalogs = this.getCatalogs();
			
			// read catalog
			tmpXML = readFile(expandPath(qryCatalogs.href[arguments.index]));
			if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
			xmlCatalogDoc = xmlParse(tmpXML);
			
			// get pages
			aPages = xmlSearch(xmlCatalogDoc,"//page");
			for(i=1;i lte ArrayLen(aPages);i=i+1) {
				QueryAddRow(qry);
				QuerySetCell(qry, "id", aPages[i].xmlAttributes.id);
				QuerySetCell(qry, "href", aPages[i].xmlAttributes.href);
				QuerySetCell(qry, "name", aPages[i].xmlAttributes.name);
				QuerySetCell(qry, "description", aPages[i].xmlText);
				if(StructKeyExists(aPages[i].xmlAttributes, "createdOn"))
					QuerySetCell(qry, "createdOn", aPages[i].xmlAttributes.createdOn);
				if(StructKeyExists(aPages[i].xmlAttributes, "title"))
					QuerySetCell(qry, "title", aPages[i].xmlAttributes.title);
				else
					QuerySetCell(qry, "title", aPages[i].xmlAttributes.name);
				QuerySetCell(qry, "accountName", ListGetAt(aPages[i].xmlAttributes.href, 2, "/"));
			}
		</cfscript>
		<cfreturn qry>
	</cffunction>

	<cffunction name="publishPage" access="public">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">
		<cfargument name="href" type="string" required="true" hint="Path of the page to publish">
		<cfargument name="description" type="string" required="true" hint="Page description">

		<cfscript>
			var xmlDoc = this.xmlDoc;
			var xmlNode = 0;
			
			tmpNode = xmlDoc.xmlRoot.registeredCatalogs.xmlChildren[arguments.index];
			
			// read catalog
			tmpXML = readFile(expandPath(tmpNode.xmlAttributes.href));
			if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
			xmlCatalogDoc = xmlParse(tmpXML);

			// check that page is not already in this catalog
			aCheck = xmlSearch(xmlCatalogDoc,"//page[@href='#arguments.href#']");

			if(ArrayLen(aCheck) eq 0) { 
				// get info on current page
				tmpXML = readFile(ExpandPath(arguments.href));
				if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
				xmlPageDoc = xmlParse(tmpXML);
				
				if(structKeyExists(xmlPageDoc.xmlRoot,"title"))
					tmpTitle = xmlPageDoc.xmlRoot.title.xmlText;
				else
					tmpTitle = arguments.href;

				// append new page name to site definition
				if(Not StructKeyExists(xmlCatalogDoc.xmlroot, "pages"))
					ArrayAppend(xmlCatalogDoc.xmlroot.xmlChildren, xmlElemNew(xmlCatalogDoc,"pages"));
				
				ArrayAppend(xmlCatalogDoc.xmlroot.pages.xmlChildren, xmlElemNew(xmlCatalogDoc,"page"));
				newNode = xmlCatalogDoc.xmlroot.pages.xmlChildren[ArrayLen(xmlCatalogDoc.xmlroot.pages.xmlChildren)];
				newNode.xmlAttributes["name"] = GetFileFromPath(arguments.href);
				newNode.xmlAttributes["href"] = arguments.href;
				newNode.xmlAttributes["title"] = tmpTitle;
				newNode.xmlAttributes["createdOn"] = now();
				newNode.xmlAttributes["id"] = createUUID();
				newNode.xmlText = arguments.description;

				// save catalog
				writeFile(expandPath(tmpNode.xmlAttributes.href), toString(xmlCatalogDoc));

			} else {
				// page already published to this catalog		
				throw("The given page has already been published to this catalog.");	
			}
		</cfscript>
	</cffunction>

	<cffunction name="getUpdateSites" access="public" returntype="query">
		<cfscript>
			var qrySites = QueryNew("url,name");

			if(StructKeyExists(this.xmlDoc.xmlRoot,"updateSites")) {
				aSites = this.xmlDoc.xmlRoot.updateSites.xmlChildren;
				for(i=1;i lte ArrayLen(aSites);i=i+1) {
					QueryAddRow(qrySites);
					if(StructKeyExists(aSites[i].xmlAttributes,"url"))
						QuerySetCell(qrySites,"url",aSites[i].xmlAttributes.url);
					QuerySetCell(qrySites,"name",aSites[i].xmlText);
				}
			}			
		</cfscript>
		<cfreturn qrySites> 
	</cffunction>

	<cffunction name="registerUpdateSite" access="public">
		<cfargument name="url" type="string" required="true" hint="URL of the HomePortals Update Site">
		<cfargument name="name" type="string" required="true" default="">

		<cfscript>
			// append updateSites section if doesn't exist
			if(Not StructKeyExists(this.xmlDoc.xmlRoot, "updateSites"))
				ArrayAppend(this.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(this.xmlDoc,"updateSites"));
			else {
				// check that this same site is not already registered
				if(StructKeyExists(this.xmlDoc.xmlRoot,"updateSites")) {
					for(i=1;i lte ArrayLen(this.xmlDoc.xmlRoot.updateSites.xmlChildren);i=i+1) {
						tmpNode = this.xmlDoc.xmlRoot.updateSites.xmlChildren[i];
						if(tmpNode.xmlAttributes.url eq arguments.url) {
							throw("This Update Site is already registered.");
						}
					}
				}
			}
			
			// append node for new site
			ArrayAppend(this.xmlDoc.xmlRoot.updateSites.xmlChildren, xmlElemNew(this.xmlDoc,"site"));
			newNode = this.xmlDoc.xmlRoot.updateSites.xmlChildren[ArrayLen(this.xmlDoc.xmlRoot.updateSites.xmlChildren)];
			newNode.xmlAttributes["url"] = arguments.url;
			newNode.xmlAttributes["name"] = arguments.name;
			
			// save library
			saveLibrary();
		</cfscript>

	</cffunction>

	<cffunction name="removeUpdateSite" access="public">
		<cfargument name="index" type="string" required="true" hint="Position of the update site in the list of registered sites">

		<cfscript>
			var xmlDoc = this.xmlDoc;
			
			// delete the site from the library
			tmpNode = xmlDoc.xmlRoot.updateSites;
			if(arguments.index lte ArrayLen(tmpNode.xmlChildren)) {
				// remove catalog from library
				ArrayDeleteAt(tmpNode.xmlChildren, arguments.index);

				// save library
				saveLibrary();
			}
		</cfscript>
	</cffunction>

	<cffunction name="getUpdateSitePackages" access="public" returntype="query">
		<cfargument name="index" type="string" required="true" hint="Position of the update site in the list of registered sites">
		<cfscript>
			var xmlDoc = this.xmlDoc;
			var qry = QueryNew("href,name,description,version,dateAdded");;
			
			// get list of resources on update site
			tmpNode = xmlDoc.xmlRoot.updateSites;
			if(arguments.index lte ArrayLen(tmpNode.xmlChildren)) {
				tmpWSDL = tmpNode.xmlChildren[arguments.index].xmlAttributes.url;
				wsUpdate = CreateObject("webservice",tmpWSDL);
				qry = wsUpdate.getPackagesList(); 
			}			
		</cfscript>
		<cfreturn qry> 
	</cffunction>

	<cffunction name="downloadPackage" access="public">
		<cfargument name="index" type="string" required="true" hint="Position of the update site in the list of registered sites">
		<cfargument name="href" type="string" required="true" hint="filename of the resource package to download">
		<cfargument name="catalogIndex" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">
		<cfargument name="modulesRoot" type="string" required="true" hint="Root folder for modules" default="/home/modules/">

		<cfscript>
			var xmlDoc = this.xmlDoc;
			var tmpWSDL = "";
			var objZip = CreateObject("component","Zip");
			//var tempDir = arguments.modulesRoot & "/library/Temp/";
			var tempDir = "";
			var backupCreated = false;
			
			// download resource package
			tmpNode = xmlDoc.xmlRoot.updateSites;
			if(arguments.index lte ArrayLen(tmpNode.xmlChildren)) {
				tmpWSDL = tmpNode.xmlChildren[arguments.index].xmlAttributes.url;
				tmpURL =  ReplaceNoCase(tmpWSDL,"wsdl","") & "method=downloadPackage&PackageHREF=" & arguments.href;
			}
		</cfscript>
		
		<cfif tmpURL neq "">
			<!--- location of the temp directory --->
			<cfset tempDir = arguments.modulesRoot & "/" & createUUID() & "/">
			<cfset tgt = ExpandPath(tempDir)>
			<!--- full path and name of where to put the downloaded file --->
			<cfset tgtFilePath = ExpandPath(tempDir & arguments.href)>
			<!--- name of the package to download (a package is a directory) --->
			<cfset pkgName = ReplaceNoCase(arguments.href,".zip","")>
			<!--- full path of the package directory --->
			<cfset pkgDir = ExpandPath(arguments.modulesRoot & pkgName)>
			<!--- location of the backups directory --->
			<cfset bkpDir = arguments.modulesRoot & "/library/archive/">
			<!--- name and final location of the backup file for the package  --->
			<cfset pkgBkpFilePath = ExpandPath(bkpDir & arguments.href) & ".bak">
			<!--- name and temporary location of the backup file for the package  --->
			<cfset pkgTmpBkpFilePath = ExpandPath(tempDir & arguments.href) & ".bak">
			<!--- default package descriptor file --->
			<cfset pkgDescFile = arguments.modulesRoot & pkgName & "/package.xml">
			
			<!--- check that temp directory exists --->
			<cfif Not DirectoryExists(tgt)>
				<cfdirectory action="create" directory="#tgt#">
			</cfif>
			
			<!--- download ---->
			<cfhttp url="#tmpURL#" 
					method="get" 
					timeout="30" 
					file="#arguments.href#"
					path="#tgt#" />

			<!--- if a package with this same name exists, then make a backup of it --->
			<cfif DirectoryExists(pkgDir)>
				<cftry>
					<cfinvoke component="#objZip#" 
							  method="AddFiles" 
							  returnvariable="rtn">
						<cfinvokeargument name="ZipFilePath" value="#pkgTmpBkpFilePath#">
						<cfinvokeargument name="directory" value="#pkgDir#">
						<cfinvokeargument name="recurse" value="true">
					</cfinvoke>					
					<cfcatch type="any">
						<cfthrow message="An error ocurred while creating a backup of an existing package">
					</cfcatch>
				</cftry>
				<cfset backupCreated = true>
			<cfelse>
				<cfdirectory action="create" directory="#pkgDir#">
			</cfif>

		
			<!--- Extract File --->
			<cftry>
				<cfinvoke component="#objZip#" 
						  method="Extract" 
						  returnvariable="rtnZip">
					<cfinvokeargument name="ZipFilePath" value="#tgtFilePath#">
					<cfinvokeargument name="extractPath" value="#pkgDir#">
					<cfinvokeargument name="overwriteFiles" value="yes">
				</cfinvoke>
				<cfcatch type="any">
					<cfthrow message="An error ocurred while extracting the files from the downloaded package. Package may have been corrupted during download.">
				</cfcatch>
			</cftry>

			<!--- check that backups directory exists --->
			<cfif Not DirectoryExists(ExpandPath(bkpDir))>
				<cfdirectory action="create" directory="#ExpandPath(bkpDir)#">
			</cfif>

			<!--- move backup to backups directory --->
			<cffile action="move" source="#pkgTmpBkpFilePath#" destination="#pkgBkpFilePath#">		
			
			<!--- delete temp directory --->
			<cfif DirectoryExists(ExpandPath(tempDir))>
				<cfdirectory action="delete" directory="#ExpandPath(tempDir)#" recurse="yes">
			</cfif>
					
			<!--- check if there is a package descriptor to register --->
			<cfif FileExists(ExpandPath(pkgDescFile))>
				<!--- descriptor exists, so register --->
				<cfset this.importCatalogResourcePackage(arguments.catalogIndex, pkgDescFile)>
			</cfif>
		</cfif>
		
		<cfreturn> 
	</cffunction>

	<!--- /*************************** Private Methods **********************************/ --->

	<!--- ************************************ --->
	<!--- * init   				 	       * --->
	<!--- ************************************ --->
	<cffunction name="init" access="private" hint="Initializes the Library component. Loads library.">
		<cfargument name="homeRoot" type="string" required="true" default="/Home/">
		<cfscript>
			var tmpXML = "";

			this.xmlDoc = 0;
			this.configFilePath = ExpandPath(arguments.homeRoot & "Config/library-config.xml");
		
			// check if updateSite configuration file exists, if not create it
			if(Not FileExists(this.configFilePath)) {
				this.xmlDoc	= xmlNew();
				this.xmlDoc.xmlRoot = xmlElemNew(this.xmlDoc,"homePortalsLibrary");
				saveLibrary();
			} else {
				tmpXML = readFile(this.configFilePath);
				if(Not IsXML(tmpXML)) throw("The given Library Config file is not a valid XML document.");
				this.xmlDoc = xmlParse(tmpXML);
			}
		</cfscript>
	</cffunction>


	<!--- ************************************ --->
	<!--- * saveLibrary  			 	       * --->
	<!--- ************************************ --->
	<cffunction name="saveLibrary" access="private">
		<cfset writeFile(this.configFilePath, toString(this.xmlDoc))>
	</cffunction>

	<!--- ************************************ --->
	<!--- * dump						 	 * --->
	<!--- ************************************ --->
	<cffunction name="dump" access="private">
		<cfargument name="var" type="any">
		<cfdump var="#arguments.var#">
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
	<!--- * copyNode  					   * --->
	<!--- ************************************ --->
	<cffunction name="copyNode" access="private" output="false" returntype="void" hint="Copies a node from one document into a second document">
		<cfargument name="xmlDoc" required="true">
		<cfargument name="newNode" required="true">
		<cfargument name="oldNode" required="true">

		<cfset var key = "" />
		<cfset var index = "" />
		<cfset var i = "" />

		<!----
			CopyNode function based on code found at 
			http://www.spike.org.uk/blog/index.cfm?do=blog.cat&catid=8245E3A4-D565-E33F-39BC6E864D6B5DAA
			spike-fu:code poetry.
		----->

		<cfscript>
			if(len(trim(oldNode.xmlComment)))
				newNode.xmlComment = trim(oldNode.xmlComment);
			
			if(len(trim(oldNode.xmlCData)))
				newNode.xmlCData = trim(oldNode.xmlCData);
				
			newNode.xmlAttributes = oldNode.xmlAttributes;
			newNode.xmlText = trim(oldNode.xmlText);
			
			for(i=1;i lte arrayLen(oldNode.xmlChildren);i=i+1) {
				newNode.xmlChildren[i] = xmlElemNew(xmlDoc,oldNode.xmlChildren[i].xmlName);
				copyNode(xmlDoc,newNode.xmlChildren[i],oldNode.xmlChildren[i]);
			}
		</cfscript>
	</cffunction>

</cfcomponent>