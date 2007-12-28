<cfparam name="arguments.index" type="numeric" default="0">

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
	aGroups = xmlSearch(xmlDoc,"//body/*");
	
	if(arguments.index gt ArrayLen(aGroups)) 
		arguments.index = 0;

	if(arguments.index gt 0) {
		aLinks = aGroups[arguments.index].XMLChildren;
		thisAttribs = duplicate(aGroups[arguments.index].XMLAttributes);
	} else {
		thisAttribs = StructNew();
		aLinks = arrayNew(1);
	}

	if(not bIsContentOwner) 
		throw("Only the owner of this bookmarks list is allowed to make changes to it."); 

	// create description for each item 
	stHelp = StructNew();
	stHelp.url = "URL for this item";
	stHelp.label = "Item label";
	stHelp.onClick = "[Advanced Use] Javascript function to call when selecting this item";
	stHelp.type = "[Advanced Use] Type of resource described by this item. Could be 'link' (default), 'atom' or 'rss'.";
	stHelp.htmlURL = "[Advanced Use] Address of an HTML resource associated with this item.";
	stHelp.xmlURL = "[Advanced Use] Address of an XML resource associated with this item.";
</cfscript>

<cfparam name="thisAttribs.text" default="" type="string">
<cfparam name="thisAttribs.url" default="" type="string">
<cfparam name="thisAttribs.target" default="" type="string">
<cfparam name="thisAttribs.onclick" default="" type="string">
<cfparam name="thisAttribs.type" default="link" type="string">
<cfparam name="thisAttribs.htmlURL" default="" type="string">
<cfparam name="thisAttribs.xmlURL" default="" type="string">
<cfset thisItem = thisAttribs.text>
	
<cfoutput>
	<form name="frm" method="post" action="##"  style="width:100%;">
		<input type="hidden" name="index" value="#arguments.index#" style="font-size:11px;">
		<table width="100%" id="#moduleID#_editItemTable">
			<tr>
				<th width="20"><a href="javascript:alert('#JSStringFormat(stHelp.label)#');">Label:</a></th>
				<td><input type="text" name="text" value="#thisItem#"></td>
			</tr>
			<tr>
				<th><a href="javascript:alert('#JSStringFormat(stHelp.url)#');">URL:</a></th>
				<td><input type="text" name="url" value="#thisAttribs.url#"></td>
			</tr>
			<tr id="#moduleID#_editMoreLabel" class="#moduleID#_showRow">
				<td colspan="2">
					<a href="javascript:#moduleID#.showMoreAttribs()">More...</a>
				</td>
			</tr>
			<tbody id="#moduleID#_editMoreBody" class="#moduleID#_hideRow">
				<tr>
					<th width="20"><a href="javascript:alert('#JSStringFormat(stHelp.onClick)#');">OnClick:</a></th>
					<td><input type="text" name="onclick" value="#thisAttribs.onclick#"></td>
				</tr>
				<tr>
					<th width="20"><a href="javascript:alert('#JSStringFormat(stHelp.type)#');">Type:</a></th>
					<td>
						<select name="type">
							<cfloop list="link,rss,atom" index="itemType">
								<option value="#itemType#"
										<cfif thisAttribs.type eq itemType>selected</cfif>
									>#itemType#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<th width="20"><a href="javascript:alert('#JSStringFormat(stHelp.htmlURL)#');">htmlURL:</a></th>
					<td><input type="text" name="htmlURL" value="#thisAttribs.htmlURL#"></td>
				</tr>
				<tr>
					<th width="20"><a href="javascript:alert('#JSStringFormat(stHelp.xmlURL)#');">xmlURL:</a></th>
					<td><input type="text" name="xmlURL" value="#thisAttribs.xmlURL#"></td>
				</tr>
			</tbody>
		</table>
		
		<p align="center">
			<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveItem',this.form)">
			<input type="button" value="Cancel" onclick="#moduleID#.getView()">
		</p>
	</form>
</cfoutput>			