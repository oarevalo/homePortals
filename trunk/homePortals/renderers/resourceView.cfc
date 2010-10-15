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
		<cfset var showPath = getContentTag().getAttribute("showPath", false)>

		<cfset oResBean = getPageRenderer()
							.getHomePortals()
							.getCatalog()
							.getResource(resourceType, resourceID)>
						
		<cfset tgtHREF = oResBean.getFullHref()>
		<cfset tgtPath = oResBean.getFullPath()>
		<cfset props = oResBean.getProperties()>
		
		<cfsavecontent variable="tmpHTML">
			<cfoutput>
			<table>
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
				<cfif oResBean.getDescription() neq "">
					<tr>
						<td><b>Description:</b></td>
						<td>#oResBean.getDescription()#</td>
					</tr>
				</cfif>
				<cfif tgtHREF neq "">
					<tr>
						<td><b>HREF:</b></td>
						<td><a href="#tgtHREF#">#tgtHREF#</a></td>
					</tr>
				<cfelseif tgtPath neq "" and showPath>
					<tr>
						<td><b>Path:</b></td>
						<td>#tgtPath#</td>
					</tr>
				</cfif>
				<cfloop collection="#props#" item="prop">
					<tr>
						<td><b>#prop#</b></td>
						<td>#props[prop]#</td>
					</tr>
				</cfloop>
			</table>
			<cfif isBoolean(displayContent) and displayContent>
				<hr />
				<cfif tgtPath neq "" and isimageFile(tgtPath)>
					<cfif tgtPath neq expandPath(tgtHREF)>
						<cfimage action="writeToBrowser" source="#tgtPath#">
					<cfelse>
						<img src="#tgtHREF#">
					</cfif>
				<cfelseif tgtPath neq "">
					<cfset txt = oResBean.readFile()>
					#txt#
				</cfif>
			</cfif>
			</cfoutput>
		</cfsavecontent>
		
		<cfset arguments.bodyContentBuffer.set( tmpHTML )>
	</cffunction>
		
</cfcomponent>
