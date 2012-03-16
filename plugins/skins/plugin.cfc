<cfcomponent extends="homePortals.components.plugin" hint="This plugin provides a way of 'skinning' site pages. Skins are created as regular Resources and stored on the resource library. Skins are used on a per-page basis.">
	<cfproperty name="skinID" type="resource:skin" required="false" hint="Use this property to define a default skin to be used for all pages. Can be overridden at page level.">

	<cffunction name="onConfigLoad" access="public" returntype="homePortals.components.homePortalsConfigBean" hint="this method is executed when the HomePortals configuration is being loaded and before the engine is fully initialized. This method should only be used to modify the current configBean.">
		<cfargument name="eventArg" type="homePortals.components.homePortalsConfigBean" required="true" hint="the application-provided config bean">	
		<!--- apply plugin configuration from the provided config file --->
		<cfset loadConfigFile( getDirectoryFromPath(getcurrentTemplatePath()) & "plugin-config.xml.cfm" ) />
		<cfreturn arguments.eventArg />
	</cffunction>

	<cffunction name="onAppInit" access="public" returntype="void">
		<cfscript>
			var oConfig = getHomePortals().getConfig();
			
			// add bundled resource library (if required)
			if(getPluginSetting("loadBundledResourceLibrary")) {
				oConfig.addResourceLibraryPath( getPluginSetting("bundledReosurceLibraryPath") );
			}

			// reinitialize environment to include new settings
			getHomePortals().initEnv(false);
		</cfscript>
	</cffunction>
	
	<cffunction name="onAfterPageLoad" access="public" returntype="homePortals.components.pageRenderer" hint="this method is executed right before the call to loadPage() returns.">
		<cfargument name="eventArg" type="homePortals.components.pageRenderer" required="true" hint="a pageRenderer object intialized for the requested page">	
		<cfscript>
			var page = arguments.eventArg.getParsedPageData();
			var pb = arguments.eventArg.getPage();
			var href = "";
			var oResourceBean = "";

			if(pb.hasProperty("skinID") and pb.getProperty("skinID") neq "") {
				try {
					oResourceBean = getHomePortals().getCatalog().getResource("skin", pb.getProperty("skinID"));
					href = oResourceBean.getFullHref();

					if(not page.stylesheets.contains( href )) {
						ArrayAppend(page.stylesheets, href);
					}
				} catch(lock e) {
					// could not load resource!
				}
			}

			return arguments.eventArg;
		</cfscript>
	</cffunction>

	<cffunction name="getPluginSetting" access="public" returntype="string">
		<cfargument name="settingName" type="string" required="true">
		<cfset var propValue = "">
		<cfset var stProps = getHomePortals().getConfig().getPageProperties()>
		<cfif structKeyExists(stProps,"plugins.skins." & arguments.settingName)>
			<cfset propValue = stProps["plugins.skins." & arguments.settingName]>
		<cfelseif structKeyExists(stProps,"plugins.skins.defaults." & arguments.settingName)>
			<cfset propValue = stProps["plugins.skins.defaults." & arguments.settingName]>
		</cfif>
		<cfreturn propValue>
	</cffunction>
	
</cfcomponent>