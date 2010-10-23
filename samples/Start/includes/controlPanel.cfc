<!---
/******************************************************/
/* controlPanel.cfc									  */
/*													  */
/* This cfc manages backend ops for the StartPage     */
/*													  */
/* (c) 2007-2010 - Oscar Arevalo					  */
/* info@homeportals.net								  */
/*													  */
/******************************************************/
--->

<cfcomponent displayname="controlPanel" hint="This cfc manages backend ops for the StartPage">

	<!--- constructor code --->
	<cfscript>
		variables.homePortals = "";
		variables.accountsService = "";
		variables.pageHREF = "";
		variables.oPage = 0;
		variables.account = "";
		variables.reloadPageHREF = "";
		
		variables.view = "";
		variables.useLayout = true;

		variables.accountHREF = "index.cfm?account={account}";
		variables.accountPageHREF = "index.cfm?account={account}&page={page}";
	</cfscript>

	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="controlPanel" hint="Initializes component.">
		<cfargument name="homePortals" type="homePortals.components.homePortals" required="true" hint="the current homeportals instance">
		<cfargument name="pageHREF" type="string" required="true" hint="the address of the current page">
		<cfscript>
			variables.homePortals = arguments.homePortals;
			variables.accountsService = variables.homePortals.getPluginManager().getPlugin("accounts").getAccountsService();
			variables.pageHREF = arguments.pageHREF;
				
			variables.oPage = variables.homePortals.getPageProvider().load(variables.pageHREF);
			if(variables.oPage.hasProperty("owner"))	
				variables.account = variables.oPage.getProperty("owner");
			else
				variables.account = "";
			
			variables.reloadPageHREF = buildLink(variables.account, variables.pageHREF);
				
			return this;
		</cfscript>
	</cffunction>
	
	

	<!---****************************************************************--->
	<!---         D O     A C T I O N     M E T H O D S                  --->
	<!---****************************************************************--->

	<cffunction name="getView" access="public" output="true">
		<cfargument name="viewName" type="string" required="yes">
		<cfargument name="useLayout" type="boolean" default="true">
		<cfset var tmpHTML = "">
	
		<cfset variables.view = arguments.viewName>
		<cfset variables.useLayout = arguments.useLayout>

		<cfset tmpHTML = renderView(argumentCollection = arguments)>

		<cfif arguments.useLayout>
			<cfset renderPage(tmpHTML)>
		<cfelse>
			<cfset writeOutput(tmpHTML)>
		</cfif>
	</cffunction>			

	<cffunction name="addModule" access="public" output="true">
		<cfargument name="moduleID" type="string" required="yes">
		<cfargument name="locationID" type="string" required="no" default="">
		<cftry>
			<cfset addModuleToPage(arguments.moduleID, arguments.locationID)>
			<cfset savePage()>
			
            <script>
                controlPanel.closePanel();
 				window.location.replace("#variables.reloadPageHREF#");
            </script>

            <cfcatch type="any">
				#renderErrorMsg(cfcatch)#
            </cfcatch>   	
		</cftry>
	</cffunction>	

	<cffunction name="deleteModule" access="public" output="true">
		<cfargument name="moduleID" type="string" required="yes">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oPage.removeModule(arguments.moduleID);
				savePage();
			</cfscript>
			<script>
				controlPanel.removeModuleFromLayout('#arguments.moduleID#');
				controlPanel.setStatusMessage("Module has been removed.");
			</script>
			<cfcatch type="any">
				#renderErrorMsg(cfcatch)#
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="addPage" access="public" output="true">
		<cfargument name="pageName" default="" type="string">
		<cfargument name="pageHREF" default="" type="string">
		<cfset var newPageURL = "">
		<cftry>
			<cfscript>
				validateOwner();
				newPageURL = getSite().addPage(arguments.pageName, arguments.pageHREF);
				
				myNewPage = variables.homePortals.getPageProvider().load(newPageURL);
				myNewPage.setTitle( getFileFromPath(newPageURL) );
				getSite().updatePageTitle( getFileFromPath(newPageURL), getFileFromPath(newPageURL) );

				oPageProvider = variables.homePortals.getPageProvider();
				oPageProvider.save(newPageURL, myNewPage);
				
				newPageURL = buildLink(variables.account, getFileFromPath(newPageURL));
			</cfscript>
			<script>
				controlPanel.closePanel();
				window.location.replace('#newPageURL#');
			</script>
			<cfcatch type="any">
				#renderErrorMsg(cfcatch)#
			</cfcatch>
		</cftry>			
	</cffunction>

	<cffunction name="deletePage" access="public" output="true">
		<cfargument name="pageHREF" type="string" required="true">
		<cftry>
			<cfscript>
				validateOwner();
				getSite().deletePage(getFileFromPath(arguments.pageHREF));
				redirHREF = buildLink(variables.account);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Deleting page from site...");
				window.location.replace('#redirHREF#');
			</script>

			<cfcatch type="any">
				#renderErrorMsg(cfcatch)#
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="changeTitle" access="public" output="true">
		<cfargument name="title" type="string" required="yes">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oPage.setTitle(arguments.title);
				savePage();
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Title changed.");
			</script>
			<cfcatch type="any">
				#renderErrorMsg(cfcatch)#
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="renamePage" access="public" output="true">
		<cfargument name="pageName" type="string" required="true">
		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.pageName eq "") throw("The page title cannot be blank.");
		
				// rename the actual page 
				variables.oPage.setTitle(arguments.pageName);
				savePage();

				getSite().renamePage(getFileFromPath(variables.pageHREF), arguments.pageName);

				newPageHREF = arguments.pageName;
				
				// set the new reload location
				variables.reloadPageHREF = buildLink(variables.account, newPageHREF) & "&#RandRange(1,100)#";
			</cfscript>
			
			<script>
				controlPanel.closePanel();
				window.location.replace("#variables.reloadPageHREF#");
			</script>

			<cfcatch type="any">
				#renderErrorMsg(cfcatch)#
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="updateModuleOrder" access="public" output="true">
		<cfargument name="layout" type="string" required="true" hint="New layout in serialized form">
		<cfset var oPageHelper = 0>
		<cftry>
			<cfscript>
				validateOwner();
				
				// remove the '_lp' string at the end of all the layout objects
				// (this string was added so that the module css rules dont get applied
				// to the modules on the layout preview )
				arguments.layout = replace(arguments.layout,"_lp","","ALL");
				
				oPageHelper = createObject("component","homePortals.components.pageHelper").init(variables.oPage);
				oPageHelper.setModuleOrder(arguments.layout);
				
				savePage();
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Layout changed.");
			</script>
			<cfcatch type="any">
				#renderErrorMsg(cfcatch)#
			</cfcatch>
		</cftry>
	</cffunction>

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
				#renderErrorMsg(cfcatch)#
			</cfcatch>
		</cftry>
	</cffunction>

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

				addModuleToPage("rssReader", "", stAttributes);
				
				savePage();
            </cfscript>
            
            <script>
				window.location.replace("#variables.reloadPageHREF#");
              	controlPanel.closePanel();
            </script>

			<cfcatch type="any">
				#renderErrorMsg(cfcatch)#
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="doLogin" access="public" returntype="void">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfset var qryAccount = 0>
		<cftry>
			<!--- check login --->
			<cfset qryAccount = variables.accountsService.loginUser(arguments.username, hash(arguments.password))>
			<cflocation url="../#buildLink(arguments.username)#" addtoken="false">
					
			<cfcatch type="homePortals.accounts.invalidLogin">
				<cflocation url="../#variables.reloadPageHREF#&_statusMessage=Invalid%20Login" addtoken="false">
			</cfcatch>		
			<cfcatch type="any">
				<cflocation url="../#variables.reloadPageHREF#&_statusMessage=#cfcatch.message#" addtoken="false">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="doLogout" access="public" returntype="void">
		<cfset variables.accountsService.logoutUser()>
		<cflocation url="../index.cfm" addtoken="false">
	</cffunction>

	<cffunction name="doRegister" access="public" returntype="void">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfargument name="password2" type="string" required="true">
		<cfargument name="firstname" type="string" required="false" default="">
		<cfargument name="lastname" type="string" required="false" default="">
		<cfargument name="email" type="string" required="false" default="">
		<cftry>
			<cfscript>
				// validate form
				if(username eq "") throw("The username cannot be empty. Please correct.","validation");
				if(reFind("[^A-Za-z0-9_]",username)) throw("The selected username name is invalid","validation");
				if(len(username) lt 5) throw("The workarea name must be at least 5 characters long","validation");
				if(password eq "") throw("Password cannot be empty","validation");
				if(len(password) lt 6) throw("Passwords must be at least 6 characters long","validation");
				if(password neq password2) throw("The password confirmation does not match the selected passwords. Please correct.","validation");
				
				// create HomePortals account
				accountID = accountsService.createAccount(username, hash(password), firstName, lastName, email);		
								
				// login to account
				doLogin(username, password);
			</cfscript>
				
			<cfcatch type="any">
				<cflocation url="../#variables.reloadPageHREF#&_statusMessage=#cfcatch.message#" addtoken="false">
			</cfcatch>
		</cftry>
	</cffunction>



	<!---****************************************************************--->
	<!---                P R I V A T E   M E T H O D S                   --->
	<!---****************************************************************--->

	<cffunction name="getUserInfo" returntype="struct" hint="returns info about the current logged in user" access="private">
		<cfscript>
			var oUserRegistry = 0;
			var stRet = structNew();
			
			oUserRegistry = createObject("Component","homePortals.Components.userRegistry").init();
			stRet = oUserRegistry.getUserInfo();	// information about the logged-in user		
			stRet.isOwner = (stRet.username eq variables.oPage.getProperty("owner"));

			return stRet;
		</cfscript>
	</cffunction>	

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

	<cffunction name="renderPage" access="private">
		<cfargument name="html" default="" hint="contents">
		<cfinclude template="layout.cfm">
	</cffunction>
	
	<cffunction name="savePage" access="private" hint="Stores a HomePortals page">
		<cfset oPageProvider = variables.homePortals.getPageProvider()>
		<cfset oPageProvider.save(variables.pageHREF, variables.oPage)>
	</cffunction>	

	<cffunction name="validateOwner" access="private" hint="Throws an error if the current user is not the page owner" returntype="boolean">
		<cfif Not getUserInfo().isOwner>
			<cfthrow message="You must sign-in as the current page owner to access this feature." type="custom">
		<cfelse>
			<cfreturn true> 
		</cfif>
	</cffunction>

	<cffunction name="getResourcesByType" access="private" hint="Retrieves a query with all resources of the given type" returntype="query">
		<cfargument name="resourceType" type="string" required="yes">
		<cfscript>
			var oHP = variables.homePortals;
			var qryResources = oHP.getCatalog().getIndex(arguments.resourceType);
			return qryResources;
		</cfscript>
	</cffunction>

	<cffunction name="getPage" access="private" output="false" returntype="any">
		<cfreturn variables.oPage>
	</cffunction>
	
	<cffunction name="getSite" access="private" output="false" returntype="any">
		<cfscript>
			var owner = getPage().getProperty("owner");
			return variables.accountsService.getSite(owner);
		</cfscript>
	</cffunction>
		
	<cffunction name="addModuleToPage" access="private" returntype="string">
		<cfargument name="moduleID" type="string" required="yes">
		<cfargument name="locationID" type="string" required="yes">
		<cfargument name="moduleAttributes" type="struct" required="no" default="#structNew()#">
		<cfscript>
	        var oHP = 0;
	        var oResourceBean = 0;
	        var newModuleID = ""; 
			var oPageHelper = 0;
			
			oHP = variables.homePortals;

            // get info for new module
            oResourceBean = oHP.getCatalog().getResource("module", arguments.moduleID);
			
			// add the module to the page
			oPageHelper = createObject("component","homePortals.components.pageHelper").init(variables.oPage);
			newModuleID = oPageHelper.addModule(oResourceBean, arguments.locationID, arguments.moduleAttributes);

			return newModuleID;
		</cfscript>
	</cffunction>
		
	<cffunction name="buildLink" access="private" returntype="string">
		<cfargument name="account" type="string" required="true" default="">
		<cfargument name="page" type="string" required="true" default="">
		<cfset var href = "">
		<cfif arguments.page neq "">
			<cfset href = replace(variables.accountPageHREF,"{account}",arguments.account)>
			<cfset href = replace(href,"{page}",getFileFromPath(arguments.page))>
		<cfelse>
			<cfset href = replace(variables.accountHREF,"{account}",arguments.account)>
		</cfif>
		<cfreturn href>
	</cffunction>	
		
	<cffunction name="renderErrorMsg" access="private" returnType="string">
		<cfargument name="error" type="any" required="true">
		<cfset var tmp = "">
		<cfsavecontent variable="tmp">
			<script>
				<cfoutput>alert("#jsStringFormat(error.message)#");</cfoutput>
			</script>
		</cfsavecontent>
		<cfreturn tmp>
	</cffunction>


	<!---****************************************************************--->
	<!---                U T I L I T Y   M E T H O D S                   --->
	<!---****************************************************************--->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string" required="yes">
		<cfthrow message="#arguments.message#">
	</cffunction>

	<cffunction name="abort" access="private">
		<cfabort>
	</cffunction>
	
	<cffunction name="dump" access="private">
		<cfargument name="data" type="any" required="yes">
		<cfdump var="#arguments.data#">
	</cffunction>	

</cfcomponent>
