<cfcomponent displayname="youTubeModule" extends="homePortals.plugins.modules.components.baseModule">

	<cffunction name="getYouTubeService" access="private" returntype="youTubeService">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var DeveloperID = cfg.getProperty("DeveloperID","");
			var oService = createObject("Component","youTubeService").init(DeveloperID);
			return oService;
		</cfscript>
	</cffunction>

</cfcomponent>
