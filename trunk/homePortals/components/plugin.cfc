<cfcomponent hint="this is the base component for all plugins">
	
	<cfset variables.homePortals = 0>
	<cfset variables._properties = structNew()>
	<cfset variables._pluginName = "">
	<cfset variables._pluginPath = "">
	<cfset variables._pluginID = createUUID()>

	<cffunction name="init" access="public" returntype="plugin" hint="constructor">
		<cfargument name="homePortals" type="homePortals" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="properties" type="struct" required="false" default="#structNew()#">
		<cfset var key = "">
		<cfset variables.homePortals = arguments.homePortals>
		<cfset variables._pluginName = arguments.name>
		<cfloop collection="#arguments.properties#" item="key">
			<cfset variables._properties[key] = arguments.properties[key].value>
		</cfloop>
		<cfreturn this>
	</cffunction>

	<cffunction name="onAppInit" access="public" returntype="void" hint="this method is executed when the HomePortals application is initialized.">
		<!--- perform any plugin initialization tasks here --->
	</cffunction>

	<cffunction name="onConfigLoad" access="public" returntype="homePortalsConfigBean" hint="this method is executed when the HomePortals configuration is being loaded and before the engine is fully initialized. This method should only be used to modify the current configBean.">
		<cfargument name="eventArg" type="homePortalsConfigBean" required="true" hint="the application-provided config bean">	
		<cfreturn arguments.eventArg>
	</cffunction>
		
	<cffunction name="onBeforePageLoad" access="public" returntype="string" hint="this method is executed before a call to loadPage(). The argument is the path to the requested page, and its return value is also a page path">
		<cfargument name="eventArg" type="string" required="true" hint="the page to load">	
		<cfreturn arguments.eventArg>
	</cffunction>

	<cffunction name="onAfterPageLoad" access="public" returntype="pageRenderer" hint="this method is executed right before the call to loadPage() returns.">
		<cfargument name="eventArg" type="pageRenderer" required="true" hint="a pageRenderer object intialized for the requested page">	
		<cfreturn arguments.eventArg>
	</cffunction>
		
	<cffunction name="getHomePortals" access="public" returntype="homePortals" hint="returns the current HomePortals environment">
		<cfreturn variables.homePortals>
	</cffunction>	

	<cffunction name="getProperty" access="public" returntype="string" hint="returns a plugin property">
		<cfargument name="name" type="string" required="true" hint="The property name">
		<cfargument name="default" type="string" required="false" default="" hint="A default value to return if the property does not exist">
		<cfif structKeyExists(variables._properties, arguments.name)>
			<cfreturn variables._properties[arguments.name] />
		<cfelse>
			<cfreturn arguments.default />
		</cfif>
	</cffunction>	

	<cffunction name="getPluginName" access="public" returntype="string" hint="returns a the name under which this plugin was registered on the current application">
		<cfreturn variables._pluginName>	
	</cffunction>
	
	<cffunction name="loadConfigFile" access="public" returntype="void" hint="This is a helper method that loads a plugin-specific HomePortals config file. Loading plugin settings through this method allows the config file to use any plugin properties as tokens for dynamic values. Additional tokens supported are {appRoot} for the application root and {pluginName} for the name under which this plugin has been registered on the application. Also, you can use {pluginPath} to indicate a web accessible path to the plugin directory. If pluginPath is not given as a plugin property, then it will be guessed based on the plugin cfc path.">
		<cfargument name="configPath" type="string" required="true" hint="Absolute path to the homePortals config file to load">	
		<cfscript>
			var configXMLDoc = "";
			var prop = "";
			var defaultPath = "/" & replace(getDirectoryFromPath(replaceNoCase(getcurrentTemplatePath(), expandPath("/"), "")),"\","/","ALL");
			var defaultCFCPath = mid(replace(defaultPath,"/",".","ALL"),2,len(replace(defaultPath,"/",".","ALL"))-2);
			var pluginCFCPath = getProperty("pluginCFCPath", defaultCFCPath);

			// load config file
			configXMLDoc = fileRead(arguments.configPath,"utf-8");

			// parse known tokens
			configXMLDoc = replaceNoCase(configXMLDoc, "{appRoot}", getHomePortals().getConfig().getAppRoot(), "ALL" );
			configXMLDoc = replaceNoCase(configXMLDoc, "{pluginName}", getPluginName(), "ALL" );
			configXMLDoc = replaceNoCase(configXMLDoc, "{pluginPath}", defaultPath, "ALL" );
			configXMLDoc = replaceNoCase(configXMLDoc, "{pluginCFCPath}", defaultCFCPath, "ALL" );
			for(prop in variables._properties) {
				if(prop neq "pluginPath") {
					configXMLDoc = replaceNoCase(configXMLDoc, "{#prop#}", variables._properties[prop], "ALL" );
				}
			}

			// apply config
			getHomePortals().getConfig().loadXML(configXMLDoc);
		</cfscript>
	</cffunction>		

</cfcomponent>