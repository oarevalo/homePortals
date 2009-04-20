<cfcomponent hint="This manages and controls access to multiple resource libraries on an application">

	<cfscript>
		variables.stResourceTypes = structNew();
		variables.aResourceLibs = createObject("java","java.util.Collections")
										.synchronizedList( 
											createObject("java","java.util.ArrayList").init() 
										);
	</cfscript>

	<!------------------------------------------------->
	<!--- init				                	   ---->
	<!------------------------------------------------->
	<cffunction name="init" returntype="resourceLibraryManager" access="public" hint="This is the constructor">
		<cfargument name="config" type="homePortalsConfigBean" required="true">
		<cfscript>
			var i = 0;
			var oResLib = 0;
			var oResType = 0;
			var stResTypes = arguments.config.getResourceTypes();
			var aResLibs = arguments.config.getResourceLibraryPaths();

			// create and register the resource library instances
			for(i=1;i lte arrayLen(aResLibs);i=i+1) {
				oResLib = createObject("component","resourceLibrary").init( aResLibs[i] );
				addResourceLibrary( oResLib );
			}

			// register the resource types into all libraries
			for(i in stResTypes) {
				oResType = createObject("component","resourceType").init();
				
				if(structKeyExists(stResTypes[i],"name")) oResType.setName( stResTypes[i].name );
				if(structKeyExists(stResTypes[i],"description")) oResType.setDescription( stResTypes[i].description );
				if(structKeyExists(stResTypes[i],"folderName")) oResType.setFolderName( stResTypes[i].folderName );
				if(structKeyExists(stResTypes[i],"resBeanPath")) oResType.setResBeanPath( stResTypes[i].resBeanPath );
				if(structKeyExists(stResTypes[i],"fileTypes")) oResType.setFileTypes( stResTypes[i].fileTypes );
				
				for(j=1;j lte arrayLen(stResTypes[i].properties);j=j+1) {
					oResType.setProperty(argumentCollection = stResTypes[i].properties[j]);
				}

				registerResourceType(oResType);
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
		<cfset reRegisterResourceTypes()>
	</cffunction>

	<!------------------------------------------------->
	<!--- registerResourceLibraryPath          	   ---->
	<!------------------------------------------------->
	<cffunction name="registerResourceLibraryPath" access="public" returntype="void">
		<cfargument name="resLibPath" type="string" required="true">
		<cfset var oResLib = createObject("component","resourceLibrary").init( arguments.resLibPath )>
		<cfset addResourceLibrary( oResLib )>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- registerResourceType                	   ---->
	<!------------------------------------------------->
	<cffunction name="registerResourceType" access="public" returntype="void">
		<cfargument name="resType" type="resourceType" required="true">
		<cfset variables.stResourceTypes[arguments.resType.getName()] = resType>
		<cfloop from="1" to="#arrayLen(variables.aResourceLibs)#" index="i">
			<cfset variables.aResourceLibs[i].registerResourceType(arguments.resType)>
		</cfloop>
	</cffunction>

	<!------------------------------------------------->
	<!--- reRegisterResourceTypes                  ---->
	<!------------------------------------------------->
	<cffunction name="reRegisterResourceTypes" access="public" returntype="void" hint="registers again all defined resource types with all libraries.">
		<cfset var res = "">

		<cfloop from="1" to="#arrayLen(variables.aResourceLibs)#" index="i">
			<cfloop collection="#variables.stResourceTypes#" item="res">
				<cfset variables.aResourceLibs[i].registerResourceType(variables.stResourceTypes[res])>
			</cfloop>
		</cfloop>
	</cffunction>


	<!------------------------------------------------->
	<!--- getResourceTypes	                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypes" access="public" returntype="array" hint="returns an array with the allowed resource types">
		<cfreturn listToArray(structKeyList(variables.stResourceTypes))>
	</cffunction>

	<!------------------------------------------------->
	<!--- getResourceTypesInfo                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypesInfo" access="public" returntype="struct" hint="returns an array of resourceType objects with details on the registered resource types">
		<cfreturn variables.stResourceTypes>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResourceTypeInfo                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypeInfo" access="public" returntype="resourceType" hint="returns a resourceType object with details on the requested resource type">
		<cfargument name="resourceType" type="string" required="true">
		<cfreturn variables.stResourceTypes[arguments.resourceType]>
	</cffunction>
		
	<!------------------------------------------------->
	<!--- hasResourceType	                	   ---->
	<!------------------------------------------------->
	<cffunction name="hasResourceType" access="public" returntype="boolean" hint="checks whether a given resource types is supported">
		<cfargument name="resourceType" type="string" required="true">
		<cfreturn structKeyExists(variables.stResourceTypes,arguments.resourceType)>
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
		
		<cfif right(arguments.resLibPath neq "/")>
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
		<cfset var qryFull = queryNew("ResType,Name")>
		<cfset var qry = 0>
		
		<cfloop from="1" to="#arrayLen(aResLibs)#" index="i">
			<cfif arguments.resourceType eq "" or aResLibs[i].hasResourceType(arguments.resourceType)>
				<cfset qry = aResLibs[i].getResourcePackagesList(arguments.resourceType)>
				<cfloop query="qry">
					<cfset queryAddRow(qryFull)>
					<cfset querySetCell(qryFull,"resType",qry.resType)>
					<cfset querySetCell(qryFull,"name",qry.name)>
				</cfloop>
			</cfif>
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
		
		<cfloop from="1" to="#arrayLen(aResLibs)#" index="i">
			<cfif aResLibs[i].hasResourceType(arguments.resourceType)>
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
		
		<cfloop from="1" to="#arrayLen(aResLibs)#" index="i">
			<cfif aResLibs[i].hasResourceType(arguments.resourceType)>
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
			<cfelseif i eq arrayLen(aResLibs)>
				<cfthrow message="Resource type [#arguments.resourceType#] not found on any of the registered resource libraries. Available resources are: #structKeyList(variables.stResourceTypes)#"
						 type="homePortals.resourceLibraryManager.resourceTypeNotFound">
			</cfif>
		</cfloop>
	</cffunction>

	
	

</cfcomponent>