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
	
	// get the selected content entry
	bIsNew = true;
	for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
		if(xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.name eq Arguments.albumName) {
			myAlbum = xmlDoc.xmlRoot.xmlChildren[i];
			bIsNew = false;
			break;
		}
	}
</cfscript>


<cfoutput>
	<form action="##" method="post" name="frmEditBox" style="margin:0px;padding:0px;">
		<table width="100%" style="border:1px solid silver;background-color:##fefcd8;">
			<tr>
				<td nowrap>
					<b>Photo Album Manager</b>
				</td>
				<td align="right">
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
				</td>
				<td width="30">&nbsp;</td>
			</tr>
		</table>
		
		<div style="border:1px solid black;padding:2px;height:410px;overflow:auto;background-color:##fff;">
			<cfif bIsNew>
				<b>Enter a name for your new photo album:</b><br>
				<input type="text" name="albumName" value=""><br><br>
				<p>
					<input type="button" name="btnCreate" value="Create Album"
							onclick="#moduleID#.doFormAction('createAlbum',this.form);#moduleID#.closeWindow();">
				</p>
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
							<td>#tmpNode.xmlAttributes.src#</td>
							<td align="center"><a href="javascript:if(confirm('Delete Image?')){#moduleID#.doAction('deleteImage',{albumName:'#jsStringFormat(arguments.albumName)#',src:'#tmpNode.xmlAttributes.src#'});#moduleID#.closeWindow();}"><img src="#imgRoot#/omit-page-orange.gif" alt="Delete" border="0"></a></td>
						</tr>
					</cfloop>
				</table>
			</cfif>
		</div>
		
		<div width="100%" style="border:1px solid silver;background-color:##fefcd8;padding:5px;">
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
			</cfif>
		</div>
	</form>


</cfoutput>
