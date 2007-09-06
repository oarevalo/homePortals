<cfcomponent name="catalog" hint="This object provides access to the catalog of reusable resources for the HomePortals application.">

	<cfscript>
		variables.resourcesRoot = "";
		variables.qryResources = QueryNew("type,id,access,name,href,package,owner,description,infoHREF");
		variables.stTimers = structNew();
		variables.mapResources = structNew();
	</cfscript>
	
	<!---------------------------------------->
	<!--- init					           --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="catalog">
		<cfargument name="resourceLibraryPath" type="string" required="true">
		<cfscript>
			var start = getTickCount();
			variables.resourcesRoot = arguments.resourceLibraryPath;
		
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
		
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM variables.qryResources
				WHERE type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.resourceType#">
		</cfquery>
		
		<cfreturn qry>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getModuleByName				   --->
	<!---------------------------------------->	
	<cffunction name="getModuleByName" access="public" returntype="any" hint="Returns the tree node for a given resource on this catalog">
		<cfargument name="moduleName" type="string" required="true" hint="Name of the module">
		<cfscript>
			var qry = 0;
			var item = "";
			var stResourceInfo = structNew();
			
			for(item in variables.mapResources.module) {
				stResourceInfo = variables.mapResources.module[item];
				if(stResourceInfo.name eq arguments.moduleName) {
					return getResourceNode("module", stResourceInfo.id);
				}
			}
		</cfscript>
		<cfthrow message="Resource [#arguments.moduleName#] not found" type="homePortals.catalog.resourceNotFound">
	</cffunction>	
	
	<!---------------------------------------->
	<!--- getResourceNode				   --->
	<!---------------------------------------->	
	<cffunction name="getResourceNode" access="public" returntype="any" hint="Returns the tree node for a given resource on this catalog">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource">
		<cfargument name="resourceID" type="string" required="true" hint="ID of the resource">
		
		<cfset var stResourceInfo = structNew()>
		<cfset var oResourceLibrary = 0>

		<cfif StructKeyExists(variables.mapResources[arguments.resourceType], arguments.resourceID)>
			<cfscript>
				// create an instance of the resourceLibrary object
				oResourceLibrary = createObject("component","resourceLibrary");
				oResourceLibrary.init(variables.resourcesRoot);
				
				// get the resource info
				stResourceInfo = variables.mapResources[arguments.resourceType][arguments.resourceID];

				// find the requested resource
				return oResourceLibrary.getResource(arguments.resourceType, stResourceInfo.package, arguments.resourceID, stResourceInfo.infoHREF);
			</cfscript>
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
		<cfif StructKeyExists(variables.mapResources[arguments.resourceType], arguments.resourceID)>
			<cfset structDelete(variables.mapResources[arguments.resourceType], arguments.resourceID)>
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
			var i = 1; var j = 0;
			var start = getTickCount();
			var oResourceLibrary = 0;
			var aResources = arrayNew(1);
			var stResourceBean = structNew();
			var st = structNew();

			// clear the catalog
			variables.mapResources = structNew();
			variables.qryResources = QueryNew("type,id,access,name,href,package,owner,description,infoHREF");

			// create an instance of the resourceLibrary object
			oResourceLibrary = createObject("component","resourceLibrary");
			oResourceLibrary.init(variables.resourcesRoot);
			
			// get list of resource packages
			qry = oResourceLibrary.getResourcePackagesList();

			// add resources to the catalog
			start = getTickCount();
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
					querySetCell(variables.qryResources, "access", stResourceBean.AccessType);
					querySetCell(variables.qryResources, "name", stResourceBean.Name);
					querySetCell(variables.qryResources, "href", stResourceBean.HREF);
					querySetCell(variables.qryResources, "package", stResourceBean.Package);
					querySetCell(variables.qryResources, "owner", stResourceBean.Owner);
					querySetCell(variables.qryResources, "description", stResourceBean.Description);					
					querySetCell(variables.qryResources, "infoHREF", stResourceBean.infoHREF);					
					
					// create resource map entry
					st = structNew();
					st.type = stResourceBean.type;
					st.id = stResourceBean.id;
					st.access = stResourceBean.AccessType;
					st.name = stResourceBean.name;
					st.HREF = stResourceBean.HREF;
					st.Package = stResourceBean.Package;
					st.Owner = stResourceBean.Owner;
					st.Description = stResourceBean.Description;
					st.infoHREF = stResourceBean.infoHREF;

					// create node for resource type group if doesnt exist
					if(Not StructKeyExists(variables.mapResources, resTypeGroup)) {
						variables.mapResources[resTypeGroup] = structNew();
					}

					// add resource to map
					variables.mapResources[resTypeGroup][stResourceBean.id] = duplicate(st);
						
				}
			}		
			
			variables.stTimers.rebuildCatalog = getTickCount()-start;
		</cfscript>
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
			var aResources = arrayNew(1);
			var j = 0;
			var stResourceBean = structNew();
			var resTypeGroup = "";
			var oResourceLibrary = 0;
			var st = structNew();

			// create an instance of the resourceLibrary object
			oResourceLibrary = createObject("component","resourceLibrary");
			oResourceLibrary.init(variables.resourcesRoot);

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
				st.access = stResourceBean.accessType;
				st.name = stResourceBean.name;
				st.HREF = stResourceBean.HREF;
				st.Package = stResourceBean.Package;
				st.Owner = stResourceBean.Owner;
				st.Description = stResourceBean.Description;
				st.infoHREF = stResourceBean.infoHREF;

				// add resource to map
				variables.mapResources[resTypeGroup][stResourceBean.id] = duplicate(st);
			}

			// recreate query of resources
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
			
			variables.qryResources = QueryNew("type,id,access,name,href,package,owner,description,infoHREF");
			
			for(resType in variables.mapResources) {
			
				for(resID in variables.mapResources[resType]) {
					
					stResourceBean = variables.mapResources[resType][resID];
					
					queryAddRow(variables.qryResources);
					querySetCell(variables.qryResources, "type", resType);
					querySetCell(variables.qryResources, "id", resID);
					querySetCell(variables.qryResources, "access", stResourceBean.access);
					querySetCell(variables.qryResources, "name", stResourceBean.Name);
					querySetCell(variables.qryResources, "href", stResourceBean.HREF);
					querySetCell(variables.qryResources, "package", stResourceBean.Package);
					querySetCell(variables.qryResources, "owner", stResourceBean.Owner);
					querySetCell(variables.qryResources, "description", stResourceBean.Description);
					querySetCell(variables.qryResources, "infoHREF", stResourceBean.infoHREF);
				
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