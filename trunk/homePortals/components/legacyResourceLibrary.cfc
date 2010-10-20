<cfcomponent implements="resourceLibrary" hint="This component contains the implementation of the resource library used in HomePortals 3.1. This is a filesystem-based library in which all resource types are stored on their own subdirectories. Also, this library requires that all resources have a single package (no nested packages allowed). This provided for backwards compatibility for applications or plugins that are not ready to use the newer implementation of the default resource library.">

	<cfscript>
		variables.resourceDescriptorFile = "info.xml";
		variables.resourcesRoot = "";
		variables.resourcesRootOriginal = "";
		variables.stTimers = structNew();
		variables.resourceTypeRegistry = 0;
		
		variables.IGNORED_DIR_NAMES = ".svn,.cvs";
	</cfscript>

	<!------------------------------------------------->
	<!--- init				                	   ---->
	<!------------------------------------------------->
	<cffunction name="init" returntype="homePortals.components.resourceLibrary" access="public" hint="This is the constructor">
		<cfargument name="resourceLibraryPath" type="string" required="true">
		<cfargument name="resourceTypeRegistry" type="homePortals.components.resourceTypeRegistry" required="true">
		<cfargument name="configStruct" type="struct" required="true">
		<cfargument name="appRoot" type="string" required="false" default="">
		<!--- this is in case the lib path is given with the resLibType prefix --->
		<cfif find("://",arguments.resourceLibraryPath)>
			<cfset arguments.resourceLibraryPath = mid(
														arguments.resourceLibraryPath,
														find("://",arguments.resourceLibraryPath)+3,
														len(arguments.resourceLibraryPath)
													)>
		</cfif>
		<cfset variables.resourcesRootOriginal = arguments.resourceLibraryPath>
		<cfset variables.resourceTypeRegistry = arguments.resourceTypeRegistry>
		<cfif left(arguments.resourceLibraryPath,1) neq "/">
			<cfset variables.resourcesRoot = arguments.appRoot & arguments.resourceLibraryPath>
		<cfelse>
			<cfset variables.resourcesRoot = arguments.resourceLibraryPath>
		</cfif>
		<cfreturn this>
	</cffunction>

	<!------------------------------------------------->
	<!--- getResourceTypeRegistry             	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypeRegistry" access="public" returntype="homePortals.components.resourceTypeRegistry" hint="Returns the registry object for resourceType information">
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
			var tmpDir = "";
			var start = getTickCount();
			var res = "";
			var aItems = arrayNew(1);
			var i = 0;
			var j = 0;
			var aResTypes = arrayNew(1);
			var pathSeparator =  createObject("java","java.lang.System").getProperty("file.separator");
			
			if(arguments.resourceType neq "")
				aResTypes[1] = arguments.resourceType;
			else
				aResTypes = reg.getResourceTypes();
			
			for(i=1;i lte arrayLen(aResTypes);i=i+1) {
				res = aResTypes[i];
				tmpDir = ExpandPath(variables.resourcesRoot & "/" & getFolderName(res));
				
				if(directoryExists(tmpDir)) {
					aItems = createObject("java","java.io.File").init(tmpDir).list();
					
					for (j=1;j lte arraylen(aItems); j=j+1){
					   name = aItems[j];
					   if(directoryexists(tmpDir & pathSeparator & name) 
					   			and not listFindNoCase(variables.IGNORED_DIR_NAMES,name)) {
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
			var oResourceBean = 0;
			var rt = getResourceTypeRegistry().getResourceType( arguments.resourceType );
			var fileTypes = rt.getFileTypes();
			var j = 0;
			var aItems = 0;
			var tmpDir = "";
			
			// check if there is a resource descriptor for the package
			tmpHREF = getResourceDescriptorFilePath(arguments.resourceType, arguments.packageName);

			if(fileExists(expandPath(tmpHREF))) {
				// resource descriptor exists, so read all resources on the descriptor
				aResources = getResourcesInDescriptorFile(arguments.resourceType, arguments.packageName);

			} else if(fileTypes neq "") {
				// there is no resource descriptor, but we know the file types for these resource,
				// so we will treat any files on the package dir with those extensions as resources
				tmpDir = variables.resourcesRoot
							& "/" 
							& getFolderName(arguments.resourceType) 
							& "/" 
							& arguments.packageName;
				if(directoryExists(expandPath(tmpDir))) {
					aItems = createObject("java","java.io.File").init(expandPath(tmpDir)).list();
					for (j=1;j lte arraylen(aItems); j=j+1){
						if(listLen(aItems[j],".") gt 1 and listFindNoCase(fileTypes,listLast(aItems[j],"."))) {
							oResourceBean = getNewResource(arguments.resourceType);
							oResourceBean.setID( listDeleteAt(aItems[j],listLen(aItems[j],"."),".") );
							oResourceBean.setHREF( getFolderName(arguments.resourceType) & "/" & arguments.packageName & "/" & aItems[j] );
							oResourceBean.setPackage( arguments.packageName );
							arrayAppend(aResources, oResourceBean);
						}
					}
				}
			
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
	<!--- getResource		                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResource" access="public" returntype="homePortals.components.resourceBean" hint="returns the resource bean for the given resource">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfargument name="resourceID" type="string" required="true">
		<cfscript>
			var tmpHREF = "";
			var oResourceBean = 0; var o = 0;
			var start = getTickCount();
			var aResources = arrayNew(1);
			var infoHREF = "";
			var rt = getResourceTypeRegistry().getResourceType( arguments.resourceType );
			var fileTypes = rt.getFileTypes();
			var i = 0;
			var qry = 0;
			
			// check that resourceID is not empty
			if(arguments.resourceID eq "") throw("Resource ID cannot be blank","HomePortals.resourceLibrary.blankResourceID");
			
			// if there is no package, then we need to look in all packages
			if(arguments.packageName eq "") {
				qry = getResourcePackagesList(arguments.resourceType);
				for(i=1;i lte qry.recordCount;i++) {
					if(qry.name[i] neq "") {
						try {
							oResourceBean = getResource(arguments.resourceType, qry.name[i], arguments.resourceID);
							return oResourceBean;
						} catch(homePortals.resourceLibrary.resourceNotFound e) {
							// nothing
						}
					}
				}
				throw("The requested resource [#arguments.packageName#][#arguments.resourceID#] was not found",
						"homePortals.resourceLibrary.resourceNotFound");
			}
			
			// check if there is a resource descriptor for the package
			infoHREF = getResourceDescriptorFilePath(arguments.resourceType, arguments.packageName);

			if(fileExists(expandPath(infoHREF))) {
				// resource descriptor exists, so read the resource from the descriptor
				aResources = getResourcesInDescriptorFile(arguments.resourceType, arguments.packageName, arguments.resourceID);
				if(arrayLen(aResources) gt 0) {
					oResourceBean = aResources[1];
				}
	
			} else if(fileTypes neq "") {
				tmpHREF = getFolderName(arguments.resourceType)
							& "/" 
							& arguments.packageName
							& "/"
							& arguments.resourceID;
				for(i=1;i lte listLen(fileTypes);i++) {
					if(fileExists(expandPath(variables.resourcesRoot & "/" & tmpHREF & "." & listGetAt(fileTypes,i)))) {
						oResourceBean = getNewResource(arguments.resourceType);
						oResourceBean.setID( arguments.resourceID );
						oResourceBean.setHREF( tmpHREF & "." & listGetAt(fileTypes,i) );
						oResourceBean.setPackage( arguments.packageName );
						break;
					}
				}
				
			} else {
				// no resource descriptor, so create resource based on package name
				oResourceBean = getDefaultResourceInPackage(arguments.resourceType, arguments.packageName);
			}
			
			if( isSimpleValue(oResourceBean) ) {
				throw("The requested resource [#arguments.packageName#][#arguments.resourceID#] was not found",
						"homePortals.resourceLibrary.resourceNotFound");
			}

			variables.stTimers.getResource = getTickCount()-start;
			return oResourceBean;
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- saveResource	                       	   ---->
	<!------------------------------------------------->
	<cffunction name="saveResource" access="public" returntype="void" hint="Adds or updates a resource in the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true" hint="the resource to add or update"> 		
		<cfscript>
			var href = "";
			var packageDir = "";
			var resDir = "";
			var reg = getResourceTypeRegistry();
			var rb = arguments.resourceBean;
			var resType = rb.getType();
			var resTypeDir = getFolderName(resType);
			var xmlNode = 0;
			var infoHREF = "";
			var aRes = arrayNew(1);
			var i = 0;
			var isNew = true;
		
			// validate bean			
			if(rb.getID() eq "") throw("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(rb.getType() eq "") throw("No resource type has been specified for the resource","homePortals.resourceLibrary.validation");
			if(rb.getPackage() eq "") throw("No package has been specified for the resource","homePortals.resourceLibrary.validation");
			if(not reg.hasResourceType(resType)) throw("The resource type is invalid or not supported","homePortals.resourceLibrary.invalidResourceType");
			
			// get location of descriptor file
			infoHREF = getResourceDescriptorFilePath( rb.getType(), rb.getPackage() );

			// setup directories

			// check if we need to create the res type directory
			resDir = variables.resourcesRoot & "/" & resTypeDir;
			if(not directoryExists(expandPath(resDir))) {
				createDir( resDir );
			}

			// check if we need to create the package directory
			packageDir = resDir & "/" & rb.getPackage();
			if(not directoryExists(expandPath(packageDir))) {
				createDir( packageDir );
			}

			// check for file descriptor, if doesnt exist, then create one
			if(fileExists(expandPath(infoHREF))) {
				xmlDoc = xmlParse(expandPath(infoHREF));
			} else {
				// create file descriptor
				xmlDoc = xmlNew();
				xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "resLib");
				xmlDoc.xmlRoot.xmlAttributes["type"] = rb.getType();
				
				// check if there are already resources in this package
				// that can be inferred from the directory contents
				aRes = getResourcesInPackage(rb.getType(), rb.getPackage());
				for(i=1;i lte arrayLen(aRes);i=i+1) {
					xmlNode = convertResourceToXMLNode( xmlDoc, aRes[i] );
					arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
				}
			}
			
			// check if we need to update the file descriptor
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				if(xmlNode.xmlAttributes.id eq rb.getID()) {
					// node found so we will delete it to add it again
					arrayDeleteAt(xmlDoc.xmlRoot.xmlChildren, i);
					isNew = false;
					break;
				}
			}

			// timestamp bean
			if(isNew) rb.setCreatedOn(now());

			// create and append new xml node for res bean			
			xmlNode = convertResourceToXMLNode( xmlDoc, rb );
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			
			// save resource descriptor file
			saveFile(expandPath(infoHREF), toString(xmlDoc));
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- deleteResource	                       ---->
	<!------------------------------------------------->
	<cffunction name="deleteResource" access="public" returntype="void" hint="Removes a resource from the library. If the resource has a related file then the file is deleted">
		<cfargument name="ID" type="string" required="true">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="package" type="string" required="true">

		<cfscript>
			var packageDir = "";
			var resHref = "";
			var resTypeDir = "";
			var infoHREF = "";
			var reg = getResourceTypeRegistry();
			var resType = reg.getResourceType(arguments.resourceType);
			var defaultExtension = listFirst(resType.getFileTypes());
			
			if(arguments.id eq "") throw("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(arguments.package eq "") throw("No folder has been specified","homePortals.resourceLibrary.validation");
			if(not reg.hasResourceType(arguments.resourceType)) throw("The resource type is invalid","homePortals.resourceLibrary.invalidResourceType");

			// get location of descriptor file
			infoHREF = getResourceDescriptorFilePath( arguments.resourceType, arguments.package  );
			
			resTypeDir = getFolderName(arguments.resourceType);

			// remove from descriptor (if exists)
			packageDir = resourcesRoot & "/" & resTypeDir & "/" & arguments.package;
			if(fileExists(expandPath(infoHREF))) {
				xmlDoc = xmlParse(expandPath(infoHREF));

				for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
					xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
					if(xmlNode.xmlAttributes.id eq id) {
						if(structKeyExists(xmlNode.xmlAttributes, "href"))
							resHref = xmlNode.xmlAttributes.href;
					
						// remove node from document
						arrayDeleteAt(xmlDoc.xmlRoot.xmlChildren, i);
						
						// save modified resource descriptor file
						saveFile(expandPath(infoHREF), toString(xmlDoc));						
									
						break;
					}
				}					
			} else {
			
				resHref = packageDir & "/" & arguments.package & "." & defaultExtension;

			}				
			
			// remove resource file
			if(resHref neq "" and left(resHref,4) neq "http" and fileExists(expandPath(variables.resourcesRoot & "/" & resHref))) {
				removeFile(expandPath(variables.resourcesRoot & "/" & resHref));			
			}
		</cfscript>	
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
	<cffunction name="getPath" access="public" returntype="string" hint="returns the root directory for this library">
		<cfreturn variables.resourcesRootOriginal>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getResourceDescriptorFilePath	   --->
	<!---------------------------------------->	
	<cffunction name="getResourceDescriptorFilePath" access="public" returntype="string" hint="Returns the relative path to the resource descriptor file for a given resource package">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfreturn variables.resourcesRoot 
					& "/" 
					& getFolderName(arguments.resourceType) 
					& "/" 
					& arguments.packageName 
					& "/" 
					& variables.resourceDescriptorFile>
	</cffunction>
						
	<!---------------------------------------->
	<!--- getTimers						   --->
	<!---------------------------------------->	
	<cffunction name="getTimers" access="public" returntype="any" hint="Returns the timers for this object">
		<cfreturn variables.stTimers>
	</cffunction>	


	<!------------------------------------------------->
	<!--- Resource (Target) File Operations   	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceFileHREF" access="public" returntype="string" hint="returns the full (web accessible) path to a file object on the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfset var href = arguments.resourceBean.getHref()>
		
		<cfif right(variables.resourcesRoot,1) neq "/">
			<cfset href = variables.resourcesRoot & "/" & href />
		<cfelse>
			<cfset href = variables.resourcesRoot & href />
		</cfif>
		
		<cfreturn href>
	</cffunction>

	<cffunction name="getResourceFilePath" access="public" returntype="string" hint="If the object can be reached through the file system, then returns the absolute path on the file system to a file object on the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfreturn expandPath(getResourceFileHREF(arguments.resourceBean))>
	</cffunction>

	<cffunction name="resourceFileExists" access="public" output="false" returntype="boolean" hint="Returns whether the file associated with a resource exists on the local file system or not.">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfreturn arguments.resourceBean.getHref() neq "" and fileExists(expandPath(arguments.resourceBean.getFullHref()))>
	</cffunction>
	
	<cffunction name="readResourceFile" access="public" output="false" returntype="any" hint="Reads the file associated with a resource. If there is no associated file then returns a missingTargetFile error. This only works for target files stored within the resource library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfargument name="readAsBinary" type="boolean" required="false" default="false" hint="Reads the file as a binary document">
		<cfset var href = getResourceFileHREF(arguments.resourceBean)>
		<cfset var doc = "">
		
		<cfif resourceFileExists(arguments.resourceBean)>
			<cfif arguments.readAsBinary>
				<cffile action="readbinary" file="#expandPath(href)#" variable="doc">
			<cfelse>
				<cffile action="read" file="#expandPath(href)#" variable="doc">
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
			
			href = getFolderName(rb.getType()) 
					& "/" 
					& rb.getPackage() 
					& "/" 
					& arguments.fileName;	
					
			rb.setHREF(href);
		</cfscript>

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
			
			href = getFolderName(rb.getType()) 
					& "/" 
					& rb.getPackage() 
					& "/" 
					& arguments.fileName;	
					
			rb.setHREF(href);
		</cfscript>

		<cffile action="copy" source="#arguments.filePath#" destination="#expandPath(rb.getFullHREF())#">

		<cfset saveResource(rb)>
	</cffunction>

	<cffunction name="deleteResourceFile" access="public" output="false" returntype="void" hint="Deletes the file associated with a resource">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfset var href = "">
		<cfif resourceFileExists(arguments.resourceBean)>
			<cfset href = getResourceFileHREF(arguments.resourceBean)>
			<cffile action="delete" file="#expandPath(href)#">
		</cfif>
		<cfset arguments.resourceBean.setHREF("")>
		<cfset saveResource(arguments.resourceBean)>
	</cffunction>
	
	
	
	<!---------------------------------------->
	<!--- Private Methods				   --->
	<!---------------------------------------->	
	<cffunction name="getResourcesInDescriptorFile"  returntype="array" access="private" hint="returns all resources on the given file descriptor, also if a resourceID is given, only returns that resource instead of all resources on the package">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource to search">
		<cfargument name="packageName" type="string" required="true" hint="Name of the package to search">
		<cfargument name="resourceID" type="string" required="false" default="" hint="Name of a specific resource to search for. If given, then the returning array only contains that resource">
		<cfscript>
			var infoHREF = "";
			var xmlDescriptorDoc = 0;
			var i = 0;
			var xpath = "";
			var oResourceBean = 0; 
			var aResBeans = arrayNew(1); 
			var aNodes = arrayNew(1);

			// read resource descriptor
			infoHREF = getResourceDescriptorFilePath(arguments.resourceType, arguments.packageName);
			xmlDescriptorDoc = xmlParse(expandPath(infoHREF));
			
			if(arguments.resourceID neq "") {
				xpath = "//resLib[@type='#arguments.resourceType#']/resource[@id='#arguments.resourceID#']";
			} else {
				xpath = "//resLib[@type='#arguments.resourceType#']/resource";
			}
			
			aNodes = xmlSearch(xmlDescriptorDoc, xpath);
			
			for(i=1;i lte ArrayLen(aNodes);i=i+1) {
				oResourceBean = getNewResource(arguments.resourceType);

				loadResourceFromXMLNode( oResourceBean, aNodes[i] );
				oResourceBean.setPackage( arguments.packageName );

				// add resource bean to returning array
				arrayAppend(aResBeans, oResourceBean);
			}
			
			return aResBeans;
		</cfscript>
	</cffunction>

	<cffunction name="getDefaultResourceInPackage" access="private" returntype="Any">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource to import">
		<cfargument name="packageName" type="string" required="true" hint="Name of the package to import">
		<cfscript>
			var tmpHREF = "";
			var oResourceBean = 0;
			var rt = getResourceTypeRegistry().getResourceType( arguments.resourceType );
			var defaultExtension = listFirst(rt.getFileTypes());
			
			// build the default name of the resource to register
			tmpHREF = getFolderName(arguments.resourceType) 
						& "/" 
						& arguments.packageName 
						& "/" 
						& arguments.packageName 
						& "." 
						& defaultExtension;

			// if the file exists, then register it
			if(fileExists(expandPath(variables.resourcesRoot & "/" & tmpHREF))) {

				// create resource bean
				oResourceBean = getNewResource(arguments.resourceType);
				oResourceBean.setID( arguments.packageName );
				oResourceBean.setHREF( tmpHREF );
				oResourceBean.setPackage( arguments.packageName );

			}
			
			return oResourceBean;
		</cfscript>
	</cffunction>

	<cffunction name="loadResourceFromXMLNode" access="public" output="false" returntype="void" hint="populates the a resource bean instance from an xml node from a resource descriptor file">
		<cfargument name="resourceBean" type="any" hint="The resource to load" required="true" />
		<cfargument name="resourceNode" type="XML" hint="XML node from a descriptor document that represents the resource" required="true" />
		<cfscript>
			var resBean = arguments.resourceBean;
			var xmlNode = arguments.resourceNode;
			var i = 0;
			var stSrc = 0;
			var stTgt = 0;

			// populate bean
			resBean.setID(xmlNode.xmlAttributes.id);

			if(structKeyExists(xmlNode.xmlAttributes,"href")) 
				resBean.setHref(xmlNode.xmlAttributes.href);
							
			if(structKeyExists(xmlNode,"description")) 
				resBean.setDescription(xmlNode.description.xmlText);

			if(structKeyExists(xmlNode.xmlAttributes,"createdOn") and xmlNode.xmlAttributes.createdOn neq "") 
				resBean.setCreatedOn(parseDateTime(xmlNode.xmlAttributes.createdOn));

			if(structKeyExists(xmlNode,"property")) {
				for(i=1;i lte arrayLen(xmlNode.xmlChildren);i=i+1) {
					stSrc = xmlNode.xmlChildren[i];
					if(stSrc.xmlName eq "property" and structKeyExists(stSrc.xmlAttributes,"name")) {
						resBean.setProperty(stSrc.xmlAttributes.name, stSrc.xmlText);
					}
				}
			}

			// this is to allow resource bean extensions to provide their own
			// mechanism to load from an XML node. Provided for backward compatibility
			// with Modules resources
			if(structKeyExists(resBean,"loadFromXMLNode")) {
				resBean.loadFromXMLNode(xmlNode);		
			}
						
		</cfscript>
	</cffunction>

	<cffunction name="convertResourceToXMLNode" access="public" output="false" returntype="xml" hint="creates the xml node corresponding to this resource instance on the resource descriptor file">
		<cfargument name="xmlDoc" type="XML" hint="XML object representing the resource descriptor file" required="true" />
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" hint="The resource bean" required="true" />
		<cfscript>
			var resBean = arguments.resourceBean;
			var xmlNode = 0;
			var xmlNode2 = 0;
			var stProps = 0;
			var key = 0;

			if(structKeyExists(resBean,"toXMLNode")) {
				xmlNode = resBean.toXMLNode(arguments.xmlDoc);		
			
			} else {
				xmlNode = xmlElemNew(arguments.xmlDoc, "resource");
				xmlNode.xmlAttributes["id"] = resBean.getID();
				xmlNode.xmlAttributes["HREF"] = resBean.getHREF();
				xmlNode.xmlAttributes["createdOn"] = resBean.getCreatedOn();
	
				if(resBean.getDescription() neq "") {
					xmlNode2 = xmlElemNew(arguments.xmlDoc, "description");
					xmlNode2.xmlText = resBean.getDescription();
					arrayAppend(xmlNode.xmlChildren, xmlNode2);
				}
	
				// set custom properties (if any)
				stProps = resBean.getProperties();
				if(not structIsEmpty(stProps)) {
					for(key in stProps) {
						xmlNode2 = xmlElemNew(arguments.xmlDoc, "property");
						xmlNode2.xmlAttributes["name"] = key;
						xmlNode2.xmlText = stProps[key];
						arrayAppend(xmlNode.xmlChildren, xmlNode2);
					}
				}
			}
						
			return xmlNode;
		</cfscript>
	</cffunction>
	
	<cffunction name="getFolderName" access="private" returntype="string">
		<cfargument name="resourceType" type="string" required="true">
		<cfset var rtn = "" />
		<cfswitch expression="#arguments.resourceType#">
			<cfcase value="content">
				<cfset rtn = "Contents">
			</cfcase>
			<cfcase value="image">
				<cfset rtn = "Images">
			</cfcase>
			<cfcase value="skin">
				<cfset rtn = "Skins">
			</cfcase>
			<cfcase value="feed">
				<cfset rtn = "Feeds">
			</cfcase>
			<cfcase value="module">
				<cfset rtn = "Modules">
			</cfcase>
			<cfdefaultcase>
				<cfset rtn = arguments.resourceType>
			</cfdefaultcase>
		</cfswitch>
		<cfreturn rtn/>
	</cffunction>



	<!---------------------------------------->
	<!--- Utility Methods                  --->
	<!---------------------------------------->
	<cffunction name="saveFile" access="private" hint="saves a file">
		<cfargument name="path" type="string" hint="Path to the file">
		<cfargument name="content" type="string" hint="file content">
		<cffile action="write" file="#arguments.path#" output="#arguments.content#">
	</cffunction>
	
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

	<cffunction name="abort" access="private" returntype="void">
		<cfabort>
	</cffunction>
	
	<cffunction name="dump" access="private" returntype="void">
		<cfargument name="data" type="any">
		<cfdump var="#arguments.data#">
	</cffunction>
	
</cfcomponent>