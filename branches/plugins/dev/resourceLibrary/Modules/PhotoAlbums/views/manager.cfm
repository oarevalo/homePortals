<cfparam name="arguments.albumName" default="">
<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();
	
	// get content store
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();

	// get the default album
	defAlbumName = this.controller.getModuleConfigBean().getPageSetting("albumName");
	if(arguments.albumName eq "") arguments.albumName = defAlbumName;

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";
	
	// get current user info
	stUser = this.controller.getUserInfo();
		
	// check if current user is owner
	bIsContentOwner = (stUser.username eq myContentStore.getOwner());
	if(not bIsContentOwner) throw("You must be signed-in and be the owner of this page to make changes.");

	// get all photo albums
	aAlbums = xmlSearch(xmlDoc,"//photoAlbum");
	
	if(arguments.albumName eq "" and arrayLen(aAlbums) gt 0) arguments.albumName = aAlbums[1].xmlAttributes.name;
	
	// get the selected content entry
	bIsNew = true;
	for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
		if(xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.name eq Arguments.albumName) {
			myAlbum = xmlDoc.xmlRoot.xmlChildren[i];
			bIsNew = false;
			break;
		}
	}
	
	csCfg = this.controller.getContentStoreConfigBean();
	dirPhotoAlbums = csCfg.getAccountsRoot() & "/#stUser.owner#/photoAlbum";
</cfscript>


<cfoutput>
<div style="background-color:##f5f5f5;">
	<div style="padding:0px;width:490px;">
	
		<div style="margin:5px;background-color:##333;border:1px solid silver;color:##fff;height:35px;">
			<div style="margin:5px;">
				<div style="float:right;">
					<select name="EntryID" onchange="#moduleID#.getPopupView('manager',{albumName:this.value})" style="width:180px;">
						<cfloop from="1" to="#ArrayLen(aAlbums)#" index="i">
							<cfset tmpAlbumName= aAlbums[i].xmlAttributes.name>
							<option value="#tmpAlbumName#"
								<cfif tmpAlbumName eq arguments.albumName>
									selected
								</cfif>
								>
								#tmpAlbumName#
							</option>
						</cfloop>
						<option value="NEW" <cfif bIsNew>selected</cfif>>--- Create New Album ---</option>
					</select> 
				</div>
				<strong>Photo Album:</strong> Manage Photos
			</div>
			<div style="clear:both;"></div>
		</div>

		<form action="##" method="post" name="frmEditBox" style="margin:0px;padding:0px;">
			<div style="width:490px;height:400px;border:1px solid silver;margin:5px;background-color:##fff;">
				<cfif bIsNew>
					<div style="margin:20px;">
						<p><b>Enter a name for your new photo album:</b></p><br>
						<input type="text" name="albumName" value=""><br><br>
						<p>
							<input type="button" name="btnCreate" value="Create Album"
									onclick="#moduleID#.doFormAction('createAlbum',this.form);#moduleID#.closeWindow();">
						</p>
					</div>
				<cfelse>
					<table width="100%" class="tblPhotoAlbumMgr">
						<tr>
							<th width="10">No.</th>
							<th>Image</th>
							<th width="50">Actions</th>
						</tr>
						<cfloop from="1" to="#arrayLen(myAlbum.xmlChildren)#" index="i">
							<cfset tmpNode = myAlbum.xmlChildren[i]>
							<tr <cfif i mod 2>style="background-color:##f7f7f7;"</cfif>>
								<td align="right"><b>#i#.</b></td>
								<td><a href="#dirPhotoAlbums#/#tmpNode.xmlAttributes.src#" target="_blank">#tmpNode.xmlAttributes.src#</td>
								<td align="center"><a href="javascript:if(confirm('Delete Image?')){#moduleID#.doAction('deleteImage',{albumName:'#jsStringFormat(arguments.albumName)#',src:'#tmpNode.xmlAttributes.src#'});#moduleID#.closeWindow();}"><img src="#imgRoot#/omit-page-orange.gif" alt="Delete" border="0"></a></td>
							</tr>
						</cfloop>
						<cfif arrayLen(myAlbum.xmlChildren) eq 0>
							<tr><td colspan="3"><em>Album is empty</em></td></tr>
						</cfif>
					</table>
				</cfif>
			</div>
		</form>
		
		<div style="margin:5px;text-align:left;background-color:##ebebeb;border:1px solid silver;">
			<div style="margin:5px;"> 
				<cfif Not bIsNew>
					<input type="button" name="btn1" onclick="#moduleID#.getPopupView('upload',{albumName:'#jsStringFormat(arguments.albumName)#'});" value="Upload Images" style="font-size:11px;">&nbsp;&nbsp;
					<input type="button" name="btn2" onclick="if(confirm('Delete Album?')){#moduleID#.doAction('deleteAlbum',{albumName:'#jsStringFormat(arguments.albumName)#'});#moduleID#.closeWindow();}" value="Delete This Album"  style="font-size:11px;">&nbsp;&nbsp;
	
					&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="checkbox" 
							name="moduleDefault" 
							<cfif arguments.albumName eq defAlbumName>checked</cfif>
							onclick="#moduleID#.doAction('toggleDefaultAlbum',{albumName:'#JSStringFormat(arguments.albumName)#',state:this.checked})"
							value="1"> 
					<span style="font-size:9px;font-weight:bold;">
						Set as default Album &nbsp;
						 (<a href="##"  style="font-size:9px;" onclick="alert('Enable this option to have this content photo album displayed on the module by default')">Help</a>)
					</span>
				<cfelse>
					<a href="##" onclick="#moduleID#.closeWindow();"><strong>Close</strong></a>
				</cfif>
			</div>
		</div>	
	</div>
</div>		


</cfoutput>
