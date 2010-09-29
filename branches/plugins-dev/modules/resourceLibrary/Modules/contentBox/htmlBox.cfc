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
		<cfargument name="newResourceID" type="string" required="false" hint="the resource id for new resources" default="">
		<cfargument name="description" type="string" required="true" hint="resource description">
		<cfargument name="body" type="string" required="true" hint="resource body">
		
        <cfset var oResourceBean = 0>
 		<cfset var oHP = this.controller.getHomePortals()>
		<cfset var oResourceLibrary = 0>
		<cfset var oResourceLibraryManager = oHP.getResourceLibraryManager()>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = getResourceType()>
		<cfset var siteOwner = "">
		<cfset var resID = "">
				
		<cfscript>
			if(arguments.body eq "") throw("The content body cannot be empty"); 

			// get owner
			stUser = this.controller.getUserInfo();
			siteOwner = stUser.username;

			// get the default resource library
			oResourceLibrary = oResourceLibraryManager.getResourceLibrary(resourceLibraryPath);

			// if this is a new resource, generate an ID
			if(arguments.resourceID eq "") {
				resID = arguments.newResourceID;
				oResourceBean = oResourceLibrary.getNewResource(resourceType);
				oResourceBean.setID(arguments.newResourceID);
				oResourceBean.setPackage(siteOwner);
			} else {
				resID = arguments.resourceID;
				oResourceBean = oResourceLibrary.getResource(resourceType, siteOwner, arguments.resourceID);
			}

			// update resource
			oResourceBean.setDescription(arguments.description); 
			oResourceBean.saveFile(resID & ".htm", arguments.body);
			oResourceLibrary.saveResource(oResourceBean);
		
			// update catalog
			oHP.getCatalog().index(resourceType,siteOwner);
					
			setResourceID(resID);
		</cfscript>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- deleteResource            		       ---->
	<!------------------------------------------------->
	<cffunction name="deleteResource" access="public" returntype="void">
		<cfargument name="resourceID" type="string" required="true" hint="resource id">
	
 		<cfset var oHP = this.controller.getHomePortals()>
		<cfset var oResourceLibraryManager = oHP.getResourceLibraryManager()>
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

			// get the default resource library
			oResourceLibrary = oResourceLibraryManager.getResourceLibrary(resourceLibraryPath);

			/// remove resource from the library
			oResourceLibrary.deleteResource(arguments.resourceID, resourceType, siteOwner);

			// remove from catalog
			oHP.getCatalog().index(resourceType, arguments.resourceID);
			
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
			var qryResources = oHP.getCatalog().getIndex(resourceType);
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