<cfcomponent extends="Home.components.contentTagRenderer">

	<!---------------------------------------->
	<!--- renderContent	                   --->
	<!---------------------------------------->		
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="Home.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="Home.components.singleContentBuffer" required="true">

		<cfscript>
			var moduleID = getContentTag().getAttribute("id");
			var href = getContentTag().getAttribute("href");
			var tmpHTML = "";

			try {
				tmpHTML = renderInclude(href);
				
				arguments.bodyContentBuffer.set( tmpHTML );
				
			} catch(any e) {
				tmpHTML = "<b>An unexpected error ocurred while retrieving content for content module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				arguments.bodyContentBuffer.set( tmpHTML );
			}
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- renderInclude	                   --->
	<!---------------------------------------->		
	<cffunction name="renderInclude" access="private" returntype="string" hint="Returns the output of an included file.">
		<cfargument name="fileToInclude" type="any" required="true">
		<cfset var tmpHTML = "">
		<cfsavecontent variable="tmpHTML">
			<cfinclude template="#arguments.fileToInclude#">	
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>	
	
</cfcomponent>