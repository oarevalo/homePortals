<cfcomponent output="false" hint="Main component for the HomePortals framework. This component provides the interface for the initialization of the entire application as well as the loading, parsing and rendering of pages">
<!---
/*
	Copyright 2007 - Oscar Arevalo (http://www.oscararevalo.com)

    This file is part of HomePortals.

    HomePortals is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    HomePortals is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with HomePortals.  If not, see <http://www.gnu.org/licenses/>.

*/ 
---->
	
	<cfscript>
		variables.hpEngineRoot = "/Home";		// root directory for the homeportals engine
		variables.appRoot = "";					// Root directory of the application as a relative URL
		variables.oHomePortalsConfigBean = 0;	// bean to store config settings
		variables.stPageCache = structNew();	// a cache to store pages
		variables.stSiteCache = structNew();	// a cache to store sites
		variables.configFilePath = "Config/homePortals-config.xml";  
												// path of the config file relative to the root of the application
		
		variables.oAccountsService = 0;			// a handle to the accoutns service
		variables.oCatalog = 0;					// a handle to the resources catalog 
		
		variables.stTimers = structNew();
	</cfscript>
	
	
	<!--------------------------------------->
	<!----  init	 					----->
	<!--------------------------------------->
	<cffunction name="init" access="public" returntype="homePortals" hint="Constructor">
		<cfargument name="appRoot" type="string" required="false" default="" hint="Root directory of the application as a relative URL">
		<cfscript>
			var pathSeparator =  createObject("java","java.lang.System").getProperty("file.separator");
			var defaultConfigFilePath = "";
			var oModuleProperties = 0;
			var start = getTickCount();
			var oCacheRegistry = 0;
			var oCacheService = 0;
			
			variables.appRoot = arguments.appRoot;

			// create object to store configuration settings
			variables.oHomePortalsConfigBean = createObject("component", "homePortalsConfigBean").init();

			// load default configuration settings
			defaultConfigFilePath = getDirectoryFromPath(getCurrentTemplatePath()) & pathSeparator & ".." & pathSeparator & "Config" & pathSeparator & "homePortals-config.xml";
			variables.oHomePortalsConfigBean.load(defaultConfigFilePath);

			// load configuration settings for the application (overrides specific settings)
			if(arguments.appRoot neq "") {
				configFilePath = listAppend(variables.appRoot, variables.configFilePath, "/");
				variables.oHomePortalsConfigBean.load(expandPath(configFilePath));
			} else {
				arguments.appRoot = variables.oHomePortalsConfigBean.getAppRoot();
			}
			
			// initialize accounts service
			variables.oAccountsService = CreateObject("Component","accounts").init(variables.oHomePortalsConfigBean);

			// initialize resource catalog
			variables.oCatalog = CreateObject("Component","catalog").init(variables.oHomePortalsConfigBean.getResourceLibraryPath());
			
			// initialize cache registry
			oCacheRegistry = createObject("component","cacheRegistry").init();
			oCacheRegistry.flush();		// clear registry

			// crate page cache instances
			oCacheService = createObject("component","cacheService").init(variables.oHomePortalsConfigBean.getPageCacheSize(), 
																			variables.oHomePortalsConfigBean.getPageCacheTTL());
			oCacheRegistry.register("hpPageCache", oCacheService);

			// load module properties and store in cache
			oModuleProperties = createObject("component","moduleProperties").init(variables.oHomePortalsConfigBean);
			oCacheService = createObject("component","cacheService").init(1,0);
			oCacheRegistry.register("hpModuleProperties", oCacheService);
			oCacheService.store("oModuleProperties", oModuleProperties);

			variables.stTimers.init = getTickCount()-start;
			return this;
		</cfscript>
	</cffunction>
	
	
	<!--------------------------------------->
	<!----  loadPage 					----->
	<!--------------------------------------->
	<cffunction name="loadPage" access="public" returntype="pageRenderer" hint="Loads and parses a HomePortals page">
		<cfargument name="account" type="string" required="true" hint="Account name, if empty will load the default account">
		<cfargument name="page" type="string" required="true" hint="Page within the account, if empty will load the default page for the account">
		<cfscript>
			var oPageRenderer = 0;
			var oSite = 0;		
			var pageHREF = "";
			var pageAccessLevel = "";
			var start = getTickCount();
						
			// determine the page to load
			if(arguments.account eq "") arguments.account = getConfig().getDefaultAccount();
			if(arguments.page eq "") 
				pageHREF = getAccountsService().getAccountDefaultPage(arguments.account);
			else
				pageHREF = getConfig().getAccountsRoot() & "/" & arguments.account & "/layouts/" & arguments.page & ".xml";

			// load page from cache
			oPageRenderer = loadPageRenderer(pageHREF);	

			// validate access to page
			validatePageAccess( oPageRenderer.getAccess() , oPageRenderer.getOwner() );

			// clear persistent storage for module data
			oConfigBeanStore = createObject("component","configBeanStore");
			oConfigBeanStore.flushAll();
	
			// process modules on page		
			oPageRenderer.processModules();
			
			variables.stTimers.loadPage = getTickCount()-start;
			return oPageRenderer;
		</cfscript>
	</cffunction>
	
	
	<!--------------------------------------->
	<!----  getConfig					----->
	<!--------------------------------------->
	<cffunction name="getConfig" access="public" returntype="homePortalsConfigBean" hint="Returns the homeportals config bean for the application">
		<cfreturn variables.oHomePortalsConfigBean>
	</cffunction>

	<!--------------------------------------->
	<!----  getConfigFilePath			----->
	<!--------------------------------------->
	<cffunction name="getConfigFilePath" access="public" returntype="string" hint="Returns the path of the config file relative to the root of the application">
		<cfreturn variables.configFilePath>
	</cffunction>

	<!--------------------------------------->
	<!----  getVersion					----->
	<!--------------------------------------->
	<cffunction name="getVersion" access="public" returntype="string" hint="Returns the HomePortals version tag">
		<cfreturn variables.oHomePortalsConfigBean.getVersion()>
	</cffunction>

	<!--------------------------------------->
	<!----  getAccountsService			----->
	<!--------------------------------------->
	<cffunction name="getAccountsService" access="public" returntype="accounts" hint="Returns the accounts service">
		<cfreturn variables.oAccountsService>
	</cffunction>

	<!--------------------------------------->
	<!----  getCatalog					----->
	<!--------------------------------------->
	<cffunction name="getCatalog" access="public" returntype="catalog" hint="Returns the resources catalog">
		<cfreturn variables.oCatalog>
	</cffunction>

	<!---------------------------------------->
	<!--- getTimers						   --->
	<!---------------------------------------->	
	<cffunction name="getTimers" access="public" returntype="any" hint="Returns the timers for this object">
		<cfreturn variables.stTimers>
	</cffunction>	
		
	<!--------------------------------------->
	<!----  Private Methods  			----->
	<!--------------------------------------->
	<cffunction name="dump" access="private">
		<cfargument name="var" type="any">
		<cfargument name="console" type="boolean" required="false" default="false">
		<!--- dump to console is disabled because of compatibility with Railo, uncomment for debugging in CF8 
		<cfif arguments.console>
			<cfdump var="#arguments.var#" output="console">
		<cfelse>
			<cfdump var="#arguments.var#">
		</cfif> --->
		<cfdump var="#arguments.var#">
	</cffunction>

	<cffunction name="abort" access="private">
		<cfabort>
	</cffunction>
		
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>

	<cffunction name="getFileLastModified" returntype="date" access="private" hint="Returns the date the file was last modified">
		<cfargument name="fileName" type="string" required="true" hint="full path to the file">
		<cfset var fileObj = createObject("java","java.io.File").init(arguments.fileName)>
		<cfset var fileDate = createObject("java","java.util.Date").init(fileObj.lastModified())>		
		<cfreturn fileDate>
	</cffunction>
				
	<cffunction name="loadPageRenderer" access="private" returntype="pageRenderer">
		<cfargument name="pageHREF" type="string" required="true">
		<cfscript>
			var oPageRenderer = 0;
			var pageCacheKey = hash(arguments.pageHREF);
			var start = getTickCount();
			var oCacheRegistry = createObject("component","cacheRegistry").init();			
			var oCache = oCacheRegistry.getCache("hpPageCache");
			var fileLastModDate = getFileLastModified(expandPath(arguments.pageHREF));

			// if the page exists on the cache, and the page hasnt been modified after
			// storing it on the cache, then get it from the cache
			try {
				oPageRenderer = oCache.retrieveIfNewer(pageCacheKey, fileLastModDate);
			
			} catch(homePortals.cacheService.itemNotFound e) {
				// page is not in cache, so load the page
				oPageRenderer = createObject("component","pageRenderer").init(arguments.pageHREF, this);
			
				// store page in cache
				oCache.store(pageCacheKey, oPageRenderer);
			}
			
			variables.stTimers.loadPageRenderer = getTickCount()-start;
			return oPageRenderer;
		</cfscript>
	</cffunction>

	<cffunction name="validatePageAccess" access="private" returntype="void" hint="Validates access to a page">
		<cfargument name="accessLevel" type="string" required="true">
		<cfargument name="owner" type="string" required="true">

		<cfscript>
			var oUserRegistry = 0;
			var stUserInfo = 0;
			var oFriendsService = 0;
			var start = getTickCount();
			
			if(arguments.accessLevel eq "friend" or arguments.accessLevel eq "owner") {
				// access to this page is restricted, so we must
				// check who is the current user
				oUserRegistry = createObject("component","userRegistry").init();
				stUserInfo = oUserRegistry.getUserInfo();
				
				// if not user logged in, then get out
				if(stUserInfo.userID eq "")
					throw("Access to this page is restricted. Please sign-in to validate access","","homePortals.engine.unauthorizedAccess");	

				// if logged in is the owner, then we are good
				if(stUserInfo.userName eq arguments.owner) 
					return;

				// validate owner-only page
				if(arguments.accessLevel eq "owner") 
					throw("Access to this page is restricted to the page owner.","","homePortals.engine.unauthorizedAccess");	
					
				// check that user is friend	
				if(arguments.accessLevel eq "friend") {
					
					// check if current friend is a friend of the owner
					oFriendsService = variables.oAccountsService.getFriendsService();
					
					if( not oFriendsService.isFriend(arguments.owner, stUserInfo.username) ) {
						throw("You must be a friend of the owner to access this page.","","homePortals.engine.unauthorizedAccess");	
					}
				
				}	
			} 
			
			variables.stTimers.validatePageAccess = getTickCount()-start;
		</cfscript>
	</cffunction>

</cfcomponent>

