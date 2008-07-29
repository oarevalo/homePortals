<cfscript>
	cfg = this.controller.getModuleConfigBean();
	moduleID = this.controller.getModuleID();
	errMessage = "";
	
	// get module settings
	thisURL =  cfg.getPageSetting("url");
	thisFollowLink =  cfg.getPageSetting("followLink",true);
	
	// make sure it has boolean value
	thisFollowLink = (isBoolean(thisFollowLink) and thisFollowLink);   

	// get module path
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";

	// get current user info
	stUser = this.controller.getUserInfo();
		
	// retrieve data
	if(thisURL neq "") {
		try {
			if(left(thisURL,4) eq "http") {
				xmlDoc = xmlParse(thisURL);
			} else {
				if(fileExists(expandPath(thisURL)))
					xmlDoc = xmlParse(expandPath(thisURL));
				else
					throw("Bookmarks file not found.");
			}
		} catch(any e) {
			errMessage = e.message;
		}
	}

</cfscript>



<cfoutput>
	<cfif thisURL neq "" and errMessage eq "">
		<cfset aGroups = xmlSearch(xmlDoc,"//body/*")>
		
		<cftry>
		<ul>
			<cfloop from="1" to="#ArrayLen(aGroups)#" index="i">
				<cfset aLinks = aGroups[i].XMLChildren>
				
				<cfset thisAttribs = aGroups[i].XMLAttributes>
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
		
				<cfset tmpEvent = "#moduleID#.raiseEvent('onClick','#tmpURL#')">
				<cfset thisAttribs.onclick = ListAppend(thisAttribs.onclick, tmpEvent, ";")>					
	
				<cfif Not thisFollowLink>
					<cfset thisAttribs.url = "##">
				</cfif>
					
				<li><a href="#URLDecode(thisAttribs.url)#" 
						target="#thisAttribs.target#" 
						onClick="#thisAttribs.onclick#"><strong>#thisItem#</strong></a></li>
	
				<cfif IsArray(aLinks)>
					<ul>
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
										
							<li><a href="#URLDecode(thisSubItem.url)#" 
									target="#thisSubItem.target#" 
									onClick="#thisSubItem.onclick#">#URLDecode(thisSubItem.text)#</a></li>
						</cfloop>
					</ul>
				</cfif>
			</cfloop>
			<cfif ArrayLen(aGroups) eq 0>
				<li><em>This list has no items</em></li>
			</cfif>
		</ul>
		<cfcatch type="any">
			<b>A problem ocurred while displaying bookmarks.</b><br>
			#cfcatch.Message#
		</cfcatch>
		</cftry>
	
	<cfelseif errMessage neq "">
		<b>URL could not be retrieved.</b><br>
		#errMessage#
	<cfelse>
		<em>No bookmarks file has been set.</em><br>
	</cfif>
	
	<cfif stUser.isOwner>
		<div class="BookmarksToolbar">
			<a href="javascript:#moduleID#.getView('config')"><img src="#imgRoot#/check-orange.gif" border="0" align="absmiddle" alt="Change Settings"></a>
			<a href="javascript:#moduleID#.getView('config')"><strong>Settings</strong></a>
		</div>
	</cfif>	
</cfoutput>