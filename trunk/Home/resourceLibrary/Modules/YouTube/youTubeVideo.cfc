<cfcomponent displayname="youTubeVideo" extends="youTubeModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			
			cfg.setModuleClassName("youTubeVideo");
			cfg.setView("default", "video");
		</cfscript>	
	</cffunction>
	
	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="videoID" type="string" default="">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setPageSetting("videoID", arguments.videoID);

			this.controller.setMessage("Settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
		</cfscript>
	</cffunction>	

		
	<!---------------------------------------->
	<!--- saveSize	                  --->
	<!---------------------------------------->		
	<cffunction name="saveSize" access="public" output="true">
		<cfargument name="width" type="string" default="">
		<cfargument name="height" type="string" default="">
		<cfargument name="autoplay" type="string" default="0">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setPageSetting("width", arguments.width);
			cfg.setPageSetting("height", arguments.height);
			cfg.setPageSetting("autoplay", arguments.autoplay);

			this.controller.setMessage("Video player settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
		</cfscript>
	</cffunction>	

	
	
</cfcomponent>