<cfcomponent displayname="youTubeModule" extends="homePortals.plugins.modules.components.baseModule">

	<cffunction name="getYouTubeService" access="private" returntype="youTubeService">
		<cfscript>
			var oService = createObject("Component","youTubeService").init();
			return oService;
		</cfscript>
	</cffunction>

</cfcomponent>
