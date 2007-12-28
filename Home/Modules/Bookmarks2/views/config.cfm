<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();
		
	// get content store
	setContentStoreURL();
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";

	// get current user info
	stUser = this.controller.getUserInfo();

	// check if current user is owner
	bIsContentOwner = (stUser.username eq myContentStore.getOwner());

 	// make sure only owner can make changes 
	if(Not bIsContentOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";
			
	bookmarksURL = cfg.getPageSetting("url");
	bFollowLink = cfg.getPageSetting("followLink");
	if(Not IsBoolean(bFollowLink)) bFollowLink = true;
</cfscript>

<cfoutput>
	<form name="frmBookmarksSettings" action="##" method="post" class="Bookmarks2Settings">
		<cfif Not bIsContentOwner>
			<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
		</cfif>

		<strong>Bookmarks URL (optional):</strong><br>
		<input type="text" name="url" value="#bookmarksURL#" size="30" #tmpDisabled#><br>
		<div style="font-size:9px;font-weight:normal;">
			<b>Hint:</b> Leave empty to store your bookmarks on the default file
		</div>

		<br>

		<strong>Follow Links?</strong>
		<input type="checkbox" name="followLink" value="yes" #tmpDisabled# 
				style="border:0px;"
				<cfif bFollowLink>checked</cfif>><br>
		<div style="font-size:9px;font-weight:normal;">
			Use this to treat each item as link to another website
		</div>

		<br>
		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
</cfoutput>
