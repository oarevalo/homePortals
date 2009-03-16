<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();

	// get current user info
	stUser = this.controller.getUserInfo();

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";

	try {	
		// get content store
		setContentStoreURL();
		myContentStore = this.controller.getContentStore();
		xmlDoc = myContentStore.getXMLData();

		// check if current user is owner
		bIsContentOwner = (stUser.username eq myContentStore.getOwner());
		
	} catch(any e) {
		bIsContentOwner = stUser.isOwner;   // since we can't read the content store, 
											// assume the page owner is the content owner
		errMessage = e.message & "<br>" & e.detail;
	}

 	// make sure only owner can make changes 
	if(Not bIsContentOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";
			
	calendarURL = cfg.getPageSetting("calendarURL");
</cfscript>

<cfoutput>
	<form name="frmAppointmentsSettings" action="##" method="post" class="SectionSettings">
		<cfif Not bIsContentOwner>
			<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
		</cfif>

		<strong>Name (optional):</strong><br>
		<input type="text" name="url" value="#calendarURL#" size="30" #tmpDisabled#><br>
		<div style="font-size:9px;font-weight:normal;">
			Use this field to give an specific name to this calendar. 
			Names may only contain letters or the '_' character.
		</div>

		<br>

		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()">
	</form>
</cfoutput>
