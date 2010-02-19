<cfset hp = variables.homePortals>
<cfset plugins = hp.getPluginManager().getPlugins()>
<cfset pageProperties = hp.getConfig().getPageProperties()>

<cfoutput>
	<div class="cms-panelTitle">
		Plugin Settings
	</div>
	<cfloop array="#plugins#" index="pluginName">
		<cfset plugin = hp.getPluginManager().getPlugin(pluginName)>
		<cfset md = getMetaData(plugin)>
		<cfset propList = "">
		
		<cfif structKeyExists(md,"properties")>
			<div class="cms-lightPanel" style="margin-bottom:15px;">
				<form name="frm" method="post" action="##">
					<table>
						<tr>
							<td colspan="2">
								<div class="cms-subTitle"><cfif structKeyExists(md,"displayName")>#md.displayName#<cfelse>#pluginName#</cfif></div>
								<cfif structKeyExists(md,"hint")>
									<div style="font-size:10px;margin-bottom:8px;">#md.hint#</div>
								</cfif>
							</td>
						</tr>
						<cfloop array="#md.properties#" index="prop">
							<cfif structKeyExists(pageProperties,prop.name)>
								<cfset propValue = pageProperties[prop.name]>
							<cfelse>
								<cfset propValue = "">
							</cfif>
							<cfset propList = listAppend(propList, prop.name)>
							<tr>
								<td><b><cfif structKeyExists(prop,"displayName")>#prop.displayName#<cfelse>#prop.name#</cfif>:</b></td>
								<td><input type="text" name="#prop.name#" value="#propValue#" class="cms-formField"></td>
							</tr>
							<cfif structKeyExists(prop,"hint")>
								<tr>
									<td>&nbsp;</td>
									<td class="cms-formFieldTip">#prop.hint#</td>
								</tr>
							</cfif>
						</cfloop>
					</table>
					<cfset propList = listQualify(propList,"'")>
					<input type="button" value="Apply Changes" onclick="controlPanel.setGlobalPageProperties(this.form,[#propList#])">
				</form>
			</div>
		</cfif>
	</cfloop>
</cfoutput>
