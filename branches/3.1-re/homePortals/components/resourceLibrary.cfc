<cfinterface>

	<!------------------------------------------------->
	<!--- init				                	   ---->
	<!------------------------------------------------->
	<cffunction name="init" returntype="resourceLibrary" access="public" hint="This is the constructor">
		<cfargument name="resourceLibraryPath" type="string" required="true">
		<cfargument name="resourceTypeRegistry" type="resourceTypeRegistry" required="true">
	</cffunction>

	<!------------------------------------------------->
	<!--- getResourceTypeRegistry              	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypeRegistry" access="public" returntype="resourceTypeRegistry" hint="returns a reference to the registry for resource types">
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
	<cffunction name="getResource" access="public" returntype="resourceBean" hint="returns the resource bean for the given resource">
		<cfargument name="resourceType" type="string" required="true">
		<cfargument name="packageName" type="string" required="true">
		<cfargument name="resourceID" type="string" required="true">
	</cffunction>

	<!------------------------------------------------->
	<!--- saveResource	                       	   ---->
	<!------------------------------------------------->
	<cffunction name="saveResource" access="public" returntype="void" hint="Adds or updates a resource in the library">
		<cfargument name="resourceBean" type="resourceBean" required="true" hint="the resource to add or update"> 		
	</cffunction>

	<!------------------------------------------------->
	<!--- saveResourceFile                     	   ---->
	<!------------------------------------------------->
	<cffunction name="saveResourceFile" access="public" returntype="void" hint="Saves a file corresponding to a resource to the library. The relative path to the file will be updated on the HREF property of the resource">
		<cfargument name="resourceBean" type="resourceBean" required="true" hint="the corresponding resource bean"> 		
		<cfargument name="resourceBody" type="string" required="true" hint="Text content of the related file">
		<cfargument name="fileName" type="string" required="false" default="" hint="The filename to use when saving the file. If empty then the resource ID will be used. Also, if there is no extension, then the defaultExtension property (if defined) will be used as extension">
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
	<cffunction name="getNewResource" access="public" returntype="resourceBean" hint="creates a new empty instance of a given resource type for this library">
		<cfargument name="resourceType" type="string" required="true">
	</cffunction>

	<!------------------------------------------------->
	<!--- getPath			                	   ---->
	<!------------------------------------------------->
	<cffunction name="getPath" access="public" returntype="string" hint="returns the path for this library">
	</cffunction>
	
</cfinterface>