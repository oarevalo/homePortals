<cfparam name="arguments.contentID" default="">
<cfparam name="arguments.html" default="false">

<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();

	// get image path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
		
	// get content store
	setContentStoreURL();
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();

	// get the default contentID
	defContentID = cfg.getPageSetting("contentID");

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

	// this flag determines if we want to use tinyMCE as the editor
	useTinyMCE = cfg.getProperty("useTinyMCE");	
	useTinyMCE = (isBoolean(useTinyMCE) and useTinyMCE);   // make sure it has boolean value


	// validate flag for editing raw HTML
	if(not isBoolean(arguments.HTML)) arguments.html = false;
	if(not useTinyMCE) arguments.html = true;
</cfscript>

<cfoutput>
	<cfif useTinyMCE and not arguments.html>
		<script>
			tinyMCE.idCounter = 0;
			tinyMCE.execCommand("mceAddControl",false,"#moduleID#_edit");
		</script>
	</cfif>
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
					<select name="EntryID" onchange="#moduleID#.getPopupView('edit',{contentID:this.value,html:#arguments.html#})" style="width:120px;">
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
		
		<textarea name="content" wrap="off" id="#moduleID#_edit" style="width:100%;border:1px solid black;padding:2px;height:410px;">#HTMLEditFormat(tmpDefValue)#</textarea>
		<div width="100%" style="border:1px solid silver;background-color:##fefcd8;padding:5px;text-align:left;">

			<cfif useTinyMCE>
				<a href="##" onclick="#moduleID#.saveContent(document.frmEditBox);#moduleID#.closeWindow();"><img src="#imgRoot#/disk.png" border="0" align="absmiddle" style="margin-right:2px;">Save Changes</a>
			<cfelse>
				<a href="##" onclick="#moduleID#.doFormAction('save',document.frmEditBox);#moduleID#.closeWindow();"><img src="#imgRoot#/disk.png" border="0" align="absmiddle" style="margin-right:2px;">Save Changes</a>
			</cfif>

			<cfif Not bIsNew>
				&nbsp;&nbsp;
				<a href="##" onclick="if(confirm('Delete entry?')){#moduleID#.doAction('deleteEntry',{contentID:'#tmpNewContentID#'});#moduleID#.closeWindow();}"><img src="#imgRoot#/cross.png" border="0" align="absmiddle" style="margin-right:2px;">Delete</a>
			</cfif>
			
			<cfif Not bIsNew>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="checkbox" 
						name="moduleDefault" 
						<cfif arguments.contentID eq defContentID>checked</cfif>
						onclick="#moduleID#.doAction('toggleDefaultContentID',{contentID:'#arguments.contentID#',state:this.checked})"
						value="1"> 
				<span style="font-size:9px;font-weight:bold;">
					Default content 
					 (<a href="##"  style="font-size:9px;" onclick="alert('Enable this option to have this content entry displayed on the module by default')">Help</a>)
				</span>

				<cfif useTinyMCE>
					&nbsp;&nbsp;
					<cfif arguments.html>
						<a href="##" onclick="#moduleID#.getPopupView('edit',{contentID:'#arguments.contentID#',html:false})"><img src="#imgRoot#/application_edit.png" border="0" align="absmiddle" style="margin-right:2px;">View Editor</a>
					<cfelse>
						<a href="##" onclick="#moduleID#.getPopupView('edit',{contentID:'#arguments.contentID#',html:true})"><img src="#imgRoot#/page_white_code.png" border="0" align="absmiddle" style="margin-right:2px;">View HTML code</a>
					</cfif>
				</cfif>
			</cfif>
		</div>
	</form>


</cfoutput>
