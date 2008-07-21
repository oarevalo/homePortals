<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	
	// get default attributes
	href = cfg.getPageSetting("url");
	width = cfg.getPageSetting("width");
	height = cfg.getPageSetting("height");

	// get current user info
	stUser = this.controller.getUserInfo();

 	// make sure only owner can make changes 
	if(Not stUser.isOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";
</cfscript>

<cfoutput>
	<form name="frmSettings" action="##" method="post" class="SectionSettings">
		<cfif Not stUser.isOwner>
			<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
		</cfif>
		
		<strong>URL:</strong><br>
		<input type="text" name="url" value="#href#" size="30" #tmpDisabled#><br><br>

		<strong>Width:</strong><br>
		<input type="text" name="width" value="#width#" size="5" #tmpDisabled#>
		<span style="font-size:9px;font-weight:normal;">
			&nbsp; Leave empty to use default width
		</span><br><br>

		<strong>Height:</strong><br>
		<input type="text" name="height" value="#height#" size="5" #tmpDisabled#>
		<span style="font-size:9px;font-weight:normal;">
			&nbsp; Leave empty to use default height
		</span><br><br>
		
		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
</cfoutput>
