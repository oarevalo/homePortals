<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();

	// get current user info
	stUser = this.controller.getUserInfo();

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";

	// set default values
	bFailed = false;
	errMessage = "";
	isRemoteURL = false;
	bIsContentOwner = stUser.isOwner;
	moduleTitle = "Bookmarks";
	aGroups = arrayNew(1);

	// get settings
	bookmarksURL = cfg.getPageSetting("url");
	bFollowLink = cfg.getPageSetting("followLink");
	moduleTitle = cfg.getPageSetting("title");
	
	// default the real URL to the setting
	realURL = bookmarksURL;
		
	try {	
		
		// check wether this is a local or remote URL
		isRemoteURL = (left(bookmarksURL,4) eq "http");
		
		if(Not isRemoteURL) {
			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();
	
			// check if current user is owner
			bIsContentOwner = (stUser.username eq myContentStore.getOwner());
			
			// get real URL
			realURL = myContentStore.getURL();

		} else {
			xmlDoc = xmlParse(bookmarksURL);		
		}
		
		if(moduleTitle eq "" or moduleTitle eq moduleID) {
			if(structKeyExists(xmlDoc.xmlRoot,"head") and structKeyExists(xmlDoc.xmlRoot.head,"title")) {
				moduleTitle = xmlDoc.xmlRoot.head.title.xmlText;
			} else if(bookmarksURL neq "") {
				moduleTitle = bookmarksURL;
			}
		}
			
		// get all content entries
		if(structKeyExists(xmlDoc.xmlRoot,"body"))
			aGroups = xmlDoc.xmlRoot.body.xmlChildren;
		
		// make sure the followLink flag is boolean
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
		<cfloop from="1" to="#ArrayLen(aGroups)#" index="i">
			<cfset aLinks = aGroups[i].XMLChildren>
			<cfset thisAttribs = duplicate(aGroups[i].XMLAttributes)>
			<cfset isFeed = false>
			<cfset tmpIconURL = "">
	
			<cfparam name="thisAttribs.text" default="" type="string">
			<cfparam name="thisAttribs.url" default="##" type="string">
			<cfparam name="thisAttribs.target" default="" type="string">
			<cfparam name="thisAttribs.onclick" default="" type="string">
			<cfparam name="thisAttribs.type" default="link" type="string">
			<cfparam name="thisAttribs.htmlURL" default="#thisAttribs.url#" type="string">
			<cfparam name="thisAttribs.xmlURL" default="" type="string">
			<cfparam name="thisAttribs.imgURL" default="" type="string">
	
			<cfset thisItem = thisAttribs.text>
	
			<cfif thisAttribs.htmlURL eq "">
				<cfset thisAttribs.htmlURL = thisAttribs.url>
			</cfif>
			
			<cfif thisAttribs.xmlURL neq "" and (thisAttribs.type eq "rss" or thisAttribs.type eq "atom")>
				<cfset thisAttribs.url = thisAttribs.xmlURL>
				<cfset isFeed = true>	<!--- flag this item as a link to a feed from a typical OPML --->
			<cfelse>
				<cfset thisAttribs.url = thisAttribs.htmlURL>
			</cfif>
	
			<cfset tmpEvent = "#moduleID#.raiseEvent('onClick',{url:'#thisAttribs.url#'})">
			<cfset thisAttribs.onclick = ListAppend(thisAttribs.onclick, tmpEvent, ";")>					
	
			<!--- Check if the url has a favicon for the domain --->
			<cfif left(URLDecode(thisAttribs.url),4) eq "http">
				<cfset tmpIconURL = "http://" & listGetAt(URLDecode(thisAttribs.url),2,"/") & "/favicon.ico">
				<cfhttp method="get" url="#tmpIconURL#" timeout="5" throwonerror="no"></cfhttp>
				<cfif thisAttribs.imgURL eq "" and cfhttp.statusCode eq "200 OK">
					<cfset thisAttribs.imgURL = tmpIconURL>
				</cfif>
			</cfif>

			<!--- if links are not to be followed, then removed URL param --->
			<cfif Not bFollowLink>
				<cfset thisAttribs.url = "##">
			</cfif>

			<div style="line-height:18px;font-size:12px;">
				<cfif bIsContentOwner and Not isRemoteURL>
					<div style="float:right;width:35px;">
						<a href="##" onclick="#moduleID#.getView('edit','',{index:#i#});"><img src="#imgRoot#/edit-page-yellow.gif" border="0" alt="Edit '#thisItem#'" title="Edit '#thisItem#'" align="absmiddle"></a>
						<a href="##" onclick="if(confirm('Delete Bookmark?')) #moduleID#.doAction('deleteItem',{index:#i#});"><img src="#imgRoot#/omit-page-orange.gif" border="0" alt="Delete '#thisItem#'" align="absmiddle" title="Delete '#thisItem#'"></a>
					</div>
				</cfif>

				<cfif thisAttribs.imgURL neq "">
					<img src="#thisAttribs.imgURL#" border="0" align="absmiddle" style="margin-right:5px;width:16px;height:16px;">
				</cfif>
				<a href="#URLDecode(thisAttribs.url)#" 
					<cfif thisAttribs.target neq "">target="#thisAttribs.target#"</cfif> 
					<cfif thisAttribs.onclick neq "">onClick="#thisAttribs.onclick#"</cfif>
					>#thisItem#</a>
			</div>	
			<div style="clear:both;"></div>
			
			<cfif IsArray(aLinks) and isRemoteURL>
				<cfloop from="1" to="#ArrayLen(aLinks)#" index="j">
					
					<cfset thisSubItem = aLinks[j].XMLAttributes>
					<cfparam name="thisSubItem.url" default="##" type="string">
					<cfparam name="thisSubItem.target" default="" type="string">
					<cfparam name="thisSubItem.text" default="" type="string">
					<cfparam name="thisSubItem.onclick" default="" type="string">
					<cfparam name="thisSubItem.type" default="link" type="string">
					<cfparam name="thisSubItem.htmlURL" default="#thisSubItem.url#" type="string">
					<cfparam name="thisSubItem.xmlURL" default="" type="string">

					<cfif thisSubItem.xmlURL neq "" and (thisSubItem.type eq "rss" or thisSubItem.type eq "atom")>
						<cfset tmpURL = thisSubItem.xmlURL>
					<cfelse>
						<cfset tmpURL = thisSubItem.htmlURL>
					</cfif>

					<cfset tmpEvent = "#moduleID#.raiseEvent('onClick','#tmpURL#')">
					<cfset thisSubItem.onclick = ListAppend(thisSubItem.onclick, tmpEvent, ";")>					
					
					<cfif Not thisFollowLink>
						<cfset thisSubItem.url = "##">
					</cfif>
					
					<div>
						<a href="#URLDecode(thisSubItem.url)#" 
							<cfif thisSubItem.target neq "">target="#thisSubItem.target#"</cfif> 
							<cfif thisSubItem.onclick neq "">onClick="#thisSubItem.onclick#"</cfif>
							>#URLDecode(thisSubItem.text)#</a>
					</div>
				</cfloop>
			</cfif>
	
		</cfloop>
		<cfif ArrayLen(aGroups) eq 0>
			<em>This list has no items</em>
		</cfif>
	
	<!--- change module title --->
	<script>
		h_setModuleContainerTitle("#moduleID#", "#jsstringformat(moduleTitle)#");
	</script>		
<cfelse>
	<b>Error:</b><br>
	#errMessage#
</cfif>

<cfif bIsContentOwner>
	<div class="SectionToolbar">
		<cfif Not isRemoteURL>
			<span style="white-space:nowrap;">
				<a href="javascript:#moduleID#.getView('edit')"><img src="#imgRoot#/add-page-orange.gif" border="0" align="absmiddle" alt="Add Bookmark"></a>
				<a href="javascript:#moduleID#.getView('edit')"><strong>Add Item</strong></a>
			</span>
			&nbsp;&nbsp;
		</cfif>
		<span style="white-space:nowrap;">
			<a href="javascript:#moduleID#.getView('config')"><img src="#imgRoot#/check-orange.gif" border="0" align="absmiddle" alt="Change Settings"></a>
			<a href="javascript:#moduleID#.getView('config')"><strong>Settings</strong></a>
		</span>
		&nbsp;&nbsp;
		<span style="white-space:nowrap;">
			<a href="#realURL#" target="_blank"><img src="#imgRoot#/opml.gif" border="0" align="absmiddle" alt="Link to this list"></a>
			<a href="#realURL#" target="_blank"><strong>Link to this list</strong></a>
		</span>
	</div>
<cfelse>
	<div class="SectionToolbar">
		<a href="#realURL#" target="_blank"><img src="#imgRoot#/opml.gif" border="0" align="absmiddle" alt="Link to this list"></a>
		<a href="#realURL#" target="_blank"><strong>Link to this list</strong></a>
	</div>
</cfif>

</cfoutput>

	
