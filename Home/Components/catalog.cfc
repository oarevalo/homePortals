<cfcomponent name="catalog" hint="This object provides access to the catalog of reusable resources for the HomePortals application.">

	<cfscript>
		variables.href = "";
		variables.resourcesRoot = "";
		variables.resInfoFile = "info.xml";
		variables.lstResourceTypes = "module,skin,pageTemplate,page,content,feed";
		variables.lstResourceTypesExtensions = "cfc,css,xml,xml,html,rss";
		variables.lstAccessTypes = "general,owner,friend";
		variables.qryResources = QueryNew("type,id,access,name,href,package,owner,description");
		variables.stTimers = structNew();
		
		variables.mapResources = structNew();
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
				WHERE type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.resourceType#s">
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

		<cfset var qry = 0>
		
		<cfloop collection="#variables.mapResources.modules#" item="item">
			
			<cfset oResourceBean = variables.mapResources.modules[item]>
			<cfif oResourceBean.getName() eq arguments.moduleName>
				<cfreturn oResourceBean>
			</cfif>
		
		</cfloop>
		
		<cfthrow message="Resource [#arguments.moduleName#] not found" type="homePortals.catalog.resourceNotFound">

	</cffunction>	
	
	<!---------------------------------------->
	<!--- getResourceNode				   --->
	<!---------------------------------------->	
	<cffunction name="getResourceNode" access="public" returntype="any" hint="Returns the tree node for a given resource on this catalog">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource">
		<cfargument name="resourceID" type="string" required="true" hint="ID of the resource">
		<cfif StructKeyExists(variables.mapResources[arguments.resourceType & "s"], arguments.resourceID)>
			<cfreturn variables.mapResources[arguments.resourceType & "s"][arguments.resourceID]>
		<cfelse>
			<cfthrow message="Resource [#arguments.resourceID#] does not exist" type="homePortals.catalog.resourceNotFound">
		</cfif>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- deleteResourceNode			   --->
	<!---------------------------------------->	
	<cffunction name="deleteResourceNode" access="public" returntype="any" hint="Deletes the given resource node on this catalog">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource">
		<cfargument name="resourceID" type="string" required="true" hint="ID of the resource">
		<cfif StructKeyExists(variables.mapResources[arguments.resourceType & "s"], arguments.resourceID)>
			<cfset structDelete(variables.mapResources[arguments.resourceType & "s"], arguments.resourceID)>
			<cfset populateResourcesQuery()>
		<cfelse>
			<cfthrow message="Resource [#arguments.resourceID#] does not exist" type="homePortals.catalog.resourceNotFound">
		</cfif>
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
			var oResourceBean = 0;
			var start = getTickCount();

			// clear the catalog
			variables.mapResources = structNew();
			
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
					importSingleResourcePackage(qry.resType[i], qry.name[i]);
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
	<!--- reloadPackage				       --->
	<!---------------------------------------->	
	<cffunction name="reloadPackage" access="public" returntype="void" 
				hint="Reloads a resources package">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		
		<cfscript>
			var tmpHREF = "";
			
			// check if there is a resource descriptor for the package
			tmpHREF = variables.resourcesRoot & "/" & arguments.resourceType & "s/" & arguments.packageName & "/" & variables.resInfoFile;

			if(fileExists(expandPath(tmpHREF))) {
				// resource descriptor exists, so import all resources on the descriptor
				importResourcePackage(tmpHREF, arguments.packageName);
			} else {
				// no resource descriptor, so register resources based on package name
				// this will only register ONE resource per package
				importSingleResourcePackage(arguments.resourceType, arguments.packageName);
			}

			// populate query of resources
			populateResourcesQuery();		
		</cfscript>
		
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
			var xmlDescriptorDoc = 0;
			var j = 0; var aResources = 0; var resourceTypeGroup = 0; 
			var resourceType = 0; var i = 0;
			var newNode = 0; var oldNode = 0;
			var ownerName = ""; var access = "general";
			var oResourceBean = 0; var stResourceBean = structNew();
			
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

				// create node for resource type group if doesnt exist
				if(Not StructKeyExists(variables.mapResources, resourceTypeGroup)) {
					variables.mapResources[resourceTypeGroup] = structNew();
				}
				
				// loop through all resources of current type
				for(i=1;i lte ArrayLen(aResources);i=i+1) {

					oResourceBean = createObject("component","resourceBean").init(aResources[i]);
					stResourceBean = oResourceBean.getMemento();

					if(stResourceBean.Package eq "")	oResourceBean.setPackage(arguments.packageName);
					if(stResourceBean.Owner eq "")	oResourceBean.setOwner(ownerName);
					if(stResourceBean.AccessType eq "")	oResourceBean.setAccessType(access);

					variables.mapResources[resourceTypeGroup][stResourceBean.id] = oResourceBean;
				}
			}
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- importSingleResourcePackage	   --->
	<!---------------------------------------->	
	<cffunction name="importSingleResourcePackage" access="private">
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

				// create node for resource type group if doesnt exist
				if(Not StructKeyExists(variables.mapResources, arguments.resourceType & "s")) {
					variables.mapResources[arguments.resourceType & "s"] = structNew();
				}
		
				// create resource bean
				oResourceBean = createObject("component","resourceBean").init();
				oResourceBean.setID( arguments.packageName );
				oResourceBean.setHref( tmpHREF );
				oResourceBean.setPackage( arguments.packageName );
				oResourceBean.setAccessType("general");

				// add resource bean to map
				variables.mapResources[arguments.resourceType & "s"][arguments.packageName] = oResourceBean;
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
			var start = getTickCount();
			var stResourceBean = structNew();
			var resType = "";
			var resID = "";
			
			variables.qryResources = QueryNew("type,id,access,name,href,package,owner,description");
			
			for(resType in variables.mapResources) {
			
				for(resID in variables.mapResources[resType]) {
					
					stResourceBean = variables.mapResources[resType][resID].getMemento();
					
					queryAddRow(variables.qryResources);
					querySetCell(variables.qryResources, "type", resType);
					querySetCell(variables.qryResources, "id", resID);
					querySetCell(variables.qryResources, "access", stResourceBean.AccessType);
					querySetCell(variables.qryResources, "name", stResourceBean.Name);
					querySetCell(variables.qryResources, "href", stResourceBean.HREF);
					querySetCell(variables.qryResources, "package", stResourceBean.Package);
					querySetCell(variables.qryResources, "owner", stResourceBean.Owner);
					querySetCell(variables.qryResources, "description", stResourceBean.Description);
				
				}
	
			}
			variables.stTimers.populateResourcesQuery = getTickCount()-start;
		</cfscript>
	</cffunction>


	<!---------------------------------------->
	<!--- debugging methods				   --->
	<!---------------------------------------->	
	<cffunction name="abort" access="private" returntype="void">
		<cfabort>
	</cffunction>
	<cffunction name="dump" access="private" returntype="void">
		<cfargument name="data" type="any">
		<cfdump var="#arguments.data#">
	</cffunction>

</cfcomponent>