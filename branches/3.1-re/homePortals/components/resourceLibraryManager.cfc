<cfcomponent hint="This manages and controls access to multiple resource libraries on an application">

	<cfscript>
		variables.resourceTypeRegistry = 0;
		variables.aResourceLibs = createObject("java","java.util.Collections")
										.synchronizedList( 
											createObject("java","java.util.ArrayList").init() 
										);
		variables.defaultResourceLibraryClass = "defaultResourceLibrary";
	</cfscript>

	<!------------------------------------------------->
	<!--- init				                	   ---->
	<!------------------------------------------------->
	<cffunction name="init" returntype="resourceLibraryManager" access="public" hint="This is the constructor">
		<cfargument name="config" type="homePortalsConfigBean" required="true">
		<cfscript>
			var i = 0;
			var oResLib = 0;
			var aResLibs = arguments.config.getResourceLibraryPaths();
			var resLibClass = "";

			// create and populate the resourceTypeRegistry
			variables.resourceTypeRegistry = createObject("component","resourceTypeRegistry").init( arguments.config );

			// create and register the resource library instances
			for(i=1;i lte arrayLen(aResLibs);i=i+1) {
				registerResourceLibraryPath( aResLibs[i] );
			}
			
			return this;
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- addResourceLibrary                	   ---->
	<!------------------------------------------------->
	<cffunction name="addResourceLibrary" access="public" returntype="void">
		<cfargument name="resLib" type="resourceLibrary" required="true">
		<cfset arrayAppend(variables.aResourceLibs, arguments.resLib)>
	</cffunction>

	<!------------------------------------------------->
	<!--- registerResourceLibraryPath          	   ---->
	<!------------------------------------------------->
	<cffunction name="registerResourceLibraryPath" access="public" returntype="void">
		<cfargument name="resLibPath" type="string" required="true">
		<cfset var resLibClass = getResourceLibraryClassByPath( arguments.resLibPath )>
		<cfset var oResLib = createObject("component",resLibClass).init( arguments.resLibPath, variables.resourceTypeRegistry )>
		<cfset addResourceLibrary( oResLib )>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResourceLibraries               	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceLibraries" access="public" returntype="array" hint="returns an array with the registered resource libraries">
		<cfreturn variables.aResourceLibs>
	</cffunction>	

	<!------------------------------------------------->
	<!--- getResourceLibrary	               	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceLibrary" access="public" returntype="resourceLibrary" hint="returns the resource library object for the given path">
		<cfargument name="resLibPath" type="string" required="true">
		
		<cfif right(arguments.resLibPath,1) neq "/">
			<cfset arguments.resLibPath = arguments.resLibPath & "/">
		</cfif>
		
		<cfloop from="1" to="#arrayLen(variables.aResourceLibs)#" index="i">
			<cfif variables.aResourceLibs[i].getPath() eq arguments.resLibPath or
					variables.aResourceLibs[i].getPath() & "/" eq arguments.resLibPath>
				<cfreturn variables.aResourceLibs[i]>	
			</cfif>
		</cfloop>
		<cfthrow message="Resource library not found" type="homePortals.resourceLibraryManager.resourceLibraryNotFound">
	</cffunction>	
	

	<!---------------------------------------->
	<!--- getResourcePackagesList		   --->
	<!---------------------------------------->	
	<cffunction name="getResourcePackagesList" returntype="query" access="public" hint="returns a query with the names of all resource packages">
		<cfargument name="resourceType" type="string" required="false" default="">
		<cfset var aResLibs = getResourceLibraries()>
		<cfset var reg = getResourceTypeRegistry()>
		<cfset var qryFull = queryNew("ResType,Name")>
		<cfset var qry = 0>
		<cfset var i = 0>
		
		<cfif arguments.resourceType neq "" and not reg.hasResourceType(arguments.resourceType)>
			<cfthrow message="Unknown resource type [#arguments.resourceType#]" type="homePortals.resourceLibraryManager.resourceTypeNotFound">
		</cfif>
		
		<cfloop from="1" to="#arrayLen(aResLibs)#" index="i">
			<cfset qry = aResLibs[i].getResourcePackagesList(arguments.resourceType)>
			<cfloop query="qry">
				<cfset queryAddRow(qryFull)>
				<cfset querySetCell(qryFull,"resType",qry.resType)>
				<cfset querySetCell(qryFull,"name",qry.name)>
			</cfloop>
		</cfloop>

		<cfreturn qryFull>
	</cffunction>	


	<!------------------------------------------------->
	<!--- getResourcesInPackage                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourcesInPackage" access="public" returntype="Array" hint="returns all resources on a package">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfset var aResLibs = getResourceLibraries()>
		<cfset var aResFull = ArrayNew(1)>
		<cfset var aRes = ArrayNew(1)>
		<cfset var i = 0>
		<cfset var j = 0>
		<cfset qryPackages = 0>

		<cfif not getResourceTypeRegistry().hasResourceType(arguments.resourceType)>
			<cfthrow message="Unknown resource type [#arguments.resourceType#]" type="homePortals.resourceLibraryManager.resourceTypeNotFound">
		</cfif>
		
		<cfloop from="1" to="#arrayLen(aResLibs)#" index="i">
			<cfset qryPackages = aResLibs[i].getResourcePackagesList(arguments.resourceType)>
			<cfif listFind(valueList(qryPackages.name), arguments.packageName)>
				<cfset aRes = aResLibs[i].getResourcesInPackage(arguments.resourceType, arguments.packageName)>
				<cfloop from="1" to="#arrayLen(aRes)#" index="j">
					<cfset arrayAppend(aResFull,aRes[j])>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn aResFull>
	</cffunction>


	<!------------------------------------------------->
	<!--- getResource		                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResource" access="public" returntype="resourceBean" hint="returns the resource bean for the given resource">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfargument name="resourceID" type="string" required="true">
		<cfset var aResLibs = getResourceLibraries()>
		<cfset var resBean = 0>
		<cfset var i = 0>
	
		<cfif not getResourceTypeRegistry().hasResourceType(arguments.resourceType)>
			<cfthrow message="Unknown resource type [#arguments.resourceType#]" type="homePortals.resourceLibraryManager.resourceTypeNotFound">
		</cfif>
	
		<cfloop from="1" to="#arrayLen(aResLibs)#" index="i">
			<cftry>
				<cfset resBean = aResLibs[i].getResource(resourceType = arguments.resourceType,
														packageName = arguments.packageName,
														resourceID = arguments.resourceID)>
				
				<!--- if we didnt get an error, then it means that the resource was found,
					so lets return that one --->
				<cfreturn resBean>

				<cfcatch type="homePortals.resourceLibrary.resourceNotFound">
					<cfif i eq arrayLen(aResLibs)>
						<!--- we are at the end of the libraries, so the resource is not in any of them --->
						<cfrethrow>
					<cfelse>
						<!--- resource not here, keep looking --->
					</cfif>
				</cfcatch>
			</cftry>
		</cfloop>
	</cffunction>

	<!------------------------------------------------->
	<!--- getResourceLibraryClassByPath        	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceLibraryClassByPath" access="private" returntype="string" hint="returns the cfc name of the resource library that corresponds to a given path">
		<cfargument name="path" type="string" required="true">
		<cfscript>
			var name = variables.defaultResourceLibraryClass;
			if(find("://",arguments.path)) {
				name = left(arguments.path,find("://",arguments.path)-1) & "ResourceLibrary";
			}
			return name;
		</cfscript>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResourceTypeRegistry             	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypeRegistry" access="public" returntype="resourceTypeRegistry" hint="Returns the registry object for resourceType information">
		<cfreturn variables.resourceTypeRegistry>
	</cffunction>

	<!------------------------------------------------->
	<!--- setResourceTypeRegistry             	   ---->
	<!------------------------------------------------->
	<cffunction name="setResourceTypeRegistry" access="public" returntype="void" hint="sets the resourceTypeRegistry property">
		<cfargument name="data" type="resourceTypeRegistry" required="true">
		<cfset variables.resourceTypeRegistry = arguments.data>
	</cffunction>

	<!------------------------------------------------->
	<!--- registerResourceType                	   ---->
	<!------------------------------------------------->
	<cffunction name="registerResourceType" access="public" returntype="void">
		<cfargument name="resType" type="resourceType" required="true">
		<cfset getResourceTypeRegistry().registerResourceType(arguments.resType)>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResourceTypes	                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypes" access="public" returntype="array" hint="returns an array with the allowed resource types">
		<cfreturn getResourceTypeRegistry().getResourceTypes()>
	</cffunction>

	<!------------------------------------------------->
	<!--- getResourceTypesInfo                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypesInfo" access="public" returntype="struct" hint="returns an array of resourceType objects with details on the registered resource types">
		<cfreturn getResourceTypeRegistry().getResourceTypesMap()>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResourceTypeInfo                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypeInfo" access="public" returntype="resourceType" hint="returns a resourceType object with details on the requested resource type">
		<cfargument name="resourceType" type="string" required="true">
		<cfreturn getResourceTypeRegistry().getResourceType(arguments.resourceType)>
	</cffunction>
		
	<!------------------------------------------------->
	<!--- hasResourceType	                	   ---->
	<!------------------------------------------------->
	<cffunction name="hasResourceType" access="public" returntype="boolean" hint="checks whether a given resource types is supported">
		<cfargument name="resourceType" type="string" required="true">
		<cfreturn getResourceTypeRegistry().hasResourceType(arguments.resourceType)>
	</cffunction>


</cfcomponent>