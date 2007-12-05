<cfparam name="arguments.contentID" default="">

<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
	
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
	
	// get the contentID defined on the page (if any)
	tmpDefaultContentID = this.controller.getModuleConfigBean().getPageSetting("contentID");	
	
	if(arguments.contentID eq "") {
		if(tmpDefaultContentID neq "") {
			arguments.contentID = tmpDefaultContentID;
		} else if(ArrayLen(aContents) gt 0) {
			// if no contentID given and there is something, then default to first one
			arguments.contentID = aContents[1].xmlAttributes.id;
		} 
	}
	
	// get the selected content entry
	if(Arguments.contentID neq "") 
		myContent = xmlSearch(xmlDoc,"//content[@id='#Arguments.contentID#']");
	else
		myContent = ArrayNew(1);
</cfscript>


<cfoutput>
	<cfif ArrayLen(myContent) gt 0>
		#myContent[1].xmlText#
		<cfif bIsContentOwner>
			<div id="#moduleID#_toolbar">
				<a href="javascript:#moduleID#.getPopupView('edit',{contentID:'NEW'});"><img src="#imgRoot#/add-page-orange.gif" border="0" align="absmiddle"></a>
				<a href="javascript:#moduleID#.getPopupView('edit',{contentID:'NEW'});">New</a>&nbsp;&nbsp;
				<cfif arguments.contentID neq "">
					<a href="javascript:#moduleID#.getPopupView('edit',{contentID:'#arguments.contentID#'});"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
					<a href="javascript:#moduleID#.getPopupView('edit',{contentID:'#arguments.contentID#'});">Edit</a>
				</cfif>
				&nbsp;&nbsp;
				#Left(arguments.contentID,20)#
			</div>
		</cfif>
	<cfelse>
		#this.controller.render('index')#
	</cfif>
</cfoutput>

