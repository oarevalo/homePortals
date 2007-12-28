<cfcomponent extends="eventHandler">

	<!------------------------------------------------->
	<!--- addPlugin                                ---->
	<!------------------------------------------------->
	<cffunction name="addPlugin" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 
		
		<cfscript>
			frm = arguments.form;
			
			if(frm.src eq "") throw("Please enter the location of the plugin specification file.");

			oPlugins = createInstance("components/plugins.cfc");
			oPlugins.install(frm.src);

			arguments.state.infoMessage = "Plugin Installed. You must exit and login again to use the new plugin.";
		</cfscript>
		
		<cfreturn arguments.state>
	</cffunction>

	<!------------------------------------------------->
	<!--- removePlugin                             ---->
	<!------------------------------------------------->
	<cffunction name="removePlugin" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 
		
		<cfscript>
			frm = arguments.url;
			
			if(frm.pluginID eq "") throw("Please enter the ID of the plugin you want to uninstall.");

			oPlugins = createInstance("components/plugins.cfc");
			oPlugins.remove(frm.pluginID);

			// rebuild menu options
			oMenu = createInstance("components/menu.cfc");
			arguments.state.qryMenuOptions = oMenu.get();

			arguments.state.infoMessage = "Plugin Removed. You must exit and login again for changes to take effect.";
		</cfscript>
				
		<cfreturn arguments.state>
	</cffunction>
	
</cfcomponent>