<cfcomponent extends="homePortals.components.plugin" hint="This plugin provides an in-page authoring interface for managing site content and layout. The CMS user interface is invoked by appending the 'admin' parameter to the current URL">

	<cffunction name="onConfigLoad" access="public" returntype="homePortalsConfigBean" hint="this method is executed when the HomePortals configuration is being loaded and before the engine is fully initialized. This method should only be used to modify the current configBean.">
		<cfargument name="eventArg" type="homePortalsConfigBean" required="true" hint="the application-provided config bean">
		<!--- apply plugin configuration from the provided config file --->
		<cfset loadConfigFile( getDirectoryFromPath(getcurrentTemplatePath()) & "plugin-config.xml.cfm" ) />
		<cfreturn arguments.eventArg />
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