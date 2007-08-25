<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	
	// get default settings
	src = cfg.getPageSetting("src","");
	href = cfg.getPageSetting("href","");
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
	<form name="frmSettings" action="##" method="post" class="RSSSettings">
		<cfif Not stUser.isOwner>
			<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
		</cfif>
		
		<strong>Image source:</strong><br>
		<input type="text" name="src" value="#src#" size="15" #tmpDisabled#><br><br>

		<strong>HREF:</strong><br>
		<input type="text" name="href" value="#href#" size="15" #tmpDisabled#><br><br>
		<div style="font-size:9px;font-weight:normal;">
			[Optional] When not empty, this is the address to go to when the image is clicked
		</div><br>

		<strong>Label:</strong><br>
		<input type="text" name="label" value="#label#" size="15" #tmpDisabled#><br><br>
		<div style="font-size:9px;font-weight:normal;">
			ALT text for the image
		</div><br>

		<br>
		
		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
</cfoutput>
