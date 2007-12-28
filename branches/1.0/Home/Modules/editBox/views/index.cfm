<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();
	
	// get content store
	setContentStoreURL();
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();

	// get current user info
	stUser = this.controller.getUserInfo();
		
	// check if current user is owner
	bIsContentOwner = (stUser.username eq myContentStore.getOwner());
	
	// get all content entries
	aContents = xmlSearch(xmlDoc,"//content");
</cfscript>

<cfoutput>
	<b>Contents:</b><br>
	<cfloop from="1" to="#ArrayLen(aContents)#" index="i">
		<option value="#aContents[i].xmlAttributes.id#">
			<li><a href="javascript:#moduleID#.getView('page','',{contentID:'#aContents[i].xmlAttributes.id#'})">#aContents[i].xmlAttributes.id#</a></li>
		</option>
	</cfloop>

	<cfif bIsContentOwner>
		<div id="#moduleID#_toolbar">
			<cfif bIsContentOwner>
				<a href="javascript:#moduleID#.getPopupView('edit',{contentID:'NEW'});"><img src="/Home/Modules/editBox/images/add-page-orange.gif" border="0" align="absmiddle"></a>
				<a href="javascript:#moduleID#.getPopupView('edit',{contentID:'NEW'});">New</a>&nbsp;&nbsp;
			</cfif>
		</div>
	</cfif>
</cfoutput>
