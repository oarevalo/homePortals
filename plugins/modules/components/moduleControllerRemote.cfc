<cfcomponent displayname="moduleControllerRemote" 
			hint="This is the module controller for remote calls made from the browser">
	
	<cfset variables.oModuleController = 0>

	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->		
	<cffunction name="init" access="public" hint="constructor" returntype="moduleControllerRemote">
		<cfargument name="pageHREF" type="any" required="true">
		<cfargument name="moduleID" type="any" required="true">
		<cfargument name="homePortals" type="homePortals.components.homePortals" required="true" hint="homeportals application instance">
		<cfscript>
			var hp = arguments.homePortals;
			var mc = 0;
			var moduleClass = "";
			var moduleInfoNode = {};
			var pageBean = 0;
			var moduleBean = 0;
			var modulesResDir = "Modules";
			
			// load container page (do it through the loader so that we can bypass plugins)
			pageBean = hp.getPageLoader().load(arguments.pageHREF);	
			
			// get the container modulebean
			moduleBean = pageBean.getModule(arguments.moduleID);
			
			// reconstruct the location of the module resource class
			if(moduleBean.hasProperty("name") and moduleBean.getProperty("name") neq "") {
				modResBean = hp.getCatalog().getResource("module", moduleBean.getProperty("name"));
				moduleClass = modResBean.getResourceLibrary().getPath() & "/" & modulesResDir & "/" & moduleBean.getProperty("name");

			} else if(moduleBean.hasProperty("moduleID") and moduleBean.getProperty("moduleID") neq "") {
				modResBean = oHP.getCatalog().getResource("module", moduleBean.getProperty("moduleID"));
				moduleClass = modResBean.getResourceLibrary().getPath() & "/" & modulesResDir & "/" & modResBean.getPackage() & "/" & modResBean.getID();
			}
			
			// convert the moduleName into a dot notation path
			moduleClass = replace(moduleClass,"/",".","ALL");
			moduleClass = replace(moduleClass,"..",".","ALL");
			if(left(moduleClass,1) eq ".") moduleClass = right(moduleClass, len(moduleClass)-1);

			// build a struct with module info
			moduleInfoNode = moduleBean.toStruct();
			moduleInfoNode["name"] = modResBean.getPackage() & "/" & modResBean.getID();
			
			// initialize module controller
			mc = createObject("component","moduleController").init(pageHREF = arguments.pageHREF,
																									pageBean = pageBean,
																									moduleID = arguments.moduleID,
																									moduleClassLocation = moduleClass,
																									modulePageSettings = moduleInfoNode,
																									isFirstInClass = false,
																									execMode = 'remote',
																									homePortals = hp);
			
			variables.oModuleController = mc;
			
			return this;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- getView                          --->
	<!---------------------------------------->	
	<cffunction name="getView" access="public" output="false"
				returnType="string" 
				hint="Renders a view sending its output directly to the screen.">
		<cfargument name="view" type="string" required="yes">
		
		<cfscript>
			var mc = variables.oModuleController;
			var tmpHTMLView = "";
			var tmpHTMLEventsJS = "";
			var tmpHTMLMessageJS = "";
			var tmpHTML = "";

			// get view output
			tmpHTMLView = mc.renderView(argumentCollection = arguments);
			
			// get code for any events to be raised
			tmpHTMLEventsJS = mc.renderRaiseEvents();
			
			// get code for any messages to set
			tmpHTMLMessageJS = mc.renderMessage();

			// prepare output			
			tmpHTML = tmpHTMLView & tmpHTMLEventsJS & tmpHTMLMessageJS;
		</cfscript>
		<cfreturn tmpHTML>
	</cffunction>			

	<!---------------------------------------->
	<!--- doAction                         --->
	<!---------------------------------------->	
	<cffunction name="doAction" access="public" output="false" 
				hint="Use this method to call server-side methods remotely.">
		<cfargument name="action" type="string" required="yes">
		
		<cfscript>
			var mc = variables.oModuleController;
			var tmpHTMLEventsJS = "";
			var tmpHTMLMessageJS = "";
			var tmpHTMLScriptJS = "";
			var tmpHTML = "";
						
			// execute requested action
			mc.execute(argumentCollection = arguments);

			// get code for any events to be raised
			tmpHTMLEventsJS = mc.renderRaiseEvents();

			// get code for any messages to set
			tmpHTMLMessageJS = mc.renderMessage();

			// get any other javascript code set to execute
			tmpHTMLScriptJS = mc.renderScript();

			// prepare output		
			tmpHTML = tmpHTMLEventsJS & tmpHTMLMessageJS & tmpHTMLScriptJS;
		</cfscript>
		<cfreturn tmpHTML>
	</cffunction>	

	<!---------------------------------------->
	<!--- throwAppTimedOut	               --->
	<!---------------------------------------->	
	<cffunction name="throwAppTimedOut" access="private">
		<cfthrow message="The application has timed out." type="homePortals.modules.applicationTimedOut">
	</cffunction>
</cfcomponent>