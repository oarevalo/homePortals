
<cfparam name="arguments.albumName" default="">
<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();

	uploaderPath = "/Home/Modules/PhotoAlbums/views/uploader.cfm";
	
	// get content store
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();

	// get current user info
	stUser = this.controller.getUserInfo();
		
	// check if current user is owner
	bIsContentOwner = (stUser.username eq myContentStore.getOwner());
	if(not bIsContentOwner) throw("You must be signed-in and be the owner of this page to make changes.");

	// get all photo albums
	aAlbums = xmlSearch(xmlDoc,"//photoAlbum");
</cfscript>

<cfoutput>
	<form action="##" method="post" name="frmPhotoAlbum" style="margin:0px;padding:0px;">
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
						<option value="NEW">--- Create New Album ---</option>
					</select> 
				</td>
				<td width="30">&nbsp;</td>
			</tr>
		</table>
			
		<iframe name="frmUpload" 
				style="width:100%;border:1px solid black;padding:2px;height:410px;overflow:auto;background-color:##fff;"
				frameborder="false" 
				src="#uploaderPath#?moduleID=#moduleID#&albumName=#arguments.albumName#"></iframe>

		<div width="100%" style="border:1px solid silver;background-color:##fefcd8;padding:5px;">
			<input type="button" name="btn1" onclick="#moduleID#.getPopupView('manager',{albumName:'#jsStringFormat(arguments.albumName)#'});" value="Return" style="font-size:11px;">
		</div>
	</form>
</cfoutput>	
