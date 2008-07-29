<cfcomponent displayname="moduleControllerRemote" 
			hint="This is the module controller for remote calls made from the browser">
	
	<cfset variables.oModuleController = 0>

	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->		
	<cffunction name="init" access="public" hint="constructor">
		<cfargument name="moduleID" type="any" required="true">
		<cfset variables.oModuleController = createObject("component","moduleController")>
		<cfset variables.oModuleController.init(arguments.moduleID)>
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
			tmpHTMLView = mc.render(argumentCollection = arguments);
			
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

</cfcomponent>