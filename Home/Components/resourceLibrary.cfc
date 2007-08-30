<cfcomponent>

	<cfscript>
		variables.lstResourceTypes = "module,skin,pageTemplate,page,content,feed";
		variables.lstResourceTypesExtensions = "cfc,css,xml,xml,html,rss";
		variables.lstAccessTypes = "general,owner,friend";	
		variables.resourceDescriptorFile = "info.xml";
		variables.resourcesRoot = "";
		variables.stTimers = structNew();
	</cfscript>

	<!------------------------------------------------->
	<!--- init				                	   ---->
	<!------------------------------------------------->
	<cffunction name="init" returntype="resourceLibrary" access="public">
		<cfargument name="resourceLibraryPath" type="string" required="true">
		<cfset variables.resourcesRoot = arguments.resourceLibraryPath>
		<cfreturn this>
	</cffunction>

	<!------------------------------------------------->
	<!--- getResourceTypes	                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypes" access="public" returntype="array" hint="returns an array with the allowed resource types">
		<cfreturn listToArray(variables.lstResourceTypes)>
	</cffunction>

	<!------------------------------------------------->
	<!--- getAccessTypes	                	   ---->
	<!------------------------------------------------->
	<cffunction name="getAccessTypes" access="public" returntype="array" hint="returns an array with the allowed access types">
		<cfreturn listToArray(variables.lstAccessTypes)>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResourcesInPackage                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourcesInPackage" access="public" returntype="Array">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfscript>
			var tmpHREF = "";
			var aResources = arrayNew(1);
			var start = getTickCount();
			
			// check if there is a resource descriptor for the package
			tmpHREF = variables.resourcesRoot & "/" & arguments.resourceType & "s/" & arguments.packageName & "/" & variables.resourceDescriptorFile;

			if(fileExists(expandPath(tmpHREF))) {
				// resource descriptor exists, so read all resources on the descriptor
				aResources = getResourcesInDescriptorFile(tmpHREF, arguments.packageName);
			} else {
				// no resource descriptor, so register resources based on package name
				// this will only register ONE resource per package
				oResourceBean = getDefaultResourceInPackage(arguments.resourceType, arguments.packageName);
				if(not isSimpleValue(oResourceBean)) arrayAppend(aResources, oResourceBean);
			}

			variables.stTimers.getResourcesInPackage = getTickCount()-start;
			return aResources;
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- saveResource	                       	   ---->
	<!------------------------------------------------->
	<cffunction name="saveResource">
		<cfargument name="resourceBean" type="resourceBean" required="true" hint="the resource to add or update"> 		
		<cfargument name="resourceBody" type="string" required="false" default="" hint="For resources that have local content, this is the text to save as the body of the resource">
		
		<cfscript>
			var ext = "";
			var href = "";
			var packageDir = "";
			var rb = arguments.resourceBean;
			var resType = rb.getType();
		
			// validate bean			
			if(rb.getID() eq "") throw("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(rb.getPackage() eq "") throw("No package has been specified for the resource","homePortals.resourceLibrary.validation");
			if(not listFindNoCase(variables.lstResourceTypes, resType)) throw("The resource type is invalid or not supported","homePortals.resourceLibrary.invalidResourceType");
			if(not listFindNoCase(variables.lstAccessTypes, rb.getAccessType())) throw("The access type is invalid","homePortals.resourceLibrary.invalidAccessType");

			// setup base directory
			packageDir = resourcesRoot & "/" & resType & "s/" & rb.getPackage();

			// for resources that use local content, set the proper href for the given path based on the ID
			href = rb.getHREF();
			if(href eq "") {
				href = packageDir & "/" & rb.getID() & "." & getResourceTypeExtension(resType);
				rb.setHREF(href); 
			} 
				
			
			// check for file descriptor, if doesnt exist, then create one
			if(fileExists(expandPath(packageDir & "/" & variables.resourceDescriptorFile))) {
				xmlDoc = xmlParse(expandPath(packageDir & "/" & variables.resourceDescriptorFile));
				if(not structKeyExists(xmlDoc.xmlRoot, resType & "s")) 
					arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc, resType & "s"));
				
			} else {
				// create file descriptor
				xmlDoc = xmlNew();
				xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "catalog");
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc, resType & "s"));
			}
			
			// check if we need to update the file descriptor
			bFound = false;
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot[resType & "s"].xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot[resType & "s"].xmlChildren[i];
				if(xmlNode.xmlAttributes.id eq rb.getID()) {
					bFound = true;
					break;
				}
			}
			
			// if resource not found in descriptor, then add it
			if(Not bFound) {
				xmlNode = xmlElemNew(xmlDoc, resType);
				xmlNode.xmlAttributes["id"] = rb.getID();
			}

			// set resource properties			
			xmlNode.xmlAttributes["href"] = href;
			xmlNode.xmlAttributes["name"] = rb.getName();
			xmlNode.xmlAttributes["owner"] = rb.getOwner();
			xmlNode.xmlAttributes["access"] = rb.getAccessType();
			xmlNode.xmlText = rb.getDescription();

			if(Not bFound) {
				arrayAppend(xmlDoc.xmlRoot[resType & "s"].xmlChildren, xmlNode);
			}
			
			// save resource descriptor file
			saveFile(expandPath(packageDir & "/" & variables.resourceDescriptorFile), toString(xmlDoc));
			
			// if this points to a local resource, then create or update the file,
			// otherwise remove the file (if exists)
			if(href neq "") {
				if(left(href,4) neq "http" and arguments.resourceBody neq "") {
					saveFile(expandPath(href), arguments.resourceBody);
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
		<cfargument name="package" type="string" required="true">

		<cfscript>
			var packageDir = "";
			var resHref = "";
			
			if(arguments.id eq "") throw("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(arguments.package eq "") throw("No folder has been specified","homePortals.resourceLibrary.validation");
			if(not listFindNoCase(variables.lstResourceTypes, arguments.resourceType)) throw("The resource type is invalid","homePortals.resourceLibrary.invalidResourceType");

			// remove from descriptor (if exists)
			packageDir = resourcesRoot & "/" & arguments.resourceType & "s" & "/" & arguments.package;
			if(fileExists(expandPath(packageDir & "/" & variables.resourceDescriptorFile))) {
				xmlDoc = xmlParse(expandPath(packageDir & "/" & variables.resourceDescriptorFile));

				for(i=1;i lte arrayLen(xmlDoc.xmlRoot[resourceType & "s"].xmlChildren);i=i+1) {
					xmlNode = xmlDoc.xmlRoot[arguments.resourceType & "s"].xmlChildren[i];
					if(xmlNode.xmlAttributes.id eq id) {
						if(structKeyExists(xmlNode.xmlAttributes, "href"))
							resHref = xmlNode.xmlAttributes.href;
					
						// remove node from document
						arrayDeleteAt(xmlDoc.xmlRoot[arguments.resourceType & "s"].xmlChildren, i);
						
						// save modified resource descriptor file
						saveFile(expandPath(packageDir & "/" & variables.resourceDescriptorFile), toString(xmlDoc));						
									
						break;
					}
				}					
			} else {
			
				ext = getResourceTypeExtension(arguments.resourceType);
				resHref = packageDir & "/" & arguments.package & "." & ext;

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
		
		<cfscript>
			var qry = QueryNew("ResType,Name");
			var tmpDir = "";
			var start = getTickCount();
			var res = "";
			var aItems = arrayNew(1);
			var i = 0;
			var j = 0;
			var aResTypes = listToArray(variables.lstResourceTypes);
			var pathSeparator =  createObject("java","java.lang.System").getProperty("file.separator");
			
			for(i=1;i lte arrayLen(aResTypes);i=i+1) {
				res = aResTypes[i];
				tmpDir = ExpandPath("#variables.resourcesRoot#/#res#s");
				
				if(directoryExists(tmpDir)) {
					aItems = createObject("java","java.io.File").init(tmpDir).list();
					
					for (j=1;j lte arraylen(aItems); j=j+1){
					   name = aItems[j];
					   path=tmpDir & pathSeparator & name;
					   if(directoryexists(path)) {
					   		queryAddRow(qry);
					   		querySetCell(qry,"resType",res);
					   		querySetCell(qry,"name",name);
					   }
					}				
				}
			}
			
			variables.stTimers.getResourcePackagesList = getTickCount()-start;
			
			return qry;
		</cfscript>
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
	<!--- getTimers						   --->
	<!---------------------------------------->	
	<cffunction name="getTimers" access="public" returntype="any" hint="Returns the timers for this object">
		<cfreturn variables.stTimers>
	</cffunction>	

	
	<!---------------------------------------->
	<!--- getResourcesInDescriptorFile	   --->
	<!---------------------------------------->	
	<cffunction name="getResourcesInDescriptorFile" access="private" hint="returns all resources on the given file descriptor" returntype="array">
		<cfargument name="href" type="string" required="true" hint="Path of the resource descriptor file">
		<cfargument name="packageName" type="string" required="true" hint="Name of the package to import">

		<cfscript>
			var xmlDescriptorDoc = 0;
			var j = 0; var resourceTypeGroup = 0; 
			var resourceType = 0; var i = 0;
			var newNode = 0; var oldNode = 0;
			var ownerName = ""; var access = "general";
			var oResourceBean = 0; var stResourceBean = structNew();
			var aResBeans = arrayNew(1); var aResources = arrayNew(1);
			
			// read resource descriptor
			xmlDescriptorDoc = xmlParse(expandPath(arguments.href));

			// check if a package is explicitly defined
			if(structKeyExists(xmlDescriptorDoc.xmlRoot.xmlAttributes, "package"))
				arguments.packageName = xmlDescriptorDoc.xmlRoot.xmlAttributes.package;

			// check if a owner name is explicitly defined for the resources on the descriptor
			if(structKeyExists(xmlDescriptorDoc.xmlRoot.xmlAttributes, "owner"))
				ownerName = xmlDescriptorDoc.xmlRoot.xmlAttributes.owner;
		
			// check if access tu[e is explicitly defined for the resources on the descriptor
			if(structKeyExists(xmlDescriptorDoc.xmlRoot.xmlAttributes, "access"))
				access = xmlDescriptorDoc.xmlRoot.xmlAttributes.access;
		
			// loop through all resource types in descriptor file 
			for(j=1;j lte arrayLen(xmlDescriptorDoc.xmlRoot.xmlChildren);j=j+1) {
				
				aResources = xmlDescriptorDoc.xmlRoot.xmlChildren[j].xmlChildren;
				resourceTypeGroup = xmlDescriptorDoc.xmlRoot.xmlChildren[j].xmlName;  // plural
				resourceType = left(resourceTypeGroup, len(resourceTypeGroup)-1); // singular
			
				// loop through all resources of current type
				for(i=1;i lte ArrayLen(aResources);i=i+1) {

					oResourceBean = createObject("component","resourceBean").init(aResources[i]);
					stResourceBean = oResourceBean.getMemento();

					if(stResourceBean.Package eq "")	oResourceBean.setPackage(arguments.packageName);
					if(stResourceBean.Owner eq "")	oResourceBean.setOwner(ownerName);
					if(stResourceBean.AccessType eq "")	oResourceBean.setAccessType(access);

					arrayAppend(aResBeans, oResourceBean);
				}
			}
			
			return aResBeans;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- getDefaultResourceInPackage	   --->
	<!---------------------------------------->	
	<cffunction name="getDefaultResourceInPackage" access="private" returntype="Any">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource to import">
		<cfargument name="packageName" type="string" required="true" hint="Name of the package to import">
		<cfscript>
			var thisResTypeExt = "";
			var tmpHREF = "";
			var oResourceBean = 0;
			
			// get the resource type extension and store them on a local cache
			thisResTypeExt = getResourceTypeExtension(arguments.resourceType);
				
			// build the default name of the resource to register
			tmpHREF = variables.resourcesRoot & "/" & arguments.resourceType & "s/" & arguments.packageName & "/" & arguments.packageName & "." & thisResTypeExt;

			// if the file exists, then register it
			if(fileExists(expandPath(tmpHREF))) {

				// create resource bean
				oResourceBean = createObject("component","resourceBean").init();
				oResourceBean.setID( arguments.packageName );
				oResourceBean.setHref( tmpHREF );
				oResourceBean.setType( arguments.resourceType );
				oResourceBean.setPackage( arguments.packageName );
				oResourceBean.setAccessType("general");
			}
			
			return oResourceBean;
		</cfscript>
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
				
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="type" type="string" default="homePortals.resourceLibrary.exception"> 
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>
	
</cfcomponent>