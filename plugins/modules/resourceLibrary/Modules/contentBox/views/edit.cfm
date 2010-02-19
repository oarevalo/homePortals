<cftry>
<cfparam name="arguments.resourceID" default="">
<cfscript>
	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
	
	stUser = this.controller.getUserInfo();
	siteOwner = stUser.username;
	
	if(arguments.resourceID neq "") {
		oResourceBean = this.controller.getHomePortals().getCatalog().getResourceNode(getResourceType(),arguments.resourceID);
		description = oResourceBean.getDescription();
		content = "";
		contentLocation = oResourceBean.getFullHref();
		tmpTitle = "Edit Content";
	} else {
		description = "";
		content = "";
		contentLocation = "";
		tmpTitle = "Create Content";
	}
		
	// get the moduleID
	moduleID = this.controller.getModuleID();	
	
	// get the resources root
	// get resource library root
	hpConfigBean = this.controller.getHomePortalsConfigBean();	
	resourcesRoot = hpConfigBean.getResourceLibraryPath();
</cfscript>

<cfif contentLocation neq "">
	<cfif fileExists(expandPath(contentLocation))>
		<cffile action="read" file="#expandPath(contentLocation)#" variable="content">
	<cfelse>
		<cfset content = "Content document not found!">
	</cfif>
</cfif>

<cfoutput>
	<div style="background-color:##f5f5f5;">
		<div style="padding:0px;width:490px;">
		
			<div style="margin:5px;background-color:##333;border:1px solid silver;color:##fff;">
				<div style="margin:5px;">
					<strong>#getResourceType()#Box:</strong> #tmpTitle#
				</div>
			</div>
	
			<form name="frmEditContent" action="##" method="post" style="margin:0px;padding:0px;">
				<input type="hidden" name="resourceID" value="#arguments.resourceID#">
				<div style="border:1px solid silver;background-color:##fff;margin:5px;">
					<table>
						<tr>
							<td width="100"><b>Name:</b></td>
							<td>
								<cfif arguments.resourceID eq "">
									<input type="text" name="newResourceID" value="" style="width:300px;">
								<cfelse>
									<b>#arguments.resourceID#</b>
								</cfif>
							</td>
						</tr>
						<tr valign="top">
							<td><strong>Description:</strong></td>
							<td><textarea name="description" style="width:300px;" rows="2">#description#</textarea></td>
						</tr>
					</table>
				</div>

				<textarea name="body" 
							wrap="off" 
							id="#moduleID#_edit" 
							style="width:475px;border:1px solid silver;padding:2px;height:300px;margin:5px;">#HTMLEditFormat(content)#</textarea>
				
				<div style="margin-top:10px;padding-bottom:10px;text-align:center;">
					<input type="button" name="btnSave" value="Save" onclick="#moduleID#.doFormAction('saveResource',this.form);#moduleID#.closeWindow();">&nbsp;&nbsp;&nbsp;
					<cfif arguments.resourceID neq "">
						<input type="button" name="btnDelete" value="Delete" onclick="if(confirm('Delete entry?')){#moduleID#.doAction('deleteResource',{resourceID:'#arguments.resourceID#'});#moduleID#.closeWindow();}">
					</cfif>
				</div>
				
			</form>

		</div>
	</div>
</cfoutput>
	<cfcatch >
	<cfdump var="#cfcatch#">
	</cfcatch>
	</cftry>
