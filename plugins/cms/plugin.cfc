<cfcomponent extends="homePortals.components.plugin">
	
	<cffunction name="onAppInit" access="public" returntype="void">
		<cfscript>
			var configPath = getDirectoryFromPath(getcurrentTemplatePath()) & "plugin-config.xml.cfm";

			// load plugin config settings
			getHomePortals().getConfig().load(configPath);

			// reinitialize environment to include new settings
			getHomePortals().initEnv(false);
		</cfscript>
	</cffunction>
	

	<cffunction name="getCMSRoot" access="public" returntype="string">
		<cfreturn getPluginSetting("cmsRoot") />
	</cffunction>

	<cffunction name="getCMSGateway" access="public" returntype="string">
		<cfreturn getPluginSetting("cmsGateway") />
	</cffunction>

	<cffunction name="getCMSLinkFormat" access="public" returntype="string">
		<cfreturn getPluginSetting("cmsLinkFormat") />
	</cffunction>

	<cffunction name="getPluginSetting" access="private" returntype="string">
		<cfargument name="settingName" type="string" required="true">
		<cfset var propValue = "">
		<cfset var stProps = getHomePortals().getConfig().getPageProperties()>
		<cfif structKeyExists(stProps,"plugins.cms." & arguments.settingName)>
			<cfset propValue = stProps["plugins.cms." & arguments.settingName]>
		<cfelseif structKeyExists(stProps,"plugins.cms.defaults." & arguments.settingName)>
			<cfset propValue = stProps["plugins.cms.defaults." & arguments.settingName]>
		</cfif>
		<cfreturn propValue>
	</cffunction>

</cfcomponent>