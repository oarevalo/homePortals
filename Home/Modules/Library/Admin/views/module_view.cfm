<cfinclude template="../../udf.cfm"> 

<cfparam name="catalogIndex" default="0">
<cfparam name="moduleID" default="">

<!--- get reference to library object --->
<cfset libraryCFCPath = appState.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
<cfset oLibrary = createInstance(libraryCFCPath)>
<cfset qryModules = oLibrary.getCatalogModules(CatalogIndex)>
<cfset xmlModule = oLibrary.getCatalogResource(CatalogIndex, moduleID, "module")>

<cfquery name="qryModule" dbtype="query">
	SELECT *
		FROM qryModules
		WHERE ID = '#moduleID#'
</cfquery>

<style type="text/css">
	h2 {
		font-size:19px;
		margin-bottom:6px;	
		margin-top:20px;
	}
	h3 {
		font-size:13px;
		margin-bottom:3px;	
	}
</style>

<cfoutput>
	<h1>Library Manager - View Module</h1>

	<p><a href="home.cfm?view=libraryManager/modules&catalogIndex=#catalogIndex#"><< Return To Catalogs</a></p>
	
	<h2>#qryModule.id#</h2>

	<h3>Name [location]:</h3>
	#qryModule.name#

	<h3>Access:</h3>
	#qryModule.access#

	<h3>Description:</h3>
	#qryModule.description#

	<cfif StructKeyExists(xmlModule,"resources")>
		<h3>Resources:</h3>
		<ul>
			<cfloop from="1" to="#arrayLen(xmlModule.resources.xmlChildren)#" index="i">
				<cfset tmpNode = xmlModule.resources.xmlChildren[i]>
				<li>[#tmpNode.xmlAttributes.type#] &nbsp;-&nbsp; <a href="#tmpNode.xmlAttributes.href#" target="_blank">#tmpNode.xmlAttributes.href#</a></li>
			</cfloop>
		</ul>
	</cfif>

	<cfif StructKeyExists(xmlModule,"attributes")>
		<h3>Attributes:</h3>
		<table class="tblGrid" width="600">
			<tr>
				<th width="10">&nbsp;</th>
				<th>Name</th>
				<th>&nbsp;Req.&nbsp;</th>
				<th>&nbsp;Type&nbsp;</th>
				<th>&nbsp;Default&nbsp;</th>
				<th>Description</th>
			</tr>
			<cfloop from="1" to="#arrayLen(xmlModule.attributes.xmlChildren)#" index="i">
				<cfset tmpNode = xmlModule.attributes.xmlChildren[i]>
				<cfparam name="tmpNode.xmlAttributes.name" default="">
				<cfparam name="tmpNode.xmlAttributes.required" default="false">
				<cfparam name="tmpNode.xmlAttributes.default" default="">
				<cfparam name="tmpNode.xmlAttributes.type" default="">
				<cfparam name="tmpNode.xmlAttributes.description" default="">
				<tr>
					<td><strong>#i#</strong></td>
					<td>#tmpNode.xmlAttributes.name#</td>
					<td align="center">#YesNoFormat(tmpNode.xmlAttributes.required)#</td>
					<td>#tmpNode.xmlAttributes.type#</td>
					<td>#tmpNode.xmlAttributes.default#</td>
					<td>#tmpNode.xmlAttributes.description#</td>
				</tr>
			</cfloop>
		</table>
	</cfif>

	<cfif StructKeyExists(xmlModule,"eventListeners")>
		<h3>Event Listeners:</h3>
		<table class="tblGrid" width="600">
			<tr>
				<th width="10">&nbsp;</th>
				<th>Object Name</th>
				<th>Event Name</th>
				<th>Event Handler</th>
			</tr>
			<cfloop from="1" to="#arrayLen(xmlModule.eventListeners.xmlChildren)#" index="i">
				<cfset tmpNode = xmlModule.eventListeners.xmlChildren[i]>
				<cfparam name="tmpNode.xmlAttributes.objectName" default="">
				<cfparam name="tmpNode.xmlAttributes.eventName" default="">
				<cfparam name="tmpNode.xmlAttributes.eventHandler" default="">
				<tr>
					<td><strong>#i#</strong></td>
					<td>#tmpNode.xmlAttributes.objectName#</td>
					<td>#tmpNode.xmlAttributes.eventName#</td>
					<td>#tmpNode.xmlAttributes.eventHandler#</td>
				</tr>
			</cfloop>
		</table>
	</cfif>

	<cfif StructKeyExists(xmlModule,"api")>
		<h3>API:</h3>
		<table class="tblGrid" width="600">
			<tr>
				<th width="10">&nbsp;</th>
				<th>Name</th>
				<th>Description</th>
			</tr>
			<cfif StructKeyExists(xmlModule.api,"methods")>
				<tr><td colspan="3"><b><em>Methods</em></b></tr>
				<cfloop from="1" to="#arrayLen(xmlModule.api.methods.xmlChildren)#" index="i">
					<cfset tmpNode = xmlModule.api.methods.xmlChildren[i]>
					<cfparam name="tmpNode.xmlAttributes.name" default="">
					<cfparam name="tmpNode.xmlAttributes.description" default="">
					<tr>
						<td><strong>#i#</strong></td>
						<td>#tmpNode.xmlAttributes.name#</td>
						<td>#tmpNode.xmlAttributes.description#</td>
					</tr>
				</cfloop>
			</cfif>
			<cfif StructKeyExists(xmlModule.api,"events")>
				<tr><td colspan="3"><b><em>Events</em></b></tr>
				<cfloop from="1" to="#arrayLen(xmlModule.api.events.xmlChildren)#" index="i">
					<cfset tmpNode = xmlModule.api.events.xmlChildren[i]>
					<cfparam name="tmpNode.xmlAttributes.name" default="">
					<cfparam name="tmpNode.xmlAttributes.description" default="">
					<tr>
						<td><strong>#i#</strong></td>
						<td>#tmpNode.xmlAttributes.name#</td>
						<td>#tmpNode.xmlAttributes.description#</td>
					</tr>
				</cfloop>
			</cfif>
		</table>
	</cfif>

	<p>&nbsp;</p>
	
</cfoutput>