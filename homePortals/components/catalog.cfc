<cfcomponent hint="This component implements a catalog to access the resource library using lazy loading of resources">

	<cfscript>
		variables.FIELD_LIST = "libpath,type,id,href,package,description,createdOn,fullhref,fullpath";
		variables.oResourceLibraryManager = 0;
		variables.contentCacheServiceName = "catalogContentCacheService";
		variables.indexCacheServiceName = "catalogIndexesCacheService";
	</cfscript>
	
	<!---------------------------------------->
	<!--- init					           --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="catalog" hint="This is the constructor">
		<cfargument name="config" type="homePortalsConfigBean" hint="main configuration bean for the application">
		<cfscript>
			var oCacheService = 0;
			var oCacheRegistry = createObject("component","cacheRegistry").init();

			// create and register the cache for catalog contents (this caches resource beans)
			oCacheService = createObject("component","cacheService").init(arguments.config.getCatalogCacheSize(), 
																			arguments.config.getCatalogCacheTTL());
			oCacheRegistry.register(variables.contentCacheServiceName, oCacheService);

			// create and register the cache for the catalog indexes 
			oCacheService = createObject("component","cacheService").init(arguments.config.getCatalogCacheSize(), 
																			arguments.config.getCatalogCacheTTL());
			oCacheRegistry.register(variables.indexCacheServiceName, oCacheService);

			return this;
		</cfscript>		
	</cffunction>


	<!---------------------------------------->
	<!--- ResourceLibraryManager		   --->
	<!---------------------------------------->	
	<cffunction name="getResourceLibraryManager" access="public" returntype="resourceLibraryManager">
		<cfreturn variables.oResourceLibraryManager>
	</cffunction> 
	<cffunction name="setResourceLibraryManager" access="public" returntype="void">
		<cfargument name="obj" type="resourceLibraryManager" required="true">
		<cfset variables.oResourceLibraryManager = arguments.obj />
	</cffunction> 

		
	<!---------------------------------------->
	<!--- getResource					   --->
	<!---------------------------------------->	
	<cffunction name="getResource" access="public" returntype="resourceBean" hint="Returns the requested resource bean from the catalog">
		<cfargument name="type" type="string" required="true" hint="Type of resource">
		<cfargument name="id" type="string" required="true" hint="Identifies the resource. This can be either the resourceID of the resource, or can be of the form 'packageName.resourceID' or 'packageName/resourceID'. Using the latter improves resource lookup performance for non cached resources.">
		<cfargument name="forceReload" type="boolean" required="false" default="false" hint="forces a reload of the resource, ignoring any cached instance">
		
		<cfscript>
			var oResBean = 0;
			var cacheKey = "";
			var package = "";
			var resourceID = "";
			var loadFromSource = arguments.forceReload;
			var delimChar = "/";

			if(left(arguments.id,1) eq delimChar)
				arguments.id = removeChars(arguments.id,1,1);
			resourceID = arguments.id;
			
			// allow resources to be identified by "packageName/resourceID" notation.
			if(listLen(resourceID,delimChar) gt 1) {
				package = listDeleteAt(resourceID, listLen(resourceID, delimChar), delimChar);
				resourceID = listLast(resourceID, delimChar);
			}

			// build the key used for storing item in cache
			cacheKey = "//" & arguments.type & "/" & resourceID;
			
			// try to read item from cache
			if(not loadFromSource) {
				try {
					oResBean = getContentCacheService().retrieve(cacheKey);
				} catch(homePortals.cacheService.itemNotFound e) {
					loadFromSource = true;
				}
			}

			// load item from resource library and store in cache
			if(loadFromSource) {
				oResBean = getResourceLibraryManager().getResource(arguments.type, package, resourceID);
				getContentCacheService().store(cacheKey, oResBean);
			}
			
			return oResBean;
		</cfscript>
	</cffunction>	

	<!---------------------------------------->
	<!--- index							   --->
	<!---------------------------------------->	
	<cffunction name="index" access="public" returntype="void" hint="Crawls the available resource libraries indexing available resources. Indexing can be restricted to a specific resource type and package. Depending on the amount of resources this operation may take some time to complete">
		<cfargument name="resourceType" type="string" required="false" default="">
		<cfargument name="packageName" type="string" required="false" default="">
		<cfscript>
			var i = 1;
			var aTypes = arrayNew(1);

			if(arguments.resourceType eq "") {
				// clears the catalog index
				getIndexCacheService().clear();

				aTypes = getResourceLibraryManager().getResourceTypes();
				for(i=1;i lte arrayLen(aTypes);i=i+1) {
					loadResources(aTypes[i]);
				}	
			} else {
				loadResources(arguments.resourceType, arguments.packageName);
			}
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- getIndex						   --->
	<!---------------------------------------->	
	<cffunction name="getIndex" access="public" returntype="query" output="False" hint="Returns a recordset with an index of the available resources. The index can be restricted to a specific resource type. Be aware that if the resourceType argument is not given, then this method calls index() internally so if there are too many resources it can take a while to complete.">
		<cfargument name="resourceType" type="string" required="false" default="">
		<cfargument name="packageName" type="string" required="false" default="">
		<cfscript>
			var	qry = queryNew(variables.FIELD_LIST);
			var stResourceBean = structNew();
			var resType = "";
			var resID = "";
			var indexCache = getIndexCacheService();
			var resourceTypes = "";
			var i = 0;
			var j = 0;
			var k = 0;
			
			if(arguments.resourceType eq "") {
				index();	// index all libraries
			
				resourceTypes = indexCache.list();
				for(i=1;i lte arrayLen(resourceTypes);i++) {
					resType = resourceTypes[i].key;
					qryType = indexCache.retrieve(resType);
					for(j=1;j lte qryType.recordCount;j++) {
						queryAddRow(qry);
						for(k=1;k lte listLen(qryType.columnList);k++) {
							fld = listGetAt(qryType.columnList,k);
							if(listFindNoCase(variables.FIELD_LIST,fld)) {
								querySetCell(qry, fld, qryType[fld][j]);
							}
						}
					}
				}

			} else if(arguments.packageName eq "") {
				if(not indexCache.hasItem(arguments.resourceType))
					index(arguments.resourceType);
				qry = indexCache.retrieve(arguments.resourceType);

			} else {
				if(not indexCache.hasItem(arguments.resourceType))
					index(arguments.resourceType, arguments.packageName);
				qry = indexCache.retrieve(arguments.resourceType);
				qry = filterQuery(qry,"package",arguments.packageName,"cf_sql_varchar","LIKE");
				if(qry.recordCount eq 0) {
					// package not found in cache, it is possible that pkg exists but has not been cached yet
					// so lets index again this package
					index(arguments.resourceType, arguments.packageName);
					qry = indexCache.retrieve(arguments.resourceType);
					qry = filterQuery(qry,"package",arguments.packageName,"cf_sql_varchar","LIKE");
				}
			}
			
			return qry;
		</cfscript>
	</cffunction>
		

	<!---------------------------------------->
	<!--- cacheServices					   --->
	<!---------------------------------------->	
	<cffunction name="getContentCacheService" access="public" returntype="cacheService" hint="Returns a reference to the cacheService object used to store individual resources">
		<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
		<cfreturn oCacheRegistry.getCache(variables.contentCacheServiceName)>
	</cffunction> 
	<cffunction name="getIndexCacheService" access="public" returntype="cacheService" hint="Returns a reference to the cacheService object used to store resource indexes">
		<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
		<cfreturn oCacheRegistry.getCache(variables.indexCacheServiceName)>
	</cffunction> 



	<!--- * * * *     P R I V A T E     M E T H O D S   * * * * 	   --->

	<cffunction name="loadResources" access="private" returntype="void" hint="loads into memory all resources of the given type and package">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="false" default="">
		<cfscript>
			var qryIndex = 0; var qryNewIndex = 0;
			var i = 1; var rt = 0; 
			var fldList = ""; var qryPackages = 0;
			var resourceLibraryManager = getResourceLibraryManager();
			var indexCache = getIndexCacheService();
	
			// if we are loading all packages, then clear any existing cache
			if(arguments.packageName eq "") {
				indexCache.flush(arguments.resourceType);
			}

			if(not indexCache.hasItem(arguments.resourceType)) {
				rt = resourceLibraryManager.getResourceTypeRegistry().getResourceType(arguments.resourceType);
				fldList = listAppend(variables.FIELD_LIST, structKeyList( rt.getProperties()) );
				qryIndex = queryNew(fldList);
			} else {
				qryIndex = indexCache.retrieve(arguments.resourceType);
			}
				
			if(arguments.packageName eq "") {
				qryIndex = addResourcesFromPackage(qryIndex, arguments.resourceType);
				qryPackages = resourceLibraryManager.getResourcePackagesList(arguments.resourceType);
				for(i=1;i lte qryPackages.recordCount;i=i+1) {
					qryIndex = addResourcesFromPackage(qryIndex, arguments.resourceType, qryPackages.name[i]);
				}
			} else {
				qryIndex = filterQuery(qryIndex,"package",arguments.packageName,"cf_sql_varchar","NOT LIKE");
				qryIndex = addResourcesFromPackage(qryIndex, arguments.resourceType, arguments.packageName);
			}

			indexCache.store(arguments.resourceType, qryIndex);
		</cfscript>
	</cffunction>

	<cffunction name="addResourcesFromPackage" access="private" returntype="query">
		<cfargument name="qryIndex" type="query" required="true">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="false" default="">
		<cfscript>
			var resourceLibraryManager = getResourceLibraryManager();
			var aResources = arrayNew(1);
			var stResourceBean = structNew();
			var rt = ""; var customFldList = ""; var i=0;
			var prop = "";

			// get all resources on the given package
			aResources = resourceLibraryManager.getResourcesInPackage(arguments.resourceType, arguments.packageName);

			// create empty query
			rt = resourceLibraryManager.getResourceTypeRegistry().getResourceType(arguments.resourceType);
			customFldList = structKeyList( rt.getProperties() );

			// store the resources
			for(i=1;i lte arrayLen(aResources);i=i+1) {
				stResourceBean = aResources[i].getMemento();
			
				queryAddRow(qryIndex);
				querySetCell(qryIndex, "type", stResourceBean.type);
				querySetCell(qryIndex, "id", stResourceBean.id);
				querySetCell(qryIndex, "HREF", stResourceBean.HREF);
				querySetCell(qryIndex, "Package", stResourceBean.Package);
				querySetCell(qryIndex, "Description", stResourceBean.Description);
				querySetCell(qryIndex, "libpath", stResourceBean.resourceLibrary.getPath());
				querySetCell(qryIndex, "createdOn", stResourceBean.createdOn);
				querySetCell(qryIndex, "fullhref", aResources[i].getFullHref());
				querySetCell(qryIndex, "fullpath", aResources[i].getFullPath());

				for(prop in stResourceBean.customProperties) {
					if(listFindNoCase(customFldList,prop)) {
						querySetCell(qryIndex, prop, stResourceBean.customProperties[prop]);
					}
				}
			}

			return qryIndex;
		</cfscript>
	</cffunction>


	<!--- * * * *     U T I L I T Y     M E T H O D S   * * * * 	   --->	
	
	<cffunction name="throw" access="private" returntype="void" hint="facade for cfthrow">
		<cfargument name="message" type="string" required="false" default="">
		<cfargument name="type" type="string" required="false" default="">
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>

	<cffunction name="abort" access="private" returntype="void" hint="facade for cfabort">
		<cfabort>
	</cffunction>
	
	<cffunction name="dump" access="private" returntype="void" hint="facade for cfdump">
		<cfargument name="data" type="any">
		<cfdump var="#arguments.data#">
	</cffunction>

	<cffunction name="dumpConsole" access="private" returntype="void" hint="facade for cfdump">
		<cfargument name="data" type="any">
		<cfdump var="#arguments.data#" output="console">
	</cffunction>
	
	<cffunction name="filterQuery" access="private" returntype="query">
		<cfargument name="query" type="query" required="true">
		<cfargument name="fieldName" type="string" required="true">
		<cfargument name="fieldValue" type="string" required="true">
		<cfargument name="fieldType" type="string" required="false" default="cf_sql_varchar">
		<cfargument name="condition" type="string" required="false" default="=">
		<cfset var qry = 0 />
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM arguments.query
				WHERE #arguments.fieldName# #arguments.condition# <cfqueryparam cfsqltype="#arguments.fieldType#" value="#arguments.fieldValue#">
		</cfquery>
		<cfreturn qry />
	</cffunction>
	
</cfcomponent>