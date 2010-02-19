<cfcomponent extends="homePortals.components.plugin">

	<cfset variables.oModuleProperties = 0>

	<cffunction name="onAppInit" access="public" returntype="void">
		<cfscript>
			var oConfig = getHomePortals().getConfig();
			var oConfigBeanStore = 0;
			var oCacheRegistry = 0;
			var oCacheService = 0;
			var oRSSService = 0;
			var configPath = "/homePortals/plugins/modules/config/homePortals-config.xml.cfm";

			// load plugin config settings
			oConfig.load(expandPath(configPath));

			// reinitialize environment to include new settings
			getHomePortals().initEnv(false);

			// load module properties
			variables.oModuleProperties = createObject("component","homePortals.plugins.modules.components.moduleProperties").init(oConfig);

			// create and register content store cache
			oCacheService = createObject("component","homePortals.components.cacheService").init(oConfig.getPageCacheSize(), 
																									oConfig.getPageCacheTTL());

			oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init();
			oCacheRegistry.register("hpContentStoreCache", oCacheService);

			// initialize cache for RSSService 
			// (there is no need to register the service with the registry since it registers itself)
			oRSSService = createObject("component","homePortals.plugins.modules.components.RSSService").init(oConfig.getCatalogCacheSize(), 
																		oConfig.getCatalogCacheTTL());

			// clear all stored pages/module contexts (configbeans)
			oConfigBeanStore = createObject("component","homePortals.plugins.modules.components.configBeanStore").init();
			oConfigBeanStore.flushAll();
		</cfscript>
	</cffunction>

	<cffunction name="onAfterPageLoad" access="public" returntype="homePortals.components.pageRenderer" hint="this method is executed right before the call to loadPage() returns.">
		<cfargument name="eventArg" type="homePortals.components.pageRenderer" required="true" hint="a pageRenderer object intialized for the requested page">	
		<cfscript>
			var pageHREF = arguments.eventArg.getPageHREF();
			var oConfigBeanStore = 0;
			
			// clear persistent storage for module data
			oConfigBeanStore = createObject("component","homePortals.plugins.modules.components.configBeanStore").init();
			oConfigBeanStore.flushByPageHREF(pageHREF);
			
			return arguments.eventArg;
		</cfscript>
	</cffunction>

	<cffunction name="getModuleProperties" access="public" returntype="homePortals.plugins.modules.components.moduleProperties">
		<cfreturn variables.oModuleProperties>
	</cffunction>		
		
</cfcomponent>