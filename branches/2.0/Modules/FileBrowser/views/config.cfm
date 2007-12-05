<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	
	// get current settings
	tmpRootPath = cfg.getPageSetting("root");
	tmpFilter = cfg.getPageSetting("filter");

	// get current user info
	stUser = this.controller.getUserInfo();

 	// make sure only owner can make changes 
	if(Not stUser.isOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";
</cfscript>

<cfoutput>
	<form name="frmSettings" action="##" method="post" class="FileBrowserSettings">
		<cfif Not stUser.isOwner>
			<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
		</cfif>
		
		<strong>Root:</strong><br>
		<input type="text" name="root" value="#tmpRootPath#" size="30" #tmpDisabled#>
		<div style="font-size:9px;font-weight:normal;">
			<b>Hint:</b> Leave empty to use your account as the root directory.
		</div><br>
		
		<strong>Filter:</strong><br>
		<input type="text" name="filter" value="#tmpFilter#" size="30" #tmpDisabled#>
		<div style="font-size:9px;font-weight:normal;">
			<b>Example:</b> *.jpg
		</div><br>

		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
</cfoutput>
