<cfoutput>
	<cfset tmpCreatedOn = "">
	<cfif StructKeyExists(xmlResNode.xmlAttributes, "createdOn")>
		<cfset tmpCreatedOn = xmlResNode.xmlAttributes.createdOn>
	</cfif>
	<cfset tmpAccountName = ListGetAt(xmlResNode.xmlAttributes.href, 2, "/")>
	
	<table width="100%" style="margin-top:10px;margin-bottom:0px;">
		<tr valign="top">
			<td><h1>#xmlResNode.xmlAttributes.title#</h1></td>
			<td align="right" style="font-size:10px;">
				<b>ID:</b> #xmlResNode.xmlAttributes.id#
			</td>
		</tr>
	</table>

	Published By <a href="/accounts/#tmpAccountName#"><strong>#tmpAccountName#</strong></a> on #DateFormat(tmpCreatedOn,"mmmm d")#

	<h2>Description:</h2>
	<cfif xmlResNode.xmlText neq "">
		#xmlResNode.xmlText#
	<cfelse>
		N/A
	</cfif>

	<h2>HREF:</h2>
	<a href="/home/home.cfm?currentHome=#xmlResNode.xmlAttributes.href#" target="_blank">#xmlResNode.xmlAttributes.href#</a>
	
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
</cfoutput>