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

		<cfset var i = 0>
		<cfset var oResLib = 0>
		<cfset var stResTypes = arguments.config.getResourceTypes()>
		<cfset var aResLibs = arguments.config.getResourceLibraryPaths()>

		<cfloop from="1" to="#arrayLen(aResLibs)#" index="i">
			<cfset oResLib = createObject("component","resourceLibrary").init( aResLibs[i] )>
			<cfset addResourceLibrary( oResLib )>
		</cfloop>
		
		<cfloop collection="#stResTypes#" item="i">
			<cfset registerResourceType(i, stResTypes[i])>
		</cfloop>
		
		<cfreturn this>
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
		<cfset var oResLib = createObject("component","resourceLibrary").init( arguments.resLibPath )>
		<cfset addResourceLibrary( oResLib )>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- registerResourceType                	   ---->
	<!------------------------------------------------->
	<cffunction name="registerResourceType" access="public" returntype="void">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="folderName" type="string" required="true">
		<cfargument name="defaultExtension" type="string" required="true">
		<cfargument name="autoIndexExtensions" type="string" required="true">
		<cfargument name="customProperties" type="string" required="true">
		<cfargument name="resBeanPath" type="string" required="true">
		<cfset variables.stResourceTypes[arguments.resourceType] = arguments.resourceExtension>
		<cfloop from="1" to="#arrayLen(variables.aResourceLibs)#" index="i">
			<cfset variables.aResourceLibs[i].registerResourceType(arguments.resourceType, arguments.resourceExtension)>
		</cfloop>
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

	<!------------------------------------------------->
	<!--- getResourceLibraries               	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceLibraries" access="public" returntype="array" hint="returns an array with the registered resource libraries">
		<cfreturn aResourceLibs>
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
			<cfif aResLibs[i].hasResourceType(arguments.resourceType)>
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