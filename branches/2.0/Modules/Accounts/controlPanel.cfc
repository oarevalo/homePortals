<!---
/******************************************************/
/* controlPanel.cfc									  */
/*													  */
/* This component provides functionality to           */
/* manage all aspects of a HomePortals page.          */
/*													  */
/* (c) 2005 - Oscar Arevalo							  */
/* oarevalo@cfempire.com							  */
/*													  */
/******************************************************/
--->

<cfcomponent displayname="controlPanel" hint="This component provides functionality to manage all aspects of a HomePortals page.">

	<!--- constructor code --->
	<cfscript>
		variables.oSite = 0;
		variables.oPage = 0;
		variables.oCatalog = 0;
		variables.moduleRoot = application.homePortalsRoot & "/Modules/Accounts";
		variables.imgRoot = variables.moduleRoot & "/images";
		init();
	</cfscript>

	<!---****************************************************************--->
	<!---         G E T     V I E W S     M E T H O D S                  --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- getView                          --->
	<!---------------------------------------->	
	<cffunction name="getView" access="remote" output="true">
		<cfargument name="viewName" type="string" required="yes">
		<cfargument name="useLayout" type="boolean" default="true">
		<cfset var tmpHTML = "">
	
		<cfset arguments.viewName = "vw" & arguments.viewName>

		<cfinvoke method="renderView" argumentcollection="#arguments#" returnvariable="tmpHTML">
		<cfif arguments.useLayout>
			<cfset renderPage(tmpHTML)>
		<cfelse>
			<cfset writeOutput(tmpHTML)>
		</cfif>
	</cffunction>			

	<!---------------------------------------->
	<!--- getLogin      	               --->
	<!---------------------------------------->	
	<cffunction name="getLogin" access="remote" output="true">
		<cfargument name="useLayout" type="boolean" default="true">
		<cfset var tmpHTML = "">
		<cfset arguments.viewName = "vwLogin">
		<cfset arguments.ownerOnly = false>
		<cfinvoke method="renderView" argumentcollection="#arguments#" returnvariable="tmpHTML">
		<cfif arguments.useLayout>
			<cfset renderPage(tmpHTML)>
		<cfelse>
			<cfset writeOutput(tmpHTML)>
		</cfif>
	</cffunction>	
		
	<!---------------------------------------->
	<!--- getCreateAccount 	               --->
	<!---------------------------------------->	
	<cffunction name="getCreateAccount" access="remote" output="true">
		<cfargument name="useLayout" type="boolean" default="true">
		<cfset var tmpHTML = "">
		<cfset arguments.viewName = "vwCreateAccount">
		<cfset arguments.ownerOnly = false>
		<cfinvoke method="renderView" argumentcollection="#arguments#" returnvariable="tmpHTML">
		<cfif arguments.useLayout>
			<cfset renderPage(tmpHTML)>
		<cfelse>
			<cfset writeOutput(tmpHTML)>
		</cfif>
	</cffunction>	
		
	<!---------------------------------------->
	<!--- getAccountWelcome	               --->
	<!---------------------------------------->	
	<cffunction name="getAccountWelcome" access="remote" output="true">
		<cfargument name="useLayout" type="boolean" default="true">
		<cfset var tmpHTML = "">
		<cfset arguments.viewName = "vwAccountWelcome">
		<cfset arguments.ownerOnly = false>
		<cfinvoke method="renderView" argumentcollection="#arguments#" returnvariable="tmpHTML">
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
	<cffunction name="addModule" access="remote" output="true">
		<cfargument name="moduleID" type="string" required="yes">
		<cfargument name="locationID" type="string" required="yes">
		<cfargument name="reloadAfterAddModule" type="boolean" required="no" default="false">

		<cftry>
			<cfscript>
				validateOwner();
				variables.oPage.addModule(arguments.moduleID, arguments.locationID, variables.oCatalog);
			</cfscript>
			
			<script>
				<cfif arguments.reloadAfterAddModule>
					window.location.replace("index.cfm?currentHome=#this.PageURL#&refresh=true&#RandRange(1,100)#");
					controlPanel.closeAddContentPanel();
				<cfelse>
					controlPanel.getView('Page');
				</cfif>
			</script>
			
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>		
		</cftry>
	</cffunction>	

	<!---------------------------------------->
	<!--- saveModule                       --->
	<!---------------------------------------->
	<cffunction name="saveModule" access="remote" output="true">
		<cfset var fld = "">
		<cfset var lstAllAttribs = "">
		<cfset var i = 1>
		<cfset var stAttribs = structNew()>

		<cftry>
			<cfscript>
				validateOwner();
				
				// create a structure with the module attributes
				lstAllAttribs = Arguments["_allAttribs"];
				for(i=1;i lte listLen(lstAllAttribs);i=i+1) {
					fld = listGetAt(lstAllAttribs,i);
					if(structKeyExists(Arguments,fld)) stAttribs[fld] = form[fld];
				}
				
				if(not StructKeyExists(Arguments,"container")) stAttribs.container = false;

				variables.oPage.saveModule(arguments.id, stAttribs);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Module saved.");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>		
	
	<!---------------------------------------->
	<!--- deleteModule                     --->
	<!---------------------------------------->
	<cffunction name="deleteModule" access="remote" output="true">
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
	<!--- saveProperty	                   --->
	<!---------------------------------------->		
	<cffunction name="saveProperty" access="remote" output="true">
		<cftry>
			<cfparam name="arguments.property_type" default="">
			<cfparam name="arguments.property_index" default="0">
			
			<cfscript>
				validateOwner();
				switch(arguments.property_type) {
					case "stylesheet":
						variables.oPage.saveStylesheet(arguments.property_index, arguments.href);
						break;
					case "script":
						variables.oPage.saveScripts(arguments.property_index, arguments.src);
						break;
					case "layout":
						variables.oPage.saveLocation(arguments.name, arguments.name, arguments.type, arguments.class);
						break;
					case "listener":
						variables.oPage.saveEventHandler(arguments.property_index, arguments.objectName, arguments.eventName, arguments.eventHandler);
						break;
					default:
						throw("Property type (#arguments.property_type#) not recognized.");
				}
			</cfscript>
			<script>
				controlPanel.setStatusMessage("#arguments.property_type# saved.");
				controlPanel.getView('Advanced',{propertyType:'#arguments.property_type#'});
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>			
	</cffunction>

	<!---------------------------------------->
	<!--- deleteProperty	               --->
	<!---------------------------------------->		
	<cffunction name="deleteProperty" access="remote" output="true">
		<cfparam name="arguments.property_type" default="">
		<cfparam name="arguments.property_index" default="0">
		
		<cftry>
			<cfscript>
				validateOwner();
				switch(arguments.property_type) {
					case "stylesheet":
						variables.oPage.deleteStylesheet(arguments.property_index);
						break;
					case "script":
						variables.oPage.deleteScripts(arguments.property_index);
						break;
					case "layout":
						variables.oPage.deleteLocation(arguments.property_index);
						break;
					case "listener":
						variables.oPage.deleteEventHandler(arguments.property_index);
						break;
					default:
						throw("Property type (#arguments.property_type#) not recognized.");
				}
			</cfscript>
			<script>
				controlPanel.setStatusMessage("#arguments.property_type# deleted.");
				controlPanel.getView('Advanced',{propertyType:'#arguments.property_type#'});
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>	

	<!---------------------------------------->
	<!--- deleteEventHandler	           --->
	<!---------------------------------------->		
	<cffunction name="deleteEventHandler" access="remote" output="true">
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
	<cffunction name="addEventHandler" access="remote" output="true">
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
	<cffunction name="addPage" access="remote" output="true">
		<cfargument name="pageName" default="" type="string">
		<cfargument name="pageHREF" default="" type="string">
		<cfset var newPageURL = "">
		<cftry>
			<cfscript>
				validateOwner();
				newPageURL = variables.oSite.addPage(arguments.pageName, arguments.pageHREF);
			</cfscript>
			<script>
				controlPanel.closeEditWindow();
				window.location.replace("index.cfm?currentHome=#newPageURL#&refresh=true&#RandRange(1,100)#");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>			
	</cffunction>

	<!---------------------------------------->
	<!--- deletePage		               --->
	<!---------------------------------------->	
	<cffunction name="deletePage" access="remote" output="true">
		<cfargument name="pageHREF" type="string" required="true">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oSite.deletePage(arguments.pageHREF);
			</cfscript>
			
			<!--- redirect to homepage --->
			<cflocation url="#this.accountsRoot#/#getUserInfo().username#">

			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- changeTitle	                   --->
	<!---------------------------------------->		
	<cffunction name="changeTitle" access="remote" output="true">
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
	<cffunction name="renamePage" access="remote" output="true">
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
				
				// update the site definition
				variables.oSite.setPageHREF(originalPageHREF, newPageHREF);			
			</cfscript>
			
			<script>
				controlPanel.closeEditWindow();
				window.location.replace("index.cfm?currentHome=#newPageHREF#&refresh=true&#RandRange(1,100)#");
			</script>

			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- selectSkin                       --->
	<!---------------------------------------->	
	<cffunction name="selectSkin" access="remote" output="true">
		<cfargument name="skinHREF" default="" type="string">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oPage.setSkin(arguments.skinHREF);
			</cfscript>
			<script>
				controlPanel.closeEditWindow();
				window.location.replace("index.cfm?currentHome=#this.pageURL#&refresh=true&#RandRange(1,100)#");
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- updateModuleOrder                --->
	<!---------------------------------------->	
	<cffunction name="updateModuleOrder" access="remote" output="true">
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
	<!--- savePageCSS			           --->
	<!---------------------------------------->	
	<cffunction name="savePageCSS" access="remote" output="true">
		<cfargument name="content" default="" type="string">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oPage.savePageCSS(arguments.content);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Local stylesheet saved.");
			</script>				
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- movePageUp		               --->
	<!---------------------------------------->	
	<cffunction name="movePageUp" access="remote" output="true">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to move">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oSite.movePageUp(arguments.pageHREF);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Page Moved.");
				controlPanel.getView('Site');
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- movePageDown		               --->
	<!---------------------------------------->	
	<cffunction name="movePageDown" access="remote" output="true">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to move">
		<cftry>
			<cfscript>
				validateOwner();
				variables.oSite.movePageDown(arguments.pageHREF);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Page Moved.");
				controlPanel.getView('Site');
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- setDefaultPage	               --->
	<!---------------------------------------->	
	<cffunction name="setDefaultPage" access="remote" output="true">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to set as default">
		<cftry>
			<cfscript>
				validateOwner();
				if(pageHREF eq "") throw("Page cannot be empty.");
				variables.oSite.setDefaultPage(arguments.pageHREF);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Default page set.");
				controlPanel.getView('Site');
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- setPagePrivacyStatus	           --->
	<!---------------------------------------->	
	<cffunction name="setPagePrivacyStatus" access="remote" output="true">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to set its private status">
		<cfargument name="isPrivate" type="boolean" required="true" hint="private flag.">
		<cftry>
			<cfscript>
				validateOwner();
				if(pageHREF eq "") throw("Page cannot be empty.");
				variables.oSite.setPagePrivacyStatus(arguments.pageHREF, arguments.isPrivate);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Privacy status changed.");
				controlPanel.getView('Site');
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- setSiteTitle			           --->
	<!---------------------------------------->	
	<cffunction name="setSiteTitle" access="remote" output="true">
		<cfargument name="title" type="string" required="true" hint="The new title for the site">
		<cftry>
			<cfscript>
				validateOwner();
				if(arguments.title eq "") throw("Site title cannot be empty"); 
				variables.oSite.setSiteTitle(arguments.title);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Site title changed.");
				controlPanel.getView('Site');
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- setPageNavStatus		           --->
	<!---------------------------------------->	
	<cffunction name="setPageNavStatus" access="remote" output="true">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to set whether it should appear on the nave map or not">
		<cfargument name="showInNav" type="boolean" required="true" hint="If true, then page shows in the nav bar.">
		<cftry>
			<cfscript>
				validateOwner();
				if(pageHREF eq "") throw("Page cannot be empty.");
				variables.oSite.setPageNavStatus(arguments.pageHREF, arguments.showInNav);
			</cfscript>
			<script>
				controlPanel.setStatusMessage("Nav bar status changed.");
				controlPanel.getView('Site');
			</script>
			<cfcatch type="any">
				<script>controlPanel.setStatusMessage("#jsstringformat(cfcatch.Message)#");</script>
			</cfcatch>
		</cftry>
	</cffunction>





	<!---****************************************************************--->
	<!---               A C C O U N T    M E T H O D S                   --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- doLogin        	               --->
	<!---------------------------------------->	
	<cffunction name="doLogin" access="remote" output="true">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="rememberMe" default="false" type="boolean" required="no">

		<cfset var qryUser = QueryNew("")>
		
		<cftry>
			<!--- check login --->
			<cfset qryUser = objAccounts.checkLogin(arguments.username, Arguments.password)>
			
			<cfif qryUser.RecordCount eq 0>
				<cfthrow message="Invalid username/password.">
			<cfelse>
				<cfset session.User = StructNew()>
				<cfset session.User.ID = qryUser.UserID>
				<cfset session.User.LocalKey = Hash(qryUser.email & "-" & qryUser.username)>
				<cfset session.User.qry = qryUser>
			</cfif>

			<cfif arguments.rememberMe eq 1>
				<cfcookie name="homeportals_username" value="#qryUser.username#" expires="never">			
				<cfcookie name="homeportals_userKey" value="#session.User.LocalKey#" expires="never">			
			</cfif>
			
			<span style="color:##006600;">Welcome Back!</span>
					
			<cflocation url="#this.accountsRoot#/#qryUser.username#">
					
			<cfcatch type="any">
				<span style="color:##990000;">#cfcatch.Message#</span>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- doCookieLogin        	           --->
	<!---------------------------------------->	
	<cffunction name="doCookieLogin" access="remote" output="true">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="userkey" type="string" required="yes">

		<cfset var realKey = "">
		<cfset var qry = "">

		<cftry>
			<!--- get info on requested user --->
			<cfset qry = objAccounts.getAccountByUsername(arguments.username)>

			<!--- if user found, then authenticate user --->
			<cfif qry.RecordCount gt 0>
				<!--- build the real key that the user needs to authenticate --->
				<cfset realKey = Hash(qry.email & "-" & qry.username)>
				
				<!--- if provided key is the same as the real key, then user is authenticated --->
				<cfif arguments.userkey eq realkey>
					<cfset session.User = StructNew()>
					<cfset session.User.ID = qry.UserID>
					<cfset session.User.LocalKey = Hash(qry.email & "-" & qry.username)>
					<cfset session.User.qry = qry>
				</cfif>
			</cfif>

			<cfcatch type="any">
				<span style="color:##990000;">#cfcatch.Message#<br>#cfcatch.Detail#</span>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- doLogoff        	               --->
	<!---------------------------------------->	
	<cffunction name="doLogoff" access="remote" output="true">
		<cfset var username = "">
		
		<cftry>
			<cfif IsDefined("session.user") and IsDefined("Session.user.qry")>
				<cfset username = session.user.qry.username>
				
				<!--- clear user from session --->
				<cfset session.user = "">
				
				<!--- delete cookies (in case autologin was enabled) --->
				<cfcookie name="homeportals_username" value="" expires="never">			
				<cfcookie name="homeportals_userKey" value="" expires="never">	
	
				<!--- redirect to user public homepage --->
				<cflocation url="#this.accountsRoot#/#username#">
			</cfif>
			
			<cfcatch type="any">
				<!--- redirect to user public homepage --->
				<cflocation url="#this.accountsRoot#/#username#">
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- doCreateAccount     	           --->
	<!---------------------------------------->	
	<cffunction name="doCreateAccount" access="remote" hint="Creates an account and sets up the account environment">
		<cfargument name="username" required="yes" type="string">
		<cfargument name="password" required="yes" type="string">
		<cfargument name="password2" required="yes" type="string">
		<cfargument name="email" required="no" type="string">
		
		<cfset var errMsg = "">
		
		<cftry>
			<!--- check that public account creation is enabled --->
			<cflock scope="application" type="readonly" timeout="10">
				<cfset allowRegister = application.HomePortalsAccountsConfig.allowRegisterAccount>
			</cflock>
			
			<cfif Not allowRegister>
				<cfthrow message="Public account creation in this site is not allowed. To create an account please contact the site administrator.">
			</cfif>

			<!--- validate arguments --->
			<cfscript>
				lstFlds = "Email,Password2,Password,Username";
				for(i=1;i lte ListLen(lstFlds);i=i+1) 
					if(Evaluate("arguments." & ListGetAt(lstFlds,i)) eq "") errMsg = ListGetAt(lstFlds,i) & " is required";
	
				if(Arguments.Password neq Arguments.Password2) errMsg = "Both passwords must match.";
			</cfscript>
			<cfif errMsg neq "">
				<cfthrow message="#errMsg#">
			</cfif>
	
			<!--- create account --->
			<cfset objAccounts.createAccount(arguments.username, arguments.password, arguments.email)>			

			<!--- login user --->
			<cfset doLogin(Arguments.Username, Arguments.Password)>

			<cfcatch type="any">
				<cfdump var="#cfcatch.tagContext#">
				<cfset tmpHTML = "<h3>An error ocurred while creating the account.</h3> <br>#cfcatch.Message#<br>#cfcatch.detail#">
				<cfoutput>#tmpHTML#</cfoutput>
			</cfcatch>
		</cftry>

	</cffunction>




	<!---****************************************************************--->
	<!---                P R I V A T E   M E T H O D S                   --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->	
	<cffunction name="init" access="private" hint="Initializes component.">
		<cfscript>
			var stSettings = structNew();
			var stAccountSettings = structNew();
			var bIsAccountsConfigLoaded = false;
			var tmpCFCPath = "";
			var hpRoot = application.homePortalsRoot;
			var	currentPage = "";
			var siteOwner = "";
	
			try {
				this.currentView = "";
	
				// get info about current page and user
				this.pageURL = cookie.hp_currentHome;
				this.baseDir = GetDirectoryFromPath(this.pageURL);
				this.pageName = GetFileFromPath(this.pageURL);
				this.siteURL = this.baseDir & "/../site.xml";
				siteOwner = ListGetAt(this.pageURL, 2, "/");
		
				// initialze HomePortals CFC
				tmpCFCPath = listAppend(hpRoot, "Components/homePortals", "/");
				objHomePortals = CreateObject("component", tmpCFCPath);
				objHomePortals.init(false, hpRoot);
				
				// get reference to Accounts Manager object
				objAccounts = application.accountsManager;
				
				// get reference to catalog
				variables.oCatalog = application.catalog;
		
				// get userID
				qryAccount = objAccounts.getAccountByUsername(siteOwner);
		
				// initialize Site CFC 
				tmpCFCPath = listAppend(hpRoot, "Components/site", "/");
				variables.oSite = CreateObject("component", tmpCFCPath);
				variables.oSite.init(qryAccount.userID, objAccounts);
	
				// initialize Site CFC 
				tmpCFCPath = listAppend(hpRoot, "Components/page", "/");
				variables.oPage = CreateObject("component", tmpCFCPath);
				variables.oPage.init(this.pageURL);
	
				// set variable pointing to the directory where accounts are stored 
				this.accountsRoot = objAccounts.getConfig().accountsRoot;
			} catch(any e) {
				writeoutput("<script>alert('#jsstringformat(e.message)#')</script>");	
				writeoutput("<script>closeEditWindow()</script>");	
				abort();
			}
		</cfscript>
	</cffunction>

	<!-------------------------------------->
	<!--- getUserInfo                    --->
	<!-------------------------------------->
	<cffunction name="getUserInfo" returntype="struct" hint="returns info about the current logged in user" access="public">
		<cfset var stRet = StructNew()>
		<cfset stRet.username = "">
		<cfset stRet.isOwner = false>
		
		<cfif structKeyExists(session, "homeConfig") and structKeyExists(session, "User")>
			<cfif isStruct(session.user) and structKeyExists(session.user, "qry")>
				<cfset stRet.username = session.user.qry.username>
				<cfset stRet.isOwner = (session.user.qry.username eq ListGetAt(session.homeConfig.href, 2, "/"))>
			</cfif>
		</cfif>
		
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
				
				<cfif Not IsDefined("Session.homeConfig") or stUser.username eq "">
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
		
		<cfset var stUser = structNew()>
		<cfset var imgRoot = this.accountsRoot & "/default">
		<cfset var stAccountsConfig = structNew()>
		
		<cftry>
			<!--- get info on whether a user is logged in --->
			<cfset stUser = getUserInfo()>

			<!--- get mail info --->
			<cflock scope="application" type="readonly" timeout="10">
				<cfset stAccountsConfig = application.HomePortalsAccountsConfig>
			</cflock>
						
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
		<cfargument name="pageXML" type="any" hint="xml object representing the page">

		<!--- check that is a valid xml file --->
		<cfif Not IsXML(arguments.pageXML)>
			<cfset throw("The given HomePortals page is not a valid XML document.")>
		</cfif>		

		<!--- store page --->
		<cffile action="write" file="#expandpath(arguments.pageURL)#" output="#toString(arguments.pageXML)#">
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
</cfcomponent>