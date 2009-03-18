<!---
RSSReader.cfc

This is the server-side component of the RSS Reader module for HomePortals.
This module retrieves and parses an RSS/Atom feed and formats it for display.

History:
2/22/06 - oarevalo - improved support for Atom feeds
				   - added support for enclosures
				   - added links for del.icio.us and technorati
				   - fixed bug: quotes in the title will no longer give a JS error
3/31/06 - oarevalo - added rss feed caching into file system. Feeds will be fetched only
					if they are older than 30 minutes.
					- cache storage is on a directory named "RSSReaderCache". If doesnt
					 exist, it will be created.
					- TODO: make cache directory and feed timout time a configrable setting.
--->

<cfcomponent displayname="RSSReader" extends="homePortalsModules.components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();

			cfg.setModuleClassName("RSSReader");
			cfg.setView("default", "main");
			cfg.setView("htmlHead", "HTMLHead");
		</cfscript>	
	</cffunction>

	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="rss" type="string" default="">
		<cfargument name="maxItems" type="string" default="">
		<cfargument name="displayMode" type="string" default="short" hint="Short or Long">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var tmpScript = "";
			
			arguments.maxItems = val(arguments.maxItems);
			if(arguments.maxItems gt 0) 
				cfg.setPageSetting("maxItems", arguments.maxItems);
			else
				cfg.setPageSetting("maxItems", "");
			
			cfg.setPageSetting("rss", arguments.rss);
			cfg.setPageSetting("displayMode", arguments.displayMode);

			this.controller.setMessage("RSS Reader settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
		</cfscript>
	</cffunction>	

	<!---------------------------------------->
	<!--- setRSS	    			       --->
	<!---------------------------------------->		
	<cffunction name="setRSS" access="public" output="true">
		<cfargument name="rssURL" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var pageHREF = cfg.getPageHREF();
			var tmpScript = "";
			
			cfg.setPageSetting("rss", arguments.rssURL);
			this.controller.setMessage("Feed source updated");
			this.controller.savePageSettings();
			
			this.controller.setScript("#moduleID#.getView();#moduleID#.closeWindow();");
		</cfscript>
	</cffunction>	
	
	<!------------------------------------------------->
	<!--- saveFeed				                ---->
	<!------------------------------------------------->
	<cffunction name="saveFeed" access="public" returntype="void">
		<cfargument name="rssURL" type="string" required="true" hint="The URL of the feed">
		<cfargument name="feedName" type="string" required="true" hint="resource name">
		<cfargument name="access" type="string" required="true" hint="access type for resource">
		<cfargument name="description" type="string" required="true" hint="resource description">
				
        <cfset var oResourceBean = 0>
 		<cfset var oHP = this.controller.getHomePortals()>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = "feed">
		<cfset var siteOwner = "">
				
		<cfscript>
			if(arguments.rssURL eq "") throw("The feed URL cannot be empty"); 
			if(arguments.feedName eq "") throw("The feed title cannot be empty"); 

			if(left(arguments.rssURL,4) neq "http") arguments.rssURL = "http://" & arguments.rssURL;

			// get owner
			stUser = this.controller.getUserInfo();
			siteOwner = stUser.username;

			// create the bean for the new resource
			oResourceBean = createObject("component","homePortals.components.resourceBean").init();	
			oResourceBean.setID(createUUID());
			oResourceBean.setName(arguments.feedName);
			oResourceBean.setHREF(arguments.rssURL);
			oResourceBean.setOwner(siteOwner);
			oResourceBean.setAccessType(arguments.access); 
			oResourceBean.setDescription(arguments.description); 
			oResourceBean.setPackage(siteOwner); 
			oResourceBean.setType(resourceType); 
			
			/// add the new resource to the library
			oResourceLibrary = createObject("component","homePortals.components.resourceLibrary").init(resourceLibraryPath);
			oResourceLibrary.saveResource(oResourceBean, arguments.body);
		
			// update catalog
			oHP.getCatalog().reloadPackage(resourceType,siteOwner);
					
			setRSS(arguments.rssURL);
		</cfscript>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- deleteFeed	            		          ---->
	<!------------------------------------------------->
	<cffunction name="deleteFeed" access="public" returntype="void">
		<cfargument name="feedID" type="string" required="true" hint="resource id">
	
 		<cfset var oHP = this.controller.getHomePortals()>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = "feed">
		<cfset var siteOwner = "">
		<cfset var oResourceLibrary = 0>
		<cfset var stUser = structNew()>
		
		<cfscript>
			if(arguments.feedID eq "") throw("The feed ID cannot be empty.");

			// get owner
			stUser = this.controller.getUserInfo();
			siteOwner = stUser.username;

			/// remove resource from the library
			oResourceLibrary = createObject("component","homePortals.components.resourceLibrary").init(resourceLibraryPath);
			oResourceLibrary.deleteResource(arguments.feedID, resourceType, siteOwner);

			// remove from catalog
			oHP.getCatalog().deleteResourceNode(resourceType, arguments.contentID);
			
			setRSS("");
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
			var oHP = this.controller.getHomePortals();
		
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

</cfcomponent>


	
