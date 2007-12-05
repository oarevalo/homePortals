<!---
RSSReader.cfc

This is the server-side component of the RSS Reader module for HomePortals.
This module retrieves and parses an RSS/Atom feed and formats it for display.

History:
2/22/06 - oarevalo - improved support for Atom feeds
				   - added support for enclosures
				   - added links for del.icio.us and technorati
				   - fixed bug: quotes in the title will no longer give a JS error
3/31/06 - oarevalo - added rss feed caching into file system. Feeds will be fetched only
					if they are older than 30 minutes.
					- cache storage is on a directory named "RSSReaderCache". If doesnt
					 exist, it will be created.
					- TODO: make cache directory and feed timout time a configrable setting.
--->

<cfcomponent displayname="RSSReader" extends="Home.Components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();

			cfg.setModuleClassName("RSSReader");
			cfg.setView("default", "main");
			cfg.setView("htmlHead", "HTMLHead");
			cfg.setDefaultLayout("main");
		</cfscript>	
	</cffunction>

	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="rss" type="string" default="">
		<cfargument name="maxItems" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var tmpScript = "";
			
			arguments.maxItems = val(arguments.maxItems);
			if(arguments.maxItems gt 0) 
				cfg.setPageSetting("maxItems", arguments.maxItems);
			else
				cfg.setPageSetting("maxItems", "");
			
			cfg.setPageSetting("rss", arguments.rss);

			this.controller.setMessage("RSS Reader settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
		</cfscript>
	</cffunction>	

</cfcomponent>


	
