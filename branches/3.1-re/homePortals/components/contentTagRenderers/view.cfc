<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="Use this content renderer to include an existing CFML view or template on a page.">
	<cfproperty name="href" default="" type="string" required="true" hint="The location of the template to include. You can use a relative address starting from the webroot or use an available mapping.">


	<!---------------------------------------->
	<!--- renderContent	                   --->
	<!---------------------------------------->		
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">

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