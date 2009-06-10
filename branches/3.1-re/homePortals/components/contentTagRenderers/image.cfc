<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="Use this content renderer to include an existing CFML view or template on a page.">
	<cfproperty name="imageID" type="resource:image" hint="Image resource from the resource library">
	<cfproperty name="href" type="string" hint="Source URL for the image (when not using an image from the resource library)">
	<cfproperty name="width" type="string" hint="Image width (pixels). Leave empty for full width." />
	<cfproperty name="height" type="string" hint="Image width (pixels). Leave empty for full height." />
	<cfproperty name="label" type="string" hint="Image label" />
	<cfproperty name="link" type="string" hint="If not empty, indicates a URL to go to when clicking on the image." />


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
			var label = getContentTag().getAttribute("label");
			var link = getContentTag().getAttribute("link");
			var tmpHTML = "";
			var imgpath = "";
			var alt = label;

			try {
				imgpath = retrieveResourceFilePath();
				
				if(alt eq "") alt = getFileFromPath(imgPath);
				
				tmpHTML = "<img src=""#imgpath#"" border=""0"" alt=""#htmlEditFormat(alt)#"" title=""#htmlEditFormat(alt)#""";
				
				if(width neq "") tmpHTML = tmpHTML & " width='#width#'";
				if(height neq "") tmpHTML = tmpHTML & " height='#height#'";
				tmpHTML = tmpHTML & ">";
				
				if(link neq "") tmpHTML = "<a href='#link#'>" & tmpHTML & "</a>";
				if(label neq "") tmpHTML = tmpHTML & "<br/>" & label;
				
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