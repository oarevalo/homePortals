<cfcomponent extends="homePortals.components.contentTagRenderer">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfscript>
			var bIsFirstInClass = false;
			var oModuleController = 0;
			var moduleID = getContentTag().getAttribute("id");
			var moduleName = getContentTag().getAttribute("name");
			var tmpMsg = "";
			var moduleNode = structNew();

			try {
				moduleName = getPageRenderer().getHomePortals().getConfig().getResourceLibraryPath() & "/Modules/" & moduleName;

				// convert the moduleName into a dot notation path
				moduleName = replace(moduleName,"/",".","ALL");
				moduleName = replace(moduleName,"..",".","ALL");
				if(left(moduleName,1) eq ".") moduleName = right(moduleName, len(moduleName)-1);

				// check if this module is the first of its class to be rendered on the page
				bIsFirstInClass = (not arguments.bodyContentBuffer.containsClass(moduleName));
				
				// add information about the page to moduleNode
				moduleNode = getContentTag().getNode();
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
								
			} catch(any e) {
				tmpMsg = "<b>An unexpected error ocurred while initializing module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				arguments.bodyContentBuffer.set(  class = moduleName, 
												content = tmpMsg );
			}
		</cfscript>	
	</cffunction>

</cfcomponent>