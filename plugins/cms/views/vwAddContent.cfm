<cfparam name="arguments.locationName" default="">

<cfset aLayoutRegions = variables.oPage.getLayoutRegions()>
<cfset tags = variables.homePortals.getConfig().getContentRenderers()>

<cfoutput>
	<div class="cms-panelTitle">Add Content</div>
	
	<form name="frm" method="post" action="index.cfm">
		<table>
			<tr>
				<td><b>Element Type:</b></td>
				<td>
					<select name="tag" class="cms-formField">
						<cfloop collection="#tags#" item="tag">
							<option value="#tag#">#tag#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<cfif arguments.locationName eq "">
				<tr>
					<td><b>Region:</b></td>
					<td>
						<select name="location" class="cms-formField">
							<cfloop array="#aLayoutRegions#" index="item">
								<option value="#item.name#"
										<cfif item.name eq arguments.locationName>selected</cfif>>#item.name#</option>
							</cfloop>
						</select>
					</td>
				</tr>
			<cfelse>
				<input type="hidden" name="location" value="#arguments.locationName#">
			</cfif>
		</table>
		<br />
		<input type="button" value="Add To Page" onclick="controlPanel.addContentTag(this.form)">
		&nbsp;&nbsp;
		<input type="button" value="Close" onclick="controlPanel.closePanel()">
	</form>	
</cfoutput>