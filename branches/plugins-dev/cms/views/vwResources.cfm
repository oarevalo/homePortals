<cfparam name="resourceType" default="">

<cfscript>
	hp = variables.homePortals;
	oCatalog = hp.getCatalog();
	rlm = hp.getResourceLibraryManager();
	aResTypes = rlm.getResourceTypes();
	
	if(resourceType eq "" and arrayLen(aResTypes) gt 0) 
		resourceType = aResTypes[1];	

</cfscript>

<cfif resourceType neq "">
	<cfset qryResources = oCatalog.getIndex(resourceType)>
	<cfquery name="qryResources" dbtype="query">
		SELECT *, upper(package) as upackage, upper(id) as uid
			FROM qryResources
			ORDER BY upackage, uid, id
	</cfquery>
</cfif>

<div class="cms-panelTitle">Site Resources</div>
<table width="100%">
	<tr valign="top">
		<td style="width:160px;">
			<strong>Resource Type: </strong>
			<select name="resType" onchange="cms.getPartialView('Resources',{resourceType:this.value},'cms-navMenuContentPanel')"
					style="width:150px;">
				<cfoutput>
					<cfloop from="1" to="#arrayLen(aResTypes)#" index="i">
						<option value="#aResTypes[i]#"
								<cfif aResTypes[i] eq resourceType>selected</cfif>
								>#aResTypes[i]#</option>
					</cfloop>
				</cfoutput>
			</select>
			
			<cfoutput>
				<p>	
					&raquo;
					<a href="javascript:cms.getPartialView('EditResourceForm',{resourceType:'#resourceType#',resourceID:'_NOVALUE_',prefix:'res'},'cms-resourceEditPanel')" 
						class="cpListLink" 
						style="font-weight:bold;" 
						>Create New...</a>
				</p>
			</cfoutput>
			
			<cfif resourceType neq "">
				<cfoutput query="qryResources" group="package">
					<cfset aPkgResources = []>
					<cfset tmpPackage = qryResources.package>
					<cfoutput>
						<cfset arrayAppend(aPkgResources, qryResources.id)>
					</cfoutput>
					<cfif arrayLen(aPkgResources) gt 1 or qryResources.id neq tmpPackage>
						<div style="margin-top:5px;">
							<b>#tmpPackage#</b><br>
							<cfloop array="#aPkgResources#" index="resID">
								<div style="border-bottom:1px solid ##ebebeb;">
									<div style="width:150px;overflow:hidden;">
										<a href="javascript:cms.getPartialView('EditResourceForm',{resourceType:'#resourceType#',resourceID:'#jsStringFormat(tmpPackage)#/#jsstringformat(resID)#',prefix:'res'},'cms-resourceEditPanel')" 
											class="cpListLink" 
											style="font-weight:normal;" 
											>#resID#</a>
									</div>
								</div>
							</cfloop>
						</div>
					<cfelse>
						<div style="border-bottom:1px solid ##ebebeb;">
							<div style="width:150px;overflow:hidden;">
								<a href="javascript:cms.getPartialView('EditResourceForm',{resourceType:'#resourceType#',resourceID:'#jsStringFormat(tmpPackage)#/#jsstringformat(qryResources.id)#',prefix:'res'},'cms-resourceEditPanel')" 
									class="cpListLink" 
									style="font-weight:normal;" 
									>#qryResources.id#</a>
							</div>
						</div>
					</cfif>
					
				</cfoutput>
				<cfif qryResources.recordCount eq 0>
					<cfoutput><em>There are no resources of type '#resourceType#'.</em></cfoutput>
				</cfif>
			</cfif>
			<!---
			<select name="prop_#thisAttr#" class="cms-formField" 
					onchange="cms.getPartialView('EditResource',{resourceType:'#resourceType#',resourceID:this.value,prefix:'res#i#'},'cms-resourceEditPanel')">
				<cfif not prop.required><option value="_NOVALUE_">Create New...</option></cfif>
				<cfloop query="qryResources">
					<option value="#qryResources.id#"
							<cfif tmpAttrValue eq qryResources.id>selected</cfif>	
								><cfif qryResources.package neq defaultPackage>#qryResources.package# :: </cfif>#qryResources.id#</option>
				</cfloop>
			</select>
				--->
		</td>
		<td>
			<div id="cms-resourceEditPanel" class="cms-lightPanel">Select a resource to load, or click on 'Create New' to create a new resource</div>
		</td>
	</tr>
</table>
