<cfscript>
	oCatalog = getValue("oCatalog", 0);	
	resourceType = getValue("resourceType","");
	lstResourceTypes = "Modules,Skins,PageTemplates,Pages";
	
	if(resourceType eq "") resourceType = listFirst(lstResourceTypes);
	
	if(resourceType eq "Modules") aResources = oCatalog.getModules();
	if(resourceType eq "Skins") aResources = oCatalog.getSkins();
	if(resourceType eq "PageTemplates") aResources = oCatalog.getPageTemplates();
	if(resourceType eq "Pages") aResources = oCatalog.getPages();

</cfscript>

<cfoutput>
	<table style="margin:5px;width:620px;" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td><h2 style="margin-top:0px;">Module Library</h2></td>
			<td align="right">
				<b>Resource Type:</b>
				<select name="resourceType" onchange="document.location='?event=ehModules.dspMain&resourceType='+this.value">
					<cfloop list="#lstResourceTypes#" index="res">
						<option value="#res#" <cfif res eq resourceType>selected</cfif>>#res#</option>
					</cfloop>
				</select>
			</td>
		</tr>
	</table>

	<cfset j = 1>
	<table class="tblGrid" width="630">
		<tr>
			<th width="10">&nbsp;</th>
			<th width="50">ID</th>
			<th>Name</th>
		</tr>
		
		<tr><td colspan="3" style="font-weight:bold;background-color:##ccc;border-bottom:1px solid ##333;border-top:1px solid white;">Modules</td></tr>
		<cfloop from="1" to="#arrayLen(aResources)#" index="i">		
			<cfset tmpItem = aResources[i]>
			<cfset urlEdit = "?event=ehModules.dspViewModuleInfo&id=#tmpItem.id#">
			<cfset urlDelete = "?event=ehModules.doRemoveModule&id=#tmpItem.id#">
			<tr <cfif j mod 2>style="background-color:##ebebeb;"</cfif>>
				<td><strong>#i#.</strong></td>
				<td>
					<cfif resourceType eq "Modules">
						<a href="#urlEdit#">#tmpItem.id#</a>	
					<cfelse>
						#tmpItem.id#
					</cfif>
				</td>
				<td>
					<cfif resourceType eq "Modules">
						#tmpItem.name#
					<cfelse>
						#tmpItem.href#
					</cfif>
				</td>
			</tr>
			<cfset j = j + 1>
		</cfloop>
		<cfif arrayLen(aResources) eq 0>
			<tr><td colspan="3"><em>No #resourceType# found!</em></td></tr>
		</cfif>
	</table>

	<p>
		<input type="button" name="btnRebuild" value="Rebuild Catalog" onClick="document.location='?event=ehModules.dspMain&rebuildCatalog=true'">
		<cfif resourceType eq "Modules">
			&nbsp;&nbsp;&nbsp;Click on module ID to view module description.
		</cfif>
	</p>
	<br>
</cfoutput>
