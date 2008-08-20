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
		variables.configFilePath = "Config/homePortals-config.xml";  
												// path of the config file relative to the root of the application
		
		variables.oAccountsService = 0;			// a handle to the accoutns service
		variables.oCatalog = 0;					// a handle to the resources catalog 
		variables.oPageProvider = 0;			// a handle to the provider of pages
		variables.oModuleProperties = 0;		// a handle to the an object that provides properties for modules
		
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
			var oRSSService = 0;
			var ppClass = "";
			var oConfigBeanStore = 0;
			
			variables.appRoot = arguments.appRoot;

			// create object to store configuration settings
			variables.oHomePortalsConfigBean = createObject("component", "homePortalsConfigBean").init();

			// load default configuration settings
			defaultConfigFilePath = getDirectoryFromPath(getCurrentTemplatePath()) & pathSeparator & ".." & pathSeparator & "Config" & pathSeparator & "homePortals-config.xml";
			variables.oHomePortalsConfigBean.load(defaultConfigFilePath);

			// load configuration settings for the application (overrides specific settings)
			if(arguments.appRoot neq "") {
				variables.oHomePortalsConfigBean.load(expandPath(variables.appRoot & "/" & variables.configFilePath));
			} else {
				arguments.appRoot = variables.oHomePortalsConfigBean.getAppRoot();
			}
			
			// initialize accounts service
			variables.oAccountsService = CreateObject("Component","Home.Components.accounts.accounts").init(variables.oHomePortalsConfigBean);

			// initialize resource catalog
			variables.oCatalog = CreateObject("Component","catalog").init(variables.oHomePortalsConfigBean.getResourceLibraryPath());

			// initialize page provider
			variables.oPageProvider = createObject("component","pageProvider").init(variables.oHomePortalsConfigBean);

			// load module properties
			variables.oModuleProperties = createObject("component","moduleProperties").init(variables.oHomePortalsConfigBean);
			
			// initialize cache registry
			oCacheRegistry = createObject("component","cacheRegistry").init();
			oCacheRegistry.flush();		// clear registry

			// crate page cache instances
			oCacheService = createObject("component","cacheService").init(variables.oHomePortalsConfigBean.getPageCacheSize(), 
																			variables.oHomePortalsConfigBean.getPageCacheTTL());
			oCacheRegistry.register("hpPageCache", oCacheService);


			// create and register content store cache
			oCacheService = createObject("component","cacheService").init(variables.oHomePortalsConfigBean.getPageCacheSize(), 
																			variables.oHomePortalsConfigBean.getPageCacheTTL());
			oCacheRegistry.register("hpContentStoreCache", oCacheService);


			// initialize cache for RSSService
			// (there is no need to register the service with the registry since it registers itself)
			oRSSService = createObject("component","RSSService").init(variables.oHomePortalsConfigBean.getRSSCacheSize(), 
																		variables.oHomePortalsConfigBean.getRSSCacheTTL());
			
			
			// clear all stored pages/module contexts (configbeans)
			oConfigBeanStore = createObject("component","configBeanStore").init();
			oConfigBeanStore.flushAll();
			
			variables.stTimers.init = getTickCount()-start;
			return this;
		</cfscript>
	</cffunction>
	

	<!--------------------------------------->
	<!----  reinit	 					----->
	<!--------------------------------------->
	<cffunction name="reinit" access="public" returntype="homePortals" hint="Reinitializes the homeportals instance. This will re-read the configuration and clear all caches.">
		<cfscript>
			// clear up instance variables
			variables.oHomePortalsConfigBean = 0;
			variables.oAccountsService = 0;	
			variables.oCatalog = 0;	
			variables.stTimers = structNew();
			
			// clear caches
			oCacheRegistry = createObject("component","cacheRegistry").init();
			oCacheRegistry.flush();		// clear registry
			
			// initialize application
			init(variables.appRoot);
			
			return this;
		</cfscript>
	</cffunction>

	
	<!--------------------------------------->
	<!----  loadAccountPage 			----->
	<!--------------------------------------->
	<cffunction name="loadAccountPage" access="public" returntype="pageRenderer" hint="Loads and parses a HomePortals page belonging to an account">
		<cfargument name="account" type="string" required="false" default="" hint="Account name, if empty will load the default account">
		<cfargument name="page" type="string" required="false" default="" hint="Page within the account, if empty will load the default page for the account">
		<cfscript>
			var oPageRenderer = 0;
			var oPageLoader = 0;
			var pageHREF = "";
			var start = getTickCount();
					
			// get location of page
			pageHREF = getAccountsService().getAccountPageHREF(arguments.account, arguments.page);		
			
			// load page 
			oPageLoader = createObject("component","pageLoader").init(this);
			oPageRenderer = oPageLoader.load(pageHREF);	

			// validate access to page
			getAccountsService().validatePageAccess( oPageRenderer.getPage() );

			variables.stTimers.loadAccountPage = getTickCount()-start;
			return oPageRenderer;
		</cfscript>
	</cffunction>
	
	
	<!--------------------------------------->
	<!----  loadPage 					----->
	<!--------------------------------------->
	<cffunction name="loadPage" access="public" returntype="pageRenderer" hint="Loads and parses a HomePortals page">
		<cfargument name="pageHREF" type="string" required="true" hint="the page to load">
		<cfscript>
			var oPageRenderer = 0;
			var oPageLoader = 0;
			var start = getTickCount();
			
			// if no page is given, then load default page
			if(arguments.pageHREF eq "") arguments.pageHREF = getConfig().getDefaultPage();			
						
			// load page 
			oPageLoader = createObject("component","pageLoader").init(this);
			oPageRenderer = oPageLoader.load(arguments.pageHREF);	

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
	<cffunction name="getAccountsService" access="public" returntype="Home.Components.accounts.accounts" hint="Returns the accounts service">
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
	<!----  getPageProvider				----->
	<!--------------------------------------->		
	<cffunction name="getPageProvider" access="public" returntype="pageProvider">
		<cfreturn variables.oPageProvider>
	</cffunction>

	<!--------------------------------------->
	<!----  getModuleProperties			----->
	<!--------------------------------------->		
	<cffunction name="getModuleProperties" access="public" returntype="moduleProperties">
		<cfreturn variables.oModuleProperties>
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


</cfcomponent>

