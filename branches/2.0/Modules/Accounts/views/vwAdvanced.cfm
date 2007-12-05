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
<cfparam name="arguments.propertyType" default="">

<cfoutput>
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr valign="top">
			<td style="width:325px;">
				<div class="cp_sectionTitle" style="width:325px;padding:0px;margin-bottom:0px;">
					<div style="margin:2px;">
						Advanced Settings
					</div>
				</div>
				<div class="cp_sectionBox" style="margin-top:0px;height:320px;padding:0px;margin-bottom:0px;width:325px;border-top:0px;">

					<div id="cp_props_edit"></div>

					<cfswitch expression="#arguments.propertyType#">
						<cfcase value="stylesheet">
							<!--- stylesheets --->
							<cfset aStylesheets = variables.oPage.getStyles()>
							<table class="cp_dataTable" cellspacing="0">
								<tr>
									<th>Stylesheet HREF</th>
									<th width="10">&nbsp;</th>
								</tr>
								<cfloop from="1" to="#arrayLen(aStylesheets)#" index="i">
									<tr <cfif i mod 2>style="background-color:##f3f3f3;"</cfif>>
										<td>#aStylesheets[i]#</td>
										<td align="right">
											<a href="javascript:controlPanel.openEditProperty('stylesheet',#i#)"><img src="#imgRoot#/edit-page-yellow.gif" align="absmiddle" border="0"></a>
											<a href="javascript:controlPanel.deleteProperty('stylesheet',#i#)"><img src="#imgRoot#/waste_small.gif" align="absmiddle" border="0"></a>
										</td>
									</tr>
								</cfloop>
								<cfif arrayLen(aStylesheets) eq 0>
									<tr><Td colspan="2"><em>No stylsheets found.</em></tr>
								</cfif>
							</table>
						</cfcase>

						<cfcase value="script">
							<!--- scripts --->
							<cfset aScripts = variables.oPage.getScripts()>
							<table class="cp_dataTable">
								<tr>
									<th>Script HREF</th>
									<th width="10">&nbsp;</th>
								</tr>
								<cfloop from="1" to="#arrayLen(aScripts)#" index="i">
									<tr <cfif i mod 2>style="background-color:##f3f3f3;"</cfif>>
										<td>#aScripts[i]#</td>
										<td align="right">
											<a href="javascript:controlPanel.openEditProperty('script',#i#)"><img src="#imgRoot#/edit-page-yellow.gif" align="absmiddle" border="0"></a>
											<a href="javascript:controlPanel.deleteProperty('script',#i#)"><img src="#imgRoot#/waste_small.gif" align="absmiddle" border="0"></a>
										</td>
									</tr>
								</cfloop>
								<cfif arrayLen(aScripts) eq 0>
									<tr><Td colspan="2"><em>No scripts found.</em></tr>
								</cfif>
							</table>
						</cfcase>

						<cfcase value="listener">
							<!--- listeners --->
							<cfset xmlDoc = variables.oPage.getXML()>
							<cfset aListener = xmlSearch(xmlDoc,"//eventListeners/event")>
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
											<a href="javascript:controlPanel.openEditProperty('listener',#i#)"><img src="#imgRoot#/edit-page-yellow.gif" align="absmiddle" border="0"></a>
											<a href="javascript:controlPanel.deleteProperty('listener',#i#)"><img src="#imgRoot#/waste_small.gif" align="absmiddle" border="0"></a>
										</td>
									</tr>
								</cfloop>
								<cfif arrayLen(aListener) eq 0>
									<tr><Td colspan="2"><em>No event listeners found.</em></tr>
								</cfif>
							</table>
						</cfcase>

						<cfcase value="layout">
							<!--- layouts --->
							<cfset qryLocations = variables.oPage.getLocations()>
							<table class="cp_dataTable">
								<tr>
									<th>Name</th>
									<th>Type</th>
									<th>Class</th>
									<th width="10">&nbsp;</th>
								</tr>
								<cfloop query="qryLocations">
									<cfset i = qryLocations.currentRow>
									<tr <cfif i mod 2>style="background-color:##f3f3f3;"</cfif>>
										<td>#qryLocations.name#</td>
										<td>#qryLocations.type#</td>
										<td>#qryLocations.class#</td>
										<td align="right">
											<a href="javascript:controlPanel.openEditProperty('layout',#i#)"><img src="#imgRoot#/edit-page-yellow.gif" align="absmiddle" border="0"></a>
											<a href="javascript:controlPanel.deleteProperty('layout','#qryLocations.name#')"><img src="#imgRoot#/waste_small.gif" align="absmiddle" border="0"></a>
										</td>
									</tr>
								</cfloop>
								<cfif qryLocations.recordCount eq 0>
									<tr><Td colspan="2"><em>No layout regions found.</em></tr>
								</cfif>
							</table>
						</cfcase>

						<cfdefaultcase>
							<p align="center"><br>
								Use the options on the side<br>
								to select the section to configure.<br><br>
								
							</p>
						</cfdefaultcase>
					</cfswitch>
				</div>
			</td>
			<td rowspan="2">
				<div class="cp_sectionBox" style="margin:0px;margin-top:5px;height:380px;padding:0px;width:150px;">
					<div style="margin:4px;">
						<li><a href="javascript:controlPanel.getView('Advanced',{propertyType:'stylesheet'})">Stylesheets</a></li>
						<li><a href="javascript:controlPanel.getView('Advanced',{propertyType:'script'})">Scripts</a></li>
						<li><a href="javascript:controlPanel.getView('Advanced',{propertyType:'layout'})">Layout Regions</a></li>
						<li><a href="javascript:controlPanel.getView('Advanced',{propertyType:'listener'})">Events</a></li>
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<td valign="bottom">
				<div class="cp_sectionBox" 
					 style="margin:0px;padding:0px;width:325px;margin-left:6px;margin-top:5px;">
					<div style="margin:4px;">
						
						<cfif arguments.propertyType neq "">
							<a href="javascript:controlPanel.openEditProperty('#arguments.propertyType#',0);"><img src="#imgRoot#/add.png" align="absmiddle" border="0"></a>
							<a href="javascript:controlPanel.openEditProperty('#arguments.propertyType#',0);">Add Property</a>
							&nbsp;&nbsp;&nbsp;&nbsp;
						</cfif>
						<a href="javascript:controlPanel.getView('Page');"><img src="#imgRoot#/cross.png" align="absmiddle" border="0"></a>
						<a href="javascript:controlPanel.getView('Page');">Return</a>
					</div>
				</div>
			</td>
		</tr>
	</table>
	
	

</cfoutput>
	