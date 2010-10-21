<cfinterface hint="Describes a component that is used to represent a collection of resources. Each implementation of a resource library defines the actual storage mechanism for the resources.">

	<!------------------------------------------------->
	<!--- init				                	   ---->
	<!------------------------------------------------->
	<cffunction name="init" returntype="homePortals.components.resourceLibrary" access="public" hint="This is the constructor">
		<cfargument name="resourceLibraryPath" type="string" required="true">
		<cfargument name="resourceTypeRegistry" type="homePortals.components.resourceTypeRegistry" required="true">
		<cfargument name="configStruct" type="struct" required="true">
		<cfargument name="appRoot" type="string" required="false" default="">
	</cffunction>

	<!------------------------------------------------->
	<!--- getResourceTypeRegistry              	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypeRegistry" access="public" returntype="homePortals.components.resourceTypeRegistry" hint="returns a reference to the registry for resource types">
	</cffunction>

	<!---------------------------------------->
	<!--- getResourcePackagesList		   --->
	<!---------------------------------------->	
	<cffunction name="getResourcePackagesList" returntype="query" access="public" hint="returns a query with the names of all resource packages">
		<cfargument name="resourceType" type="string" required="false" default="">
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResourcesInPackage                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourcesInPackage" access="public" returntype="Array" hint="returns all resources on a package">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResource		                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResource" access="public" returntype="homePortals.components.resourceBean" hint="returns the resource bean for the given resource">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfargument name="resourceID" type="string" required="true">
	</cffunction>

	<!------------------------------------------------->
	<!--- saveResource	                       	   ---->
	<!------------------------------------------------->
	<cffunction name="saveResource" access="public" returntype="void" hint="Adds or updates a resource in the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true" hint="the resource to add or update"> 		
	</cffunction>

	<!------------------------------------------------->
	<!--- deleteResource	                       ---->
	<!------------------------------------------------->
	<cffunction name="deleteResource" access="public" returntype="void" hint="Removes a resource from the library. If the resource has a related file then the file is deleted">
		<cfargument name="ID" type="string" required="true">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="package" type="string" required="true">
	</cffunction>	

	<!------------------------------------------------->
	<!--- getNewResource	                       ---->
	<!------------------------------------------------->
	<cffunction name="getNewResource" access="public" returntype="homePortals.components.resourceBean" hint="creates a new empty instance of a given resource type for this library">
		<cfargument name="resourceType" type="string" required="true">
	</cffunction>

	<!------------------------------------------------->
	<!--- getPath			                	   ---->
	<!------------------------------------------------->
	<cffunction name="getPath" access="public" returntype="string" hint="returns the path for this library">
	</cffunction>
	

	<!------------------------------------------------->
	<!--- Resource (Target) File Operations   	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceFileHREF" access="public" returntype="string" hint="returns the full (web accessible) path to a file object on the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
	</cffunction>

	<cffunction name="getResourceFilePath" access="public" returntype="string" hint="If the object can be reached through the file system, then returns the absolute path on the file system to a file object on the library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
	</cffunction>
	
	<cffunction name="resourceFileExists" access="public" output="false" returntype="boolean" hint="Returns whether the file associated with a resource exists on the local file system or not.">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
	</cffunction>
	
	<cffunction name="readResourceFile" access="public" output="false" returntype="any" hint="Reads the file associated with a resource. If there is no associated file then returns a missingTargetFile error. This only works for target files stored within the resource library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfargument name="readAsBinary" type="boolean" required="false" default="false" hint="Reads the file as a binary document">
	</cffunction>
	
	<cffunction name="saveResourceFile" access="public" output="false" returntype="void" hint="Saves a file associated to this resource">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfargument name="fileContent" type="any" required="true" hint="File contents">
		<cfargument name="fileName" type="string" required="false" hint="filename to use" default="">
		<cfargument name="contentType" type="string" required="false" hint="MIME content type of the resource file" default="">
	</cffunction>

	<cffunction name="addResourceFile" access="public" output="false" returntype="void" hint="Copies an existing file to the resource library">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
		<cfargument name="filePath" type="string" required="true" hint="absolute location of the file">
		<cfargument name="fileName" type="string" required="false" hint="filename to use" default="">
		<cfargument name="contentType" type="string" required="false" hint="MIME content type of the resource file" default="">
	</cffunction>

	<cffunction name="deleteResourceFile" access="public" output="false" returntype="void" hint="Deletes the file associated with a resource">
		<cfargument name="resourceBean" type="homePortals.components.resourceBean" required="true"> 
	</cffunction>

</cfinterface>