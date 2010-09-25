<!---
WebViewer.cfc

This is the server-side component of the WebViewer module for HomePortals.
This module displays an IFrame and loads a URL inside.

History:
2/10/07 - oarevalo - created
--->

<cfcomponent displayname="WebViewer" extends="homePortals.plugins.modules.components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();

			cfg.setModuleClassName("WebViewer");
			cfg.setView("default", "main");
			cfg.setView("htmlHead", "HTMLHead");
		</cfscript>	
	</cffunction>

	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="url" type="string" default="">
		<cfargument name="width" type="string" default="">
		<cfargument name="height" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setPageSetting("url", arguments.url);
			cfg.setPageSetting("width", arguments.width);
			cfg.setPageSetting("height", arguments.height);

			this.controller.setMessage("WebViewer settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
		</cfscript>
	</cffunction>	

</cfcomponent>


	
