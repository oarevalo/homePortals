<cfcomponent extends="homePortals.components.contentTagRenderer" hint="Displays information about a resource">
	<cfproperty name="resourceType" type="string" required="true" displayname="Resource Type">
	<cfproperty name="resourceID" type="string" required="true" displayname="Resource ID">
	
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		
		<cfset var tmpHTML = "">
		<cfset var tgtHREF = "">
		<cfset var resourceType = getContentTag().getAttribute("resourceType") >
		<cfset var resourceID = getContentTag().getAttribute("resourceID")>
		<cfset var displayContent = getContentTag().getAttribute("displayContent", false)>

		<cfset oResBean = getPageRenderer()
							.getHomePortals()
							.getCatalog()
							.getResource(resourceType, resourceID)>
						
		<cfif oResBean.targetFileExists()>
			<cfset tgtHREF = oResBean.getFullHref()>
		</cfif>	
		
		<cfsavecontent variable="tmpHTML">
			<cfoutput>
			<table border="1">
				<tr>
					<td><b>ID:</b></td>
					<td>#oResBean.getID()#</td>
				</tr>
				<tr>
					<td><b>Created On:</b></td>
					<td>#lsDateFormat(oResBean.getCreatedOn())#</td>
				</tr>
				<tr>
					<td><b>Package:</b></td>
					<td>#oResBean.getPackage()#</td>
				</tr>
				<tr>
					<td><b>Description:</b></td>
					<td>#oResBean.getDescription()#</td>
				</tr>
				<cfif tgtHREF neq "">
					<tr>
						<td><b>HREF:</b></td>
						<td><a href="#tgtHREF#">#tgtHREF#</a></td>
					</tr>
				</cfif>
			</table>
			<cfif isBoolean(displayContent) and displayContent>
				<hr />
				<cfset path = oResBean.getFullPath()>
				<cfif path neq "" and isimageFile(path)>
					<img src="#tgtHREF#">
				<cfelseif tgtHREF neq "">
					<cfset txt = oResBean.readFile()>
					#txt#
				</cfif>
			</cfif>
			</cfoutput>
		</cfsavecontent>
		
		<cfset arguments.bodyContentBuffer.set( tmpHTML )>
	</cffunction>
		
</cfcomponent>
