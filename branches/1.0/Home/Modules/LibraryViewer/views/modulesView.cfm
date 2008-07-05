<cfoutput>
	<table width="100%" style="margin-top:10px;margin-bottom:0px;">
		<tr valign="top">
			<td><h1>#xmlResNode.xmlAttributes.id#</h1></td>
			<td align="right" style="font-size:10px;">
				<strong>Name:</strong> #xmlResNode.xmlAttributes.name#<br>
				<strong>Access:</strong> #xmlResNode.xmlAttributes.access#
			</td>
		</tr>
	</table>

	<h2 style="margin-top:0px;">Description:</h2>
	#xmlResNode.description.xmlText#

	<cfif StructKeyExists(xmlResNode,"resources")>
		<h2>Resources:</h2>
		<ul>
			<cfloop from="1" to="#arrayLen(xmlResNode.resources.xmlChildren)#" index="i">
				<cfset tmpNode = xmlResNode.resources.xmlChildren[i]>
				<li>[#tmpNode.xmlAttributes.type#] &nbsp;-&nbsp; <a href="#tmpNode.xmlAttributes.href#" target="_blank">#tmpNode.xmlAttributes.href#</a></li>
			</cfloop>
		</ul>
	</cfif>

	<cfif StructKeyExists(xmlResNode,"attributes")>
		<h2>Attributes:</h2>
		<table class="tblGrid">
			<tr>
				<th width="10">&nbsp;</th>
				<th>Name</th>
				<th>&nbsp;Req.&nbsp;</th>
				<th>&nbsp;Type&nbsp;</th>
				<th>&nbsp;Default&nbsp;</th>
				<th>Description</th>
			</tr>
			<cfloop from="1" to="#arrayLen(xmlResNode.attributes.xmlChildren)#" index="i">
				<cfset tmpNode = xmlResNode.attributes.xmlChildren[i]>
				<cfparam name="tmpNode.xmlAttributes.name" default="">
				<cfparam name="tmpNode.xmlAttributes.required" default="false">
				<cfparam name="tmpNode.xmlAttributes.default" default="">
				<cfparam name="tmpNode.xmlAttributes.type" default="">
				<cfparam name="tmpNode.xmlAttributes.description" default="">
				<tr>
					<td><strong>#i#</strong></td>
					<td>#tmpNode.xmlAttributes.name#</td>
					<td align="center">#YesNoFormat(tmpNode.xmlAttributes.required)#</td>
					<td align="center">#tmpNode.xmlAttributes.type#</td>
					<td align="center">#tmpNode.xmlAttributes.default#</td>
					<td>#tmpNode.xmlAttributes.description#</td>
				</tr>
			</cfloop>
		</table>
	</cfif>

	<cfif StructKeyExists(xmlResNode,"eventListeners")>
		<h2>Event Listeners:</h2>
		<table class="tblGrid">
			<tr>
				<th width="10">&nbsp;</th>
				<th>Object Name</th>
				<th>Event Name</th>
				<th>Event Handler</th>
			</tr>
			<cfloop from="1" to="#arrayLen(xmlResNode.eventListeners.xmlChildren)#" index="i">
				<cfset tmpNode = xmlResNode.eventListeners.xmlChildren[i]>
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

	<cfif StructKeyExists(xmlResNode,"api")>
		<h2>API:</h2>
		<table class="tblGrid">
			<tr>
				<th width="10">&nbsp;</th>
				<th>Name</th>
				<th>Description</th>
			</tr>
			<cfif StructKeyExists(xmlResNode.api,"methods")>
				<tr><td colspan="3"><b><em>Methods</em></b></tr>
				<cfloop from="1" to="#arrayLen(xmlResNode.api.methods.xmlChildren)#" index="i">
					<cfset tmpNode = xmlResNode.api.methods.xmlChildren[i]>
					<cfparam name="tmpNode.xmlAttributes.name" default="">
					<cfparam name="tmpNode.xmlAttributes.description" default="">
					<tr>
						<td><strong>#i#</strong></td>
						<td>#tmpNode.xmlAttributes.name#</td>
						<td>#tmpNode.xmlAttributes.description#</td>
					</tr>
				</cfloop>
			</cfif>
			<cfif StructKeyExists(xmlResNode.api,"events")>
				<tr><td colspan="3"><b><em>Events</em></b></tr>
				<cfloop from="1" to="#arrayLen(xmlResNode.api.events.xmlChildren)#" index="i">
					<cfset tmpNode = xmlResNode.api.events.xmlChildren[i]>
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
	
	<cfif StructKeyExists(xmlResNode,"images")>
		<h2>Images:</h2>
		<cfloop from="1" to="#arrayLen(xmlResNode.images.xmlChildren)#" index="i">
			<cfset tmpNode = xmlResNode.images.xmlChildren[i]>
			<cfparam name="tmpNode.xmlAttributes.url" default="">
			<cfparam name="tmpNode.xmlAttributes.label" default="">
			<cfparam name="tmpNode.xmlAttributes.thumbURL" default="#tmpNode.xmlAttributes.url#">

			<div style="display:inline;">
				<a href="#tmpNode.xmlAttributes.url#" target="_blank">
					<img src="#tmpNode.xmlAttributes.thumbURL#" 
							alt="#tmpNode.xmlAttributes.label#" 
							title="#tmpNode.xmlAttributes.label#" 
							border="0"></a><br>
				#tmpNode.xmlAttributes.label#
			</div>
		</cfloop>
	</cfif>

	<p>&nbsp;</p>
</cfoutput>