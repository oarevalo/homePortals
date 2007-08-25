<cfcomponent>

	<cfscript>
		variables.homePortalsConfigBean = 0;
		variables.lstResourceTypes = "module,skin,pageTemplate,page,content,feed";
		variables.lstResourceTypesExtensions = "cfc,css,xml,xml,html,rss";
		variables.lstAccessTypes = "general,owner,friend";	
	</cfscript>

	<cffunction name="init" returntype="resourceLibrary" access="public">
		<cfargument name="configBean" type="homePortalsConfigBean" required="true" hint="ConfigBean for the HomePortals application">
		<cfset variables.homePortalsConfigBean = arguments.configBean>
		<cfreturn this>
	</cffunction>

	<cffunction name="getResourceTypes" access="public" returntype="array" hint="returns an array with the allowed resource types">
		<cfreturn listToArray(variables.lstResourceTypes)>
	</cffunction>


	<cffunction name="saveResource">
		<cfargument name="originalID" type="string" required="true">
		<cfargument name="ID" type="string" required="true">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="folder" type="string" required="true">
		<cfargument name="href" type="string" required="true">
		<cfargument name="accessType" type="string" required="true">
		<cfargument name="owner" type="string" required="true">
		<cfargument name="description" type="string" required="true">
		<cfargument name="body" type="string" required="true">
		<cfargument name="hasLocalContent" type="boolean" required="false" default="false">
		
		<cfscript>
			var resourcesRoot = variables.homePortalsConfigBean.getResourceLibraryPath();
			var ext = "";
			var href = "";
			var packageDir = "";
			
			if(arguments.id eq "") throw("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(arguments.folder eq "") throw("No folder has been specified","homePortals.resourceLibrary.validation");
			if(not listFindNoCase(variables.lstResourceTypes, arguments.resourceType)) throw("The resource type is invalid","homePortals.resourceLibrary.invalidResourceType")
			if(not listFindNoCase(variables.lstAccessTypes, arguments.accessType)) throw("The access type is invalid","homePortals.resourceLibrary.invalidAccessType")

			// for resources that use local content, set the proper href for the given path based on the ID
			if(arguments.href eq "" and arguments.hasLocalContent) {
				href = arguments.resourcesRoot & "/" & arguments.resourceType & "s/" & arguments.folder & "/" & arguments.id & "." & getResourceTypeExtension(resourceType);					
			}
			
			// check for file descriptor, if doesnt exist, then create one
			packageDir = arguments.resourcesRoot & "/" & arguments.resourceType & "s/" & arguments.folder;
			if(fileExists(expandPath(packageDir & "/info.xml"))) {
				xmlDoc = xmlParse(expandPath(packageDir & "/info.xml"));
				
				if(not structKeyExists(xmlDoc.xmlRoot, resourceType & "s")) 
					arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc, resourceType & "s"));
				
			} else {
				// create file descriptor
				xmlDoc = xmlNew();
				xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "catalog");
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc, resourceType & "s"));
			}
			
			// update the file descriptor
			if(originalID eq "") {
				// this is a new resource
				xmlNode = xmlElemNew(xmlDoc, resourceType);
				xmlNode.xmlAttributes["id"] = id;
				xmlNode.xmlAttributes["href"] = href;
				xmlNode.xmlAttributes["owner"] = owner;
				xmlNode.xmlAttributes["access"] = accessType;
				xmlNode.xmlText = description;
				arrayAppend(xmlDoc.xmlRoot[resourceType & "s"].xmlChildren, xmlNode);
				
			} else {
				// this is an existing resource
				bFound = false;
				for(i=1;i lte arrayLen(xmlDoc.xmlRoot[resourceType & "s"].xmlChildren);i=i+1) {
					xmlNode = xmlDoc.xmlRoot[resourceType & "s"].xmlChildren[i];
					if(xmlNode.xmlAttributes.id eq originalID) {
						xmlNode.xmlAttributes["id"] = id;
						xmlNode.xmlAttributes["href"] = href;
						xmlNode.xmlAttributes["owner"] = owner;
						xmlNode.xmlAttributes["access"] = accessType;
						xmlNode.xmlText = description;
						bFound = true;
						break;
					}
				}
				
				// if resource not found in descriptor, then add it
				if(Not bFound) {
					xmlNode = xmlElemNew(xmlDoc, resourceType);
					xmlNode.xmlAttributes["id"] = id;
					xmlNode.xmlAttributes["href"] = href;
					xmlNode.xmlAttributes["owner"] = owner;
					xmlNode.xmlAttributes["access "] = accessType;
					xmlNode.xmlText = description;
					arrayAppend(xmlDoc.xmlRoot[resourceType & "s"].xmlChildren, xmlNode);
				}
			}
			
			// save resource descriptor file
			saveFile(expandPath(packageDir & "/info.xml"), toString(xmlDoc));
			
			// if this points to a local resource, then create or update the file,
			// otherwise remove the file (if exists)
			if(href neq "") {
				if(left(href,4) neq "http") {
					saveFile(expandPath(href), body);
				} else {
					if(fileExists(expandPath(href)))
						removeFile(expandPath(href));
				}
			}

		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- deleteResource	                       ---->
	<!------------------------------------------------->
	<cffunction name="deleteResource" access="public" returntype="void">
		<cfargument name="ID" type="string" required="true">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="folder" type="string" required="true">

		<cfscript>
			var packageDir = "";
			var resourcesRoot = variables.homePortalsConfigBean.getResourceLibraryPath();
			var resHref = "";
			
			if(arguments.id eq "") throw("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(arguments.folder eq "") throw("No folder has been specified","homePortals.resourceLibrary.validation");
			if(not listFindNoCase(variables.lstResourceTypes, arguments.resourceType)) throw("The resource type is invalid","homePortals.resourceLibrary.invalidResourceType")

			// remove from descriptor (if exists)
			packageDir = resourcesRoot & "/" & arguments.resourceType & "s" & "/" & arguments.folder;
			if(fileExists(expandPath(packageDir & "/info.xml"))) {
				xmlDoc = xmlParse(expandPath(packageDir & "/info.xml"));

				for(i=1;i lte arrayLen(xmlDoc.xmlRoot[resourceType & "s"].xmlChildren);i=i+1) {
					xmlNode = xmlDoc.xmlRoot[arguments.resourceType & "s"].xmlChildren[i];
					if(xmlNode.xmlAttributes.id eq id) {
						if(structKeyExists(xmlNode.xmlAttributes, "href"))
							resHref = xmlNode.xmlAttributes.href;
					
						// remove node from document
						arrayDeleteAt(xmlDoc.xmlRoot[arguments.resourceType & "s"].xmlChildren, i);
						
						// save modified resource descriptor file
						saveFile(expandPath(packageDir & "/info.xml"), toString(xmlDoc));						
									
						break;
					}
				}					
			} else {
			
				ext = getResourceTypeExtension(arguments.resourceType);
				resHref = resourcesRoot & "/" & arguments.resourceType & "s/" & arguments.folder & "/" & arguments.folder & "." & ext;

			}				
			
			// remove resource file
			if(resHref neq "" and left(resHref,4) neq "http" and fileExists(expandPath(resHref))) {
				removeFile(expandPath(resHref));			
			}
			
		</cfscript>	
	</cffunction>	


	<!---------------------------------------->
	<!--- getResourcePackagesList		   --->
	<!---------------------------------------->	
	<cffunction name="getResourcePackagesList" returntype="query" access="public"
				hint="returns a query with the names of all resource packages">

		<cfset var qry = QueryNew("type,name")>
		<cfset var qryTemp = QueryNew("")>
		<cfset var tmpDir = "">
		<cfset var resourcesRoot = variables.homePortalsConfigBean.getResourceLibraryPath()>
		
		<cfloop list="#variables.lstResourceTypes#" index="res">
			<cfset tmpDir = ExpandPath("#resourcesRoot#/#res#s")>
			<cfif directoryExists(tmpDir)>
				<cfdirectory action="list" directory="#tmpDir#" name="qryTemp">
				<cfif qry.recordCount gt 0>
					<cfquery name="qry" dbtype="query">
						SELECT '#res#' AS type, name
							FROM qryTemp
							WHERE type = 'Dir'
						UNION
						SELECT type, name
							FROM qry
							ORDER BY name
					</cfquery>
				<cfelse>
					<cfquery name="qry" dbtype="query">
						SELECT '#res#' AS type, name
							FROM qryTemp
							WHERE type = 'Dir'
							ORDER BY name
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
		<cfreturn qry>
	</cffunction>

	<!---------------------------------------->
	<!--- getResourceTypeExtension		   --->
	<!---------------------------------------->
	<cffunction name="getResourceTypeExtension" access="public" output="false" returntype="string" hint="Returns the file extension associated with the given resource type">
		<cfargument name="resourceType" type="string" required="true">
		<cfset var res = "">
		<cfset var index = 1>
		
		<cfloop list="#variables.lstResourceTypes#" index="res">
			<cfif res eq arguments.resourceType>
				<cfreturn listGetAt(variables.lstResourceTypesExtensions, index)>
			</cfif>
			<cfset index = index + 1>
		</cfloop>
		
		<cfthrow message="Invalid resource type" type="homeportals.resourceLibrary.invalidResourceType">
	</cffunction>
	
	

	<!---------------------------------------->
	<!--- saveFile                         --->
	<!---------------------------------------->
	<cffunction name="saveFile" access="private" hint="saves a file">
		<cfargument name="path" type="string" hint="Path to the file">
		<cfargument name="content" type="string" hint="file content">

		<!--- store page --->
		<cffile action="write" file="#arguments.path#" output="#arguments.content#">
	</cffunction>
	
	<!---------------------------------------->
	<!--- removeFile                       --->
	<!---------------------------------------->
	<cffunction name="removeFile" access="private" hint="deletes a file">
		<cfargument name="path" type="string" hint="full path to file">

		<cffile action="delete" file="#arguments.path#">
	</cffunction>	

	<cffunction name="dir" access="private" returnttye="query">
		<cfargument name="path" type="string" required="true">
		<cfargument name="recurse" type="boolean" required="false" default="false">
		<cfset var qry = QueryNew("")>

		<cfdirectory action="list" name="qry" directory="#ExpandPath(arguments.path)#" recurse="#arguments.recurse#">
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qry
				ORDER BY Type, Name
		</cfquery>		
		<cfreturn qry>	
	</cffunction>

	<cffunction name="createDir" access="private" returnttye="void">
		<cfargument name="path" type="string" required="true">
		<cfdirectory action="create" directory="#ExpandPath(arguments.path)#">
	</cffunction>
	
	<cffunction name="deleteDir" access="private" returnttye="void">
		<cfargument name="path" type="string" required="true">
		<cfdirectory action="delete" directory="#ExpandPath(arguments.path)#" recurse="true">
	</cffunction>
				
	
</cfcomponent>