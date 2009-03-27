<cfcomponent>

	<cfscript>
		variables.resourceDescriptorFile = "info.xml";
		variables.resourcesRoot = "";
		variables.stTimers = structNew();
		variables.stResourceTypes = structNew();
		
		variables.IGNORED_DIR_NAMES = ".svn,.cvs";
		variables.DEFAULT_RES_BEAN_PATH = "homePortals.components.resourceBean";
	</cfscript>

	<!------------------------------------------------->
	<!--- init				                	   ---->
	<!------------------------------------------------->
	<cffunction name="init" returntype="resourceLibrary" access="public" hint="This is the constructor">
		<cfargument name="resourceLibraryPath" type="string" required="true">
		<cfargument name="resourceTypesStruct" type="struct" required="false" default="#structNew()#">
		<cfset var res = "">
		<cfset var args = structNew()>
		<cfset variables.resourcesRoot = arguments.resourceLibraryPath>
		<cfloop collection="#arguments.resourceTypesStruct#" item="res">
			<cfset args = arguments.resourceTypesStruct[res]>
			<cfset args.resourceType = res>
			<cfset registerResourceType(argumentCollection = args)>
		</cfloop>
		<cfreturn this>
	</cffunction>



	<!------------------------------------------------->
	<!--- registerResourceType                	   ---->
	<!------------------------------------------------->
	<cffunction name="registerResourceType" access="public" returntype="void">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="folderName" type="string" required="false" default="">
		<cfargument name="defaultExtension" type="string" required="false" default="">
		<cfargument name="customProperties" type="string" required="false" default="">
		<cfargument name="resBeanPath" type="string" required="false" default="">
		
		<cfif arguments.resourceType eq "">
			<cfthrow message="Resource type name cannot be empty" type="homePortals.resourceLibrary.invalidResourceType">
		</cfif>
		<cfif arguments.folderName eq "">
			<cfset arguments.folderName = arguments.resourceType>
		</cfif>
		<cfif arguments.resBeanPath eq "">
			<cfset arguments.resBeanPath = variables.DEFAULT_RES_BEAN_PATH>
		</cfif>
		
		<cfset variables.stResourceTypes[arguments.resourceType] = structNew()>
		<cfset variables.stResourceTypes[arguments.resourceType].folderName = arguments.folderName>
		<cfset variables.stResourceTypes[arguments.resourceType].defaultExtension = arguments.defaultExtension>
		<cfset variables.stResourceTypes[arguments.resourceType].customProperties = arguments.customProperties>
		<cfset variables.stResourceTypes[arguments.resourceType].resBeanPath = arguments.resBeanPath>
	</cffunction>

	<!------------------------------------------------->
	<!--- getResourceTypes	                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypes" access="public" returntype="array" hint="returns an array with the allowed resource types">
		<cfreturn listToArray(structKeyList(variables.stResourceTypes))>
	</cffunction>

	<!------------------------------------------------->
	<!--- hasResourceType	                	   ---->
	<!------------------------------------------------->
	<cffunction name="hasResourceType" access="public" returntype="boolean" hint="checks whether a given resource types is supported">
		<cfargument name="resourceType" type="string" required="true">
		<cfreturn structKeyExists(variables.stResourceTypes,arguments.resourceType)>
	</cffunction>


	
	<!---------------------------------------->
	<!--- getResourcePackagesList		   --->
	<!---------------------------------------->	
	<cffunction name="getResourcePackagesList" returntype="query" access="public" hint="returns a query with the names of all resource packages">
		<cfargument name="resourceType" type="string" required="false" default="">
		<cfscript>
			var qry = QueryNew("ResType,Name");
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
				aResTypes = getResourceTypes();
			
			for(i=1;i lte arrayLen(aResTypes);i=i+1) {
				res = aResTypes[i];
				tmpDir = ExpandPath(variables.resourcesRoot & "/" & getResourceTypeProperty(res, "folderName"));
				
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
			
			// check if there is a resource descriptor for the package
			tmpHREF = getResourceDescriptorFilePath(arguments.resourceType, arguments.packageName);

			if(fileExists(expandPath(tmpHREF))) {
				// resource descriptor exists, so read all resources on the descriptor
				aResources = getResourcesInDescriptorFile(arguments.resourceType, arguments.packageName);
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
	<cffunction name="getResource" access="public" returntype="resourceBean" hint="returns the resource bean for the given resource">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfargument name="resourceID" type="string" required="true">
		<cfscript>
			var tmpHREF = "";
			var oResourceBean = 0; var o = 0;
			var start = getTickCount();
			var aResources = arrayNew(1);
			var infoHREF = "";
			
			// check that resourceID is not empty
			if(arguments.resourceID eq "") throw("Resource ID cannot be blank","HomePortals.resourceLibrary.blankResourceID");
			
			// check if there is a resource descriptor for the package
			infoHREF = getResourceDescriptorFilePath(arguments.resourceType, arguments.packageName);

			if(fileExists(expandPath(infoHREF))) {
				// resource descriptor exists, so read the resource from the descriptor
				aResources = getResourcesInDescriptorFile(arguments.resourceType, arguments.packageName, arguments.resourceID);
				if(arrayLen(aResources) gt 0) {
					oResourceBean = aResources[1];
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
		<cfargument name="resourceBean" type="resourceBean" required="true" hint="the resource to add or update"> 		
		<cfscript>
			var href = "";
			var packageDir = "";
			var rb = arguments.resourceBean;
			var resType = rb.getType();
			var resTypeDir = getResourceTypeProperty(resType, "folderName");
			var xmlNode = 0;
			var infoHREF = "";
		
			// validate bean			
			if(rb.getID() eq "") throw("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(rb.getType() eq "") throw("No resource type has been specified for the resource","homePortals.resourceLibrary.validation");
			if(rb.getPackage() eq "") throw("No package has been specified for the resource","homePortals.resourceLibrary.validation");
			if(not hasResourceType(resType)) throw("The resource type is invalid or not supported","homePortals.resourceLibrary.invalidResourceType");

			// get location of descriptor file
			infoHREF = getResourceDescriptorFilePath( rb.getType(), rb.getPackage() );

			// setup base directory
			packageDir = variables.resourcesRoot & "/" & resTypeDir & "/" & rb.getPackage();

			// check if we need to create the package directory
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
			}
			
			// check if we need to update the file descriptor
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				if(xmlNode.xmlAttributes.id eq rb.getID()) {
					// node found so we will delete it to add it again
					arrayDeleteAt(xmlDoc.xmlRoot.xmlChildren, i);
					break;
				}
			}

			// create and append new xml node for res bean			
			xmlNode = rb.toXMLNode(xmlDoc);
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			
			// save resource descriptor file
			saveFile(expandPath(infoHREF), toString(xmlDoc));
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- saveResourceFile                     	   ---->
	<!------------------------------------------------->
	<cffunction name="saveResourceFile" access="public" returntype="void" hint="Saves a file corresponding to a resource to the library. The relative path to the file will be updated on the HREF property of the resource">
		<cfargument name="resourceBean" type="resourceBean" required="true" hint="the corresponding resource bean"> 		
		<cfargument name="resourceBody" type="string" required="true" hint="Text content of the related file">
		<cfargument name="fileName" type="string" required="false" default="" hint="The filename to use when saving the file. If empty then the resource ID will be used. Also, if there is no extension, then the defaultExtension property (if defined) will be used as extension">
		<cfscript>
			var rb = arguments.resourceBean;
			var href = "";

			// get default filename and extension
			if(arguments.fileName eq "") {
				arguments.fileName = rb.getID();
			}

			if(listLen(arguments.fileName,".") eq 0
					and getResourceTypeProperty( rb.getType(), "defaultExtension") neq "") {
				arguments.fileName  = arguments.fileName 
										& "." 
										& getResourceTypeProperty(resType, "defaultExtension");
			}
			
			// path is always relative to the res lib root
			href = getResourceTypeProperty(rb.getType(), "folderName") 
					& "/" 
					& rb.getPackage() 
					& "/" 
					& arguments.fileName;
			rb.setHREF(href); 
		
			// save file (or delete if empty)
			filePath = expandPath(variables.resourcesRoot & "/" & href);
			if(arguments.resourceBody neq "") {
				saveFile(filePath, arguments.resourceBody);
			}

			// update resource bean
			saveResource(rb);		
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
			
			if(arguments.id eq "") throw("The ID of the resource cannot be empty","homePortals.resourceLibrary.validation");
			if(arguments.package eq "") throw("No folder has been specified","homePortals.resourceLibrary.validation");
			if(not hasResourceType(arguments.resourceType)) throw("The resource type is invalid","homePortals.resourceLibrary.invalidResourceType");

			// get location of descriptor file
			infoHREF = getResourceDescriptorFilePath( rb.getType(), rb.getPackage() );
			
			resTypeDir = getResourceTypeProperty(arguments.resourceType, "folderName");

			// remove from descriptor (if exists)
			packageDir = resourcesRoot & "/" & resTypeDir & "/" & arguments.package;
			if(fileExists(expandPath(infoHREF))) {
				xmlDoc = xmlParse(expandPath(infoHREF));

				for(i=1;i lte arrayLen(xmlDoc.xmlRoot[resTypeDir].xmlChildren);i=i+1) {
					xmlNode = xmlDoc.xmlRoot[resTypeDir].xmlChildren[i];
					if(xmlNode.xmlAttributes.id eq id) {
						if(structKeyExists(xmlNode.xmlAttributes, "href"))
							resHref = xmlNode.xmlAttributes.href;
					
						// remove node from document
						arrayDeleteAt(xmlDoc.xmlRoot[resTypeDir].xmlChildren, i);
						
						// save modified resource descriptor file
						saveFile(expandPath(infoHREF), toString(xmlDoc));						
									
						break;
					}
				}					
			} else {
			
				ext = getResourceTypeProperty(arguments.resourceType, "defaultExtension");
				resHref = packageDir & "/" & arguments.package & "." & ext;

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
	<cffunction name="getNewResource" access="public" returntype="resourceBean" hint="creates a new empty instance of a given resource type for this library">
		<cfargument name="resourceType" type="string" required="true">
		<cfset var oResBean = 0>
		<cfset var key = "">
		<cfset var lstProps = getResourceTypeProperty(arguments.resourceType,"customProperties")>

		<cfif hasResourceType(arguments.resourceType)>
			<cfset oResBean = createObject( "component", getResourceTypeProperty(arguments.resourceType,"resBeanPath") ).init()>
			<cfset oResBean.setID(createUUID())>
			<cfset oResBean.setType(arguments.resourceType)>
			<cfset oResBean.setResLibPath(variables.resourcesRoot)>
			<cfloop list="#lstProps#" index="key">
				<cfset oResBean.setProperty( key, "" )>
			</cfloop>
			<cfreturn oResBean>
		<cfelse>
			<cfthrow message="Invalid resource type" type="homePortals.resourceLibrary.invalidResourceType">
		</cfif>
	</cffunction>



	<!------------------------------------------------->
	<!--- getPath			                	   ---->
	<!------------------------------------------------->
	<cffunction name="getPath" access="public" returntype="string" hint="returns the root directory for this library">
		<cfreturn variables.resourcesRoot>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getResourceDescriptorFilePath	   --->
	<!---------------------------------------->	
	<cffunction name="getResourceDescriptorFilePath" access="public" returntype="string" hint="Returns the relative path to the resource descriptor file for a given resource package">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfreturn variables.resourcesRoot 
					& "/" 
					& getResourceTypeProperty(arguments.resourceType, "folderName") 
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

				oResourceBean.loadFromXMLNode( aNodes[i] );
				oResourceBean.setPackage( arguments.packageName );
				oResourceBean.setInfoHREF( infoHREF );

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
			
			// build the default name of the resource to register
			tmpHREF = getResourceTypeProperty(arguments.resourceType, "folderName") 
						& "/" 
						& arguments.packageName 
						& "/" 
						& arguments.packageName 
						& "." 
						& getResourceTypeProperty(arguments.resourceType, "defaultExtension");

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

	<cffunction name="getResourceTypeProperty" access="private" returntype="string" hint="Returns a property of the given resource type">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="propertyName" type="string" required="true">
		<cfreturn variables.stResourceTypes[arguments.resourceType][arguments.propertyName] />
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