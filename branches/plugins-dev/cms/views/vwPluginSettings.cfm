<cfset hp = variables.homePortals>
<cfset plugins = hp.getPluginManager().getPlugins()>
<cfset pageProperties = hp.getConfig().getPageProperties()>
<cfset oCatalog = hp.getCatalog()>
<cfset hasSettings = false>

<cfoutput>
	<div class="cms-panelTitle">
		Plugin Settings
	</div>
	<cfloop array="#plugins#" index="pluginName">
		<cfset plugin = hp.getPluginManager().getPlugin(pluginName)>
		<cfset md = getMetaData(plugin)>
		<cfset propList = "">
		
		<cfif structKeyExists(md,"properties")>
			<cfset hasSettings = true>
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
							
							<cfset tmpType = prop.type>
							<cfif listLen(prop.type,":") eq 2 and listfirst(prop.type,":") eq "resource">
								<cfset tmpType = listfirst(prop.type,":")>
								<cfset resourceType = listlast(prop.type,":")>
							</cfif>
					
							<tr>
								<td><b><cfif structKeyExists(prop,"displayName")>#prop.displayName#<cfelse>#prop.name#</cfif>:</b></td>
								<td>
									<cfswitch expression="#tmpType#">
										<cfcase value="list">
											<cfset lstValues = prop.values>
											<select name="#prop.name#" class="cms-formField" style="width:150px;">
												<cfif not prop.required><option value=""></option></cfif>
												<cfloop list="#lstValues#" index="item">
													<option value="#item#" <cfif propValue eq item>selected</cfif>>#item#</option>
												</cfloop>
											</select>
										</cfcase>
										
										<cfcase value="resource">
											<cfset qryResources = oCatalog.getIndex(resourceType)>
											<cfquery name="qryResources" dbtype="query">
												SELECT *, upper(package) as upackage, upper(id) as uid
													FROM qryResources
													ORDER BY upackage, uid, id
											</cfquery>
											<select name="#prop.name#" class="cms-formField">
												<cfif not prop.required><option value=""></option></cfif>
												<cfloop query="qryResources">
													<option value="#qryResources.id#"
															<cfif propValue eq qryResources.id>selected</cfif>	
																><cfif qryResources.package neq qryResources.id
																	>[#qryResources.package#] </cfif>#qryResources.id#</option>
												</cfloop>
											</select>
										</cfcase>
										
										<cfcase value="boolean">
											<cfif prop.required>
												<cfset isTrueChecked = (isBoolean(propValue) and propValue)>
												<cfset isFalseChecked = (isBoolean(propValue) and not propValue) or (propValue eq "")>
											<cfelse>
												<cfset isTrueChecked = (isBoolean(propValue) and propValue)>
												<cfset isFalseChecked = (isBoolean(propValue) and not propValue)>
											</cfif>
											
											<input type="radio" name="#prop.name#" 
													style="border:0px;width:15px;"
													value="true" 
													<cfif isTrueChecked>checked</cfif>> True 
											<input type="radio" name="#prop.name#" 
													style="border:0px;width:15px;"
													value="false" 
													<cfif isFalseChecked>checked</cfif>> False 
										</cfcase>
										
										<cfdefaultcase>
											<input type="text" 
													name="#prop.name#" 
													value="#propValue#" 
													class="cms-formField">
										</cfdefaultcase>
									</cfswitch>
								</td>
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
					<input type="button" value="Apply Changes" onclick="cms.setGlobalPageProperties(this.form,[#propList#])">
				</form>
			</div>
		</cfif>
	</cfloop>
	<cfif not hasSettings>
		<p>There are no configurable options for any of the installed plugins.</p>
	</cfif>
</cfoutput>
