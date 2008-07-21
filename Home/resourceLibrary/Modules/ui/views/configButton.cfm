<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	
	// get default settings
	onClick = cfg.getPageSetting("onClick","");
	label = cfg.getPageSetting("label","");

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
		
		<strong>Label:</strong><br>
		<input type="text" name="label" value="#label#" size="15" #tmpDisabled#><br><br>
		<div style="font-size:9px;font-weight:normal;">
			The label to display on the button
		</div><br>

		<strong>On Click:</strong><br>
		<input type="text" name="onClick" value="#onClick#" size="15" #tmpDisabled#><br><br>
		<div style="font-size:9px;font-weight:normal;">
			A JavaScript action to execute when the button is clicked
		</div><br>

		<br>
		
		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
</cfoutput>
