<cfcomponent displayname="contentBox" extends="Home.Components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setModuleClassName("contentBox");
			cfg.setView("default", "main");
		</cfscript>	
	</cffunction>
	
	<!---------------------------------------->
	<!--- setContentID    			       --->
	<!---------------------------------------->		
	<cffunction name="setContentID" access="public" output="true">
		<cfargument name="contentID" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var pageHREF = cfg.getPageHREF();
			var tmpScript = "";
			
			cfg.setPageSetting("contentID", arguments.contentID);
			this.controller.setMessage("Content selected");
			this.controller.savePageSettings();
			
			this.controller.setScript("#moduleID#.getView();#moduleID#.closeWindow();");
		</cfscript>
	</cffunction>		


	<!------------------------------------------------->
	<!--- saveContent				                ---->
	<!------------------------------------------------->
	<cffunction name="saveContent" access="public" returntype="void">
		<cfargument name="contentID" type="string" required="true" hint="resource id">
		<cfargument name="name" type="string" required="true" hint="Content resource name">
		<cfargument name="access" type="string" required="true" hint="access type for resource">
		<cfargument name="description" type="string" required="true" hint="resource description">
		<cfargument name="body" type="string" required="true" hint="resource body">
		
        <cfset var oResourceBean = 0>
 		<cfset var oHP = application.homePortals>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = "content">
		<cfset var siteOwner = "">
				
		<cfscript>
				if(arguments.body eq "") throw("The content body cannot be empty"); 

				// get owner
				stUser = this.controller.getUserInfo();
				siteOwner = stUser.username;

				// if this is a new resource, generate an ID
				if(arguments.contentID eq "")
					arguments.contentID = createUUID();

				// create the bean for the new resource
				oResourceBean = createObject("component","Home.Components.resourceBean").init();	
				oResourceBean.setID(arguments.contentID);
				oResourceBean.setName(arguments.name);
				oResourceBean.setOwner(siteOwner);
				oResourceBean.setAccessType(arguments.access); 
				oResourceBean.setDescription(arguments.description); 
				oResourceBean.setPackage(siteOwner); 
				oResourceBean.setType(resourceType); 
				
				/// add the new resource to the library
				oResourceLibrary = createObject("component","Home.Components.resourceLibrary").init(resourceLibraryPath);
				oResourceLibrary.saveResource(oResourceBean, arguments.body);
			
				// update catalog
				oHP.getCatalog().reloadPackage(resourceType,siteOwner);
						
				setContentID(arguments.contentID);
		</cfscript>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- deleteContent            		          ---->
	<!------------------------------------------------->
	<cffunction name="deleteContent" access="public" returntype="void">
		<cfargument name="contentID" type="string" required="true" hint="resource id">
	
 		<cfset var oHP = application.homePortals>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = "content">
		<cfset var siteOwner = "">
		<cfset var oResourceLibrary = 0>
		<cfset var stUser = structNew()>
		
		<cfscript>
			if(arguments.contentID eq "") throw("The content name cannot be empty.");

			// get owner
			stUser = this.controller.getUserInfo();
			siteOwner = stUser.username;

			/// remove resource from the library
			oResourceLibrary = createObject("component","Home.Components.resourceLibrary").init(resourceLibraryPath);
			oResourceLibrary.deleteResource(arguments.contentID, resourceType, siteOwner);

			// remove from catalog
			oHP.getCatalog().deleteResourceNode(resourceType, arguments.contentID);
			
			setContentID("");
        </cfscript>
	</cffunction>		
	
	
	
	<!---------------------------------------->
	<!--- getResourcesForAccount           --->
	<!---------------------------------------->
	<cffunction name="getResourcesForAccount" access="private" hint="Retrieves a query with all resources of the given type available for a given account" returntype="query">
		<cfargument name="owner" type="string" required="yes">
		<cfargument name="resourceType" type="string" required="yes">

		<cfscript>
			var aAccess = arrayNew(1);
			var j = 1;
			var oHP = application.homePortals;
		
			var oFriendsService = oHP.getAccountsService().getFriendsService();
			var qryFriends = oFriendsService.getFriends(arguments.owner);
			
			var qryResources = oHP.getCatalog().getResourcesByType(arguments.resourceType);
			
			for(j=1;j lte qryResources.recordCount;j=j+1) {
				aAccess[j] = qryResources.access[j] eq "general"
							or qryResources.access[j] eq ""
							or (qryResources.access[j] eq "owner" and qryResources.owner[j] eq arguments.owner)
							or (qryResources.access[j] eq "friend" and qryResources.owner[j] eq arguments.owner)
							or (qryResources.access[j] eq "friend" and listFindNoCase(valueList(qryFriends.userName), qryResources.owner[j]));
			}
			queryAddColumn(qryResources, "hasAccess", aAccess);
		</cfscript>
		
		<cfquery name="qryResources" dbtype="query">
			SELECT *
				FROM qryResources
				WHERE hasAccess = 1
				ORDER BY package, id
		</cfquery>

		<cfreturn qryResources>
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