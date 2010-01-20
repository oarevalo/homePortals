<cfcomponent displayname="htmlBox" extends="homePortals.plugins.modules.components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setModuleClassName("htmlBox");
			cfg.setView("default", "main");
			
			variables.resourceType = "html";
		</cfscript>	
	</cffunction>
	
	<!---------------------------------------->
	<!--- setResourceID    			       --->
	<!---------------------------------------->		
	<cffunction name="setResourceID" access="public" output="true">
		<cfargument name="resourceID" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var pageHREF = cfg.getPageHREF();
			var tmpScript = "";
			
			cfg.setPageSetting("resourceID", arguments.resourceID);
			this.controller.setMessage("Resource selected");
			this.controller.savePageSettings();
			
			this.controller.setScript("#moduleID#.getView();#moduleID#.closeWindow();");
		</cfscript>
	</cffunction>		


	<!------------------------------------------------->
	<!--- saveResource				                ---->
	<!------------------------------------------------->
	<cffunction name="saveResource" access="public" returntype="void">
		<cfargument name="resourceID" type="string" required="true" hint="resource id">
		<cfargument name="name" type="string" required="true" hint="Content resource name">
		<cfargument name="description" type="string" required="true" hint="resource description">
		<cfargument name="body" type="string" required="true" hint="resource body">
		
        <cfset var oResourceBean = 0>
 		<cfset var oHP = this.controller.getHomePortals()>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = getResourceType()>
		<cfset var siteOwner = "">
				
		<cfscript>
				if(arguments.body eq "") throw("The content body cannot be empty"); 

				// get owner
				stUser = this.controller.getUserInfo();
				siteOwner = stUser.username;

				// if this is a new resource, generate an ID
				if(arguments.resourceID eq "")
					arguments.resourceID = createUUID();

				// create the bean for the new resource
				oResourceBean = createObject("component","homePortals.components.resourceBean").init();	
				oResourceBean.setID(arguments.resourceID);
				oResourceBean.setName(arguments.name);
				oResourceBean.setDescription(arguments.description); 
				oResourceBean.setPackage(siteOwner); 
				oResourceBean.setType(resourceType); 
				
				/// add the new resource to the library
				oResourceLibrary = createObject("component","homePortals.components.resourceLibrary").init(resourceLibraryPath);
				oResourceLibrary.saveResource(oResourceBean, arguments.body);
			
				// update catalog
				oHP.getCatalog().reloadPackage(resourceType,siteOwner);
						
				setResourceID(arguments.resourceID);
		</cfscript>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- deleteResource            		       ---->
	<!------------------------------------------------->
	<cffunction name="deleteResource" access="public" returntype="void">
		<cfargument name="resourceID" type="string" required="true" hint="resource id">
	
 		<cfset var oHP = this.controller.getHomePortals()>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = getResourceType()>
		<cfset var siteOwner = "">
		<cfset var oResourceLibrary = 0>
		<cfset var stUser = structNew()>
		
		<cfscript>
			if(arguments.resourceID eq "") throw("Select a resource to delete.");

			// get owner
			stUser = this.controller.getUserInfo();
			siteOwner = stUser.username;

			/// remove resource from the library
			oResourceLibrary = createObject("component","homePortals.components.resourceLibrary").init(resourceLibraryPath);
			oResourceLibrary.deleteResource(arguments.resourceID, resourceType, siteOwner);

			// remove from catalog
			oHP.getCatalog().deleteResourceNode(resourceType, arguments.resourceID);
			
			setResourceID("");
        </cfscript>
	</cffunction>		
	
	
	
	<!---------------------------------------->
	<!--- getResourcesForAccount           --->
	<!---------------------------------------->
	<cffunction name="getResourcesForAccount" access="private" hint="Retrieves a query with all resources of the current type for the given account" returntype="query">
		<cfargument name="owner" type="string" required="yes">

		<cfscript>
			var aAccess = arrayNew(1);
			var j = 1;
			var oHP = this.controller.getHomePortals();
			var resourceType = getResourceType();			
			var qryResources = oHP.getCatalog().getResourcesByType(resourceType);
		</cfscript>
		
		<cfquery name="qryResources" dbtype="query">
			SELECT *
				FROM qryResources
				ORDER BY package, id
		</cfquery>

		<cfreturn qryResources>
	</cffunction>

	<!------------------------------------------------->
	<!--- getResourceType            		       ---->
	<!------------------------------------------------->
	<cffunction name="getResourceType" access="private" returntype="string">
		<cfreturn variables.resourceType>
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