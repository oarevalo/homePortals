<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	
	// get default RSS feed
	rssURL = cfg.getPageSetting("rss");
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
	<form name="frmSettings" action="##" method="post" class="RSSSettings">
		<cfif Not stUser.isOwner>
			<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
		</cfif>
		
		<strong>Feed URL:</strong><br>
		<input type="text" name="rss" value="#rssURL#" size="30" #tmpDisabled#><br><br>

		<strong>Max. Items To Display:</strong><br>
		<input type="text" name="maxItems" value="#maxItems#" size="5" #tmpDisabled#>
		<div style="font-size:9px;font-weight:normal;">
			Leave empty to display all items in the feed.
		</div><br>
		
		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
</cfoutput>
