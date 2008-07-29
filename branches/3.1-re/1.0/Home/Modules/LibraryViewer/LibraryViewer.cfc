<cfcomponent displayname="ModuleViewer">

	<!--- call constructor --->
	<cfset init()>

	<cffunction name="getResource" access="public">
		<cfargument name="instanceName" type="String" required="true">
		<cfargument name="resourcePath" type="any" required="true">
		
		<cfset var tmpIndex = 1>
		<cfset var tmpType = "">
		<cfset var tmpID = "">

		<cfif ListLen(arguments.resourcePath,"/") gte 3>
			<cfset tmpIndex = ListFirst(arguments.resourcePath,"/")>
			<cfset tmpID = ListLast(arguments.resourcePath,"/")>
			<cfset tmpType = ListGetAt(arguments.resourcePath,2,"/")>
	
			<cfset xmlResNode = getCatalogResource(tmpIndex, tmpID, left(tmpType, len(tmpType)-1))>
	
			<cfinclude template="views/#tmpType#View.cfm">
		<cfelse>
			<p>Select a resource from the catalog to view information about it.</p>
		</cfif>
	</cffunction>

	<cffunction name="getCatalogResources" access="public">
		<cfargument name="instanceName" type="String" required="true">
		<cfargument name="catalogIndex" type="any" required="false" default="1">
	
		<cfset catalogCount = getCatalogCount()>
		<cfif Not IsNumeric(arguments.catalogIndex) or arguments.catalogIndex gt catalogCount>
			<cfset arguments.catalogIndex = 1>
		</cfif>
		<cfset stCatalog = getCatalog(arguments.catalogIndex)>
		<cfset lstResources = stCatalog.resourceList>
		
		<cfinclude template="views/resourceSelect.cfm">
	</cffunction>

	<cffunction name="init" hint="Reads the module config file">

		<cfset currentPath = getcurrenttemplatepath()>
		<cfset currentDir = getDirectoryFromPath(currentPath)>
		<cfset configFile = currentDir & "config.xml">
		
		<cfif FileExists(configFile)>
			<cffile action="read" file="#configFile#" variable="txtConfig">
		<cfelse>
			<cfthrow message="The config file for the ModuleViewer module does not exist. [#configFile#]">		
		</cfif>
		
		<cfif IsXML(txtConfig)>
			<cfset xmlConfigDoc = xmlParse(txtConfig)>
		<cfelse>
			<cfthrow message="The config file for the ModuleViewer module is corrupted.">
		</cfif>
		
		<cfif Not StructKeyExists(xmlConfigDoc.xmlRoot, "catalogs")>
			<cfset arrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, xmlElemNew(xmlConfigDoc,"catalogs"))>
		</cfif>
		
		<cfset this.xmlConfigDoc = xmlConfigDoc>
	</cffunction>
	
	<cffunction name="getCatalogCount" returntype="numeric" hint="Returns the number of catalogs registered for viewing">
		<cfreturn ArrayLen(this.xmlConfigDoc.xmlRoot.catalogs.xmlChildren)>
	</cffunction>
	
	<cffunction name="getCatalog" returntype="struct" hint="Reads a catalog and returns its contents">
		<cfargument name="catalogIndex" type="numeric" required="true" hint="The index of the catalog on the config file. The index is used as a security measure to ensure that only the content of published catalogs can be queried.">
		
		<cfset var stCatalog = StructNew()>
		<cfset var catalogFile = getCatalogHREF(arguments.catalogIndex)>

		<!---- parse catalog xml --->
		<cfscript>
			xmlDoc = readCatalog(arguments.catalogIndex);	
			
			stCatalog.href = catalogFile;
			
			// get catalog name if defined, else use the file name
			if(StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "name"))
				stCatalog.name = xmlDoc.xmlRoot.xmlAttributes.name;
			else
				stCatalog.name = Replace(GetFileFromPath(catalogFile),".xml","");
			
			// if catalog has a description, use it
			if(StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "description"))
				stCatalog.description = xmlDoc.xmlRoot.xmlAttributes.description;	
			else
				stCatalog.description  = "";

			// get resources
			stCatalog.resources = structNew();
			stCatalog.modules = getCatalogModules(xmlDoc);
			stCatalog.skins = getCatalogSkins(xmlDoc);
			stCatalog.pages = getCatalogPages(xmlDoc); 
			
			lstResources = "";
			if(stCatalog.modules.recordCount gt 0) lstResources = ListAppend(lstResources, "Modules");
			if(stCatalog.skins.recordCount gt 0) lstResources = ListAppend(lstResources, "Skins");
			if(stCatalog.pages.recordCount gt 0) lstResources = ListAppend(lstResources, "Pages");
			stCatalog.resourceList = lstResources;
		</cfscript>
		
		<cfreturn stCatalog>
	</cffunction>

	<cffunction name="getCatalogs" access="public" returntype="query">
		<cfscript>
			var qryCatalogs = QueryNew("index,href,label");
			
			if(StructKeyExists(this.xmlConfigDoc.xmlRoot,"catalogs")) {
				aCatalogs = this.xmlConfigDoc.xmlRoot.catalogs.xmlChildren;
				for(i=1;i lte ArrayLen(aCatalogs);i=i+1) {
					QueryAddRow(qryCatalogs);
					QuerySetCell(qryCatalogs,"href",aCatalogs[i].xmlText);
					QuerySetCell(qryCatalogs,"label",aCatalogs[i].xmlAttributes.label);
					QuerySetCell(qryCatalogs,"index",i);
				}
			}
		</cfscript>

		<cfreturn qryCatalogs>
	</cffunction>

	<cffunction name="getCatalogModules" access="public" returntype="query">
		<cfargument name="xmlCatalogDoc" type="XML" required="true" hint="Catalog xml document">

		<cfscript>
			var qry = QueryNew("id,name,access,description");
			
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
		<cfargument name="xmlCatalogDoc" type="XML" required="true" hint="Catalog xml document">

		<cfscript>
			var qry = QueryNew("id,href,description");
			
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
		<cfargument name="xmlCatalogDoc" type="XML" required="true" hint="Catalog xml document">
		<cfscript>
			var qry = QueryNew("id,href,name,description,createdOn,title,accountName");
			
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

	<cffunction name="getCatalogResource" access="public" returntype="any">
		<cfargument name="index" type="string" required="true" hint="Position of the catalog in the list of registered catalogs">
		<cfargument name="resourceID" type="string" required="true" hint="ID of the resource">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource. module, skin or page">
	
		<cfscript>
			var xmlNode = 0;
			var catalogHREF = getCatalogHREF(arguments.index);
			
			// read catalog
			tmpXML = readFile(expandPath(catalogHREF));
			if(Not IsXML(tmpXML)) throw("The given catalog file is not a valid XML document.");
			xmlCatalogDoc = xmlParse(tmpXML);
			
			aResources = xmlSearch(xmlCatalogDoc,"//" & lcase(arguments.resourceType));
			
			for(i=1;i lte ArrayLen(aResources);i=i+1) {
				if(aResources[i].xmlAttributes.id eq arguments.resourceID) {
					xmlNode = aResources[i];
					break;
				}
			}
		</cfscript>
		<cfreturn xmlNode>
	</cffunction>
	
	<cffunction name="getCatalogHREF" returntype="string" hint="Returns the href of a catalog">
		<cfargument name="catalogIndex" type="numeric" required="true" hint="The index of the catalog on the config file. The index is used as a security measure to ensure that only the content of published catalogs can be queried.">
		<cfif arguments.catalogIndex gt ArrayLen(this.xmlConfigDoc.xmlRoot.catalogs.xmlChildren)>
			<cfthrow message="You have requested an invalid catalog index">
		</cfif>
		<cfreturn this.xmlConfigDoc.xmlRoot.catalogs.xmlChildren[arguments.catalogIndex].xmlText>
	</cffunction>
			
	<cffunction name="readCatalog" access="private" returntype="xml">
		<cfargument name="catalogIndex" type="numeric" required="true" hint="The index of the catalog on the config file. The index is used as a security measure to ensure that only the content of published catalogs can be queried.">

		<cfset var xmlDoc = 0>

		<!---- read catalog file --->
		<cfset catalogFile = getCatalogHREF(arguments.catalogIndex)>

		<cfif FileExists(ExpandPath(catalogFile))>
			<cffile action="read" file="#expandPath(catalogFile)#" variable="txtCatalog">
		<cfelse>
			<cfthrow message="The requested catalog does not exist.">		
		</cfif>

		<cfif IsXML(txtCatalog)>
			<cfset xmlDoc = xmlParse(txtCatalog)>
		<cfelse>
			<cfthrow message="The requested catalog is corrupted.">
		</cfif>
		
		<cfreturn xmlDoc>	
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
	
</cfcomponent>