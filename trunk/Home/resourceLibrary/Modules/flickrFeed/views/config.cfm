<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	args = structNew();
	
	// get current settings
	args.showHeader = cfg.getPageSetting("showheader");
	args.onClickGotoFlickr = cfg.getPageSetting("onClickGotoFlickr");
	args.UserID = cfg.getPageSetting("userid");
	args.Tags = cfg.getPageSetting("tags");
	args.username = cfg.getPageSetting("username");
	args.maxItems = cfg.getPageSetting("maxItems",0);

	// get current user info
	stUser = this.controller.getUserInfo();

 	// make sure only owner can make changes 
	if(Not stUser.isOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";
</cfscript>

<cfoutput>
	<form name="frmSettings" action="##" method="post" class="flickrFeedSettings">
		<cfif Not stUser.isOwner>
			<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
		</cfif>
		
		<strong>Flickr Username:</strong><br>
		<input type="text" name="Username" value="#args.Username#" size="20" #tmpDisabled#><br><br>
		
		<strong>Search Tags:</strong><br>
		<input type="text" name="tags" value="#args.Tags#" size="20" #tmpDisabled#><br><br>

		<strong>Max. No. of pictures to show:</strong><br>
		<input type="text" name="maxItems" value="#args.maxItems#" size="20" #tmpDisabled#><br>
		<div style="font-size:9px;font-weight:normal;">
			Enter 0 or leave empty to display all pictures
		</div>
		<br />
		
		<strong>Show Header?</strong>
		<input type="checkbox" name="showHeader" value="yes" #tmpDisabled# 
				style="border:0px;"
				<cfif args.showHeader>checked</cfif>><br>

		<strong>On Click Go to Flickr?</strong>
		<input type="checkbox" name="onClickGotoFlickr" value="yes" #tmpDisabled# 
				style="border:0px;"
				<cfif args.onClickGotoFlickr>checked</cfif>><br>
		<div style="font-size:9px;font-weight:normal;">
			Check this option to go to the Flickr site when clicking on a thumbnail
			instead of displaying the picture in full size.
		</div>
		<br>
		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
</cfoutput>
