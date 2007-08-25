<cfparam name="arguments.contentID" default="">
<cfscript>
	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";
	
	contentID = arguments.contentID;	
	
	stUser = this.controller.getUserInfo();
	siteOwner = stUser.username;
	
	if(contentID neq "") {
		oResourceBean = application.homePortals.getCatalog().getResourceNode("content",contentID);
		access = oResourceBean.getAccessType();
		description = oResourceBean.getDescription();
		content = "";
		contentLocation = oResourceBean.getHref();
		tmpTitle = "Edit Content";
	} else {
		access = "owner";
		description = "";
		content = "";
		contentLocation = "";
		tmpTitle = "Create Content";
	}
		
	// get the moduleID
	moduleID = this.controller.getModuleID();	
</cfscript>

<cfif contentLocation neq "">
	<cffile action="read" file="#expandPath(contentLocation)#" variable="content">
</cfif>

<cfoutput>
	<div style="background-color:##f5f5f5;">
		<div style="padding:0px;width:490px;">
		
			<div style="margin:5px;background-color:##333;border:1px solid silver;color:##fff;">
				<div style="margin:5px;">
					<strong>ContentBox:</strong> #tmpTitle#
				</div>
			</div>
	
			<form name="frmEditContent" action="##" method="post" style="margin:0px;padding:0px;">
				<input type="hidden" name="contentID" value="#contentID#">
				<div style="border:1px solid silver;background-color:##fff;margin:5px;">
					<table>
						<tr>
							<td width="100"><b>Name:</b></td>
							<td>
								<cfif contentID neq "">
									<input type="text" name="newContentID" value="#contentID#" style="width:300px;" readonly="true">
								<cfelse>
									<input type="text" name="newContentID" value="" style="width:300px;">
								</cfif>
							</td>
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
					<input type="button" name="btnSave" value="Save" onclick="#moduleID#.doFormAction('saveContent',this.form);#moduleID#.closeWindow();">&nbsp;&nbsp;&nbsp;
					<cfif contentID neq "">
						<input type="button" name="btnDelete" value="Delete" onclick="if(confirm('Delete entry?')){#moduleID#.doAction('deleteContent',{contentID:'#contentID#'});#moduleID#.closeWindow();}">
					</cfif>
				</div>
				
			</form>

		</div>
	</div>
</cfoutput>
