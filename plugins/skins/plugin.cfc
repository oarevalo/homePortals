<cfcomponent extends="homePortals.components.plugin" hint="This plugin provides a way of 'skinning' site pages. Skins are created as regular Resources and stored on the resource library. Skins are used on a per-page basis.">

	<cffunction name="onAppInit" access="public" returntype="void">
		<cfscript>
			var oConfig = getHomePortals().getConfig();
			var configPath = "/homePortals/plugins/skins/config/homePortals-config.xml.cfm";

			// load plugin config settings
			oConfig.load(expandPath(configPath));

			// reinitialize environment to include new settings
			getHomePortals().initEnv(false);
		</cfscript>
	</cffunction>

</cfcomponent>