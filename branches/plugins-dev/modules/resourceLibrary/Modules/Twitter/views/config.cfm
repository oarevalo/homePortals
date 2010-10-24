<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	
	// get default values
	accountName = cfg.getPageSetting("accountName");
	maxItems = cfg.getPageSetting("maxItems");

	// get current user info
	stUser = this.controller.getUserInfo();

 	// make sure only owner can make changes 
	if(Not stUser.isOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";
</cfscript>

<cfoutput>
	<form name="frmSettings" action="##" method="post" class="settings" style="font-size:10px;">
		<cfif Not stUser.isOwner>
			<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
		</cfif>
		
		<strong>Account Name:</strong><br>
		<input type="text" name="accountName" value="#accountName#" #tmpDisabled# style="font-size:11px;border:1px solid silver;width:170px;"><br>
		<br>

		<strong>Max. Items To Display:</strong>&nbsp;
		<input type="text" name="maxItems" value="#maxItems#" size="5" #tmpDisabled# style="font-size:11px;border:1px solid silver;"><br><br>

		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
</cfoutput>
