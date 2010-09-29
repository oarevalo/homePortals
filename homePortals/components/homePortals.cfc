<cfcomponent output="false" hint="Main component for the HomePortals framework. This component provides the interface for the initialization of the entire application as well as the loading, parsing and rendering of pages">
<!---
	homePortals
	http://www.homeportals.net

    This file is part of HomePortals.

	Copyright 2007-2010 Oscar Arevalo
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.	
--->
	
	<cfscript>
		/// PUBLIC PROPERTIES ///
		this.CONFIG_FILE_NAME = "homePortals-config.xml.cfm";
		this.CONFIG_FILE_DIR =  "config";
		/////////////////////////
		
		variables.hpEngineRoot = "/homePortals/";		// root directory for the homeportals engine
		variables.appRoot = "";					// Root directory of the application as a relative URL
		variables.oHomePortalsConfigBean = 0;	// bean to store config settings
		variables.configFilePath = "#this.CONFIG_FILE_DIR#/#this.CONFIG_FILE_NAME#";  
												// path of the config file relative to the root of the application
		
		variables.oCatalog = 0;					// a handle to the resources catalog 
		variables.oPageProvider = 0;			// a handle to the provider of pages
		variables.oPageLoader = 0;				// a handle to the page loader (handles the caching)
		variables.oPluginManager = 0;			// a handle to the object responsible for managing extension plugins
		variables.oResourceLibraryManager = 0;	// a handle to the resource library manager
		variables.oTemplateManager = 0;			// a handle to the template manager
		
		variables.stTimers = structNew();
	</cfscript>
	
	
	<!--------------------------------------->
	<!----  init	 					----->
	<!--------------------------------------->
	<cffunction name="init" access="public" returntype="homePortals" hint="Constructor">
		<cfargument name="appRoot" type="string" required="false" default="" hint="Root directory of the application as a relative URL">
		<cfargument name="config" type="any" required="false" hint="Provides an explicit configuration to load. This can be a an instance of homePortalsConfigBean, an XML object or a string containing the configuration. If this parameter is missing, HomePortals will try to locate a config file in the app directory" />
		<cfscript>
			var defaultConfigFilePath = "";
			var start = getTickCount();
			var aPlugins = []; 
			var pluginLoader = 0; 
			var i = 0;

			// check that appRoot has the right format
			if(right(arguments.appRoot,1) neq "/") arguments.appRoot = arguments.appRoot & "/";
			variables.appRoot = arguments.appRoot;

			// create object to store configuration settings
			variables.oHomePortalsConfigBean = createObject("component", "homePortalsConfigBean").init();

			// load default configuration settings
			defaultConfigFilePath = variables.hpEngineRoot & variables.configFilePath;
			variables.oHomePortalsConfigBean.load(expandPath(defaultConfigFilePath));

			// set the appRoot on the config bean so that it is globally accessible
			variables.oHomePortalsConfigBean.setAppRoot(arguments.appRoot);

			// load configuration settings for the application (overrides specific settings)
			if(arguments.appRoot neq variables.hpEngineRoot) {

				// create a config bean with the app configuration
				userConfigBean = createObject("component", "homePortalsConfigBean").init();

				if(structKeyExists(arguments,"config")) {
					if(isXML(arguments.config) or isXMLDoc(arguments.config))
						userConfigBean.loadXML(arguments.config);
					else if(not isSimpleValue(arguments.config))
						userConfigBean.loadXML(arguments.config.toXML());

				} else if(fileExists(expandPath(variables.appRoot & variables.configFilePath))) {
					userConfigBean.load(expandPath(variables.appRoot & variables.configFilePath));

				} else if(fileExists(expandPath(variables.appRoot & this.CONFIG_FILE_NAME))) {
					// we also handle the case in which the config is found at the app root level
					variables.configFilePath = this.CONFIG_FILE_NAME;
					userConfigBean.load(expandPath(variables.appRoot & variables.configFilePath));
				}

				// set a default content root and for the app
				if(userConfigBean.getContentRoot() eq "")
					userConfigBean.setContentRoot(arguments.appRoot);
	
				// make sure we always have a resource library, defaulting to the application root
				if(userConfigBean.getResourceLibraryPath() eq "")
					userConfigBean.setResourceLibraryPath(arguments.appRoot);

				// allow plugins to do any config changes they want
				userPlugins = userConfigBean.getPlugins();
				hpPlugins = oHomePortalsConfigBean.getPlugins();
				if(arrayLen(userPlugins) gt 0 or arrayLen(hpPlugins) gt 0) {
					pluginLoader = createObject("component","pluginManager").init(this);

					for(i=1;i lte arrayLen(hpPlugins);i++) {
						pluginLoader.registerPlugin(hpPlugins[i].name, hpPlugins[i].path);
					}
					for(i=1;i lte arrayLen(userPlugins);i++) {
						pluginLoader.registerPlugin(userPlugins[i].name, userPlugins[i].path);
					}
					pluginLoader.notifyPlugins("configLoad", userConfigBean);
				}

				// now apply app configuration on top of the global config
				variables.oHomePortalsConfigBean.loadXML(userConfigBean.toXML());

			} else {
				// set a default content root and for the app
				if(variables.oHomePortalsConfigBean.getContentRoot() eq "")
					variables.oHomePortalsConfigBean.setContentRoot(arguments.appRoot);
	
				// make sure we always have a resource library, defaulting to the application root
				if(variables.oHomePortalsConfigBean.getResourceLibraryPath() eq "")
					variables.oHomePortalsConfigBean.setResourceLibraryPath(arguments.appRoot);

				// allow plugins to do any config changes they want
				hpPlugins = variables.oHomePortalsConfigBean.getPlugins();
				if(arrayLen(userPlugins) gt 0 or arrayLen(hpPlugins) gt 0) {
					pluginLoader = createObject("component","pluginManager").init(this);
					for(i=1;i lte arrayLen(hpPlugins);i++) {
						pluginLoader.registerPlugin(hpPlugins[i].name, hpPlugins[i].path);
					}
					pluginLoader.notifyPlugins("configLoad", userConfigBean);
				}
			}

			// initialize environment with current config
			initEnv();
						
			variables.stTimers.init = getTickCount()-start;
			return this;
		</cfscript>
	</cffunction>
	
	<!--------------------------------------->
	<!----  reinit	 					----->
	<!--------------------------------------->
	<cffunction name="reinit" access="public" returntype="homePortals" hint="Reinitializes the homeportals instance. This will re-read the configuration and clear all caches.">
		<cfscript>
			var oCacheRegistry = 0;
			
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
	<!----  initEnv	 					----->
	<!--------------------------------------->
	<cffunction name="initEnv" access="public" returntype="void" hint="Initializes the environment based on the current configuration bean">
		<cfargument name="initPlugins" type="boolean" required="false" default="true">
		<cfscript>
			var oCacheRegistry = 0;
			var oCacheService = 0;
			var ppClass = "";

			// initialize cache registry
			oCacheRegistry = createObject("component","cacheRegistry").init();
			if(arguments.initPlugins) {
				oCacheRegistry.flush();		// clear registry
			}

			// initialize resource library manager
			variables.oResourceLibraryManager = CreateObject("Component","resourceLibraryManager").init(variables.oHomePortalsConfigBean);
			
			// initialize resource catalog
			variables.oCatalog = CreateObject("Component","catalog").init(variables.oHomePortalsConfigBean);
			variables.oCatalog.setResourceLibraryManager(variables.oResourceLibraryManager);

			// initialize page provider
			variables.oPageProvider = createObject("component", variables.oHomePortalsConfigBean.getPageProviderClass() ).init(variables.oHomePortalsConfigBean);
		
			// initialize page loader
			variables.oPageLoader = createObject("component","pageLoader").init( variables.oPageProvider );

			// crate page cache instance
			oCacheService = createObject("component","cacheService").init(variables.oHomePortalsConfigBean.getPageCacheSize(), 
																			variables.oHomePortalsConfigBean.getPageCacheTTL());
			oCacheRegistry.register("hpPageCache", oCacheService);

			// initialize template manager
			variables.oTemplateManager = createObject("component","templateManager").init(variables.oHomePortalsConfigBean);
						
			// register and initialize plugins (this flag is to allow plugins to reinit the environment without getting into an infinite loop)
			if(arguments.initPlugins) {
				variables.oPluginManager = createObject("component","pluginManager").init(this);
				getPluginManager().notifyPlugins("appInit");		
			}
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
			var oPage = 0;
			var start = getTickCount();
			
			// notify plugins
			arguments.pageHREF = getPluginManager().notifyPlugins("beforePageLoad", arguments.pageHREF);
			
			// if no page is given, then load default page
			if(arguments.pageHREF eq "") arguments.pageHREF = getConfig().getDefaultPage();			
						
			// load page 
			oPage = getPageLoader().load(arguments.pageHREF);	
			oPageRenderer = createObject("component","pageRenderer").init(arguments.pageHREF, oPage, this);

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
		<cfargument name="pageHREF" type="string" required="false" default="" hint="A optional client-defined key or identifier for the page. If empty uses a unique identifier for the page bean instance">
		<cfscript>
			var oPageRenderer = 0;
			var start = getTickCount();

			if(arguments.pageHREF eq "") 
				arguments.pageHREF = createObject("java", "java.lang.System").identityHashCode(arguments.page);

			// notify plugins
			arguments.pageHREF = getPluginManager().notifyPlugins("beforePageLoad", arguments.pageHREF);
			
			oPageRenderer = createObject("component","pageRenderer").init(arguments.pageHREF, arguments.page, this);

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
	<!----  getTemplateManager			----->
	<!--------------------------------------->		
	<cffunction name="getTemplateManager" access="public" returntype="templateManager">
		<cfreturn variables.oTemplateManager>
	</cffunction>

	<!--------------------------------------->
	<!----  getPageLoader				----->
	<!--------------------------------------->		
	<cffunction name="getPageLoader" access="public" returntype="pageLoader">
		<cfreturn variables.oPageLoader>
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

