<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	
	// get default RSS feed
	rssURL = cfg.getPageSetting("rss");
	maxItems = cfg.getPageSetting("maxItems");
	displayMode = cfg.getPageSetting("displayMode");

	// get current user info
	stUser = this.controller.getUserInfo();

 	// make sure only owner can make changes 
	if(Not stUser.isOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";
		
	showFeedDirectory = cfg.getProperty("showFeedDirectory",true);	
</cfscript>

<cfoutput>
	<form name="frmSettings" action="##" method="post" class="settings" style="font-size:10px;">
		<cfif Not stUser.isOwner>
			<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
		</cfif>
		
		<strong>Feed URL:</strong><br>
		<input type="text" name="rss" value="#rssURL#" #tmpDisabled# style="font-size:11px;border:1px solid silver;width:170px;"><br>
		<cfif showFeedDirectory>
			<a href="javascript:#moduleID#.getPopupView('directory');">Feed Directory</a><br>
		</cfif>
		<br>

		<strong>Display Mode:</strong><br>
		<select name="displayMode" style="font-size:11px;border:1px solid silver;width:170px;">
			<option value="short" <cfif displayMode eq "short">selected</cfif>>Headlines only</option>
			<option value="long" <cfif displayMode eq "long">selected</cfif>>Headlines + content</option>
		</select><br><br>

		<strong>Max. Items To Display:</strong>&nbsp;
		<input type="text" name="maxItems" value="#maxItems#" size="5" #tmpDisabled# style="font-size:11px;border:1px solid silver;"><br><br>

		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
</cfoutput>
