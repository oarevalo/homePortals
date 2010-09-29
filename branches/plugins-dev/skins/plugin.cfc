<cfcomponent extends="homePortals.components.plugin" hint="This plugin provides a way of 'skinning' site pages. Skins are created as regular Resources and stored on the resource library. Skins are used on a per-page basis.">
	<cfproperty name="skinID" type="resource:skin" required="false" hint="Use this property to define a default skin to be used for all pages. Can be overridden at page level.">

	<cffunction name="onConfigLoad" access="public" returntype="homePortalsConfigBean" hint="this method is executed when the HomePortals configuration is being loaded and before the engine is fully initialized. This method should only be used to modify the current configBean.">
		<cfargument name="eventArg" type="homePortalsConfigBean" required="true" hint="the application-provided config bean">	
		<cfscript>
			var configPath = getDirectoryFromPath(getcurrentTemplatePath()) & "plugin-config.xml.cfm";

			// load plugin config settings
			getHomePortals().getConfig().load(configPath);

			return arguments.eventArg;
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
				} catch(any e) {
					// could not load resource!
				}
			}

			return arguments.eventArg;
		</cfscript>
	</cffunction>

</cfcomponent>