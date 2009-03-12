<cfcomponent displayname="flickrFeed" extends="Home.components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			cfg.setModuleClassName("flickrFeed");
			cfg.setView("default", "main");
			
			variables.apiKey = cfg.getProperty("API_Key");
		</cfscript>	
	</cffunction>


	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="userid" type="string" default="">
		<cfargument name="username" type="string" default="">
		<cfargument name="tags" type="string" default="">
		<cfargument name="showheader" type="string" default="false">
		<cfargument name="onClickGotoFlickr" type="string" default="false">
		<cfargument name="maxItems" type="string" default="false">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setPageSetting("userid", arguments.userid);
			cfg.setPageSetting("username", arguments.username);
			cfg.setPageSetting("tags", arguments.tags);
			cfg.setPageSetting("showheader", arguments.showheader);
			cfg.setPageSetting("onClickGotoFlickr", arguments.onClickGotoFlickr);
			cfg.setPageSetting("maxItems", val(arguments.maxItems));
			
			this.controller.setMessage("Settings changed");
			this.controller.setScript("#moduleID#.getView();");
			this.controller.savePageSettings();
			
		</cfscript>
	</cffunction>	

	<!---------------------------------------->
	<!--- getUserID                        --->
	<!---------------------------------------->		
	<cffunction name="getUserID" access="private" returntype="string">
		<cfargument name="userName" value="" required="true">
		
		<cfset var rtn = "">
		
		<cfhttp method="get" url="http://api.flickr.com/services/rest/">
			<cfhttpparam name="method" value="flickr.people.findByUsername" type="url">
			<cfhttpparam name="api_key" value="#variables.apiKey#" type="url">
			<cfhttpparam name="username" value="#arguments.userName#" type="url">
		</cfhttp>	
		
		<cfscript>
			if(cfhttp.StatusCode eq "200 OK") {
				xmlDoc = xmlParse(cfhttp.FileContent);
				if(xmlDoc.xmlRoot.xmlAttributes.stat eq "ok")
					rtn = xmlDoc.xmlRoot.user.xmlAttributes.id;
				else
					throw("#xmlDoc.xmlRoot.err.xmlAttributes.msg#");
			} else {
				throw("Something happened while checking for user id. Status Code: #cfhttp.StatusCode#");
			}
		</cfscript>
			
		<cfreturn rtn>	
	</cffunction>	
</cfcomponent>