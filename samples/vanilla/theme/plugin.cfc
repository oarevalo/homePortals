<cfcomponent extends="homePortals.components.plugin" displayName="ZenLikeTheme" hint="This plugin applies the ZenLike theme.">
	<cfproperty name="siteTitle" type="string" displayname="Site Title" hint="Title to display on the page header">
	<cfproperty name="siteTagline" type="string" displayname="Site Tagline" hint="Subtitle displayed under the main site title">
	<cfproperty name="siteCopyright" type="string" displayname="Site Copyright" hint="Copyright line for the website">

	<cffunction name="onAppInit" access="public" returntype="void">
		<cfscript>
			var configPath = getDirectoryFromPath(getcurrentTemplatePath()) & "theme-config.xml.cfm";

			// load plugin config settings
			getHomePortals().getConfig().load(configPath);

			// reinitialize environment to include new settings
			getHomePortals().initEnv(false);
		</cfscript>
	</cffunction>
		
</cfcomponent>