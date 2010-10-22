<cfparam name="arguments.locationName" default="">

<cfset aLayoutRegions = variables.oPage.getLayoutRegions()>
<cfset tags = variables.homePortals.getConfig().getContentRenderers()>

<cfscript>
	if(arrayLen(aLayoutRegions) eq 0) {
		tmp = variables.homePortals.getTemplateManager().getLayoutSections( variables.oPage.getPageTemplate() );
		tmp = listToArray(tmp);
		for(i=1;i lte ArrayLen(tmp);i=i+1) {
			st = {
				type = tmp[i],
				id = tmp[i],
				class = "",
				style = "",
				name = tmp[i]
			};
			ArrayAppend(aLayoutRegions, st );
		}
	}
</cfscript>

<cfoutput>
	<script>
		jQuery(function() {
			jQuery("##cms-contentTagName").change(function() {
				cms.getPartialView('ContentTagInfo',{tagName:this.value},'cms-contentTagInfoPanel');
			});
			<cfif arrayLen(structKeyArray(tags)) gt 0>
				<cfset tmp = structKeyArray(tags)>
				cms.getPartialView('ContentTagInfo',{tagName:'#tmp[1]#'},'cms-contentTagInfoPanel');
			</cfif>
		});
	</script>

	<div class="cms-panelTitle">Add Content <cfif arguments.locationName neq "">to '#arguments.locationName#'</cfif></div>
	
	<form name="frm" method="post" action="index.cfm">
		<table>
			<tr>
				<td style="white-space:nowrap;"><b>Element Type:</b></td>
				<td>
					<select name="tag" class="cms-formField" id="cms-contentTagName">
						<cfloop collection="#tags#" item="tag">
							<option value="#tag#">#tag#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td id="cms-contentTagInfoPanel"></td>
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
					<td></td>
				</tr>
			<cfelse>
				<input type="hidden" name="location" value="#arguments.locationName#">
			</cfif>
		</table>
		<br />
		<input type="button" value="Add To Page" onclick="cms.addContentTag(this.form)">
		&nbsp;&nbsp;
		<input type="button" value="Close" onclick="cms.closePanel()">
	</form>	
</cfoutput>