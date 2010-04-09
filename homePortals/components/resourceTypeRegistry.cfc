<cfcomponent hint="This component acts as a central registry for resourceType information">
	
	<cfscript>
		variables.stResourceTypes = structNew();
	</cfscript>

	<!------------------------------------------------->
	<!--- init				                	   ---->
	<!------------------------------------------------->
	<cffunction name="init" returntype="resourceTypeRegistry" access="public" hint="This is the constructor">
		<cfargument name="config" type="homePortalsConfigBean" required="true">
		<cfscript>
			var i = 0;
			var oResLib = 0;
			var oResType = 0;
			var stResTypes = arguments.config.getResourceTypes();

			// register the resource types into all libraries
			for(i in stResTypes) {
				oResType = createObject("component","resourceType").init();
				
				if(structKeyExists(stResTypes[i],"name")) oResType.setName( stResTypes[i].name );
				if(structKeyExists(stResTypes[i],"description") and stResTypes[i].description neq "") oResType.setDescription( stResTypes[i].description );
				if(structKeyExists(stResTypes[i],"folderName") and stResTypes[i].folderName neq "") oResType.setFolderName( stResTypes[i].folderName );
				if(structKeyExists(stResTypes[i],"resBeanPath") and stResTypes[i].resBeanPath neq "") oResType.setResBeanPath( stResTypes[i].resBeanPath );
				if(structKeyExists(stResTypes[i],"fileTypes") and stResTypes[i].fileTypes neq "") oResType.setFileTypes( stResTypes[i].fileTypes );
				
				for(j=1;j lte arrayLen(stResTypes[i].properties);j=j+1) {
					oResType.setProperty(argumentCollection = stResTypes[i].properties[j]);
				}

				registerResourceType(oResType);
			}			
			
			return this;
		</cfscript>
	</cffunction>
		
	<!------------------------------------------------->
	<!--- registerResourceType                	   ---->
	<!------------------------------------------------->
	<cffunction name="registerResourceType" access="public" returntype="void">
		<cfargument name="resType" type="resourceType" required="true">
		<cfset variables.stResourceTypes[arguments.resType.getName()] = resType>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResourceTypes	                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypes" access="public" returntype="array" hint="returns an array with the allowed resource types">
		<cfreturn listToArray(structKeyList(variables.stResourceTypes))>
	</cffunction>

	<!------------------------------------------------->
	<!--- getResourceTypesMap                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceTypesMap" access="public" returntype="struct" hint="returns an map of resourceType objects with details on the registered resource types">
		<cfreturn variables.stResourceTypes>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- getResourceType	                	   ---->
	<!------------------------------------------------->
	<cffunction name="getResourceType" access="public" returntype="resourceType" hint="returns a resourceType object with details on the requested resource type">
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
	
</cfcomponent>
