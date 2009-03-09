<cfcomponent extends="Home.Components.contentTagRenderer">

	<!---------------------------------------->
	<!--- renderContent	                   --->
	<!---------------------------------------->		
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="Home.Components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="Home.Components.singleContentBuffer" required="true">

		<cfscript>
			var moduleID = getContentTag().getAttribute("id");
			var href = getContentTag().getAttribute("href");
			var tmpHTML = "";

			try {
				tmpHTML = renderInclude(href);
				
				arguments.bodyContentBuffer.set(id = moduleID, 
												content = tmpHTML );
				
			} catch(any e) {
				tmpHTML = "<b>An unexpected error ocurred while retrieving content for content module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				arguments.bodyContentBuffer.set(id = moduleID, 
												content = tmpHTML );
			}
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- renderInclude	                   --->
	<!---------------------------------------->		
	<cffunction name="renderInclude" access="public" returntype="string" 
				hint="Returns the output of an included file. The included file is executed under the context of the current module.">
		<cfargument name="fileToInclude" type="any" required="true">
		<cfset var tmpHTML = "">
		<cfsavecontent variable="tmpHTML">
			<cfinclude template="#arguments.fileToInclude#">	
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>	
	
</cfcomponent>