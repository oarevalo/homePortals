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
		<cfargument name="newContentID" type="string" required="true" hint="when creating a new resource, this is the new id">
		<cfargument name="access" type="string" required="true" hint="access type for resource">
		<cfargument name="description" type="string" required="true" hint="resource description">
		<cfargument name="body" type="string" required="true" hint="resource body">
		
        <cfset var xmlDoc = 0>
        <cfset var xmlNode = 0>
 		<cfset var oHP = application.homePortals>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = "content">
		<cfset var folder = "">
		<cfset var packageDir = "">
		<cfset var siteOwner = "">
		<cfset var href = "">
		<cfset var fixedContentID = "">
				
		<cfscript>
				if(arguments.contentID eq "" and arguments.newContentID eq "") throw("The content name cannot be empty.");
				if(arguments.body eq "") throw("The content body cannot be empty"); 

				// get owner
				stUser = this.controller.getUserInfo();
				siteOwner = stUser.username;

				if(arguments.contentID neq "") {
					arguments.newContentID = arguments.contentID;
				}

				// remove any invalid characters from the id
				arguments.newContentID = reReplace(arguments.newContentID, "[^A-Za-z0-9_ ]", "_", "ALL");

				// this is the directory where the resources of this type for this account will be stored
				packageDir = resourceLibraryPath & "/" & resourceType & "s" & "/" & siteOwner;

				// set the proper href for the given path based on the ID
				href = resourceLibraryPath & "/" & resourceType & "s/" & siteOwner & "/" & arguments.newContentID & ".html";					
				
				// create a package for the current account on the resource type folder
				if(Not DirectoryExists(expandPath(packageDir))) {
					createDir(packageDir);
				}
	
				
				// check for file descriptor, if doesnt exist, then create one
				if(fileExists(expandPath(packageDir & "/info.xml"))) {
					xmlDoc = xmlParse(expandPath(packageDir & "/info.xml"));
					
					if(not structKeyExists(xmlDoc.xmlRoot, resourceType & "s")) 
						arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc, resourceType & "s"));
					
				} else {
					// create file descriptor
					xmlDoc = xmlNew();
					xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "catalog");
					arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc, resourceType & "s"));
				}
				
				
				// update the file descriptor
				if(arguments.contentID eq "") {
					// this is a new resource
					xmlNode = xmlElemNew(xmlDoc, resourceType);
					xmlNode.xmlAttributes["id"] = arguments.newContentID;
					xmlNode.xmlAttributes["href"] = href;
					xmlNode.xmlAttributes["owner"] = siteOwner;
					xmlNode.xmlAttributes["access"] = arguments.access;
					xmlNode.xmlText = arguments.description;
					arrayAppend(xmlDoc.xmlRoot[resourceType & "s"].xmlChildren, xmlNode);
					
				} else {
					// this is an existing resource
					bFound = false;
					for(i=1;i lte arrayLen(xmlDoc.xmlRoot[resourceType & "s"].xmlChildren);i=i+1) {
						xmlNode = xmlDoc.xmlRoot[resourceType & "s"].xmlChildren[i];
						if(xmlNode.xmlAttributes.id eq arguments.contentID) {
							xmlNode.xmlAttributes["id"] = arguments.contentID;
							xmlNode.xmlAttributes["href"] = href;
							xmlNode.xmlAttributes["owner"] = siteOwner;
							xmlNode.xmlAttributes["access"] = arguments.access;
							xmlNode.xmlText = arguments.description;
							bFound = true;
							break;
						}
					}
					
					// if resource not found in descriptor, then add it
					if(Not bFound) {
						xmlNode = xmlElemNew(xmlDoc, resourceType);
						xmlNode.xmlAttributes["id"] = arguments.contentID;
						xmlNode.xmlAttributes["href"] = href;
						xmlNode.xmlAttributes["owner"] = siteOwner;
						xmlNode.xmlAttributes["access "] = arguments.access;
						xmlNode.xmlText = arguments.description;
						arrayAppend(xmlDoc.xmlRoot[resourceType & "s"].xmlChildren, xmlNode);
					}
				}
				
				// save resource descriptor file
				saveFile(packageDir & "/info.xml", toString(xmlDoc));
				
				// create or update the file,
				saveFile(href, arguments.body);
				
				oHP.getCatalog().reloadPackage("content",siteOwner);
				
				setContentID(arguments.newContentID);
		</cfscript>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- deleteContent            		          ---->
	<!------------------------------------------------->
	<cffunction name="deleteContent" access="public" returntype="void">
		<cfargument name="contentID" type="string" required="true" hint="resource id">
	
        <cfset var xmlDoc = 0>
        <cfset var xmlNode = 0>
 		<cfset var oHP = application.homePortals>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = "content">
		<cfset var packageDir = "">
		<cfset var siteOwner = "">
		<cfset var resHref = "">
		
		<cfscript>
			if(arguments.contentID eq "") throw("The content name cannot be empty.");

			// get owner
			stUser = this.controller.getUserInfo();
			siteOwner = stUser.username;

			// this is the directory where the resources of this type for this account will be stored
			packageDir = resourceLibraryPath & "/" & resourceType & "s" & "/" & siteOwner;
		

			// remove from descriptor (if exists)
			if(fileExists(expandPath(packageDir & "/info.xml"))) {
				xmlDoc = xmlParse(expandPath(packageDir & "/info.xml"));

				for(i=1;i lte arrayLen(xmlDoc.xmlRoot[resourceType & "s"].xmlChildren);i=i+1) {
					xmlNode = xmlDoc.xmlRoot[resourceType & "s"].xmlChildren[i];
					if(xmlNode.xmlAttributes.id eq arguments.contentID) {
						if(structKeyExists(xmlNode.xmlAttributes, "href"))
							resHref = xmlNode.xmlAttributes.href;
					
						// remove node from document
						arrayDeleteAt(xmlDoc.xmlRoot[resourceType & "s"].xmlChildren, i);
						
						// save modified resource descriptor file
						saveFile(packageDir & "/info.xml", toString(xmlDoc));				
									
						break;
					}
				}					
			}				
		
			// remove resource file
			if(resHref neq "" and left(resHref,4) neq "http" and fileExists(expandPath(resHref))) {
				removeFile(resHref);			
			}
			
			// remove from catalog
			oHP.getCatalog().deleteResourceNode("content", arguments.contentID);
			
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
	<!--- saveFile                         --->
	<!---------------------------------------->
	<cffunction name="saveFile" access="private" hint="writes a file">
		<cfargument name="path" type="string" hint="Path for the file as a relative URL">
		<cfargument name="content" type="string" hint="content">

		<!--- store page --->
		<cffile action="write" file="#expandpath(arguments.path)#" output="#arguments.content#">
	</cffunction>
	
	<!---------------------------------------->
	<!--- createDir                        --->
	<!---------------------------------------->
	<cffunction name="createDir" access="private" returnttye="void">
		<cfargument name="path" type="string" required="true">
		<cfdirectory action="create" directory="#ExpandPath(arguments.path)#">
	</cffunction>		

	<!---------------------------------------->
	<!--- removeFile                       --->
	<!---------------------------------------->
	<cffunction name="removeFile" access="private" hint="deletes a file">
		<cfargument name="href" type="string" hint="relative path to page">

		<cffile action="delete" file="#expandpath(arguments.href)#">
	</cffunction>	

</cfcomponent>