<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="Displays an interactive widget on the page">
	
	<cfproperty name="moduleID" type="resource:module" required="false"  displayname="Module" />
	<!---
	<cfproperty name="name" type="string" required="false" displayname="Module name" hint="Use format Package/Resource ID" />
	--->

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

			try {
				if(moduleName neq "") {
					modResBean = oHP.getResourceLibraryManager().getResource("module",listFirst(moduleName,"/"),listLast(moduleName,"/"));
					moduleName = modResBean.getResLibPath() & "/Modules/" & moduleName;
				} else if(moduleResID neq "") {
					modResBean = oHP.getCatalog().getResourceNode("module",moduleResID);
					moduleName = modResBean.getResLibPath() & "/Modules/" & modResBean.getPackage() & "/" & modResBean.getID();
				}

				// convert the moduleName into a dot notation path
				moduleName = replace(moduleName,"/",".","ALL");
				moduleName = replace(moduleName,"..",".","ALL");
				if(left(moduleName,1) eq ".") moduleName = right(moduleName, len(moduleName)-1);

				// check if this module is the first of its class to be rendered on the page
				bIsFirstInClass = (not arguments.bodyContentBuffer.containsClass(moduleName));
				
				// add information about the page to moduleNode
				moduleNode = getContentTag().getNode();
				moduleNode["name"] = modResBean.getPackage() & "/" & modResBean.getID();
				moduleNode["_page"] = structNew();
				moduleNode["_page"].owner =  getPageRenderer().getPage().getOwner();
				moduleNode["_page"].href =  getPageRenderer().getPageHREF();
				
				// instantiate module controller and call constructor
				oModuleController = createObject("component","homePortalsModules.components.moduleController");
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
								
			} catch(lock e) {
				tmpMsg = "<b>An unexpected error ocurred while initializing module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				arguments.bodyContentBuffer.set(  class = moduleName, 
												content = tmpMsg );
			}
		</cfscript>	
	</cffunction>

</cfcomponent>