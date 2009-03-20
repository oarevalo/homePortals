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
		variables.hpEngineRoot = "/homePortals/";		// root directory for the homeportals engine
		variables.appRoot = "";					// Root directory of the application as a relative URL
		variables.oHomePortalsConfigBean = 0;	// bean to store config settings
		variables.configFilePath = "config/homePortals-config.xml";  
												// path of the config file relative to the root of the application
		
		variables.oCatalog = 0;					// a handle to the resources catalog 
		variables.oPageProvider = 0;			// a handle to the provider of pages
		variables.oPluginManager = 0;			// a handle to the object responsible for managing extension plugins
		variables.oResourceLibraryManager = 0;	// a handle to the resource library manager
		
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
			var start = getTickCount();
			var oCacheRegistry = 0;
			var oCacheService = 0;
			var oRSSService = 0;
			var ppClass = "";

			// check that appRoot has the right format
			if(right(arguments.appRoot,1) neq "/") arguments.appRoot = arguments.appRoot & "/";

			variables.appRoot = arguments.appRoot;

			// create object to store configuration settings
			variables.oHomePortalsConfigBean = createObject("component", "homePortalsConfigBean").init();

			// load default configuration settings
			defaultConfigFilePath = getDirectoryFromPath(getCurrentTemplatePath()) & pathSeparator & ".." & pathSeparator & "Config" & pathSeparator & "homePortals-config.xml";
			variables.oHomePortalsConfigBean.load(defaultConfigFilePath);

			// load configuration settings for the application (overrides specific settings)
			if(arguments.appRoot neq "" and arguments.appRoot neq variables.hpEngineRoot) {
				if(fileExists(expandPath(variables.appRoot & "/" & variables.configFilePath))) {
					variables.oHomePortalsConfigBean.load(expandPath(variables.appRoot & "/" & variables.configFilePath));
				}
			} else {
				arguments.appRoot = variables.oHomePortalsConfigBean.getAppRoot();
			}
			
			// set the appRoot to the given parameter, this way, we can get away without having a local config 
			// and only pass the appRoot on the constructor
			variables.oHomePortalsConfigBean.setAppRoot(arguments.appRoot);

			// initialize resource library manager
			variables.oResourceLibraryManager = CreateObject("Component","resourceLibraryManager").init(variables.oHomePortalsConfigBean);
			
			// initialize resource catalog
			variables.oCatalog = CreateObject("Component","catalog").init(variables.oResourceLibraryManager);

			// initialize page provider
			variables.oPageProvider = createObject("component", variables.oHomePortalsConfigBean.getPageProviderClass() ).init(variables.oHomePortalsConfigBean);
		
			// initialize cache registry
			oCacheRegistry = createObject("component","cacheRegistry").init();
			oCacheRegistry.flush();		// clear registry

			// crate page cache instances
			oCacheService = createObject("component","cacheService").init(variables.oHomePortalsConfigBean.getPageCacheSize(), 
																			variables.oHomePortalsConfigBean.getPageCacheTTL());
			oCacheRegistry.register("hpPageCache", oCacheService);


			// initialize cache for RSSService
			// (there is no need to register the service with the registry since it registers itself)
			oRSSService = createObject("component","homePortals.components.lib.RSSService").init(variables.oHomePortalsConfigBean.getRSSCacheSize(), 
																								variables.oHomePortalsConfigBean.getRSSCacheTTL());
						
			// register and initialize plugins
			variables.oPluginManager = createObject("component","pluginManager").init(this);
			
			// ask plugins to perform their own initialization tasks
			getPluginManager().notifyPlugins("appInit");
			
						
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
	<!----  load			 			----->
	<!--------------------------------------->
	<cffunction name="load" access="public" returntype="pageRenderer" hint="Loads and parses a HomePortals page">
		<cfargument name="path" type="string" required="false" default="" hint="Path in the content root for the page to load. This argument is mutually exclusive with all the rest">
		<cfargument name="pageObj" type="pageBean" required="false" hint="Instance of a pageBean object to load. This argument is mutually exclusive with all the rest">
		<cfscript>
			var pagePath = "";
			
			// no arguments, so get the overall default page
			if(arguments.path eq "" and not structKeyExists(arguments,"pageObj"))
				pagePath = getConfig().getDefaultPage();
			
			// check mutually exclusive arguments
			if(pagePath neq "") {
				return loadPage(pagePath);			
			
			} else {
				if(arguments.path neq "") {
					return loadPage(arguments.path);
									
				} else if(structKeyExists(arguments,"pageObj"))
					return loadPageBean(arguments.pageObj);
			}
			
			throw("No page to load","homePortals.noDefaultPageFound");
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
			
			// notify plugins
			arguments.pageHREF = getPluginManager().notifyPlugins("beforePageLoad", arguments.pageHREF);
			
			// if no page is given, then load default page
			if(arguments.pageHREF eq "") arguments.pageHREF = getConfig().getDefaultPage();			
						
			// load page 
			oPageLoader = createObject("component","pageLoader").init(this);
			oPageRenderer = oPageLoader.load(arguments.pageHREF);	

			// notify plugins
			oPageRenderer = getPluginManager().notifyPlugins("afterPageLoad", oPageRenderer);

			variables.stTimers.loadPage = getTickCount()-start;
			return oPageRenderer;
		</cfscript>
	</cffunction>
		
	<!--------------------------------------->
	<!----  loadPageBean				----->
	<!--------------------------------------->
	<cffunction name="loadPageBean" access="public" returntype="pageRenderer" hint="Loads and parses a HomePortals page. This method accepts an instance of a pageBean component.">
		<cfargument name="page" type="pageBean" required="true" hint="the page to load">
		<cfscript>
			var oPageRenderer = 0;
			var pageUUID = createUUID();
			var start = getTickCount();

			// notify plugins
			arguments.pageHREF = getPluginManager().notifyPlugins("beforePageLoad", pageUUID);
			
			oPageRenderer = createObject("component","pageRenderer").init(pageUUID, arguments.page, this);

			// notify plugins
			oPageRenderer = getPluginManager().notifyPlugins("afterPageLoad", oPageRenderer);

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
	<!----  getPluginManager			----->
	<!--------------------------------------->		
	<cffunction name="getPluginManager" access="public" returntype="pluginManager">
		<cfreturn variables.oPluginManager>
	</cffunction>

	<!--------------------------------------->
	<!----  getResourceLibraryManager	----->
	<!--------------------------------------->		
	<cffunction name="getResourceLibraryManager" access="public" returntype="resourceLibraryManager">
		<cfreturn variables.oResourceLibraryManager>
	</cffunction>
		
		
		
	<!--------------------------------------->
	<!----  Private Methods  			----->
	<!--------------------------------------->
	<cffunction name="dump" access="public">
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

	<cffunction name="abort" access="public">
		<cfabort>
	</cffunction>
		
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>


</cfcomponent>

