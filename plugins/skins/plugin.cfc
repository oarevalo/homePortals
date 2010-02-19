<cfcomponent extends="homePortals.components.plugin">

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