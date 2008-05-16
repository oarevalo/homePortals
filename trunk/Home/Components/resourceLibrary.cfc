<cfcomponent>

	<cfscript>
		variables.lstResourceTypes = "module,skin,pagetemplate,page,content,feed,html";
		variables.lstResourceTypesExtensions = "cfc,css,xml,xml,html,rss,html";
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
	<!--- getResource		                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResource" access="public" returntype="resourceBean" hint="returns the resource bean for the given resource">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfargument name="resourceID" type="string" required="true">
		<cfargument name="infoHREF" type="string" required="false" default="" hint="the location of the resource descriptor file, if exists">
		<cfscript>
			var tmpHREF = "";
			var oResourceBean = 0; var o = 0;
			var start = getTickCount();
			var aResources = arrayNew(1);
			
			// check that resourceID is not empty
			if(arguments.resourceID eq "") throw("Resource ID cannot be blank","HomePortals.resourceLibrary.blankResourceID");
			
			// check if there is a resource descriptor for the package
			if(arguments.infoHREF eq "")
				arguments.infoHREF = variables.resourcesRoot & "/" & getResourceTypeDirName(arguments.resourceType) & "/" & arguments.packageName & "/" & variables.resourceDescriptorFile;

			if(fileExists(expandPath(arguments.infoHREF))) {
				// resource descriptor exists, so read the resource from the descriptor
				aResources = getResourcesInDescriptorFile(arguments.infoHREF, arguments.packageName, arguments.resourceID);
				oResourceBean = aResources[1];
			} else {
				// no resource descriptor, so create resource based on package name
				o = getDefaultResourceInPackage(arguments.resourceType, arguments.packageName);
				if(not isSimpleValue(o)) oResourceBean = o;
			}

			variables.stTimers.getResource = getTickCount()-start;
			return oResourceBean;
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- getResourcesInPackage                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourcesInPackage" access="public" returntype="Array" hint="returns all resources on a package">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfscript>
			var tmpHREF = "";
			var aResources = arrayNew(1);
			var start = getTickCount();
			
			// check if there is a resource descriptor for the package
			tmpHREF = variables.resourcesRoot & "/" & getResourceTypeDirName(arguments.resourceType) & "/" & arguments.packageName & "/" & variables.resourceDescriptorFile;

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
			var filePath = "";
			var resTypeDir = getResourceTypeDirName(resType);
		
			// validate bean			
			if(rb.getID() eq "") throw("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(rb.getPackage() eq "") throw("No package has been specified for the resource","homePortals.resourceLibrary.validation");
			if(not listFindNoCase(variables.lstResourceTypes, resType)) throw("The resource type is invalid or not supported","homePortals.resourceLibrary.invalidResourceType");
			if(not listFindNoCase(variables.lstAccessTypes, rb.getAccessType())) throw("The access type is invalid","homePortals.resourceLibrary.invalidAccessType");

			// setup base directory
			packageDir = variables.resourcesRoot & "/" & resTypeDir & "/" & rb.getPackage();

			// check if we need to create the package directory
			if(not directoryExists(expandPath(packageDir))) {
				createDir( packageDir );
			}

			// for resources that use local content, set the proper href for the given path based on the ID
			// the path to the local content is always stored as path relative to the resources root,
			// this is to make the resource more portable
			href = rb.getHREF();
			if(href eq "") {
				href = resTypeDir & "/" & rb.getPackage() & "/" & rb.getID() & "." & getResourceTypeExtension(resType);
				rb.setHREF(href); 
			} 
				
			
			// check for file descriptor, if doesnt exist, then create one
			if(fileExists(expandPath(packageDir & "/" & variables.resourceDescriptorFile))) {
				xmlDoc = xmlParse(expandPath(packageDir & "/" & variables.resourceDescriptorFile));
				if(not structKeyExists(xmlDoc.xmlRoot, resTypeDir)) 
					arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc, resTypeDir));
				
			} else {
				// create file descriptor
				xmlDoc = xmlNew();
				xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "catalog");
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc, resTypeDir));
			}
			
			// check if we need to update the file descriptor
			bFound = false;
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot[resTypeDir].xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot[resTypeDir].xmlChildren[i];
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
				arrayAppend(xmlDoc.xmlRoot[resTypeDir].xmlChildren, xmlNode);
			}
			
			// save resource descriptor file
			saveFile(expandPath(packageDir & "/" & variables.resourceDescriptorFile), toString(xmlDoc));
			
			// if this points to a local resource, then create or update the file,
			// otherwise remove the file (if exists)
			if(href neq "") {
				filePath = expandPath(variables.resourcesRoot & "/" & href);
				if(left(href,4) neq "http" and arguments.resourceBody neq "") {
					saveFile(filePath, arguments.resourceBody);
				} else {
					if(fileExists(filePath))
						removeFile(filePath);
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
			var resTypeDir = "";
			
			if(arguments.id eq "") throw("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(arguments.package eq "") throw("No folder has been specified","homePortals.resourceLibrary.validation");
			if(not listFindNoCase(variables.lstResourceTypes, arguments.resourceType)) throw("The resource type is invalid","homePortals.resourceLibrary.invalidResourceType");
			
			resTypeDir = getResourceTypeDirName(arguments.resourceType);

			// remove from descriptor (if exists)
			packageDir = resourcesRoot & "/" & resTypeDir & "/" & arguments.package;
			if(fileExists(expandPath(packageDir & "/" & variables.resourceDescriptorFile))) {
				xmlDoc = xmlParse(expandPath(packageDir & "/" & variables.resourceDescriptorFile));

				for(i=1;i lte arrayLen(xmlDoc.xmlRoot[resTypeDir].xmlChildren);i=i+1) {
					xmlNode = xmlDoc.xmlRoot[resTypeDir].xmlChildren[i];
					if(xmlNode.xmlAttributes.id eq id) {
						if(structKeyExists(xmlNode.xmlAttributes, "href"))
							resHref = xmlNode.xmlAttributes.href;
					
						// remove node from document
						arrayDeleteAt(xmlDoc.xmlRoot[resTypeDir].xmlChildren, i);
						
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
			if(resHref neq "" and left(resHref,4) neq "http" and fileExists(expandPath(variables.resourcesRoot & "/" & resHref))) {
				removeFile(expandPath(variables.resourcesRoot & "/" & resHref));			
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
				tmpDir = ExpandPath(variables.resourcesRoot & "/" & getResourceTypeDirName(res));
				
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
	<cffunction name="getResourcesInDescriptorFile" access="private" hint="returns all resources on the given file descriptor, also if a resourceID is given, only returns that resource instead of all resources on the package" returntype="array">
		<cfargument name="href" type="string" required="true" hint="Path of the resource descriptor file">
		<cfargument name="packageName" type="string" required="true" hint="Name of the package to import">
		<cfargument name="resourceID" type="string" required="false" default="" hint="Name of a specific resource to import. If given, then the returning array only contains that resource">

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

					if(arguments.resourceID eq "" or arguments.resourceID eq aResources[i].xmlAttributes.id) {
					
						oResourceBean = createObject("component","resourceBean").init(aResources[i]);
						stResourceBean = oResourceBean.getMemento();
	
						if(stResourceBean.Package eq "")	oResourceBean.setPackage(arguments.packageName);
						if(stResourceBean.Owner eq "")	oResourceBean.setOwner(ownerName);
						if(stResourceBean.AccessType eq "")	oResourceBean.setAccessType(access);
	
						oResourceBean.setInfoHREF(arguments.href);
	
						// add resource bean to returning array
						arrayAppend(aResBeans, oResourceBean);
						
						// if we are looking for a particular resource and we found it, 
						// then just leave instead of keep looking through the resources
						if(arguments.resourceID neq "") return aResBeans;
					}

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
			tmpHREF = getResourceTypeDirName(arguments.resourceType) & "/" & arguments.packageName & "/" & arguments.packageName & "." & thisResTypeExt;

			// if the file exists, then register it
			if(fileExists(expandPath(variables.resourcesRoot & "/" & tmpHREF))) {

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
				
	<!---------------------------------------->
	<!--- getResourceTypeDirName		   --->
	<!---------------------------------------->
	<cffunction name="getResourceTypeDirName" access="public" output="false" returntype="string" hint="Returns the name of the directory on the resource library for the given resource type">
		<cfargument name="resourceType" type="string" required="true">
		
		<cfif listFind(variables.lstResourceTypes, arguments.resourceType)>
			<cfreturn ucase(left(arguments.resourceType,1)) & lcase(mid(arguments.resourceType,2,len(arguments.resourceType)-1)) & "s">
		</cfif>
		
		<cfthrow message="Invalid resource type" type="homeportals.resourceLibrary.invalidResourceType">
	</cffunction>
					
				
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="type" type="string" default="homePortals.resourceLibrary.exception"> 
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>

	<cffunction name="abort" access="private" returntype="void">
		<cfabort>
	</cffunction>
	<cffunction name="dump" access="private" returntype="void">
		<cfargument name="data" type="any">
		<cfdump var="#arguments.data#">
	</cffunction>
	
</cfcomponent>