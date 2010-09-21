<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="Use this content renderer to display an image.">
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
			var imageID = getContentTag().getAttribute("imageID");
			var href = getContentTag().getAttribute("href");
			var tmpHTML = "";
			var imgpath = "";
			var alt = label;

			if(imageID neq "") {
				resBean = retrieveResource();
				imgpath = resBean.getFullHref();
				alt = resBean.getProperty("label");
				label = resBean.getProperty("label");
				link = resBean.getProperty("url");
			} else {
				imgpath = href;
			}
			
			if(alt eq "") alt = getFileFromPath(imgPath);
			if(link eq "$") link = imgpath;
			
			tmpHTML = "<img src=""#imgpath#"" border=""0"" alt=""#htmlEditFormat(alt)#"" title=""#htmlEditFormat(alt)#""";
			
			if(width neq "") tmpHTML = tmpHTML & " width='#width#'";
			if(height neq "") tmpHTML = tmpHTML & " height='#height#'";
			tmpHTML = tmpHTML & ">";
			
			if(link neq "") tmpHTML = "<a href='#link#'>" & tmpHTML & "</a>";
			if(label neq "") tmpHTML = tmpHTML & "<div>" & label & "</div>";
			
			arguments.bodyContentBuffer.set( tmpHTML );
				
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- retrieveResource		           --->
	<!---------------------------------------->		
	<cffunction name="retrieveResource" access="private" returntype="any" hint="retrieves res from source for a module">
		<cfscript>
			var oCatalog = getPageRenderer().getHomePortals().getCatalog();
			
			var resourceID = getContentTag().getAttribute("imageID");
			var resourceType = getContentTag().getAttribute("resourceType","image");
			
			// define source of content (resource or external)
			var oResourceBean = oCatalog.getResourceNode(resourceType, resourceID);
			
			return oResourceBean;
		</cfscript>
	</cffunction>

</cfcomponent>