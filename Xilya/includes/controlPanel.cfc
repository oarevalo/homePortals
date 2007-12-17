<!---
/******************************************************/
/* controlPanel.cfc									  */
/*													  */
/* This component provides functionality to           */
/* manage all aspects of a xilya account page.        */
/*													  */
/* (c) 2007 - Oscar Arevalo							  */
/* oarevalo@cfempire.com							  */
/*													  */
/******************************************************/
--->

<cfcomponent displayname="controlPanel" hint="This component provides functionality to manage all aspects of a HomePortals page.">

	<!--- constructor code --->
	<cfscript>
		variables.moduleRoot = "/xilya/includes";
		variables.imgRoot = variables.moduleRoot & "/images";
		variables.localSecret = "En su grave rincón, los jugadores "
							& "rigen las lentas piezas. El tablero "
							& "los demora hasta el alba en su severo "
							& "ámbito en que se odian dos colores. ";
		variables.controlPanelTitle = "Workspace Setup";
		variables.controlPanelIcon = "cog";		
		
		variables.accountsRoot = "";
		variables.pageHREF = "";
		variables.oPage = 0;
		variables.reloadPageHREF = "index.cfm";
	</cfscript>


	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="controlPanel" hint="Initializes component.">
		<cfargument name="pageHREF" type="string" required="true" hint="the address of the current page">
		<cfscript>
			this.currentView = "";

			variables.accountsRoot = application.homePortals.getConfig().getAccountsRoot();
			variables.pageHREF = arguments.pageHREF;
				
			variables.oPage = CreateObject("component", "Home.Components.page").init(variables.pageHREF);	
			
			variables.reloadPageHREF = "index.cfm?account=" & variables.oPage.getOwner() & "&page=" & replaceNoCase(getFileFromPath(variables.pageHREF),".xml","");
				
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
	
		<cfset arguments.viewName = "vw" & arguments.viewName>

		<cfinvoke method="renderView" argumentcollection="#arguments#" returnvariable="tmpHTML" />
		<cfif arguments.useLayout>
			<cfset renderPage(tmpHTML)>
		<cfelse>
			<cfset writeOutput(tmpHTML)>
		</cfif>
	</cffunction>			



	<!---****************************************************************--->
	<!---         D O     A C T I O N     M E T H O D S                  --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- addModule			               --->
	<!---------------------------------------->	
	<cffunction name="addModule" access="public" output="true">
		<cfargument name="moduleID" type="string" required="yes">
		<cfargument name="locationID" type="string" required="yes">
		
        <cfset var stRet = structNew()>
		<cftry>
			<cfset stRet = addModuleToPage(arguments.moduleID, arguments.locationID, false)>
			
            <script>
                // controlPanel.insertModule ('#stRet.moduleID#','#stRet.locationID#');
                controlPanel.closeAddModule();
 				window.location.replace("#variables.reloadPageHREF#");
            </script>

            <cfcatch type="lock">
                <script>controlPanel.setStatusMessage("#jsstringformat( cfcatch.Message)#");</script>
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
				variables.oPage.deleteModule(arguments.moduleID);
			</cfscript>
			<script>
				controlPanel.removeModuleFromLayout('#arguments.moduleID#');
				controlPanel.setStatusMessage("Module has been removed.");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- deleteEventHandler	           --->
	<!---------------------------------------->		
	<cffunction name="deleteEventHandler" access="public" output="true">
		<cftry>
			<cfparam name="arguments.index" default="0">
			
			<cfscript>
				validateOwner();
				variables.oPage.deleteEventHandler(arguments.index);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Event handler deleted.");
				controlPanel.getView('Events',{});
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>			
	</cffunction>

	<!---------------------------------------->
	<!--- addEventHandler               --->
	<!---------------------------------------->		
	<cffunction name="addEventHandler" access="public" output="true">
		<cftry>
			<cfparam name="arguments.eventName" default="">
			<cfparam name="arguments.eventHandler" default="">
			
			<cfscript>
				validateOwner();
				variables.oPage.saveEventHandler(0, listFirst(arguments.eventName,"."), listLast(arguments.eventName,"."), arguments.eventHandler);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Event handler saved.");
				controlPanel.getView('Events',{});
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>			
	</cffunction>
	
	<!---------------------------------------->
	<!--- addPage			               --->
	<!---------------------------------------->	
	<cffunction name="addPage" access="public" output="true">
		<cfargument name="pageName" default="" type="string">
		<cfargument name="pageHREF" default="" type="string">
		<cfset var newPageURL = "">
		<cftry>
			<cfscript>
				validateOwner();
				newPageURL = getSite().addPage(arguments.pageName, arguments.pageHREF);
				newPageURL = "index.cfm?account=" & variables.oPage.getOwner() & "&page=" & replaceNoCase(getFileFromPath(newPageURL),".xml","");
			</cfscript>
			<script>
				controlPanel.closeEditWindow();
				window.location.replace('#newPageURL#');
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>			
	</cffunction>

	<!---------------------------------------->
	<!--- addPageResource	               --->
	<!---------------------------------------->	
	<cffunction name="addPageResource" access="public" output="true">
		<cfargument name="resourceID" type="string">
		<cfset var newPageURL = "">
		<cfset var resLibraryPath = "">
		<cfset var oResourceBean = 0>

		<cftry>
			<cfscript>
				validateOwner();
				resLibraryPath = application.homePortals.getConfig().getResourceLibraryPath();

				// get page resource
				oResourceBean = application.homePortals.getCatalog().getResourceNode("page", arguments.resourceID);

				// add page to site
				newPageURL = getSite().addPageResource(oResourceBean, resLibraryPath);

				// redirect to new page				
				newPageURL = "index.cfm?account=" & variables.oPage.getOwner() & "&page=" & replaceNoCase(getFileFromPath(newPageURL),".xml","");
			</cfscript>
			<script>
				controlPanel.closeEditWindow();
				window.location.replace('#newPageURL#');
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
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
				getSite().deletePage(arguments.pageHREF);
				redirHREF = "index.cfm?account=" & variables.oPage.getOwner();
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Removing workspace...");
				window.location.replace('#redirHREF#');
			</script>

			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
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
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Title changed.");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
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
				if(pageName eq "") throw("The page title cannot be blank.");
		
				// get the original location of the page
				originalPageHREF = variables.oPage.getHREF();
		
				// rename the actual page 
				variables.oPage.setPageTitle(arguments.pageName);
				variables.oPage.renamePage(arguments.pageName);
				newPageHREF = variables.oPage.getHREF();
				
				// set the new reload location
				variables.reloadPageHREF = "index.cfm?account=" & variables.oPage.getOwner() & "&page=" & replaceNoCase(getFileFromPath(newPageHREF),".xml","") & "&#RandRange(1,100)#";
				
				// update the site definition
				getSite().setPageHREF(originalPageHREF, newPageHREF);			
			</cfscript>
			
			<script>
				controlPanel.closeEditWindow();
				window.location.replace("#variables.reloadPageHREF#");
			</script>

			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!---------------------------------------->
	<!--- updateModuleOrder                --->
	<!---------------------------------------->	
	<cffunction name="updateModuleOrder" access="public" output="true">
		<cfargument name="layout" type="string" required="true" hint="New layout in serialized form">
		<cftry>
			<cfscript>
				validateOwner();
				
				// remove the '_lp' string at the end of all the layout objects
				// (this string was added so that the module css rules dont get applied
				// to the modules on the layout preview )
				arguments.layout = replace(arguments.layout,"_lp","","ALL");
				
				variables.oPage.setModuleOrder(arguments.layout);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Layout changed.");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- applyPageTemplate		           --->
	<!---------------------------------------->	
	<cffunction name="applyPageTemplate" access="public" output="true">
		<cfargument name="resourceID" default="" type="string">
		<cfset var resLibraryPath = "">
		<cftry>
			<cfscript>
				validateOwner();
				resLibraryPath = application.homePortals.getConfig().getResourceLibraryPath();

				// get pagetemplate resource
				oResourceBean = application.homePortals.getCatalog().getResourceNode("pageTemplate", arguments.resourceID);

				variables.oPage.applyPageTemplate(oResourceBean, resLibraryPath);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Layout changed.");
				controlPanel.closeEditWindow();
				window.location.replace("#variables.reloadPageHREF#");
			</script>				
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- setSiteTitle			           --->
	<!---------------------------------------->	
	<cffunction name="setSiteTitle" access="public" output="true">
		<cfargument name="title" type="string" required="true" hint="The new title for the site">
		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.title eq "") throw("Site title cannot be empty"); 
				getSite().setSiteTitle(arguments.title);
			</cfscript>
			<script>
				window.location.replace("#variables.reloadPageHREF#");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- setPageAccess			           --->
	<!---------------------------------------->	
	<cffunction name="setPageAccess" access="public" output="true">
		<cfargument name="accessType" type="string" required="true" hint="Access type">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oPage.setAccess(arguments.accessType);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Page access changed.");
				window.location.replace("#variables.reloadPageHREF#");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- addFeed				           --->
	<!---------------------------------------->	
	<cffunction name="addFeed" access="public" output="true">
		<cfargument name="feedURL" type="string" required="true" hint="The URL of the feed">
		<cfargument name="feedTitle" type="string" required="true" hint="The title for the feed module">

		<cfset var stRet = structNew()>
		<cfset var stAttributes = structNew()>
		
		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.feedURL eq "") throw("The feed URL cannot be empty"); 

				// build custom properties
				stAttributes = structNew();
				stAttributes["rss"] = arguments.feedURL;
				if(arguments.feedTitle neq "") 
					stAttributes["title"] = arguments.feedTitle;
				stAttributes["maxItems"] = 10;

				stRet = addModuleToPage("rssReader", "", false, stAttributes);
            </cfscript>
            
            <script>
              	controlPanel.closeEditWindow();
				window.location.replace("#variables.reloadPageHREF#");
            </script>

			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- addContent		           --->
	<!---------------------------------------->	
	<cffunction name="addContent" access="public" output="true">
		<cfargument name="contentID" type="string" required="true" hint="The id of the content resource to add">

		<cfset var stRet = structNew()>
		<cfset var stAttributes = structNew()>

		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.contentID eq "") throw("The content ID cannot be empty"); 

				// build custom properties
				stAttributes = structNew();
				stAttributes["contentID"] = arguments.contentID;

               	stRet = addModuleToPage("contentBox", "", false, stAttributes);
            </cfscript>
            
            <script>
              	controlPanel.closeEditWindow();
				window.location.replace("#variables.reloadPageHREF#");
            </script>

			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>




	<!---****************************************************************--->
	<!---               F R I E N D   M A N A G E M E N T                --->
	<!---****************************************************************--->
	
	<!---------------------------------------->
	<!--- addFriend		           --->
	<!---------------------------------------->	
	<cffunction name="addFriend" access="public" output="true">
		<cfargument name="accountName" type="string" required="true" hint="The name of the account to add as a friend">
		<cfset var oFriendsService = 0>
		<cfset var siteOwner = variables.oPage.getOwner()>
		
		<cftry>
			<cfscript>
				validateOwner();	
				
				if(arguments.accountName eq "") throw("The account name cannot be empty");
				
				oFriendsService = application.homePortals.getAccountsService().getFriendsService();
				oFriendsService.addFriendshipRequest(siteOwner, arguments.accountName);
			</cfscript>
			
           <script>
              	controlPanel.closeEditWindow();
				controlPanel.setStatusMessage("#arguments.accountName# has been invited to be part of your friends.");
				window.location.replace("#variables.reloadPageHREF#");
            </script>
			
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- removeFriend		           --->
	<!---------------------------------------->	
	<cffunction name="removeFriend" access="public" output="true">
		<cfargument name="accountName" type="string" required="true" hint="The name of the account to remove as a friend">
		<cfset var oFriendsService = 0>
		<cfset var siteOwner = variables.oPage.getOwner()>
		
		<cftry>
			<cfscript>
				validateOwner();	
				
				if(arguments.accountName eq "") throw("The account name cannot be empty");
				
				oFriendsService = application.homePortals.getAccountsService().getFriendsService();
				oFriendsService.remove(siteOwner, arguments.accountName);
				oFriendsService.remove(arguments.accountName, siteOwner);
			</cfscript>
			
           <script>
              	controlPanel.closeEditWindow();
				controlPanel.setStatusMessage("#arguments.accountName# has been removed from your friends list.");
				window.location.replace("#variables.reloadPageHREF#");
            </script>
			
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!---------------------------------------->
	<!--- acceptFriendRequest               --->
	<!---------------------------------------->	
	<cffunction name="acceptFriendRequest" access="public" output="true">
		<cfargument name="sender" type="string" required="true" hint="The name of the account to add as a friend">
		<cfset var oFriendsService = 0>
		<cfset var siteOwner = variables.oPage.getOwner()>
		
		<cftry>
			<cfscript>
				validateOwner();	
				
				if(arguments.sender eq "") throw("The sender cannot be empty");
				
				oFriendsService = application.homePortals.getAccountsService().getFriendsService();
				oFriendsService.acceptFriendshipRequest(siteOwner, arguments.sender);
			</cfscript>
			
           <script>
              	controlPanel.closeEditWindow();
				controlPanel.setStatusMessage("#arguments.sender# has been added to your friends list.");
				window.location.replace("#variables.reloadPageHREF#");
            </script>
			
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- rejectFriendRequest               --->
	<!---------------------------------------->	
	<cffunction name="rejectFriendRequest" access="public" output="true">
		<cfargument name="sender" type="string" required="true" hint="The name of the account to reject as a friend">
		<cfset var oFriendsService = 0>
		<cfset var siteOwner = variables.oPage.getOwner()>
		
		<cftry>
			<cfscript>
				validateOwner();	
				
				if(arguments.sender eq "") throw("The sender cannot be empty");
				
				oFriendsService = application.homePortals.getAccountsService().getFriendsService();
				oFriendsService.removeFriendshipRequest(siteOwner, arguments.sender);
				oFriendsService.removeFriendshipRequest(arguments.sender, siteOwner);
			</cfscript>
			
           <script>
              	controlPanel.closeEditWindow();
				controlPanel.setStatusMessage("The request from #arguments.sender# has been removed.");
				window.location.replace("#variables.reloadPageHREF#");
            </script>
			
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- inviteFriend		           --->
	<!---------------------------------------->	
	<cffunction name="inviteFriend" access="public" output="true">
		<cfargument name="email" type="string" required="true" hint="The name of the account to add as a friend">
		<cfset var oMembers = 0>
		<cfset var qryOwnerAccount = 0>
		<cfset var qryOwnerMember = 0>
		<cfset var siteOwner = variables.oPage.getOwner()>
		
		<cftry>
			<cfscript>
				validateOwner();	
				if(arguments.email eq "") throw("The email address cannot be empty");

				// get site owner membership info
				oMembers = CreateObject("component", "xilya.components.members").init();
				qryOwnerAccount = application.homePortals.getAccountsService().getAccountByUsername(siteOwner);
				qryOwnerMember = oMembers.getByAccountID(qryOwnerAccount.userID);				
			</cfscript>
			
			<cfmail from="info@xilya.com" 
					to="#arguments.email#" 
					bcc="info@xilya.com"
					subject="#siteOwner# invites you to join Xilya.com" type="html">
				
				<div style="background-color:##000;">
					<a href="http://www.xilya.com"><img src="http://www.xilya.com/images/bgtop_small.jpg" alt="Xilya.com - Your Space, Your Work" border="0"></a>
				</div>

				<div style="margin:20px;font-family:'Trebuchet Ms',sans-serif;font-size:12px;line-height:14px;">
					Hello!
					
					<p>#qryOwnerMember.firstName# #qryOwnerMember.lastName# (#siteOwner#) is inviting you to join a new online community
						called <a href="http://www.xilya.com">Xilya.com</a> and form part of his network</p>
					
					<p>To create an account at Xilya.com, <a href="http://www.xilya.com/register">Click Here</a> or visit
					the following URL:</p>
					
					<p align="center"><a href="http://www.xilya.com/register">http://www.xilya.com/register</a></p>
					
					<p>Once you create your account, let #siteOwner# know by adding #siteOwner# to your friends list.</p>
						
					<p>&nbsp;</p>
				</div>

				<div style="font-size:10px;">
					*** This email has been sent automatically by Xilya.com on behalf of
					#qryOwnerMember.firstName# #qryOwnerMember.lastName# (#siteOwner#).
				</div>
			</cfmail>
			
           <script>
              	controlPanel.closeEditWindow();
				controlPanel.setStatusMessage("An email has been sent to #arguments.email# inviting him/her to be part of your network.");
            </script>
			
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	
	
	
	<!---****************************************************************--->
	<!---          R E S O U R C E     M A N A G E M E N T               --->
	<!---****************************************************************--->
	
	<!---------------------------------------->
	<!--- addToMyFeeds			           --->
	<!---------------------------------------->	
	<cffunction name="addToMyFeeds" access="public" output="true">
		<cfargument name="rssURL" type="string" required="true" hint="The URL of the feed">
		<cfargument name="feedName" type="string" required="true" hint="resource name">
		<cfargument name="access" type="string" required="true" hint="access type for resource">
		<cfargument name="description" type="string" required="true" hint="resource description">
		
	    <cfset var oHP = application.homePortals>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = "feed">
		<cfset var siteOwner = variables.oPage.getOwner()>
		<cfset var oResourceBean = 0>
		<cfset var oResourceLibrary = 0>
		
		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.rssURL eq "") throw("The feed URL cannot be empty"); 
				if(arguments.feedName eq "") throw("The feed title cannot be empty"); 

				if(left(arguments.rssURL,4) neq "http") arguments.rssURL = "http://" & arguments.rssURL;

				// create the bean for the new resource
				oResourceBean = createObject("component","Home.Components.resourceBean").init();	
				oResourceBean.setID(createUUID());
				oResourceBean.setName(arguments.feedName);
				oResourceBean.setHREF(arguments.rssURL);
				oResourceBean.setOwner(siteOwner);
				oResourceBean.setAccessType(arguments.access); 
				oResourceBean.setDescription(arguments.description); 
				oResourceBean.setPackage(siteOwner); 
				oResourceBean.setType(resourceType); 

				/// add the new resource to the library
				oResourceLibrary = createObject("component","Home.Components.resourceLibrary").init(resourceLibraryPath);
				oResourceLibrary.saveResource(oResourceBean);
			
				// update catalog
				oHP.getCatalog().reloadPackage(resourceType,siteOwner);
				
				// add the feed to the page
				addFeed(arguments.rssURL,"");
            </cfscript>

			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message & cfcatch.Detail)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>	
	
	<!------------------------------------------------->
	<!--- removeFromMyFeeds	                       ---->
	<!------------------------------------------------->
	<cffunction name="removeFromMyFeeds" access="public" returntype="void">
		<cfargument name="id" type="string" required="true" hint="resource id">
	
		<cfset var oHP = application.homePortals>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = "feed">
		<cfset var siteOwner = variables.oPage.getOwner()>
		<cfset var oResourceBean = 0>
		<cfset var oResourceLibrary = 0>		
		
		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.id eq "") throw("The feed id cannot be empty"); 

				/// remove resource from the library
				oResourceLibrary = createObject("component","Home.Components.resourceLibrary").init(resourceLibraryPath);
				oResourceLibrary.deleteResource(arguments.id, resourceType, siteOwner);

				// remove from catalog
				oHP.getCatalog().deleteResourceNode(resourceType, arguments.id);
	        </cfscript>
			<script>controlPanel.getView('Feeds');</script>
	
			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message & cfcatch.Detail)#");
				</script>
			</cfcatch>
		</cftry>	
	</cffunction>		
	
	<!---------------------------------------->
	<!--- addToMyContent		           --->
	<!---------------------------------------->	
	<cffunction name="addToMyContent" access="public" output="true">
		<cfargument name="contentName" type="string" required="true" hint="resource id">
		<cfargument name="access" type="string" required="true" hint="access type for resource">
		<cfargument name="description" type="string" required="true" hint="resource description">
		<cfargument name="body" type="string" required="true" hint="resource body">
		
 		<cfset var oHP = application.homePortals>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = "content">
		<cfset var siteOwner = variables.oPage.getOwner()>
		<cfset var oResourceBean = 0>
		<cfset var oResourceLibrary = 0>	
		<cfset var id = createUUID()>	

		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.contentName eq "") throw("The content name cannot be empty"); 
				if(arguments.body eq "") throw("The content body cannot be empty"); 

				// create the bean for the new resource
				oResourceBean = createObject("component","Home.Components.resourceBean").init();	
				oResourceBean.setID(id);
				oResourceBean.setName(arguments.contentName);
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

				// add the content to the page
				addContent(id);
            </cfscript>

			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message & cfcatch.Detail)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>	
	
	<!------------------------------------------------->
	<!--- removeFromMyContent                      ---->
	<!------------------------------------------------->
	<cffunction name="removeFromMyContent" access="public" returntype="void">
		<cfargument name="id" type="string" required="true" hint="resource id">
	
 		<cfset var oHP = application.homePortals>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var resourceType = "content">
		<cfset var siteOwner = variables.oPage.getOwner()>
		<cfset var oResourceBean = 0>
		<cfset var oResourceLibrary = 0>		
		
		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.id eq "") throw("The content id cannot be empty"); 

				/// remove resource from the library
				oResourceLibrary = createObject("component","Home.Components.resourceLibrary").init(resourceLibraryPath);
				oResourceLibrary.deleteResource(arguments.id, resourceType, siteOwner);

				// remove from catalog
				oHP.getCatalog().deleteResourceNode(resourceType, arguments.id);
	        </cfscript>
			<script>controlPanel.getView('Content');</script>
	
			<cfcatch type="any">
				<script>
					<cfoutput>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message & cfcatch.Detail)#");</cfoutput>
				</script>
			</cfcatch>
		</cftry>	
	</cffunction>		

	<!---------------------------------------->
	<!--- setResourceAccess	           --->
	<!---------------------------------------->	
	<cffunction name="setResourceAccess" access="public" output="true">
		<cfargument name="resourceType" type="string" required="true" hint="type of resource">
		<cfargument name="id" type="string" required="true" hint="resource id">
		<cfargument name="access" type="string" required="true" hint="access type for resource">
		
        <cfset var xmlDoc = 0>
        <cfset var xmlNode = 0>
		<cfset var oHP = application.homePortals>
		<cfset var resourceLibraryPath = oHP.getConfig().getResourceLibraryPath()>
		<cfset var packageDir = "">
		<cfset var siteOwner = variables.oPage.getOwner()>
		<cfset var href = "">
		
		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.id eq "") throw("The content name cannot be empty"); 
				if(arguments.access eq "") throw("The access type cannot be empty"); 
				if(arguments.resourceType eq "") throw("The resource type type cannot be empty"); 

				// get resource bean
				oResourceBean = oHP.getCatalog().getResourceNode(arguments.resourceType, arguments.id);
				oResourceBean.setAccessType(arguments.access); 

				// save changes to library
				oResourceLibrary = createObject("component","Home.Components.resourceLibrary").init(resourceLibraryPath);
				oResourceLibrary.saveResource(oResourceBean);
			
				// reload resource
				oHP.getCatalog().reloadPackage(arguments.resourceType, siteOwner);
            </cfscript>
			<script>controlPanel.getView('Sharing',{resourceType:'#arguments.resourceType#'});</script>
	
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message & cfcatch.Detail)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>	
		
	
	
	
	
	<!---****************************************************************--->
	<!---               A C C O U N T    M E T H O D S                   --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- doLogoff        	               --->
	<!---------------------------------------->	
	<cffunction name="doLogoff" access="public" output="true">
		<cfset var oUserRegistry = "">
		<cfset var homePagePath = "/">

		<!--- logout user from session --->		
		<cfset application.homePortals.getAccountsService().logoutUser()>
			
		<!--- remove autologin cookies --->	
		<cfcookie name="homeportals_username" value="" expires="now">			
		<cfcookie name="homeportals_userKey" value="" expires="now">
			
		<cfif cgi.SERVER_NAME eq "localhost">
			<cfset homePagePath = "/xilya.com">
		</cfif>
			
		<script>
			document.location='#homePagePath#'
		</script>
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
			
			oUserRegistry = createObject("Component","Home.Components.userRegistry").init();
			stRet = oUserRegistry.getUserInfo();	// information about the logged-in user		
			stRet.isOwner = (stRet.username eq variables.oPage.getOwner());
		</cfscript>

		<cfreturn stRet>
	</cffunction>	

	<!---------------------------------------->
	<!--- renderView                       --->
	<!---------------------------------------->		
	<cffunction name="renderView" access="private" returntype="string">
		<cfargument name="viewName" type="string" required="yes">
		<cfargument name="ownerOnly" type="boolean" required="no" default="true"
					hint="Flag that tells that only the page owner can access this page">
		
		<cfset var tmpHTML = "">
		<cfset var viewHREF = "views/" & arguments.viewName & ".cfm">
		<cfset var stUser = structNew()>
		<cfset var bRenderView = true>
		<cfset var publicViews = "vwFeedback,vwLogin,vwCreateAccount,vwError,vwNotAuthorized">
		
		<cfparam name="arguments.standAlone" default="true" type="boolean">

		<cftry>
			<cfset this.currentView = arguments.viewName>
	
			<cfif not ListFindNoCase(publicViews, arguments.viewName)>
				<!--- get info on whether a user is logged in --->
				<cfset stUser = getUserInfo()>
				
				<cfif stUser.username eq "">
					<cfsavecontent variable="tmpHTML">
						<cfset arguments.standAlone = false>
						<cfinclude template="views/vwLogin.cfm">				
					</cfsavecontent>
					
				<cfelseif Not stUser.isOwner>
					<cfsavecontent variable="tmpHTML">
						<cfinclude template="views/vwNotAuthorized.cfm">				
					</cfsavecontent>
				</cfif>
			</cfif>
			
			<cfif tmpHTML eq "">
				<cfsavecontent variable="tmpHTML">
					<cfinclude template="#viewHREF#">				
				</cfsavecontent>
			</cfif>
		

			<cfcatch type="lock">
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
		
		<cfset var stUser = structNew()>
		<cfset var imgRoot = variables.accountsRoot & "/default">

		<cftry>
			<!--- get info on whether a user is logged in --->
			<cfset stUser = getUserInfo()>

			<cfcatch type="any">
				<cfset args = structNew()>
				<cfset args.viewName = "vwError">
				<cfset args.errMessage = cfcatch.Message>
				<cfinvoke method="renderView" 
							argumentcollection="#args#" 
							returnvariable="tmpHTML">
				<cfset arguments.html = tmpHTML>
			</cfcatch>
		</cftry>
		
		<Cfinclude template="layouts/controlPanelPage.cfm">
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
	<!--- savePage                         --->
	<!---------------------------------------->
	<cffunction name="savePage" access="private" hint="Stores a HomePortals page">
		<cfargument name="pageURL" type="string" hint="Path for the page as a relative URL">
		<cfargument name="pageContent" type="string" hint="page content">

		<!--- store page --->
		<cffile action="write" file="#expandpath(arguments.pageURL)#" output="#arguments.pageContent#">
	</cffunction>
	
	<!---------------------------------------->
	<!--- removeFile                       --->
	<!---------------------------------------->
	<cffunction name="removeFile" access="private" hint="deletes a file">
		<cfargument name="href" type="string" hint="relative path to page">

		<cffile action="delete" file="#expandpath(arguments.href)#">
	</cffunction>	

	<!---------------------------------------->
	<!--- selectTab                        --->
	<!---------------------------------------->
	<cffunction name="selectTab" access="private">
		<cfargument name="tab" type="string" required="yes">
		<cfoutput>	
			<script>
				<cfif arguments.tab eq "Page">
					$("cp_PageTab").className="cp_selectedTab";
					$("cp_SiteTab").className="";
				<cfelse>
					$("cp_PageTab").className="";
					$("cp_SiteTab").className="cp_selectedTab";
				</cfif>
			</script>
		</cfoutput>
	</cffunction>

	<!---------------------------------------->
	<!--- validateOwner                    --->
	<!---------------------------------------->
	<cffunction name="validateOwner" access="private" hint="Throws an error if the current user is not the page owner" returntype="boolean">
		<cfif Not getUserInfo().isOwner>
			<cfthrow message="You must sign-in as the current page owner to access this feature." type="custom">
		<cfelse>
			<cfreturn true> 
		</cfif>
	</cffunction>

	<!---------------------------------------->
	<!--- getResourcesForAccount           --->
	<!---------------------------------------->
	<cffunction name="getResourcesForAccount" access="private" hint="Retrieves a query with all resources of the given type available for a given account" returntype="query">
		<cfargument name="resourceType" type="string" required="yes">

		<cfscript>
			var aAccess = arrayNew(1);
			var j = 1;
			var oHP = application.homePortals;
			var owner = variables.oPage.getOwner();
		
			var oFriendsService = oHP.getAccountsService().getFriendsService();
			var qryFriends = oFriendsService.getFriends(owner);
			var lstFriends = valueList(qryFriends.userName);
			
			var qryResources = oHP.getCatalog().getResourcesByType(arguments.resourceType);
			
			for(j=1;j lte qryResources.recordCount;j=j+1) {
				aAccess[j] = qryResources.access[j] eq "general"
							or qryResources.access[j] eq ""
							or qryResources.owner[j] eq owner
							or (qryResources.access[j] eq "friend" and listFindNoCase(lstFriends, qryResources.owner[j]));
			}
			queryAddColumn(qryResources, "hasAccess", aAccess);
		</cfscript>
		
		<cfquery name="qryResources" dbtype="query">
			SELECT *
				FROM qryResources
				WHERE hasAccess = 1
		</cfquery>

		<cfreturn qryResources>
	</cffunction>

	<!---------------------------------------->
	<!--- createDir				           --->
	<!---------------------------------------->
	<cffunction name="createDir" access="private" returnttye="void">
		<cfargument name="path" type="string" required="true">
		<cfdirectory action="create" directory="#ExpandPath(arguments.path)#">
	</cffunction>

	<!---------------------------------------->
	<!--- setControlPanelTitle                --->
	<!---------------------------------------->
	<cffunction name="setControlPanelTitle" access="private" output="true">
		<cfargument name="label" type="string" required="yes">
		<cfargument name="img" type="string" required="yes">
		<cfset variables.controlPanelTitle = arguments.label>
		<cfset variables.controlPanelIcon = arguments.img>
		<script>
			$("cp_TitleBar_icon").src="#variables.imgRoot#/#variables.controlPanelIcon#.png";
			$("cp_TitleBar_label").innerHTML="#variables.controlPanelTitle#";
		</script>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getSite			                --->
	<!---------------------------------------->
	<cffunction name="getSite" access="private" output="false" returntype="Home.Components.site">
		<cfscript>
			var oAccountsService = application.homePortals.getAccountsService();
			var owner = variables.oPage.getOwner();
			return createObject("component","Home.Components.site").init(owner, oAccountsService);
		</cfscript>
	</cffunction>
		
	<!-------------------------------------->
	<!--- addModuleToPage                --->
	<!-------------------------------------->
	<cffunction name="addModuleToPage" access="private" returntype="struct">
		<cfargument name="moduleID" type="string" required="yes">
		<cfargument name="locationID" type="string" required="yes">
		<cfargument name="initializeModule" type="boolean" required="no" default="false">
		<cfargument name="moduleAttributes" type="struct" required="no" default="#structNew()#">
		
		<cfscript>
	        var oModuleController = 0;
	        var tmpCFCPath = "";
	        var oHP = 0;
	        var oResourceBean = 0;
	        var moduleClassName = "";
	        var newModuleID = ""; 
			var oCatalog = 0;
			var moduleLibraryPath = "";
			var stRet = structNew();
			
			// prepare return struct
			stRet.locationID = "";
			stRet.moduleID = "";
	
			oHP = application.homePortals;
			oCatalog = oHP.getCatalog();
			moduleLibraryPath = oHP.getConfig().getResourceLibraryPath() & "/modules/";

            // get info for new module
            oResourceBean = oCatalog.getResourceNode("module", arguments.moduleID);
			
         	// get location info
         	if(arguments.locationID neq "") {
				qryLocation = variables.oPage.getLocationByName(arguments.locationID);
				if(qryLocation.recordCount eq 0)
					throw("The selected location does not exist on the page");
         	} else {
               	// get location info
               	qryLocation = variables.oPage.getLocations();
               	arguments.locationID = qryLocation.name;         	
         	}

			// add the module to the page
			newModuleID = variables.oPage.addModule(oResourceBean, arguments.locationID, arguments.moduleAttributes);

	
			// initialize module if requested (this does not work very well!!)
			if(arguments.initializeModule) {
			
	            // build module class name
	            moduleClassName = moduleLibraryPath & oResourceBean.getName();
	            moduleClassName = replace(moduleClassName,"/",".","ALL");
	            if(left(moduleClassName,1) eq ".")
	                moduleClassName = right(moduleClassName, len(moduleClassName)-1);
	
	            // get moduleController
	            oModuleController = createObject("component", "Home.Components.moduleController");
	
	            stPageSettings = duplicate(variables.oPage.getModule(newModuleID));
	            stPageSettings["_page"] = structNew();
				stPageSettings["_page"].owner = variables.oPage.getOwner();
				stPageSettings["_page"].href = variables.oPage.getHREF();                
	            
	            // initialize new module
	            oModuleController.init(newModuleID,
	                                    moduleClassName,
	                                    stPageSettings,
	                                    true,
	                                    "local",
	                                    oHP.getConfig());
			}
	
			// prepare return struct
			stRet.locationID = qryLocation.id;
			stRet.moduleID = newModuleID;
			
			return stRet;
		</cfscript>
	</cffunction>
		
</cfcomponent>