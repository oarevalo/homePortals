<!---
/******************************************************/
/* cms.cfc											  */
/*													  */
/* This component provides functionality to           */
/* manage edit/manage current site			 .        */
/*													  */
/* (c) 2010 - Oscar Arevalo							  */
/* oarevalo@gmail.com								  */
/*													  */
/******************************************************/
--->

<cfcomponent hint="This component provides functionality to manage all aspects of a HomePortals page.">

	<!--- constructor code --->
	<cfscript>
		variables.oPage = 0;
		variables.homePortals = 0;
		variables.pageHREF = "";
		variables.reloadPageHREF = "";
		
		variables.view = "";
		variables.useLayout = true;
		variables.cmsRoot = "";
	</cfscript>


	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="cms" hint="Initializes component.">
		<cfargument name="homePortals" type="homePortals.components.homePortals" required="true" hint="HomePortals engine">
		<cfargument name="pageHREF" type="string" required="false" default="" hint="the address of the current page">
		<cfscript>
			variables.homePortals = arguments.homePortals;
			variables.pageHREF = arguments.pageHREF;
			variables.cmsRoot =  variables.homePortals.getPluginManager().getPlugin("cms").getCMSRoot();
			
			if(variables.pageHREF neq "") {
				variables.oPage = variables.homePortals.getPageProvider().load(variables.pageHREF);
			}
			
			variables.reloadPageHREF = buildLink(variables.pageHREF);
				
			return this;
		</cfscript>
	</cffunction>
	
	

	<!---****************************************************************--->
	<!---         G E T     V I E W S     M E T H O D S                  --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- getView                          --->
	<!---------------------------------------->	
	<cffunction name="getView" access="public" output="true">
		<cfargument name="viewName" type="string" required="yes">
		<cfargument name="useLayout" type="boolean" default="true">
		<cfset var tmpHTML = "">
	
		<cfset variables.view = arguments.viewName>
		<cfset variables.useLayout = arguments.useLayout>

		<cfset tmpHTML = renderView(argumentCollection = arguments)>

		<cfset renderPage(tmpHTML)>
	</cffunction>			



	<!---****************************************************************--->
	<!---         D O     A C T I O N     M E T H O D S                  --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- addContentTag		               --->
	<!---------------------------------------->	
	<cffunction name="addContentTag" access="public" output="true">
		<cfargument name="tag" type="string" required="yes">
		<cfargument name="location" type="string" required="no" default="">
		<cftry>
			<cfscript>
				usedModuleIDList = "";
				oPageHelper = createObject("component","homePortals.components.pageHelper").init(variables.oPage);

				if(variables.oPage.hasProperty("extends") and variables.oPage.getProperty("extends") neq "") {
					oPageRenderer = createObject("component","homePortals.components.pageRenderer").init(variables.pageHREF, variables.oPage, variables.homePortals);
					p = oPageRenderer.getParsedPageData();
					for(key in p.modules) {
						for(i=1;i lte arrayLen(p.modules[key]);i++) {
							usedModuleIDList = listappend(usedModuleIDList,p.modules[key][i].getID());
						}
					}
				}

				newModuleID = oPageHelper.addContentTag(arguments.tag, arguments.location, structNew(), usedModuleIDList);
				savePage();
			</cfscript>
			
            <script>
                cms.closePanel();
 				window.location.replace("#variables.reloadPageHREF#");
            </script>

            <cfcatch type="any">
                <script>cms.setStatusMessage("#jsstringformat( cfcatch.Message)#");</script>
            </cfcatch>   	
		</cftry>
	</cffunction>	

	<!---------------------------------------->
	<!--- deleteModule                     --->
	<!---------------------------------------->
	<cffunction name="deleteModule" access="public" output="true">
		<cfargument name="moduleID" type="string" required="yes">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oPage.removeModule(arguments.moduleID);
				savePage();
			</cfscript>
			<script>
				cms.removeModuleFromLayout('#arguments.moduleID#');
				cms.setStatusMessage("Module has been removed.");
			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- addPage			               --->
	<!---------------------------------------->	
	<cffunction name="addPage" access="public" output="true">
		<cfargument name="pageName" default="" type="string">
		<cfargument name="parent" default="" type="string">
		<cfargument name="pageTemplate" default="" type="string">
		<cfargument name="createDefaultLayout" default="false" type="boolean">
		<cfset var newPageURL = "">
		<cfset var hp = variables.homePortals>
		<Cfset var bFound = true>
		<Cfset var currIndex = 1>
		<cftry>
			<cfscript>
				validateOwner();

				oPage = createObject("component","homePortals.components.pageBean").init();
				
				// create a default layout based on the default page template
				if(arguments.createDefaultLayout) {
					tm = hp.getTemplateManager();
					if(arguments.pageTemplate eq "") 
						pt = tm.getDefaultTemplate("page");
					else
						pt = tm.getTemplate("page",arguments.pageTemplate);
					lstLayoutSections = tm.getLayoutSections( pt.name );
					for(i=1;i lte listLen(lstLayoutSections);i++) {
						oPage.addLayoutRegion(lcase(listGetAt(lstLayoutSections,i)), lcase(listGetAt(lstLayoutSections,i)));
					}
				}
				
				if(right(arguments.parent,1) neq "/") arguments.parent = arguments.parent & "/";
				
				// make sure the page has a unique name within the account
				newPath = arguments.parent & arguments.pageName;
				bFound = hp.getPageProvider().pageExists(newPath);
				while(bFound) {
					newPath = arguments.parent & arguments.pageName & currIndex;
					bFound = hp.getPageProvider().pageExists(newPath);
					currIndex = currIndex + 1;
				}					
				
				oPage.setTitle( newPath );
				oPage.setProperty("owner", getUserInfo().userName );
			
				hp.getPageProvider().save(newPath,oPage);

				newPagePath = buildLink(newPath);
			</cfscript>
			
			<script>
				cms.closePanel();
				window.location.replace('#newPagePath#');
			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>			
	</cffunction>

	<!---------------------------------------->
	<!--- deletePage		               --->
	<!---------------------------------------->	
	<cffunction name="deletePage" access="public" output="true">
		<cfargument name="pageHREF" type="string" required="true">
		<cftry>
			<cfscript>
				validateOwner();
				
				// check if this is the site's homepage
				if(variables.homePortals.getConfig().getDefaultPage() eq arguments.pageHREF) {
					throw("This is page is set as the site's Homepage. Cannot delete.");
				}
				
				variables.homePortals.getPageProvider().delete(arguments.pageHREF);
				redirHREF = "index.cfm";
			</cfscript>
			<script>
				cms.setStatusMessage("Page deleted...");
				window.location.replace('#redirHREF#');
			</script>

			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- deleteFolder		               --->
	<!---------------------------------------->	
	<cffunction name="deleteFolder" access="public" output="true">
		<cfargument name="path" type="string" required="true">
		<cftry>
			<cfscript>
				validateOwner();
				variables.homePortals.getPageProvider().deleteFolder(arguments.path);
				redirHREF = "index.cfm";
			</cfscript>
			<script>
				cms.setStatusMessage("Folder deleted...");
				window.location.replace('#redirHREF#');
			</script>

			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- changeTitle	                   --->
	<!---------------------------------------->		
	<cffunction name="changeTitle" access="public" output="true">
		<cfargument name="title" type="string" required="yes">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oPage.setPageTitle(arguments.title);
				savePage();
			</cfscript>
			<script>
				cms.setStatusMessage("Title changed.");
			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- renamePage	                   --->
	<!---------------------------------------->		
	<cffunction name="renamePage" access="public" output="true">
		<cfargument name="pageName" type="string" required="true">
		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.pageName eq "") throw("The page title cannot be blank.");
		
				// rename the actual page 
				variables.homePortals.getPageProvider().move(variables.pageHREF, arguments.pageName);
				variables.oPage.setTitle(arguments.pageName);

				// check if this is the site's homepage
				if(variables.homePortals.getConfig().getDefaultPage() eq arguments.pageHREF) {
					setHomepage(arguments.pageName);
				}

				variables.pageHREF = arguments.pageName;
				savePage();
				
				// set the new reload location
				variables.reloadPageHREF = buildLink(arguments.pageName);
			</cfscript>
			
			<script>
				cms.closePanel();
				window.location.replace("#variables.reloadPageHREF#");
			</script>

			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

   	<!---------------------------------------->
   	<!--- updatePage	                   --->
   	<!---------------------------------------->
   	<cffunction name="updatePage" access="public" output="true">
   		<cfargument name="name" type="string" required="yes">
   		<cfargument name="title" type="string" required="yes">
   		<cfargument name="template" type="string" required="yes">
  		<cfargument name="description" type="string" required="yes">
  		<cfargument name="keywords" type="string" required="yes">
  		<cfargument name="extends" type="string" required="yes">
   		<cftry>
   			<cfscript>
   				validateOwner();
   				variables.oPage
   						.setTitle(arguments.title)
   						.setPageTemplate(arguments.template)
   						.removeMetaTag("description")
   						.removeMetaTag("keywords")
   						.removeProperty("extends");
						
				if(arguments.description neq "") variables.oPage.addMetaTag("description",arguments.description);
				if(arguments.keywords neq "") variables.oPage.addMetaTag("keywords",arguments.keywords);
				if(arguments.extends neq "") variables.oPage.setProperty("extends",arguments.extends);
						
   				savePage();
   				
   				if(arguments.name neq "" and arguments.name neq getFileFromPath(variables.pageHREF)) {
   					variables.homePortals.getPageProvider().move(variables.pageHREF, arguments.name);

					// check if this is the site's homepage
					if(variables.homePortals.getConfig().getDefaultPage() eq variables.pageHREF) {
						setHomepage(arguments.name);
					}

   					variables.reloadPageHREF = buildLink(arguments.name);
   					variables.pageHREF = arguments.name;
   				}
   			</cfscript>
   			<script>
              	cms.closePanel();
  				window.location.replace("#variables.reloadPageHREF#");
   			</script>
   			<cfcatch type="any">
   				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
   			</cfcatch>
   		</cftry>
   	</cffunction>
	
	<!---------------------------------------->
	<!--- updateModuleOrder                --->
	<!---------------------------------------->	
	<cffunction name="updateModuleOrder" access="public" output="true">
		<cfargument name="layout" type="string" required="true" hint="New layout in serialized form">
		<cfset var oPageHelper = 0>
		<cftry>
			<cfscript>
				validateOwner();
				oPageHelper = createObject("component","homePortals.components.pageHelper").init(variables.oPage);
				oPageHelper.setModuleOrder(arguments.layout);
				savePage();
			</cfscript>
			<script>
				cms.setStatusMessage("Layout changed.");
			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

   	<!---------------------------------------->
   	<!--- updateModule                     --->
   	<!---------------------------------------->
   	<cffunction name="updateModule" access="public" output="true">
   		<cfargument name="moduleID" type="string" required="yes">
   		<cfargument name="title" type="string" required="yes">
   		<cfargument name="location" type="string" required="yes">
  		<cfargument name="moduleTemplate" type="string" required="yes">
  		<cfargument name="style" type="string" required="yes">
  		<cfargument name="resPrefixes" type="string" required="false" default="">
		<cfset var prefix = "prop_">
   		<cftry>
   			<cfscript>
   				validateOwner();
   				oModuleBean = variables.oPage.getModule(arguments.moduleID);
   				oModuleBean.setTitle(trim(arguments.title));
   				oModuleBean.setModuleTemplate(arguments.moduleTemplate);
   				oModuleBean.setLocation(arguments.location);
   				oModuleBean.setStyle(trim(arguments.style));

				// update module properties
   				for(arg in arguments) {
   					if(left(arg,len(prefix)) eq prefix and listLast(arg,"_") neq "default") {
						if(arguments[arg] eq "_NOVALUE_")
	   						oModuleBean.setProperty(replaceNoCase(arg,prefix,""),"");
						else {
	   						oModuleBean.setProperty(replaceNoCase(arg,prefix,""),arguments[arg]);
						}
					}
   				}

   				
   				// save resources (if needed)
   				if(arguments.resPrefixes neq "") {
   					aResItems = listToArray(arguments.resPrefixes);
   					for(i=1;i lte arrayLen(aResItems);i++) {
   						resourceID = "";
   						propName = listFirst(aResItems[i],":");
   						resType = listGetAt(aResItems[i],2,":");
   						resPrefix = listGetAt(aResItems[i],3,":") & "_";
   						
   						// get resource ID
   						if(structKeyExists(arguments,resPrefix & "_id")) {
	   						resourceID = arguments[resPrefix & "_id"]; 
	   						if(listLen(resourceID,"/") gt 1) {
	   							resPackage = listFirst(resourceID);
	   							resourceID = listRest(resourceID);
	   						} else {
	   							resPackage = "default";
	   						}

	   						if(arguments[resPrefix & "_iscustom"]) {
								oModuleBean.setProperty(propName,resourceID);
								doUpdateResource = false;

	   						} else if(arguments[resPrefix & "_isnew"]) {
	   							resLib = getDefaultResourceLibrary();
	   							oResourceBean = resLib.getNewResource(resType);
								oResourceBean.setID(resourceID);
								//oResourceBean.setDescription(description); 
								oResourceBean.setPackage(resPackage); 
								doUpdateResource = true;
	   						} else {
	   							oResourceBean = variables.homePortals
	   														.getCatalog()
	   														.getResourceNode(resType, resourceID, true);
								doUpdateResource = true;
	   						}

							if(doUpdateResource) {
				   				for(arg in arguments) {
				   					// update resource properties
				   					if(left(arg,len(resPrefix)) eq resPrefix
				   						and listLast(arg,"_") neq "default"
				   						and arg neq resPrefix & "_id"
				   						and arg neq resPrefix & "_isnew"
				   						and arg neq resPrefix & "_file"
				   						and arg neq resPrefix & "_filebody"
				   						and arg neq resPrefix & "_filename"
				   						and arg neq resPrefix & "_filecontenttype") {
											
										if(arguments[arg] eq "_NOVALUE_")
					   						oResourceBean.setProperty(replaceNoCase(arg,resPrefix,""),"");
										else
					   						oResourceBean.setProperty(replaceNoCase(arg,resPrefix,""),arguments[arg]);
									}
				   				}
				   				oResourceBean.getResourceLibrary().saveResource(oResourceBean);
	
								// update body
								if(structKeyExists(arguments, resPrefix & "_filebody")) {
									oResourceBean.getResourceLibrary().saveResourceFile(oResourceBean, 
																						arguments[resPrefix & "_filebody"], 
																						arguments[resPrefix & "_filename"], 
																						arguments[resPrefix & "_filecontenttype"]);
								}
								
								// upload file
								if(structKeyExists(arguments, resPrefix & "_file") and arguments[resPrefix & "_file"] neq "") {
									pathSeparator =  createObject("java","java.lang.System").getProperty("file.separator");
									path = getTempFile(getTempDirectory(),"cmsPluginFileUpload");
									stFileInfo = fileUpload(arguments[resPrefix & "_file"], path);
									if(not stFileInfo.fileWasSaved)	throw("File upload failed");
									path = stFileInfo.serverDirectory & pathSeparator & stFileInfo.serverFile;
					
									oResourceBean.getResourceLibrary().addResourceFile(oResourceBean, 
																						path, 
																						stFileInfo.clientFile, 
																						stFileInfo.contentType & "/" & stFileInfo.contentSubType);
								}

								// reload package
				   				variables.homePortals.getCatalog().index(resType,oResourceBean.getPackage());
							}

							// update module in page
			   				oModuleBean.setProperty(propName,resourceID);
   						}
   						
   					}
   				}
   				
   				variables.oPage.setModule(oModuleBean);
   				savePage();
   			</cfscript>
   			<script>
  				window.location.replace("#variables.reloadPageHREF#");
              	cms.closePanel();
   			</script>
   			<cfcatch type="any">
   				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
   			</cfcatch>
   		</cftry>
   	</cffunction>

   	<!---------------------------------------->
   	<!--- login		                       --->
   	<!---------------------------------------->
	<cffunction name="login" access="public" output="true">
		<cfargument name="username" type="string" required="false" default="">
		<cfargument name="password" type="string" required="false" default="">
		<cftry>
			<cfset appRoot = variables.homePortals.getConfig().getAppRoot()>
			<cfset oCatalog = variables.homePortals.getCatalog()>
			<cfset oUserRegistry = createObject("component","homePortals.components.userRegistry").init()>
			<cfset link = buildLink(variables.pageHREF,true,true)>

			<!--- check if user exists --->
			<cftry>
				<cfset resNode = oCatalog.getResource("cmsUser","users/" &  arguments.username,true)>
				<cfif resNode.getProperty("password") eq hash(arguments.password,'SHA','utf-8')>
					<cfset oUserRegistry.setUserInfo( arguments.username, arguments.username, resNode )>
				<cfelse>
					<cfthrow message="Invalid username/password">
				</cfif>

				<cfcatch type="homePortals.catalog.resourceNotFound">
					<cfthrow message="Invalid username/password">
				</cfcatch>
			</cftry>
				
   			<script>
  				window.location.replace("#link#");
   			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>		
	</cffunction>

   	<!---------------------------------------->
   	<!--- logout	                       --->
   	<!---------------------------------------->
	<cffunction name="logout" access="public" output="true">
		<cftry>
			<cfset oUserRegistry = createObject("component","homePortals.components.userRegistry").init()>
			<cfset oUserRegistry.reinit()>
			
			<cfset appRoot = variables.homePortals.getConfig().getAppRoot()>
			<cfcookie name="cmsShowAdminBar" expires="now" value="">
   			<script>
  				window.location.replace("#appRoot#");
   			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

   	<!---------------------------------------->
   	<!--- createUser                       --->
   	<!---------------------------------------->
	<cffunction name="createUser" access="public" output="true">
		<cfargument name="username" type="string" required="false" default="">
		<cfargument name="password" type="string" required="false" default="">
		<cfargument name="password2" type="string" required="false" default="">
		<cftry>
			<cfset appRoot = variables.homePortals.getConfig().getAppRoot()>

			<cfif username eq "" or password eq "">
				<cfthrow message="Please complete all fields">
			</cfif>
			<cfif password neq password2>
				<cfthrow message="Passwords do not match">
			</cfif>

			<cfset oCatalog = variables.homePortals.getCatalog()>
			
			<!--- check if user exists --->
			<cftry>
				<cfset qry = oCatalog.getResource("cmsUser",arguments.username,true)>
				<cfthrow message="The given username already exists. Please select a different one">
				<cfcatch type="homePortals.catalog.resourceNotFound">
					<!--- good, username not taken --->
				</cfcatch>
			</cftry>

			<!--- find the default library --->
			<cfset defLib = getDefaultResourceLibrary()>
			
			<!--- create user --->
			<cfset oResNode = defLib.getNewResource("cmsUser")>
			<cfset oResNode.setID(arguments.username)>
			<cfset oResNode.setPackage("users")>
			<cfset oResNode.setProperty("password",hash(arguments.password,'SHA','utf-8'))>
			<cfset defLib.saveResource(oResNode)>
			
			<cfset oCatalog.index("cmsUser","users")>
			
			<cflocation url="#appRoot#?_statusMessage=User%20created" addToken="false">
			<cfcatch type="any">
				<cflocation url="#appRoot#?_statusMessage=#urlEncodedFormat(cfcatch.Message)#" addToken="false">
			</cfcatch>
		</cftry>
	</cffunction>

   	<!---------------------------------------->
   	<!--- addLocation                      --->
   	<!---------------------------------------->
	<cffunction name="addLocation" access="public" output="true">
		<cfargument name="locationName" required="true" type="string">
		<cftry>
   			<cfscript>
   				validateOwner();
   				locs = variables.oPage.getLayoutRegions();
   				
   				for(i=1;i lte arrayLen(locs);i++) {
   					if(locs[i].name eq arguments.locationName) {
   						locType = locs[i].type;
   						locName = "";
   						j = 1;
   						
						while(locName eq "") {
							testLocationName = locType & j;
							bCanUseName = true;
							for(k=1; k lte arrayLen(locs); k=k+1) {
								if(locs[k].type eq locType and locs[k].name eq testLocationName) 
									bCanUseName = false;
							}
							if(bCanUseName) locName = testLocationName;
							j = j + 1;
						}  
   						
   						variables.oPage.addLayoutRegion(locName,locType);
		   				savePage();
   						break;
   					}
   				}
   			</cfscript>			
   			<script>
  				window.location.replace("#variables.reloadPageHREF#");
   			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

   	<!---------------------------------------->
   	<!--- deleteLocation                   --->
   	<!---------------------------------------->
	<cffunction name="deleteLocation" access="public" output="true">
		<cfargument name="locationName" default="" type="string">
		<cftry>
   			<cfscript>
   				validateOwner();
   				locs = variables.oPage.getLayoutRegions();
   				numLocs = 0;
   				canDelete  = false;
   				locType = "";
   				
   				for(i=1;i lte arrayLen(locs);i++) {
   					if(locs[i].name eq arguments.locationName) {
   						locType = locs[i].type;
		   				numLocs = 1;
   					}
   				}
   				if(locType eq "") throw("Location not found");

   				for(i=1;i lte arrayLen(locs);i++) {
   					if(locs[i].type eq locType and locs[i].name neq arguments.locationName) {
   						numLocs++;
   					}
   				}

				if(numLocs gt 1) {
					oPage.removeLayoutRegion(arguments.locationName);
					savePage();
				} else {
					throw("You cannot delete all containers for a given region type");
				}
   			</cfscript>			
   			<script>
  				window.location.replace("#variables.reloadPageHREF#");
   			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

   	<!---------------------------------------->
   	<!--- createFolder	                   --->
   	<!---------------------------------------->
	<cffunction name="createFolder" access="public" output="true">
		<cfargument name="parent" required="true" type="string">
		<cfargument name="name" required="true" type="string">
		<cftry>
   			<cfscript>
   				validateOwner();
				pp = variables.homePortals.getPageProvider();
				name = trim(name);
   				
   				if(name eq "") throw("Folder name cannot be blank");
				if(pp.folderExists(parent & "/" & name))
					throw("You are trying to create a folder that already exists");
			
				pp.createFolder(parent,name);
   			</cfscript>			
   			<script>
				cms.setStatusMessage("Folder created");
  				cms.getPartialView("SiteMap",{path:'#parent#/#name#'},"cms-navMenuContentPanel");
   			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

   	<!---------------------------------------->
   	<!--- resetApp		                   --->
   	<!---------------------------------------->
	<cffunction name="resetApp" access="public" output="true">
		<cftry>
   			<cfscript>
   				validateOwner();
   				variables.homePortals.reinit();
   				appRoot = variables.homePortals.getConfig().getAppRoot();
   			</cfscript>			
   			<script>
				cms.setStatusMessage("Application reloaded");
  				window.location.replace("#appRoot#?admin");
   			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>
				
   	<!---------------------------------------->
   	<!--- updateSettings                   --->
   	<!---------------------------------------->
	<cffunction name="updateSettings" access="public" output="true">
		<cfargument name="defaultPage" type="string" required="true">
		<cfargument name="newPassword" type="string" required="true">
		<cfargument name="newPassword2" type="string" required="true">
		<cftry>
   			<cfscript>
   				validateOwner();
   				
   				// check if we need to change password
   				if(newPassword neq "") {
   					if(newPassword neq newPassword2) throw("Passwords do not match");
   					oCatalog = variables.homePortals.getCatalog();
   					resNode = oCatalog.getResource("cmsUser",getUserInfo().username,true);
					resNode.setProperty("password",hash(arguments.newPassword,'SHA','utf-8'));
   					defLib = resNode.getResourceLibrary();
   					defLib.saveResource(resNode);
   				}
   				
   				// update homepage
   				if(arguments.defaultPage neq variables.homePortals.getConfig().getDefaultPage()) {
   					// check that we are using an existing page
   					if(not variables.homePortals.getPageProvider().pageExists(arguments.defaultPage)) {
   						throw("The page entered as homepage does not exist. Please use an existing page");
   					}
   					
   					// set homepage
   					setHomepage(arguments.defaultPage);
   				}
   				
   				appRoot = variables.homePortals.getConfig().getAppRoot();
   			</cfscript>			
   			<script>
				cms.setStatusMessage("Settings updated");
  				window.location.replace("#appRoot#?admin");
   			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#",10000);</script>
			</cfcatch>
		</cftry>
	</cffunction>
							
  	<!---------------------------------------->
   	<!--- setGlobalPageProperties          --->
   	<!---------------------------------------->
	<cffunction name="setGlobalPageProperties" access="public" output="true">
		<cfset var prefix = "prop_">
		<cftry>
   			<cfscript>
   				validateOwner();
   				
   				for(arg in arguments) {
   					if(left(arg,len(prefix)) eq prefix) {
   						setGlobalPageProperty(replaceNoCase(arg,prefix,""),arguments[arg]);
   					}
   				}
   				variables.homePortals.reinit();
   				appRoot = variables.homePortals.getConfig().getAppRoot();
   			</cfscript>			
   			<script>
				cms.setStatusMessage("Settings updated");
  				window.location.replace("#appRoot#?admin");
   			</script>
			<cfcatch type="any">
				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

   	<!---------------------------------------->
   	<!--- updateResource                   --->
   	<!---------------------------------------->
	<cffunction name="updateResource" access="public" output="true">
		<cfargument name="resourceType" type="string" required="true" />
		<cfargument name="prefix" type="string" required="true" />
   		<cftry>
   			<cfscript>
   			validateOwner();
			resourceID = "";
			resType = arguments.resourceType;
			resPrefix = arguments.prefix & "_";
			
			// get resource ID
			if(structKeyExists(arguments,resPrefix & "_id")) {
				resourceID = arguments[resPrefix & "_id"]; 
				if(listLen(resourceID,"/") gt 1) {
					resPackage = listFirst(resourceID);
					resourceID = listRest(resourceID);
				} else {
					resPackage = "default";
				}
			}
			
			if(resourceID neq "") {
				if(arguments[resPrefix & "_isnew"]) {
					resLib = getDefaultResourceLibrary();
					oResourceBean = resLib.getNewResource(resType);
					oResourceBean.setID(resourceID);
					//oResourceBean.setDescription(description); 
					oResourceBean.setPackage(resPackage); 
				} else {
					oResourceBean = variables.homePortals
												.getCatalog()
												.getResourceNode(resType, resourceID, true);
				}

				for(arg in arguments) {
					// update resource properties
					if(left(arg,len(resPrefix)) eq resPrefix
						and listLast(arg,"_") neq "default"
						and arg neq resPrefix & "_id"
						and arg neq resPrefix & "_isnew"
						and arg neq resPrefix & "_file"
						and arg neq resPrefix & "_filebody"
						and arg neq resPrefix & "_filename"
						and arg neq resPrefix & "_filecontenttype") {
						
						if(arguments[arg] eq "_NOVALUE_")
	   						oResourceBean.setProperty(replaceNoCase(arg,resPrefix,""),"");
						else
	   						oResourceBean.setProperty(replaceNoCase(arg,resPrefix,""),arguments[arg]);
					}
				}
				oResourceBean.getResourceLibrary().saveResource(oResourceBean);

				// update body
				if(structKeyExists(arguments, resPrefix & "_filebody")) {
					oResourceBean.getResourceLibrary().saveResourceFile(oResourceBean, 
																		arguments[resPrefix & "_filebody"], 
																		arguments[resPrefix & "_filename"], 
																		arguments[resPrefix & "_filecontenttype"]);
				}
				
				// upload file
				if(structKeyExists(arguments, resPrefix & "_file") and arguments[resPrefix & "_file"] neq "") {
					pathSeparator =  createObject("java","java.lang.System").getProperty("file.separator");
					path = getTempFile(getTempDirectory(),"cmsPluginFileUpload");
					stFileInfo = fileUpload(arguments[resPrefix & "_file"], path);
					if(not stFileInfo.fileWasSaved)	throw("File upload failed");
					path = stFileInfo.serverDirectory & pathSeparator & stFileInfo.serverFile;
	
					oResourceBean.getResourceLibrary().addResourceFile(oResourceBean, 
																		path, 
																		stFileInfo.clientFile, 
																		stFileInfo.contentType & "/" & stFileInfo.contentSubType);
				}

				// reload package
				variables.homePortals.getCatalog().index(resType,oResourceBean.getPackage());
			}
   			</cfscript>
   			<script>
  				window.location.replace("#variables.reloadPageHREF#");
              	cms.closePanel();
   			</script>
   			<cfcatch type="any">
   				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
   			</cfcatch>
   		</cftry>
	</cffunction>

   	<!---------------------------------------->
   	<!--- deleteResource                   --->
   	<!---------------------------------------->
	<cffunction name="deleteResource" access="public" output="true">
		<cfargument name="resourceType" type="string" required="true" />
		<cfargument name="resourceID" type="string" required="true" />
   		<cftry>
			<cfscript>
	   			validateOwner();
				oCatalog = variables.homePortals.getCatalog();
				oResourceBean = oCatalog.getResource(arguments.resourceType, arguments.resourceID, true);

				// delete resource
				oResourceBean.getResourceLibrary().deleteResource(resourceID, resourceType, oResourceBean.getPackage());

				// remove from catalog
				oCatalog.index(resourceType, resourceID);
   			</cfscript>
   			<script>
  				window.location.replace("#variables.reloadPageHREF#");
              	cms.closePanel();
   			</script>
   			<cfcatch type="any">
   				<script>cms.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
   			</cfcatch>
   		</cftry>
	</cffunction>


	<!---****************************************************************--->
	<!---                P R I V A T E   M E T H O D S                   --->
	<!---****************************************************************--->

	<!-------------------------------------->
	<!--- getUserInfo                    --->
	<!-------------------------------------->
	<cffunction name="getUserInfo" returntype="struct" hint="returns info about the current logged in user" access="public">
		<cfscript>
			var oUserRegistry = 0;
			var stRet = structNew();
			
			oUserRegistry = createObject("Component","homePortals.components.userRegistry").init();
			stRet = oUserRegistry.getUserInfo();	// information about the logged-in user	
			stRet.isLoggedIn = ( stRet.username neq "" );
		</cfscript>

		<cfreturn stRet>
	</cffunction>	

	<!---------------------------------------->
	<!--- renderView                       --->
	<!---------------------------------------->		
	<cffunction name="renderView" access="private" returntype="string">
		<cfset var tmpHTML = "">
		<cfset var viewHREF = "views/vw" & variables.view & ".cfm">
		
		<cftry>
			<cfsavecontent variable="tmpHTML">
				<cfinclude template="#viewHREF#">				
			</cfsavecontent>

			<cfcatch type="any">
				<cfset tmpHTML = cfcatch.Message & "<br>" & cfcatch.Detail>
			</cfcatch>
		</cftry>
		
		<cfreturn tmpHTML>
	</cffunction>

	<!---------------------------------------->
	<!--- renderPage                       --->
	<!---------------------------------------->
	<cffunction name="renderPage" access="private">
		<cfargument name="html" default="" hint="contents">
		<cfif variables.useLayout>
			<cfinclude template="includes/layout.cfm">
		<cfelse>
			<cfset writeOutput(arguments.html)>
		</cfif>
	</cffunction>
	
	<!---------------------------------------->
	<!--- savePage                         --->
	<!---------------------------------------->
	<cffunction name="savePage" access="private" hint="Stores a HomePortals page">
		<cfset oPageProvider = variables.homePortals.getPageProvider()>
		<cfset oPageProvider.save(variables.pageHREF, variables.oPage)>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- throw                            --->
	<!---------------------------------------->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string" required="yes">
		<cfthrow message="#arguments.message#">
	</cffunction>

	<!---------------------------------------->
	<!--- abort                            --->
	<!---------------------------------------->
	<cffunction name="abort" access="private">
		<cfabort>
	</cffunction>
	
	<!---------------------------------------->
	<!--- dump                             --->
	<!---------------------------------------->
	<cffunction name="dump" access="private">
		<cfargument name="data" type="any" required="yes">
		<cfdump var="#arguments.data#">
	</cffunction>	

	<!---------------------------------------->
	<!--- validateOwner                    --->
	<!---------------------------------------->
	<cffunction name="validateOwner" access="private" hint="Throws an error if the current user is not the page owner" returntype="boolean">
		<cfif Not getUserInfo().isLoggedIn>
			<cfthrow message="You must sign-in to access this feature." type="custom">
		<cfelse>
			<cfreturn true> 
		</cfif>
	</cffunction>

	<!---------------------------------------->
	<!--- getResources			           --->
	<!---------------------------------------->
	<cffunction name="getResources" access="private" hint="Retrieves a query with all resources of the given type" returntype="query">
		<cfargument name="resourceType" type="string" required="yes">
		<cfscript>
			var oHP = variables.homePortals;
			var qryResources = oHP.getCatalog().getIndex(arguments.resourceType);
			return qryResources;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- getDefaultResourceLibrary        --->
	<!---------------------------------------->
	<cffunction name="getDefaultResourceLibrary" access="private" returntype="any">
		<cfset var appRoot = variables.homePortals.getConfig().getAppRoot()>
		<cfset var aLibs = variables.homePortals.getResourceLibraryManager().getResourceLibraries()>
		<cfset var defLib = 0>
		<cfset var defLibFound = false>
		
		<cfloop from="1" to="#arrayLen(aLibs)#" index="i">
			<cfif left(aLibs[i].getPath(),len(appRoot)) eq appRoot>
				<cfset defLibFound = true>
				<cfset defLib = aLibs[i]>
			</cfif>
		</cfloop>
		<cfif not defLibFound>
			<cfthrow message="no default resource library found">
		</cfif>
		
		<cfif not defLibFound and arrayLen(aLibs) gt 0>
			<cfset defLib = aLibs[1]>
		<cfelseif arrayLen(aLibs) eq 0>
			<cfthrow message="Site has no resource libraries configured.">
		</cfif>
		<cfreturn defLib>
	</cffunction>	

	<!---------------------------------------->
	<!--- setHomepage				        --->
	<!---------------------------------------->
	<cffunction name="setHomepage" access="private" returntype="any">
		<cfargument name="pagePath" type="string" required="true">
		<cfscript>
			var appRoot = variables.homePortals.getConfig().getAppRoot();
			var configPath = appRoot & "/" & variables.homePortals.getConfigFilePath();
			var oConfig = createObject("component","homePortals.components.homePortalsConfigBean").init(expandPath(configPath));
			oConfig.setDefaultPage(trim(arguments.pagePath));
			fileWrite(expandPath(configPath),toString(oConfig.toXML()),"utf-8");
			variables.homePortals.reinit();
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- setGlobalPageProperty		       --->
	<!---------------------------------------->
	<cffunction name="setGlobalPageProperty" access="private" returntype="any">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		<cfscript>
			var appRoot = variables.homePortals.getConfig().getAppRoot();
			var configPath = appRoot & "/" & variables.homePortals.getConfigFilePath();
			var oConfig = createObject("component","homePortals.components.homePortalsConfigBean").init(expandPath(configPath));
			oConfig.setPageProperty(arguments.name, arguments.value);
			fileWrite(expandPath(configPath),toString(oConfig.toXML()),"utf-8");
			variables.homePortals.reinit();
		</cfscript>
	</cffunction>
			
	<!---------------------------------------->
	<!--- fileUpload				       --->
	<!---------------------------------------->
	<cffunction name="fileUpload" access="private" returntype="struct">
		<cfargument name="fieldName" type="string" required="true">
		<cfargument name="destPath" type="string" required="true">
		
		<cfset var stFile = structNew()>
		
		<cffile action="upload" 
				filefield="#arguments.fieldName#" 
				nameconflict="makeunique"  
				result="stFile"
				destination="#arguments.destPath#">
		
		<cfreturn stFile>
	</cffunction>	
					
	<!---------------------------------------->
	<!--- buildLink					       --->
	<!---------------------------------------->
	<cffunction name="buildLink" access="private" returntype="string">
		<cfargument name="page" type="string" required="true">
		<cfargument name="makeUnique" type="boolean" required="false" default="true">
		<cfargument name="admin" type="boolean" required="false" default="false">
		<cfset var link = variables.homePortals.getPluginManager().getPlugin("cms").getCMSLinkFormat()>
		<cfset link = replaceNoCase(link,"{appRoot}",variables.homePortals.getConfig().getAppRoot())>
		<cfset link = replaceNoCase(link,"{page}",arguments.page)>
		<cfif arguments.makeUnique>
			<cfif find("?",link)>
				<cfset link = link & "&" & getTickCount()>
			<cfelse>
				<cfset link = link & "?" & getTickCount()>
			</cfif>
		</cfif>
		<cfif arguments.admin>
			<cfif find("?",link)>
				<cfset link = link & "&admin=1">
			<cfelse>
				<cfset link = link & "?admin=1">
			</cfif>
		</cfif>
		<cfset link = replace(link,"//","/","ALL")>
		<cfreturn link>
	</cffunction>				
					
</cfcomponent>