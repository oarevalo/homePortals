
<cfset catalogIndex = 0>
<cfset aModules = ArrayNew(1)>

<cfoutput>
<cftry>
	<div class="cp_sectionTitle" id="cp_pd_moduleProperties_Title" 
			style="width:298px;padding:0px;margin:0px;">
		<table style="margin:2px;" cellpadding="0" cellspacing="0">
			<tr>
				<td>
					<img src="#imgRoot#/brick_add.png" align="absmiddle"> Add Content
				</td>
				<td align="right">
					<a href="javascript:controlPanel.closeAddContentPanel()" style="font-size:9px;">Close</a>
					&nbsp;&nbsp;
				</td>
			</tr>
		</table>
	</div>
	<div class="cp_sectionBox" 
		style="margin:0px;width:298px;padding:0px;height:276px;border-top:0px;">
	
		<div style="font-weight:bold;margin-bottom:5px;margin:4px;">Click on a module to add to the page.</div>
		<table style="margin-left:4px;width:290px;" cellpadding="0" cellspacing="0">
			<tr>
				<!--- Display modules in catalog --->
				<cfset aModules = variables.oCatalog.getModules()>
				
				<!--- put modules into a query and sort them --->
				<cfset lstModules = "">
				<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
					<cfset lstModules = ListAppend(lstModules, aModules[j].id)>
				</cfloop>
				<cfset lstModules = ListSort(lstModules, "textnocase")>
		
				<cfset j=1>
				<cfloop list="#lstModules#" index="tmpItem">
					<td>
						<a href="javascript:controlPanel.getAddModule('#tmpItem#')" 
							class="cpListLink" 
							style="font-weight:normal;color:##333;" 
							>#tmpItem#</a>
					</td>
					<cfif not(j mod 3)></tr><tr></cfif>
					<cfset j=j+1>
				</cfloop>
			</tr>
		</table>
	

		</div>
	</div>
	
	<script>
		d = $("addContent_BodyRegion");
		h = $("cp_pd_moduleProperties_Title");
		d.setDragHandle(h);
	</script>
	
	<cfcatch type="any">
		<br><b>Error:</b> #cfcatch.Message#
	</cfcatch>
</cftry>
</cfoutput>

<!--- reserve space to display module info --->
<div id="catalogModuleInfo_BodyRegion" style="display:none;bottom:-20px;left:-390px;"></div>