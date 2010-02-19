<cfset defaultPackage = "default">

<cfoutput>	
	<cfif structKeyExists(tagInfo,"properties") and arrayLen(tagInfo.properties) gt 0>
		<table width="100%">
			<cfloop from="1" to="#arrayLen(tagInfo.properties)#" index="i">
				<cfset prop = duplicate(tagInfo.properties[i])>
				<cfparam name="prop.name" default="property">
				<cfparam name="prop.hint" default="">
				<cfparam name="prop.default" default="">
				<cfparam name="prop.type" default="">
				<cfparam name="prop.required" default="false">
				<cfparam name="prop.displayName" default="#prop.name#">
				
				<cfparam name="thisModule[prop.name]" default="#prop.default#">
				
				<cfset tmpAttrValue = thisModule[prop.name]>
				<cfset thisAttr = prop.name>
				<cfif listLen(prop.type,":") eq 2 and listfirst(prop.type,":") eq "resource">
					<cfset tmpType = listfirst(prop.type,":")>
					<cfset resourceType = listlast(prop.type,":")>
				<cfelse>
					<cfset tmpType = prop.type>
				</cfif>
				<cfset lstModuleAttribs = listAppend(lstModuleAttribs, "prop_" & prop.name)>
				<cfset lstModuleAttribs = listAppend(lstModuleAttribs, "prop_" & prop.name & "_default")>
				
				<cfif tmpType eq "resource">
					<cfset lstResPrefixes = listAppend(lstResPrefixes, "#thisAttr#:#resourceType#:res#i#")>
					<cfset lstResPrefixesJs = listAppend(lstResPrefixesJs, "res#i#")>
				</cfif>				
										
				<tr valign="top">
					<td nowrap="nowrap" style="width:80px;"><strong>#prop.displayName#:</strong></td>
					<td>
						<cfswitch expression="#tmpType#">
							<cfcase value="list">
								<cfif structKeyExists(prop,"values")>
									<cfset lstValues = prop.values>
								<cfelse>
									<cfset lstValues = "">
								</cfif>
								<cfparam name="prop.values" default="string">
								<select name="prop_#thisAttr#" class="cms-formField">
									<cfif not prop.required><option value="_NOVALUE_"></option></cfif>
									<cfloop list="#lstValues#" index="item">
										<option value="#item#" <cfif tmpAttrValue eq item>selected</cfif>>#item#</option>
									</cfloop>
								</select>
							</cfcase>
							
							<cfcase value="resource">
								<cfset qryResources = oCatalog.getResourcesByType(resourceType)>
								<cfquery name="qryResources" dbtype="query">
									SELECT *, upper(package) as upackage, upper(id) as uid
										FROM qryResources
										ORDER BY upackage, uid, id
								</cfquery>
								<select name="prop_#thisAttr#" class="cms-formField" 
										onchange="controlPanel.getPartialView('EditResource',{resourceType:'#resourceType#',resourceID:this.value,prefix:'res#i#'},'cms-resourceEditPanel')">
									<cfif not prop.required><option value="_NOVALUE_">Create New...</option></cfif>
									<cfloop query="qryResources">
										<option value="#qryResources.id#"
												<cfif tmpAttrValue eq qryResources.id>selected</cfif>	
													><cfif qryResources.package neq defaultPackage>#qryResources.package# :: </cfif>#qryResources.id#</option>
									</cfloop>
								</select>
							</cfcase>
							
							<cfcase value="boolean">
								<cfif prop.required>
									<cfset isTrueChecked = (isBoolean(tmpAttrValue) and tmpAttrValue)>
									<cfset isFalseChecked = (isBoolean(tmpAttrValue) and not tmpAttrValue) or (tmpAttrValue eq "")>
								<cfelse>
									<cfset isTrueChecked = (isBoolean(tmpAttrValue) and tmpAttrValue)>
									<cfset isFalseChecked = (isBoolean(tmpAttrValue) and not tmpAttrValue)>
								</cfif>
								
								<input type="radio" name="prop_#thisAttr#" 
										style="border:0px;width:15px;"
										value="true" 
										<cfif isTrueChecked>checked</cfif>> True 
								<input type="radio" name="prop_#thisAttr#" 
										style="border:0px;width:15px;"
										value="false" 
										<cfif isFalseChecked>checked</cfif>> False 
							</cfcase>
							
							<cfdefaultcase>
								<input type="text" 
										name="prop_#thisAttr#" 
										value="#tmpAttrValue#" 
									 class="cms-formField">
							</cfdefaultcase>
						</cfswitch>
						<input type="hidden" name="prop_#thisAttr#_default" value="#prop.default#">
					</td>
					<td class="cms-formFieldTip">
						<cfif prop.hint neq "" and prop.hint neq "N/A">
							#prop.hint#
						</cfif>
					</td>
				</tr>
				<cfif tmpType eq "resource">
					<tr>
						<td>&nbsp;</td>
						<td colspan="2">
							<div id="cms-resourceEditPanel" class="cms-lightPanel"></div>
							<script>controlPanel.getPartialView("EditResource",{resourceType:'#resourceType#',resourceID:'#tmpAttrValue#',prefix:'res#i#'},"cms-resourceEditPanel")</script>
						</td>
					</tr>
				</cfif>
			</cfloop>
		</table>
	</cfif>
	<cfset lstIgnoreAttribs = listAppend(lstIgnoreAttribs, lstModuleAttribs)>
</cfoutput>