<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();

	// get current user info
	stUser = this.controller.getUserInfo();

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";

	// used to catch errors
	bFailed = false;
	errMessage = "";
		
	try {	
		// get content store
		setContentStoreURL();
		myContentStore = this.controller.getContentStore();
		xmlDoc = myContentStore.getXMLData();

		// check if current user is owner
		bIsContentOwner = (stUser.username eq myContentStore.getOwner());
		
		// get all content entries
		aGroups = xmlSearch(xmlDoc,"//body/*");
		
		bFollowLink = cfg.getPageSetting("followLink");
		if(Not IsBoolean(bFollowLink))
			bFollowLink = true;

	} catch(any e) {
		aGroups = ArrayNew(1);
		bFailed = true;
		bIsContentOwner = stUser.isOwner;   // since we can't read the content store, 
											// assume the page owner is the content owner
		errMessage = e.message & "<br>" & e.detail;
	}
</cfscript>

<cfoutput>

<cfif Not bFailed>
	<table border="0" cellpading="0" cellspacing="0" style="margin-top:0px;">
		<cfloop from="1" to="#ArrayLen(aGroups)#" index="i">
			<cfset aLinks = aGroups[i].XMLChildren>
			<cfset thisAttribs = duplicate(aGroups[i].XMLAttributes)>
	
			<cfparam name="thisAttribs.text" default="" type="string">
			<cfparam name="thisAttribs.url" default="##" type="string">
			<cfparam name="thisAttribs.target" default="" type="string">
			<cfparam name="thisAttribs.onclick" default="" type="string">
			<cfparam name="thisAttribs.type" default="link" type="string">
			<cfparam name="thisAttribs.htmlURL" default="#thisAttribs.url#" type="string">
			<cfparam name="thisAttribs.xmlURL" default="" type="string">
	
			<cfset thisItem = thisAttribs.text>
	
			<cfif thisAttribs.htmlURL eq "">
				<cfset thisAttribs.htmlURL = thisAttribs.url>
			</cfif>
			
			<cfif thisAttribs.xmlURL neq "" and (thisAttribs.type eq "rss" or thisAttribs.type eq "atom")>
				<cfset tmpURL = thisAttribs.xmlURL>
			<cfelse>
				<cfset tmpURL = thisAttribs.htmlURL>
			</cfif>
	
			<cfset tmpEvent = "#moduleID#.raiseEvent('onClick',{url:'#tmpURL#'})">
			<cfset thisAttribs.onclick = ListAppend(thisAttribs.onclick, tmpEvent, ";")>					
	
			<cfif Not bFollowLink>
				<cfset thisAttribs.url = "##">
			</cfif>
	
			<tr>
				<td>
					<!--- if current user is the owner, show option to edit list --->
					<cfif bIsContentOwner>
						<a href="javascript:#moduleID#.getView('edit','',{index:#i#});"><img src="#imgRoot#/edit-page-yellow.gif" border="0" alt="Edit Bookmark" title="Edit Bookmark" align="absmiddle"></a>
						<a href="javascript:if(confirm('Delete Bookmark?')) #moduleID#.doAction('deleteItem',{index:#i#});"><img src="#imgRoot#/omit-page-orange.gif" border="0" alt="Delete Bookmark" align="absmiddle" title="Delete Bookmark"></a>
					</cfif>
					<a href="#URLDecode(thisAttribs.url)#" 
						<cfif thisAttribs.target neq "">target="#thisAttribs.target#"</cfif> 
						<cfif thisAttribs.onclick neq "">onClick="#thisAttribs.onclick#"</cfif>
						><strong>#thisItem#</strong></a>
				</td>
			</tr>
	
		</cfloop>
		<cfif ArrayLen(aGroups) eq 0>
			<li><em>This list has no items</em></li>
		</cfif>
	</table>
<cfelse>
	<b>Error:</b><br>
	#errMessage#
</cfif>

<cfif bIsContentOwner>
	<div class="Bookmarks2Toolbar">
		<a href="javascript:#moduleID#.getView('edit')"><img src="#imgRoot#/add-page-orange.gif" border="0" align="absmiddle" alt="Add Bookmark"></a>
		<a href="javascript:#moduleID#.getView('edit')"><strong>Add Item</strong></a>
		&nbsp;&nbsp;
		<a href="javascript:#moduleID#.getView('config')"><img src="#imgRoot#/check-orange.gif" border="0" align="absmiddle" alt="Change Settings"></a>
		<a href="javascript:#moduleID#.getView('config')"><strong>Settings</strong></a>
	</div>
</cfif>

</cfoutput>

	
