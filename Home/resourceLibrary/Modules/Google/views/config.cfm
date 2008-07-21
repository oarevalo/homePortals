<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	lstAvailableSearchers = "Web,Local,Video,Blog,News,Book,Image";
	
	// get default attributes
	searchers = cfg.getPageSetting("searchers");
	localSearchCenterPoint = cfg.getPageSetting("localSearchCenterPoint");

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
		<input type="hidden" name="searchers" value="#searchers#">
		
		<cfif Not stUser.isOwner>
			<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
		</cfif>
		
		<strong>Search in:</strong><br><br>
		
		<cfloop list="#lstAvailableSearchers#" index="item">
			<input type="checkbox" name="cb_searchers" value="#item#" <cfif listFindNoCase(searchers, item)>checked</cfif>> #item#<br>
		</cfloop>

		<br>
		
		For local searches, enter the address or location where to search:<br>
		<input type="text" name="localSearchCenterPoint" value="#localSearchCenterPoint#" size="30" #tmpDisabled#><br><br>
		
		<input type="button" value="Save" onclick="#moduleID#.submitSettingsForm(this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
	
</cfoutput>
