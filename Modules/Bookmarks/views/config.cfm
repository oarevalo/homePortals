<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();
		
	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";

	// get current user info
	stUser = this.controller.getUserInfo();

 	// make sure only owner can make changes 
	if(Not stUser.isOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";
			
	bookmarksURL = cfg.getPageSetting("url");
	bFollowLink = cfg.getPageSetting("followLink");
	if(Not IsBoolean(bFollowLink)) bFollowLink = true;
</cfscript>

<cfoutput>
	<form name="frmBookmarksSettings" action="##" method="post" class="Bookmarks2Settings">
		<cfif Not stUser.isOwner>
			<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
		</cfif>

		<strong>Bookmarks URL:</strong><br>
		<input type="text" name="url" value="#bookmarksURL#" size="30" #tmpDisabled#><br>
		<div style="font-size:9px;font-weight:normal;">
			<b>Hint:</b> URL must indicate the location of an OPML document.
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
