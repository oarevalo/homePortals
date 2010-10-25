
<cfparam name="arguments.albumName" default="">
<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();

	uploaderPath =  "/homePortals/plugins/modules/resourceLibrary/Modules/PhotoAlbums/views/uploader.cfm";
	
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
	
	pageHREF = this.controller.getModuleConfigBean().getPageHREF();
	appRoot = this.controller.getHomePortalsConfigBean().getAppRoot();
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
						<option value="NEW">--- Create New Album ---</option>
					</select> 
				</div>
				<strong>Photo Album:</strong> Upload Photos
			</div>
			<div style="clear:both;"></div>
		</div>

		<div style="margin:5px;text-align:left;background-color:##ebebeb;border:1px solid silver;">
			<div style="margin:5px;"> 
				<input type="button" name="btn1" onclick="#moduleID#.getPopupView('manager',{albumName:'#jsStringFormat(arguments.albumName)#'});" value="Return" style="font-size:11px;">
			</div>
		</div>	

		<iframe name="frmUpload" 
				style="width:480px;height:375px;border:1px solid silver;margin:5px;background-color:##fff;overflow:auto;"
				frameborder="false" 
				src="#uploaderPath#?moduleID=#moduleID#&albumName=#arguments.albumName#&pageHREF=#pageHREF#&appRoot=#appRoot#"></iframe>
	</div>
</div>		
</cfoutput>	
