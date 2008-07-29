<!--- 
vwConfigPage

Display the view to configure all page settings

** This file should be included from addContent.cfc

History:
12/4/05 - oarevalo - created
12/5/05 - oarevalo - added "private" attribute to mark private pages only accessible to you.
12/13/05 - oarevalo - user HomePortals.cfc to encapsulte access to homeportals pages
3/24/06 - oarevalo - added option to set page as default
5/30/06 - oarevalo - changed layout
---->

<cfset initContext()>

<cfset xmlDoc = xmlParse(expandPath(this.pageURL))>
<cfset aStylesheets = xmlSearch(xmlDoc,"//stylesheet")>
<cfset aScripts = xmlSearch(xmlDoc,"//script")>
<cfset aLocations = xmlSearch(xmlDoc,"//layout/location")>
<cfset aListener = xmlSearch(xmlDoc,"//eventListeners/event")>

<cfset aCatalogs = getCatalogs()>

<cfset xmlSite = xmlParse(expandpath(this.siteURL))>

<cfoutput>
	<div class="cp_sectionTitle" style="width:340px;padding:0px;">
		<table style="width:335px;margin:2px;">
			<tr>
				<td>Advanced Settings</td>
				<td align="right">
					<select name="selTab" onchange="controlPanel.showPageConfigSec(this.value)" style="font-size:11px;">
						<option value="pnl_intro">--- Select One ---</option>
						<option value="pnl_stylesheets">Stylesheets</option>
						<option value="pnl_scripts">Scripts</option>
						<option value="pnl_layouts">Layout Regions</option>
						<option value="pnl_eventListeners">Events</option>
					</select>
				</td>
			</tr>
		</table>
			
	</div>
	<div class="cp_sectionBox" style="margin-top:0px;height:330px;padding:0px;width:340px;">
	<div id="cp_props_edit"></div>

	<div id="pnl_intro">
		<p align="center"><br>
			Use the drop-down control above<br>
			to select the section to configure.<br><br>
			<b>* Recommended for advanced users only</b>
		</p>
	</div>
	
	<!--- stylesheets --->
	<div id="pnl_stylesheets" style="display:none;">
		<table class="cp_dataTable" cellspacing="0">
			<tr>
				<th>Stylesheet HREF</th>
				<th width="10">&nbsp;</th>
			</tr>
			<cfloop from="1" to="#arrayLen(aStylesheets)#" index="i">
				<tr <cfif i mod 2>style="background-color:##f3f3f3;"</cfif>>
					<td>#aStylesheets[i].xmlAttributes.href#</td>
					<td align="right">
						<a href="javascript:controlPanel.openEditProperty('stylesheet',#i#)"><img src="#this.accountsRoot#/default/btn_edit.gif" align="absmiddle" border="0"></a>
						<a href="javascript:controlPanel.deleteProperty('stylesheet',#i#)"><img src="#this.accountsRoot#/default/btn_delete.gif" align="absmiddle" border="0"></a>
					</td>
				</tr>
			</cfloop>
			<cfif arrayLen(aStylesheets) eq 0>
				<tr><Td colspan="2"><em>No stylsheets found.</em></tr>
			</cfif>
		</table>
		<p><a href="javascript:controlPanel.openEditProperty('stylesheet',0)"><strong>Add Stylesheet</strong></a></p>
	</div>
	
	<!--- scripts --->
	<div id="pnl_scripts" style="display:none;">
		<table class="cp_dataTable">
			<tr>
				<th>Script HREF</th>
				<th width="10">&nbsp;</th>
			</tr>
			<cfloop from="1" to="#arrayLen(aScripts)#" index="i">
				<tr <cfif i mod 2>style="background-color:##f3f3f3;"</cfif>>
					<td>#aScripts[i].xmlAttributes.src#</td>
					<td align="right">
						<a href="javascript:controlPanel.openEditProperty('script',#i#)"><img src="#this.accountsRoot#/default/btn_edit.gif" align="absmiddle" border="0"></a>
						<a href="javascript:controlPanel.deleteProperty('script',#i#)"><img src="#this.accountsRoot#/default/btn_delete.gif" align="absmiddle" border="0"></a>
					</td>
				</tr>
			</cfloop>
			<cfif arrayLen(aScripts) eq 0>
				<tr><Td colspan="2"><em>No scripts found.</em></tr>
			</cfif>
		</table>
		<p><a href="javascript:controlPanel.openEditProperty('script',0)"><strong>Add Script</strong></a></p>
	</div>
	
	<!--- layouts --->
	<div id="pnl_layouts" style="display:none;">
		<table class="cp_dataTable">
			<tr>
				<th>Name</th>
				<th>Type</th>
				<th>Class</th>
				<th width="10">&nbsp;</th>
			</tr>
			<cfloop from="1" to="#arrayLen(aLocations)#" index="i">
				<tr <cfif i mod 2>style="background-color:##f3f3f3;"</cfif>>
					<td>#aLocations[i].xmlAttributes.name#</td>
					<td>#aLocations[i].xmlAttributes.type#</td>
					<td>#aLocations[i].xmlAttributes.class#</td>
					<td align="right">
						<a href="javascript:controlPanel.openEditProperty('layout',#i#)"><img src="#this.accountsRoot#/default/btn_edit.gif" align="absmiddle" border="0"></a>
						<a href="javascript:controlPanel.deleteProperty('layout',#i#)"><img src="#this.accountsRoot#/default/btn_delete.gif" align="absmiddle" border="0"></a>
					</td>
				</tr>
			</cfloop>
			<cfif arrayLen(aLocations) eq 0>
				<tr><Td colspan="2"><em>No layout regions found.</em></tr>
			</cfif>
		</table>
		<p><a href="javascript:controlPanel.openEditProperty('layout',0)"><strong>Add Layout Region</strong></a></p>
	</div>
		
	<!--- listeners --->
	<div id="pnl_eventListeners" style="display:none;">
		<table class="cp_dataTable">
			<tr>
				<th>Object</th>
				<th>Event Name</th>
				<th>Event Handler</th>
				<th width="10">&nbsp;</th>
			</tr>
			<cfloop from="1" to="#arrayLen(aListener)#" index="i">
				<tr <cfif i mod 2>style="background-color:##f3f3f3;"</cfif>>
					<td>#aListener[i].xmlAttributes.objectName#</td>
					<td>#aListener[i].xmlAttributes.eventName#</td>
					<td>#aListener[i].xmlAttributes.eventHandler#</td>
					<td align="right">
						<a href="javascript:controlPanel.openEditProperty('listener',#i#)"><img src="#this.accountsRoot#/default/btn_edit.gif" align="absmiddle" border="0"></a>
						<a href="javascript:controlPanel.deleteProperty('listener',#i#)"><img src="#this.accountsRoot#/default/btn_delete.gif" align="absmiddle" border="0"></a>
					</td>
				</tr>
			</cfloop>
			<cfif arrayLen(aListener) eq 0>
				<tr><Td colspan="2"><em>No event listeners found.</em></tr>
			</cfif>
		</table>
		<p><a href="javascript:controlPanel.openEditProperty('listener',0)"><strong>Add Event Listener</strong></a></p>
	</div>
	
		</div>

</cfoutput>
	