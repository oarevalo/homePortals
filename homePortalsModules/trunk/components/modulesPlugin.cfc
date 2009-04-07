<cfcomponent extends="homePortals.components.plugin">

	<cfset variables.oModuleProperties = 0>


	<cffunction name="onAppInit" access="public" returntype="void">
		<cfscript>
			var oConfig = getHomePortals().getConfig();
			var oConfigBeanStore = 0;
			var oCacheRegistry = 0;
			var oCacheService = 0;
			var oResourceLibraryManager = 0;
			var oResourceType = 0;

			// load module properties
			variables.oModuleProperties = createObject("component","moduleProperties").init(oConfig);


			// create and register content store cache
			oCacheService = createObject("component","homePortals.components.cacheService").init(oConfig.getPageCacheSize(), 
																									oConfig.getPageCacheTTL());

			oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init();
			oCacheRegistry.register("hpContentStoreCache", oCacheService);


			// clear all stored pages/module contexts (configbeans)
			oConfigBeanStore = createObject("component","configBeanStore").init();
			oConfigBeanStore.flushAll();
			

			// add resource type to library
			oResourceType = createObject("component","homePortals.components.resourceType")
							.init()
							.setName("module")
							.setFolderName("Modules")
							.setResBeanPath("homePortalsModules.components.moduleResourceBean");
			
			oResourceLibraryManager = getHomePortals().getResourceLibraryManager();
			oResourceLibraryManager.registerResourceLibraryPath("/homePortalsModules/resourceLibrary");
			oResourceLibraryManager.registerResourceType(oResourceType);

			
			// update main config bean
			oConfig.addBaseResource("style","/homePortalsModules/common/CSS/modules.css");
			oConfig.addBaseResource("script","/homePortalsModules/common/JavaScript/prototype-1.4.0.js");
			oConfig.addBaseResource("script","/homePortalsModules/common/JavaScript/Main.js");
			oConfig.addBaseResource("script","/homePortalsModules/common/JavaScript/moduleClient.js");


			// register the contentTagRenderer
			oConfig.setContentRenderer("module","homePortalsModules.components.contentTagRenderers.module");
		</cfscript>
	</cffunction>

	<cffunction name="onAfterPageLoad" access="public" returntype="homePortals.components.pageRenderer" hint="this method is executed right before the call to loadPage() returns.">
		<cfargument name="eventArg" type="homePortals.components.pageRenderer" required="true" hint="a pageRenderer object intialized for the requested page">	
		<cfscript>
			var pageHREF = arguments.eventArg.getPageHREF();
			var oConfigBeanStore = 0;
			
			// clear persistent storage for module data
			oConfigBeanStore = createObject("component","configBeanStore").init();
			oConfigBeanStore.flushByPageHREF(pageHREF);
			
			return arguments.eventArg;
		</cfscript>
	</cffunction>


	<cffunction name="getModuleProperties" access="public" returntype="moduleProperties">
		<cfreturn variables.oModuleProperties>
	</cffunction>		

			
</cfcomponent>