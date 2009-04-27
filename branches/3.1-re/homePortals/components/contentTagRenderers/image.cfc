<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="Use this content renderer to include an existing CFML view or template on a page.">
	<cfproperty name="imageID" type="resource:image">
	<cfproperty name="href" type="string">
	<cfproperty name="width" type="string" />
	<cfproperty name="height" type="string" />
	<cfproperty name="showLabel" type="boolean" default="true" />


	<!---------------------------------------->
	<!--- renderContent	                   --->
	<!---------------------------------------->		
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">

		<cfscript>
			var moduleID = getContentTag().getAttribute("id");
			var width = getContentTag().getAttribute("width");
			var height = getContentTag().getAttribute("height");
			var tmpHTML = "";
			var imgpath = "";

			try {
				imgpath = retrieveResourceFilePath();
				tmpHTML = "<img src='#imgpath#' width='#width#' height='#height#'>";
				arguments.bodyContentBuffer.set( tmpHTML );
				
			} catch(any e) {
				tmpHTML = "<b>An unexpected error ocurred while retrieving content for content module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				arguments.bodyContentBuffer.set( tmpHTML );
			}
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- retrieveResourceFilePath         --->
	<!---------------------------------------->		
	<cffunction name="retrieveResourceFilePath" access="private" returntype="string" hint="retrieves res from source for a module">
		<cfscript>
			var oResourceBean = 0;
			var resPath = "";
			var tmpHTML = "";
			var st = structNew();
			var oCatalog = getPageRenderer().getHomePortals().getCatalog();
			var oHPConfig = getPageRenderer().getHomePortals().getConfig();
			
			var resourceID = getContentTag().getAttribute("imageID");
			var resourceType = getContentTag().getAttribute("resourceType","image");
			var href = getContentTag().getAttribute("href");
			
			// define source of content (resource or external)
			if(resourceID neq "") {
				oResourceBean = oCatalog.getResourceNode(resourceType, resourceID);
				resPath = oResourceBean.getFullHref();
			
			} else if(href neq "") {
				resPath = href;
			}

		</cfscript>
		<cfreturn resPath>
	</cffunction>

</cfcomponent>