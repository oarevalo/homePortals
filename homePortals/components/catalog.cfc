<cfcomponent hint="This component implements a catalog to access the resource library using lazy loading of resources">

	<cfscript>
		variables.qryResources = QueryNew("libpath,type,id,href,package,description");
		variables.mapResources = structNew();
		variables.oResourceLibraryManager = 0;
		variables.cacheServiceName = "catalogCacheService";
	</cfscript>
	
	<!---------------------------------------->
	<!--- init					           --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="catalog" hint="This is the constructor">
		<cfargument name="resourceLibraryManager" type="resourceLibraryManager" required="true" hint="An instance of the resource library manager">
		<cfargument name="indexLibrary" type="boolean" required="false" default="false" hint="Flag to indicate whether or not to perform a full index of the entire resource library. Depending on the amount of resources on the library this operation may take some time to complete. The default is False">

		<cfset variables.oResourceLibraryManager = arguments.resourceLibraryManager>

		<cfif arguments.indexLibrary>
			<cfset index()>
		</cfif>
		
		<cfreturn this>
	</cffunction>

	<!---------------------------------------->
	<!--- getResourceLibraryManager		   --->
	<!---------------------------------------->	
	<cffunction name="getResourceLibraryManager" access="public" returntype="resourceLibraryManager">
		<cfreturn variables.oResourceLibraryManager>
	</cffunction> 




	<!---------------------------------------->
	<!--- getResourcesByType         --->
	<!---------------------------------------->	
	<cffunction name="getResourcesByType" access="public" returntype="query" output="False" hint="Returns all resources of a given type">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource">
		<cfargument name="resLibPath" type="string" required="false" default="" hint="Restricts the resources to a single resource library">

		<cfset var qry = queryNew("")>
		
		<cfif not StructKeyExists(variables.mapResources, arguments.resourceType)>
			<cfset loadResourcesByType(arguments.resourceType)>
		</cfif>
		
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM variables.qryResources
				WHERE type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.resourceType#">
					<cfif resLibPath neq "">
						AND libpath = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.resLibPath#"> 
					</cfif>
		</cfquery>
		
		<cfreturn qry>
	</cffunction>
		
	<!---------------------------------------->
	<!--- getResourceNode				   --->
	<!---------------------------------------->	
	<cffunction name="getResourceNode" access="public" returntype="any" hint="Returns the tree node for a given resource on this catalog">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource">
		<cfargument name="resourceID" type="string" required="true" hint="Path to the resource.">
		<cfargument name="forceReload" type="boolean" required="false" default="false" hint="forces a reload of the resource, ignoring any cached instance">
		
		<cfscript>
			var stResourceInfo = structNew();
			var oResBean = 0;
			var cacheKey = "";
			
			// Make sure the resourceID does not have any XML escaped characters
			arguments.resourceID = XMLUnformat(arguments.resourceID);

			// check if the resource type has been loaded and that the requested resource is in memory,
			// if not, then load the resource type to memory
			if(not StructKeyExists(variables.mapResources, arguments.resourceType)
				or not StructKeyExists(variables.mapResources[arguments.resourceType], arguments.resourceID)) {
				loadResourcesByType(arguments.resourceType);
			}

			// check again if the resource has been loaded to memory
			if(StructKeyExists(variables.mapResources, arguments.resourceType)
				and StructKeyExists(variables.mapResources[arguments.resourceType], arguments.resourceID)) {
				stResourceInfo = variables.mapResources[arguments.resourceType][arguments.resourceID];
			} else {
				// reload package from file system
				throw("Resource [#arguments.resourceID#] of type [#arguments.resourceType#] does not exist", "homePortals.catalog.resourceNotFound");
			}
			
			// if the cache for the catalog has been enabled, then first check if the resource is already cached
			if(hasCacheService()) {

				// generate a key for the cache entry
				cacheKey = "//" & arguments.resourceType & "/" & stResourceInfo.package & "/" & arguments.resourceID;
				
				try {
					// if we are forcing a reload, then we make it look like it wasnt in the cache
					if(forceReload) throw("","homePortals.cacheService.itemNotFound");
					
					// read from cache
					oResBean = getCacheService().retrieve(cacheKey);
				
				} catch(homePortals.cacheService.itemNotFound e) {
					// read from source
					oResBean = getResourceLibraryManager().getResource(arguments.resourceType, stResourceInfo.package, arguments.resourceID);
					
					// update cache
					getCacheService().store(cacheKey, oResBean);
				}
			
			} else {
				// not using catalog cache, so just read the resource from the library
				oResBean = getResourceLibraryManager().getResource(arguments.resourceType, stResourceInfo.package, arguments.resourceID);
			}
			
			return oResBean;
		</cfscript>
	</cffunction>	

	<!---------------------------------------->
	<!--- deleteResourceNode			   --->
	<!---------------------------------------->	
	<cffunction name="deleteResourceNode" access="public" returntype="any" hint="Deletes the given resource node on this catalog">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource">
		<cfargument name="resourceID" type="string" required="true" hint="ID of the resource">

		<cfif StructKeyExists(variables.mapResources, arguments.resourceType) and
				StructKeyExists(variables.mapResources[arguments.resourceType], arguments.resourceID)>
			<cfset structDelete(variables.mapResources[arguments.resourceType], arguments.resourceID)>
			<cfset populateResourcesQuery()>
		</cfif>
	</cffunction>		

	<!---------------------------------------->
	<!--- index							   --->
	<!---------------------------------------->	
	<cffunction name="index" access="public" returntype="void" hint="Crawls the resource library indexing all available resources. Depending on the amount of resources this operation may take some time to complete">
		<cfscript>
			var i = 1;
			var oResourceLibrary = 0;
			var aResources = arrayNew(1);

			// clear the catalog
			variables.mapResources = structNew();
			variables.qryResources = QueryNew("type,id,href,package,description,libPath");

			// create an instance of the resourceLibrary object
			oResourceLibrary = getResourceLibraryManager();
			
			aTypes = oResourceLibrary.getResourceTypes();
			
			for(i=1;i lte arrayLen(aTypes);i=i+1) {
				loadResourcesByType(aTypes[i]);
			}	
			
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- getResources				         --->
	<!---------------------------------------->	
	<cffunction name="getResources" access="public" returntype="query" output="False" hint="Returns all resources currently indexed. To obtain a complete list of all resources in the library you must first call the index() method in this component or use the methods in the ResourceLibrary component">
		<cfreturn variables.qryResources>
	</cffunction>
		
	<!---------------------------------------->
	<!--- reloadPackage				       --->
	<!---------------------------------------->	
	<cffunction name="reloadPackage" access="public" returntype="void" hint="Reloads all resources of the given type in the given package">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		
		<cfscript>
			var aResources = arrayNew(1);
			var j = 0;
			var stResourceBean = structNew();
			var resTypeGroup = "";
			var oResourceLibrary = 0;
			var st = structNew();

			// create an instance of the resourceLibrary object
			oResourceLibrary = getResourceLibraryManager();

			// get all resources on the current package
			aResources = oResourceLibrary.getResourcesInPackage(arguments.resourceType, arguments.packageName);
			
			// update resource map
			for(j=1;j lte arrayLen(aResources);j=j+1) {
				stResourceBean = aResources[j].getMemento();
				resTypeGroup = stResourceBean.type;

				// create node for resource type group if doesnt exist
				if(Not StructKeyExists(variables.mapResources, resTypeGroup)) {
					variables.mapResources[resTypeGroup] = structNew();
				}

				// create resource map entry
				st = structNew();
				st.type = stResourceBean.type;
				st.id = stResourceBean.id;
				st.HREF = stResourceBean.HREF;
				st.Package = stResourceBean.Package;
				st.Description = stResourceBean.Description;
				st.libpath = stResourceBean.resourceLibrary.getPath();

				// add resource to map
				variables.mapResources[resTypeGroup][stResourceBean.id] = duplicate(st);
			}

			// recreate query of resources
			populateResourcesQuery();		
		</cfscript>
		
	</cffunction>


	<!--- * * * *     P R I V A T E     M E T H O D S   * * * * 	   --->

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
			
			variables.qryResources = QueryNew("type,id,href,package,description,libpath");
			
			for(resType in variables.mapResources) {
			
				for(resID in variables.mapResources[resType]) {
					
					stResourceBean = variables.mapResources[resType][resID];
					
					queryAddRow(variables.qryResources);
					querySetCell(variables.qryResources, "type", resType);
					querySetCell(variables.qryResources, "id", resID);
					querySetCell(variables.qryResources, "href", stResourceBean.HREF);
					querySetCell(variables.qryResources, "package", stResourceBean.Package);
					querySetCell(variables.qryResources, "description", stResourceBean.Description);
					querySetCell(variables.qryResources, "libpath", stResourceBean.libpath);			
				}
	
			}
			variables.stTimers.populateResourcesQuery = getTickCount()-start;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- loadResourcesByType			   --->
	<!---------------------------------------->	
	<cffunction name="loadResourcesByType" access="private" returntype="void" hint="loads into memory all resources of the given type">
		<cfargument name="resourceType" type="string" required="false" default="">
		<cfscript>
			var qry = QueryNew("");
			var i = 1; var j = 0;
			var oResourceLibrary = 0;
			var aResources = arrayNew(1);
			var stResourceBean = structNew();
			var st = structNew();

			// create an instance of the resourceLibrary object
			oResourceLibrary = getResourceLibraryManager();

			// clear existing map for this resource type
			variables.mapResources[arguments.resourceType] = structNew();
			
			// get list of resource packages
			qry = oResourceLibrary.getResourcePackagesList(arguments.resourceType);

			// add resources to the catalog
			for(i=1;i lte qry.recordCount;i=i+1) {
				// get all resources on the current package
				aResources = oResourceLibrary.getResourcesInPackage(qry.resType[i], qry.name[i]);

				// store the resources in a map
				for(j=1;j lte arrayLen(aResources);j=j+1) {
					stResourceBean = aResources[j].getMemento();
					resTypeGroup = stResourceBean.type;

					// add resource to resources query
					queryAddRow(variables.qryResources);
					querySetCell(variables.qryResources, "type", stResourceBean.type);
					querySetCell(variables.qryResources, "id", stResourceBean.id);
					querySetCell(variables.qryResources, "href", stResourceBean.HREF);
					querySetCell(variables.qryResources, "package", stResourceBean.Package);
					querySetCell(variables.qryResources, "description", stResourceBean.Description);					
					querySetCell(variables.qryResources, "libpath", stResourceBean.resourceLibrary.getPath());					
					
					// create resource map entry
					st = structNew();
					st.type = stResourceBean.type;
					st.id = stResourceBean.id;
					st.HREF = stResourceBean.HREF;
					st.Package = stResourceBean.Package;
					st.Description = stResourceBean.Description;
					st.libpath = stResourceBean.resourceLibrary.getPath();

					// create node for resource type group if doesnt exist
					if(Not StructKeyExists(variables.mapResources, resTypeGroup)) {
						variables.mapResources[resTypeGroup] = structNew();
					}

					// add resource to map
					variables.mapResources[resTypeGroup][stResourceBean.id] = duplicate(st);
				}
			}

			// recreate query of resources
			populateResourcesQuery();		
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- hasCacheService				   --->
	<!---------------------------------------->	
	<cffunction name="hasCacheService" access="private" returntype="boolean" hint="Checks whether the cache for the catalog has been registered">
		<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
		<cfreturn oCacheRegistry.isRegistered(variables.cacheServiceName)>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getCacheService				   --->
	<!---------------------------------------->	
	<cffunction name="getCacheService" access="private" returntype="cacheService" hint="Retrieves a cacheService instance used for caching resources in the catalog">
		<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
		<cfreturn oCacheRegistry.getCache(variables.cacheServiceName)>
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

	<cffunction name="XMLUnformat" access="private" returntype="string">
		<cfargument name="string" type="string" default="">
		<cfscript>
			var resultString=arguments.string;
			resultString=ReplaceNoCase(resultString,"&apos;","'","ALL");
			resultString=ReplaceNoCase(resultString,"&quot;","""","ALL");
			resultString=ReplaceNoCase(resultString,"&lt;","<","ALL");
			resultString=ReplaceNoCase(resultString,"&gt;",">","ALL");
			resultString=ReplaceNoCase(resultString,"&amp;","&","ALL");
		</cfscript>
		<cfreturn resultString>
	</cffunction>				
</cfcomponent>