<cfparam name="arguments.resourceID" default="">
<cfscript>
	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";
	
	resourceID = arguments.resourceID;	
	
	stUser = this.controller.getUserInfo();
	siteOwner = stUser.username;
	
	if(resourceID neq "") {
		oResourceBean = this.controller.getHomePortals().getCatalog().getResourceNode(getResourceType(),resourceID);
		access = oResourceBean.getAccessType();
		name = oResourceBean.getName();
		description = oResourceBean.getDescription();
		content = "";
		contentLocation = oResourceBean.getHref();
		tmpTitle = "Edit Content";
	} else {
		access = "owner";
		description = "";
		name = "";
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
	<cfset contentLocation = resourcesRoot & "/" & contentLocation>
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
				<input type="hidden" name="resourceID" value="#resourceID#">
				<div style="border:1px solid silver;background-color:##fff;margin:5px;">
					<table>
						<tr>
							<td width="100"><b>Name:</b></td>
							<td><input type="text" name="name" value="#name#" style="width:300px;"></td>
						</tr>
						<tr>
							<td><strong>Share with:</strong></td>
							<td>
								<input type="radio" name="access_chk" value="general" <cfif access eq "general">checked</cfif> onclick="if(this.checked) this.form.access.value=this.value;"> Everyone &nbsp;&nbsp;&nbsp;
								<input type="radio" name="access_chk" value="friend" <cfif access eq "friend">checked</cfif> onclick="if(this.checked) this.form.access.value=this.value;"> My Friends &nbsp;&nbsp;&nbsp;
								<input type="radio" name="access_chk" value="owner" <cfif access eq "owner">checked</cfif> onclick="if(this.checked) this.form.access.value=this.value;"> Only Me
								<input type="hidden" name="access" value="#access#">
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
							style="width:475px;border:1px solid silver;padding:2px;height:285px;margin:5px;">#HTMLEditFormat(content)#</textarea>
				
				<div style="margin-top:10px;padding-bottom:10px;text-align:center;">
					<input type="button" name="btnSave" value="Save" onclick="#moduleID#.doFormAction('saveResource',this.form);#moduleID#.closeWindow();">&nbsp;&nbsp;&nbsp;
					<cfif resourceID neq "">
						<input type="button" name="btnDelete" value="Delete" onclick="if(confirm('Delete entry?')){#moduleID#.doAction('deleteResource',{resourceID:'#resourceID#'});#moduleID#.closeWindow();}">
					</cfif>
				</div>
				
			</form>

		</div>
	</div>
</cfoutput>
