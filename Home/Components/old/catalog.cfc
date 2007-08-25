<cfcomponent name="catalog" hint="This object provides access to the catalog of reusable resources for the HomePortals application.">

	<cfscript>
		variables.href = "";
		variables.xmlDoc = 0;
		variables.resourcesRoot = "";
		variables.resInfoFile = "info.xml";
		variables.lstResourceTypes = "module,skin,pageTemplate,page,content,feed";
		variables.lstResourceTypesExtensions = "cfc,css,xml,xml,html,rss";
		variables.lstAccessTypes = "general,owner,friend";
		variables.qryResources = QueryNew("type,id,access,name,href,package,owner,description");
		variables.stTimers = structNew();
	</cfscript>
	
	<!---------------------------------------->
	<!--- init					           --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="catalog">
		<cfargument name="resourcesRoot" type="string" required="true">
		<cfscript>
			var start = getTickCount();
			variables.resourcesRoot = arguments.resourcesRoot;
		
			// rebuild the catalog 
			rebuildCatalog();
			
			variables.stTimers.init = getTickCount()-start;
			return this;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- getResourcesByType         --->
	<!---------------------------------------->	
	<cffunction name="getResourcesByType" access="public" returntype="query" output="False"
				hint="Returns all resources of a given type">
		<cfargument name="resourceType" type="string" required="false" hint="Type of resource">

		<cfset var qry = queryNew("")>
		
		<cfif not ListFindNoCase(variables.lstResourceTypes, arguments.resourceType)>
			<cfthrow message="Invalid resource type" type="homeportals.catalog.invalidResourceType">
		</cfif>
		
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM variables.qryResources
				WHERE type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.resourceType#">
		</cfquery>
		
		<cfreturn qry>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getResourceTypes            --->
	<!---------------------------------------->	
	<cffunction name="getResourceTypes" access="public" returntype="array" output="False"
				hint="Returns an array with all supported resource types">
		<cfreturn listToArray(variables.lstResourceTypes)>
	</cffunction>	

	<!---------------------------------------->
	<!--- getAccessTypes            --->
	<!---------------------------------------->	
	<cffunction name="getAccessTypes" access="public" returntype="array" output="False"
				hint="Returns an array with all supported access types">
		<cfreturn listToArray(variables.lstAccessTypes)>
	</cffunction>		
	
	<!---------------------------------------->
	<!--- getModuleByName				   --->
	<!---------------------------------------->	
	<cffunction name="getModuleByName" access="public" returntype="any" hint="Returns the tree node for a given resource on this catalog">
		<cfargument name="moduleName" type="string" required="true" hint="Name of the module">
	
		<cfscript>
			var xmlNode = 0;
			var xpath = "";
			var aModule = 0;
			
			// get resource
			xpath = "//module[@name='#arguments.moduleName#']";
			aModule = xmlSearch(variables.xmlDoc, xpath);
			
			if(ArrayLen(aModule) gt 0) {
				xmlNode = aModule[1];
			}
		</cfscript>
		<cfreturn xmlNode>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- getResourceNode				   --->
	<!---------------------------------------->	
	<cffunction name="getResourceNode" access="public" returntype="any" hint="Returns the tree node for a given resource on this catalog">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource">
		<cfargument name="resourceID" type="string" required="true" hint="ID of the resource">
	
		<cfscript>
			var xmlNode = 0;
			var xpath = "";
			var aResources = 0;
			
			// get resource
			xpath = "//" & lcase(arguments.resourceType) & "[@id='#arguments.resourceID#']";
			aResources = xmlSearch(variables.xmlDoc, xpath);
			
			if(ArrayLen(aResources) gt 0) {
				xmlNode = aResources[1];
			}
		</cfscript>
		<cfreturn xmlNode>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- deleteResourceNode			   --->
	<!---------------------------------------->	
	<cffunction name="deleteResourceNode" access="public" returntype="any" hint="Deletes the given resource node on this catalog">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource">
		<cfargument name="resourceID" type="string" required="true" hint="ID of the resource">
	
		<cfscript>
			var xmlNode = 0;
			var xpath = "";
			
			// get resource
			xpath = "//" & lcase(arguments.resourceType) & "[@id='#arguments.resourceID#']";
			aResources = xmlSearch(variables.xmlDoc, xpath);
			
			for(i=1;i lte arrayLen(variables.xmlDoc.xmlRoot[arguments.resourceType].xmlChildren);i=i+1) {
				xmlNode = variables.xmlDoc.xmlRoot[arguments.resourceType].xmlChildren[i];
				if(xmlNode.xmlAttributes.id eq arguments.resourceID) {
					ArrayDeleteAt(variables.xmlDoc.xmlRoot[arguments.resourceType].xmlChildren, i);
					break;
				}
			}
			
			save();
		</cfscript>
	</cffunction>		

	<!---------------------------------------->
	<!--- rebuildCatalog				   --->
	<!---------------------------------------->	
	<cffunction name="rebuildCatalog" access="public" returntype="void" hint="Rebuilds the catalog">
		<cfscript>
			var qry = QueryNew("");
			var i = 1;
			var tmpHREF = "";
			var newNode = 0;
			var mapResourceTypeExtensions = structNew();
			var thisResTypeExt = "";
			var start = getTickCount();

			// recreate the catalog
			variables.xmlDoc = xmlNew();
			variables.xmlDoc.xmlRoot = xmlElemNew(variables.xmlDoc,"catalog");
			
			// get list of resource packages
			qry = getResourcePackagesList();

			// add resources to the catalog
			start = getTickCount();
			for(i=1;i lte qry.recordCount;i=i+1) {

				// check if there is a resource descriptor for the package
				tmpHREF = variables.resourcesRoot & "/" & qry.resType[i] & "s/" & qry.name[i] & "/" & variables.resInfoFile;
				if(fileExists(expandPath(tmpHREF))) {
					// resource descriptor exists, so import all resources on the descriptor
					importResourcePackage(tmpHREF, qry.name[i]);
				} else {
				
					// no resource descriptor, so register resources based on package name
					// this will only register ONE resource per package

					
					// get the resource type extension and store them on a local cache
					// since this will have to be lookup multiple times
					if(Not structKeyExists(mapResourceTypeExtensions, qry.resType[i])) {
						mapResourceTypeExtensions[qry.resType[i]] = getResourceTypeExtension(qry.resType[i]);
					}
					thisResTypeExt = mapResourceTypeExtensions[qry.resType[i]];
						
					// build the default name of the resource to register
					tmpHREF = variables.resourcesRoot & "/" & qry.resType[i] & "s/" & qry.name[i] & "/" & qry.name[i] & "." & thisResTypeExt;

					// if the file exists, then register it
					if(fileExists(expandPath(tmpHREF))) {

						// create node for resource type if doesnt exist
						if(Not StructKeyExists(variables.xmlDoc.xmlRoot, qry.resType[i] & "s" )) {
							ArrayAppend(variables.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(variables.xmlDoc, qry.resType[i] & "s" ));	
						}
						
						newNode = xmlElemNew(variables.xmlDoc, qry.resType[i] );
						newNode.xmlAttributes["id"] = qry.name[i];
						newNode.xmlAttributes["href"] = tmpHREF;
						newNode.xmlAttributes["package"] = qry.name[i];
						newNode.xmlAttributes["owner"] = "";
						newNode.xmlAttributes["access"] = "general";
						newNode.xmlAttributes["name"] = "";
					
						ArrayAppend(variables.xmlDoc.xmlRoot[qry.resType[i] & "s"].xmlChildren, newNode);							
					}
				}
			}		
			
			// populate query of resources
			// this allows for faster and easier searching
			populateResourcesQuery();		
			
			variables.stTimers.rebuildCatalog = getTickCount()-start;
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
		
		<cfthrow message="Invalid resource type" type="homeportals.catalog.invalidResourceType">
	</cffunction>
	
	<!---------------------------------------->
	<!--- getResources				         --->
	<!---------------------------------------->	
	<cffunction name="getResources" access="public" returntype="query" output="False"
				hint="Returns all resources">
		<cfreturn variables.qryResources>
	</cffunction>
		
	
	<!---------------------------------------->
	<!--- getTimers						   --->
	<!---------------------------------------->	
	<cffunction name="getTimers" access="public" returntype="any" hint="Returns the timers for this object">
		<cfreturn variables.stTimers>
	</cffunction>	
	
	<!--- * * * *     P R I V A T E     M E T H O D S   * * * * 	   --->


	<!---------------------------------------->
	<!--- getResourcePackagesList		   --->
	<!---------------------------------------->	
	<cffunction name="getResourcePackagesList" returntype="query" access="private"
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
	<!--- importResourcePackage			   --->
	<!---------------------------------------->	
	<cffunction name="importResourcePackage" access="private">
		<cfargument name="href" type="string" required="true" hint="Path of the resource descriptor file">
		<cfargument name="packageName" type="string" required="true" hint="Name of the package to import">

		<cfscript>
			var xmlCatalogDoc = 0; var xmlDescriptorDoc = 0;
			var j = 0; var aResources = 0; var resourceTypeGroup = 0; 
			var resourceType = 0; var i = 0;
			var newNode = 0; var oldNode = 0;
			var ownerName = ""; var access = "general";
			
			// read catalog
			xmlCatalogDoc = variables.xmlDoc;
						
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
		
		
			// append all resources in descriptor file to the catalog
			for(j=1;j lte arrayLen(xmlDescriptorDoc.xmlRoot.xmlChildren);j=j+1) {
				
				aResources = xmlDescriptorDoc.xmlRoot.xmlChildren[j].xmlChildren;
				resourceTypeGroup = xmlDescriptorDoc.xmlRoot.xmlChildren[j].xmlName;  // plural
				resourceType = left(resourceTypeGroup, len(resourceTypeGroup)-1); // singular

				// create node for resource type group if doesnt exist
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
						
						// make sure nodes have all necessary attributes
						if(Not structKeyExists(newNode.xmlAttributes, "package"))	newNode.xmlAttributes["package"] = arguments.packageName;
						if(Not structKeyExists(newNode.xmlAttributes, "owner"))		newNode.xmlAttributes["owner"] = ownerName;
						if(Not structKeyExists(newNode.xmlAttributes, "access"))	newNode.xmlAttributes["access"] = access;
						if(Not structKeyExists(newNode.xmlAttributes, "name"))		newNode.xmlAttributes["name"] = "";
						if(Not structKeyExists(newNode.xmlAttributes, "href"))		newNode.xmlAttributes["href"] = "";

						// append node to catalog	
						ArrayAppend(xmlCatalogDoc.xmlRoot[resourceTypeGroup].xmlChildren, newNode);
					}
				}
			}
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- populateResourcesQuery		   --->
	<!---------------------------------------->	
	<cffunction name="populateResourcesQuery" access="private" returntype="void" hint="Puts all resources into a query to improve performance while searching and listing">
		<cfscript>
			var i=0; 
			var j=0;
			var xmlResourcesNode = 0;
			var xmlNode = 0;
			var start = getTickCount();
			
			variables.qryResources = QueryNew("type,id,access,name,href,package,owner,description");
			
			for(i=1;i lte arrayLen(variables.xmlDoc.xmlRoot.xmlChildren);i=i+1) {
			
				xmlResourcesNode = variables.xmlDoc.xmlRoot.xmlChildren[i];
					
				for(j=1;j lte arrayLen(xmlResourcesNode.xmlChildren);j=j+1) {
					xmlNode = xmlResourcesNode.xmlChildren[j];
					
					queryAddRow(variables.qryResources);
					querySetCell(variables.qryResources, "type", xmlNode.xmlName);
					querySetCell(variables.qryResources, "id", xmlNode.xmlAttributes.id);
					querySetCell(variables.qryResources, "access", xmlNode.xmlAttributes.access);
					querySetCell(variables.qryResources, "name", xmlNode.xmlAttributes.name);
					querySetCell(variables.qryResources, "href", xmlNode.xmlAttributes.href);
					querySetCell(variables.qryResources, "package", xmlNode.xmlAttributes.package);
					querySetCell(variables.qryResources, "owner", xmlNode.xmlAttributes.owner);
					querySetCell(variables.qryResources, "description", xmlNode.xmlText);
				
				}
	
			}
			variables.stTimers.populateResourcesQuery = getTickCount()-start;
		</cfscript>
	</cffunction>
	
	<!---------------------------------------->
	<!--- copyNode  					   --->
	<!---------------------------------------->
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