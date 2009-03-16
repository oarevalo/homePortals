<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	
	// get default settings
	onClickGotoURL = cfg.getPageSetting("onClickGotoURL",true);
	mode = cfg.getPageSetting("mode","searchByTag");
	term = cfg.getPageSetting("term","");

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
		
		<b>Select mode:</b><br>
		<select name="mode">
			<option value="searchByTag" <cfif mode eq "searchByTag">selected</cfif>> Search by tags</option>
			<option value="searchByUser" <cfif mode eq "searchByUser">selected</cfif>> Search by user</option>
			<option value="listFeatured" <cfif mode eq "listFeatured">selected</cfif>> List featured videos</option>
			<option value="listPopular" <cfif mode eq "listPopular">selected</cfif>> List popular videos</option>
		</select>
		
		<br><br>
		<b>Search For:</b>
		<input type="text" name="term" value="#term#"><br>
		<div style="font-size:10px;">Only used when searching by tag or user</div><br>
		
		<strong>View items in YouTube website?:</strong> 
		<input type="checkbox" name="onClickGotoURL" value="true" <cfif onClickGotoURL>checked</cfif> #tmpDisabled#>
		<br><br>

		<br>
		
		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
</cfoutput>
