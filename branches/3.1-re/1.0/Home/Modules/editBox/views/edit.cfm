<cfparam name="arguments.contentID" default="">

<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();
	
	// get content store
	setContentStoreURL();
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();

	// get the default contentID
	defContentID = this.controller.getModuleConfigBean().getPageSetting("contentID");

	// get current user info
	stUser = this.controller.getUserInfo();
		
	// check if current user is owner
	bIsContentOwner = (stUser.username eq myContentStore.getOwner());
	if(not bIsContentOwner) throw("You must be signed-in and be the owner of this page to make changes.");
	
	// get all content entries
	aContents = xmlSearch(xmlDoc,"//content");
	
	// get the selected content entry
	myContent = xmlSearch(xmlDoc,"//content[@id='#Arguments.contentID#']");
	bIsNew = (ArrayLen(myContent) eq 0);
	if(Not bIsNew)
		tmpDefValue = myContent[1].xmlText;
	else
		tmpDefValue = "Enter Content Here";
</cfscript>


<cfoutput>
	<form action="##" method="post" name="frmEditBox" style="margin:0px;padding:0px;">
		<table width="100%" style="border:1px solid silver;background-color:##fefcd8;">
			<tr>
				<td nowrap>
					<b>Title:</b>
					<cfif bIsNew>
						<input type="text" name="contentID" value="New Entry" style="width:200px;border:1px solid black;padding:2px;">
					<cfelse>
						<input type="text" name="contentID" value="#arguments.contentID#" style="width:200px;border:1px solid black;padding:2px;" disabled="yes">
						<cfset tmpNewContentID = arguments.contentID>
					</cfif>
				</td>
				<td align="right">
					<select name="EntryID" onchange="#moduleID#.getPopupView('edit',{contentID:this.value})" style="width:120px;">
						<option value="NEW">--- New Entry ---</option>
						<cfloop from="1" to="#ArrayLen(aContents)#" index="i">
							<option value="#aContents[i].xmlAttributes.id#"
								<cfif aContents[i].xmlAttributes.id eq arguments.contentID>
									selected
								</cfif>
								>
								#aContents[i].xmlAttributes.id#
							</option>
						</cfloop>
					</select> 
				</td>
				<td width="30">&nbsp;</td>
			</tr>
		</table>
		
		<textarea name="content" wrap="off" style="width:100%;border:1px solid black;padding:2px;height:410px;">#HTMLEditFormat(tmpDefValue)#</textarea>
		<div width="100%" style="border:1px solid silver;background-color:##fefcd8;padding:5px;">
			<input type="button" name="btn1" onclick="#moduleID#.doFormAction('save',this.form);#moduleID#.closeWindow();" value="Save Changes" style="font-size:11px;">&nbsp;&nbsp;
			<cfif Not bIsNew>
				<input type="button" name="btn2" onclick="if(confirm('Delete entry?')){#moduleID#.doAction('deleteEntry',{contentID:'#tmpNewContentID#'});#moduleID#.closeWindow();}" value="Delete This Entry"  style="font-size:11px;">&nbsp;&nbsp;
			</cfif>
			<!---
			<input type="button" name="btn3" onclick="#moduleID#.closeWindow();" value="Close" style="font-size:11px;">
			--->
			
			<cfif Not bIsNew>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="checkbox" 
						name="moduleDefault" 
						<cfif arguments.contentID eq defContentID>checked</cfif>
						onclick="#moduleID#.doAction('toggleDefaultContentID',{contentID:'#arguments.contentID#',state:this.checked})"
						value="1"> 
				<span style="font-size:9px;font-weight:bold;">
					Set as module content &nbsp;
					 (<a href="##"  style="font-size:9px;" onclick="alert('Enable this option to have this content entry displayed on the module by default')">Help</a>)
				</span>
			</cfif>
		</div>
	</form>


</cfoutput>
