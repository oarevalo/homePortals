<cfcomponent displayname="moduleControllerRemote" 
			hint="This is the module controller for remote calls made from the browser">
	
	<cfset variables.oModuleController = 0>

	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->		
	<cffunction name="init" access="public" hint="constructor" returntype="moduleControllerRemote">
		<cfargument name="pageURI" type="any" required="true">
		<cfargument name="moduleID" type="any" required="true">
		<cfargument name="homePortals" type="homePortals" required="true" hint="homeportals application instance">
		
		<cfscript>
			var myConfigBeanStore = createObject("component", "configBeanStore").init();
			
			// verify that the session still exists before initializing the module controller
			if(myConfigBeanStore.exists(arguments.pageURI, arguments.moduleID)) {
				variables.oModuleController = createObject("component","moduleController");
				variables.oModuleController.init(pageURI = arguments.pageURI,
												moduleID = arguments.moduleID,
												execMode = 'remote',
												homePortals = arguments.homePortals);
			} else {
				throwSessionTimedOut();
			}
			
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
	<!--- throwSessionTimedOut             --->
	<!---------------------------------------->	
	<cffunction name="throwSessionTimedOut" access="private">
		<cfthrow message="The session has timed out." type="homePortals.sessionTimedOut">
	</cffunction>
</cfcomponent>