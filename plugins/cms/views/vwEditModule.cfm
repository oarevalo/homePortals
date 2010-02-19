<cfset hp = variables.homePortals>
<cfset modID = arguments.moduleID>
<cfset oModuleBean = variables.oPage.getModule(modID)>
<cfset stTemplates = hp.getTemplateManager().getTemplates("module")>
<cfset aLayoutRegions = variables.oPage.getLayoutRegions()>
<cfscript>
	objPath = hp.getConfig().getContentRenderer(oModuleBean.getModuleType());
	obj = createObject("component",objPath);
	tagInfo = getMetaData(obj);
	lstModuleAttribs = "";
	lstIgnoreAttribs = "";
	lstResPrefixes = "";
	lstResPrefixesJs = "";
	oCatalog = hp.getCatalog();
	thisModule = oModuleBean.toStruct();
	
	modTitle = oModuleBean.getTitle();
</cfscript>	
<cfoutput>
	<div class="cms-panelTitle">Edit Module: #modID#</div>
	
	<form name="frmModuleProperties" method="post" action="index.cfm" enctype="multipart/form-data">
		<input type="hidden" name="method" value="">
		<input type="hidden" name="_pageHREF" value="">
		<cfif structKeyExists(tagInfo,"hint") and tagInfo.hint neq "">
			<div class="cms-lightPanel" style="margin-bottom:5px;">
				<img src="#cmsRoot#/images/information.png" align="absmiddle">
				#tagInfo.hint#
			</div>
		</cfif>
		<table>
			<tr>
				<td style="width:80px;"><b>Title:</b></td>
				<td><input type="text" name="title" value="#modTitle#" class="cms-formField"></td>
				<td style="width:30px;">&nbsp;</td>
				<td style="width:80px;"><b>Template:</b></td>
				<td>
					<select name="moduleTemplate" class="cms-formField">
						<option value="">(Default)</option>
						<cfloop collection="#stTemplates#" item="key">
							<option value="#stTemplates[key].name#" 
									<cfif stTemplates[key].name eq oModuleBean.getModuleTemplate()>selected</cfif>>#stTemplates[key].name# <cfif stTemplates[key].isdefault eq true>*</cfif></option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td><b>Location:</b></td>
				<td>
					<select name="location" class="cms-formField">
						<option value=""></option>
						<cfloop array="#aLayoutRegions#" index="item">
							<option value="#item.name#"
									<cfif item.name eq oModuleBean.getLocation()>selected</cfif>>#item.name#</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
		<div class="cms-divider"></div>
		<cfinclude template="vwModuleProperties.cfm">
		<br />
		<cfset lstModuleAttribs = listQualify(lstModuleAttribs,"'")>
		<cfset lstResPrefixesJs = listQualify(lstResPrefixesJs,"'")>
		<input type="hidden" name="moduleID" value="#modID#">
		<input type="hidden" name="resPrefixes" value="#lstResPrefixes#">
		<input type="button" value="Apply Changes" onclick="controlPanel.updateModule(this.form,[#lstModuleAttribs#],'#lstResPrefixes#',[#lstResPrefixesJs#])">
		&nbsp;&nbsp;
		<input type="button" value="Close" onclick="controlPanel.closePanel()">
	</form>
	
</cfoutput>