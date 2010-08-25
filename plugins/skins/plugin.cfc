<cfcomponent extends="homePortals.components.plugin" hint="This plugin provides a way of 'skinning' site pages. Skins are created as regular Resources and stored on the resource library. Skins are used on a per-page basis.">
	<cfproperty name="skinID" type="resource:skin" required="false" hint="Use this property to define a default skin to be used for all pages. Can be overridden at page level.">

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

	<cffunction name="onAfterPageLoad" access="public" returntype="pageRenderer" hint="this method is executed right before the call to loadPage() returns.">
		<cfargument name="eventArg" type="pageRenderer" required="true" hint="a pageRenderer object intialized for the requested page">	
		<cfscript>
			var page = arguments.eventArg.getParsedPageData();
			var pb = arguments.eventArg.getPage();
			var href = "";
			var oResourceBean = "";

			if(pb.hasProperty("skinID") and pb.getProperty("skinID") neq "") {
				try {
					oResourceBean = getHomePortals().getCatalog().getResourceNode("skin", pb.getProperty("skinID"));
					href = oResourceBean.getFullHref();

					if(not page.stylesheets.contains( href )) {
						ArrayAppend(page.stylesheets, href);
					}
				} catch(any e) {
					// could not load resource!
				}
			}

			return arguments.eventArg;
		</cfscript>
	</cffunction>

</cfcomponent>