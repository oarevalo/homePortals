<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="Displays an interactive widget on the page">
	
	<cfproperty name="moduleID" type="resource:module" required="false"  displayname="Module" />

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfscript>
			var bIsFirstInClass = false;
			var oModuleController = 0;
			var moduleID = getContentTag().getAttribute("id");
			var moduleName = getContentTag().getAttribute("name");
			var moduleResID = getContentTag().getAttribute("moduleID");
			var tmpMsg = "";
			var moduleNode = structNew();
			var oHP = getPageRenderer().getHomePortals();
			var oCatalog = getPageRenderer().getHomePortals().getCatalog();
			var modResBean = 0;
			var modulesResDir = "Modules";

			if(moduleName neq "") {
				modResBean = oHP.getCatalog().getResource("module",moduleName);
				moduleName = modResBean.getResourceLibrary().getPath() & "/" & modulesResDir & "/" & moduleName;
			} else if(moduleResID neq "") {
				modResBean = oHP.getCatalog().getResource("module",moduleResID);
				moduleName = modResBean.getResourceLibrary().getPath() & "/" & modulesResDir & "/" & modResBean.getPackage() & "/" & modResBean.getID();
			}

			// convert the moduleName into a dot notation path
			moduleName = replace(moduleName,"/",".","ALL");
			moduleName = replace(moduleName,"..",".","ALL");
			if(left(moduleName,1) eq ".") moduleName = right(moduleName, len(moduleName)-1);

			// check if this module is the first of its class to be rendered on the page
			bIsFirstInClass = (not arguments.bodyContentBuffer.containsClass(moduleName));
			
			// add information about the page to moduleNode
			moduleNode = getContentTag().getModuleBean().toStruct();
			moduleNode["name"] = modResBean.getPackage() & "/" & modResBean.getID();
			moduleNode["_page"] = structNew();
			moduleNode["_page"].href =  getPageRenderer().getPageHREF();
			if(getPageRenderer().getPage().hasProperty("owner")) 
				moduleNode["_page"].owner = getPageRenderer().getPage().getProperty("owner");
			else
				moduleNode["_page"].owner = "";
			
			// instantiate module controller and call constructor
			oModuleController = createObject("component","homePortals.plugins.modules.components.moduleController");
			oModuleController.init(getPageRenderer().getPageHREF(), 
									moduleID, 
									moduleName, 
									moduleNode, 
									bIsFirstInClass, 
									"local", 
									getPageRenderer().getHomePortals());

			// render html content
			arguments.headContentBuffer.append( oModuleController.renderClientInit() );
			arguments.headContentBuffer.append( oModuleController.renderHTMLHead() );
			arguments.bodyContentBuffer.set(  class = moduleName, 
											content = oModuleController.renderView() );
		</cfscript>	
	</cffunction>

</cfcomponent>