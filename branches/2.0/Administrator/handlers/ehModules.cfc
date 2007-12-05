<cfcomponent name="ehModules" extends="ehBase">
	
	<!--- ************************************************************* --->
	<!--- 
		This method should not be altered, unless you want code to be executed
		when this handler is instantiated. This init method should be on all
		event handlers, usually left untouched.
	--->
	<cffunction name="init" access="public" returntype="Any">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<!------------------------------------------------->
	<!--- dspMain		                           ---->
	<!------------------------------------------------->
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var oLibrary = 0;
			var oCatalog = 0;
			var rebuildCatalog = getValue("rebuildCatalog",false);
			
			// create catalog object and instantiate for this page
			oCatalog = createInstance("../Components/catalog.cfc");
			oCatalog.init(getSetting("HomeRoot"), rebuildCatalog);
			
			if(rebuildCatalog) 
				getPlugin("messagebox").setMessage("info", "Catalog has been rebuilt.");
			
			// pass data to the view	
			setValue("oCatalog", oCatalog);	
				
			session.mainMenuOption = "Module Library";
			setView("Modules/vwMain");
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- dspViewModuleInfo                        ---->
	<!------------------------------------------------->
	<cffunction name="dspViewModuleInfo" access="public" returntype="void">
		<cfscript>
			var id = getValue("id","");
			var oCatalog = 0;
			
			oCatalog = createInstance("../Components/catalog.cfc");
			oCatalog.init(getSetting("HomeRoot"));
			
			// get the node for the resource
			xmlResNode = oCatalog.getResourceNode("module",id);
			setValue("xmlResNode", xmlResNode);  
			
			session.mainMenuOption = "Module Library";
			setView("Modules/vwViewModuleInfo");
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- dspViewSkinInfo	                       ---->
	<!------------------------------------------------->
	<cffunction name="dspViewSkinInfo" access="public" returntype="void">
		<cfscript>
			var id = getValue("id","");
			var oCatalog = 0;
			
			oCatalog = createInstance("../Components/catalog.cfc");
			oCatalog.init(getSetting("HomeRoot"));
			
			// get the node for the resource
			xmlResNode = oCatalog.getResourceNode("skin",id);
			setValue("xmlResNode", xmlResNode);  
			
			session.mainMenuOption = "Module Library";
			setView("Modules/vwViewSkinInfo");
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doRemoveModule	                       ---->
	<!------------------------------------------------->
	<cffunction name="doRemoveModule" access="public" returntype="void">
		<cfscript>
			var oCatalog = 0;
			var moduleID = getValue("id","");
			
			try {
				if(moduleID eq "") throw("No module has been specified.");
				
				// get catalog
				oCatalog = createInstance("../Components/catalog.cfc");
				oCatalog.init(getSetting("HomeRoot"));

				// remove node
				oCatalog.deleteResourceNode("modules",id);
				
				getPlugin("messagebox").setMessage("info", "Module has been removed from catalog.");
				setNextEvent("ehModules.dspMain");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehModules.dspMain");
			}
		</cfscript>	
	</cffunction>	


	<!------------------------------------------------->
	<!--- doRemoveSkin		                       ---->
	<!------------------------------------------------->
	<cffunction name="doRemoveSkin" access="public" returntype="void">
		<cfscript>
			var oCatalog = 0;
			var moduleID = getValue("id","");
			
			try {
				if(moduleID eq "") throw("No skin has been specified.");
				
				// get catalog
				oCatalog = createInstance("../Components/catalog.cfc");
				oCatalog.init(getSetting("HomeRoot"));

				// remove node
				oCatalog.deleteResourceNode("skins",id);
				
				getPlugin("messagebox").setMessage("info", "Skin has been removed from catalog.");
				setNextEvent("ehModules.dspMain");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehModules.dspMain");
			}
		</cfscript>	
	</cffunction>	

</cfcomponent>
