<cfcomponent extends="homePortals.components.plugin" hint="This plugin provides a resource library of ready-to-use interactive widgets that can be added directly to pages.">

	<cfset variables.oModuleProperties = 0>

	<cffunction name="onConfigLoad" access="public" returntype="homePortals.components.homePortalsConfigBean" hint="this method is executed when the HomePortals configuration is being loaded and before the engine is fully initialized. This method should only be used to modify the current configBean.">
		<cfargument name="eventArg" type="homePortals.components.homePortalsConfigBean" required="true" hint="the application-provided config bean">	
		<!--- apply plugin configuration from the provided config file --->
		<cfset loadConfigFile( getDirectoryFromPath(getcurrentTemplatePath()) & "plugin-config.xml.cfm" ) />
		<cfreturn arguments.eventArg />
	</cffunction>
	
	<cffunction name="onAppInit" access="public" returntype="void">
		<cfscript>
			var oConfig = getHomePortals().getConfig();
			var oConfigBeanStore = 0;
			var oCacheRegistry = 0;
			var oCacheService = 0;
			var oRSSService = 0;
			
			// add bundled resource library (if required)
			if(getPluginSetting("loadBundledResourceLibrary")) {
				oConfig.addResourceLibraryPath( getPluginSetting("bundledReosurceLibraryPath") );
			}

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

	<cffunction name="getPluginSetting" access="public" returntype="string">
		<cfargument name="settingName" type="string" required="true">
		<cfset var propValue = "">
		<cfset var stProps = getHomePortals().getConfig().getPageProperties()>
		<cfif structKeyExists(stProps,"plugins.modules." & arguments.settingName)>
			<cfset propValue = stProps["plugins.modules." & arguments.settingName]>
		<cfelseif structKeyExists(stProps,"plugins.modules.defaults." & arguments.settingName)>
			<cfset propValue = stProps["plugins.modules.defaults." & arguments.settingName]>
		</cfif>
		<cfreturn propValue>
	</cffunction>
					
</cfcomponent>