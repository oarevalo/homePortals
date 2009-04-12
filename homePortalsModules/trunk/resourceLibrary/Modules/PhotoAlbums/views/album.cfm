<cfscript>
	
	// get the moduleID
	moduleID = this.controller.getModuleID();
		
	// get content store
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();
	
	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";

	// get the default album
	defAlbumName = cfg.getPageSetting("albumName");
	
	// get current user info
	stUser = this.controller.getUserInfo();
		
	// check if current user is owner
	bIsContentOwner = (stUser.username eq myContentStore.getOwner());
	
	// set album storage directory
	csCfg = this.controller.getContentStoreConfigBean();
	dirPhotoAlbums = csCfg.getAccountsRoot() & "/#stUser.owner#/photoAlbum";
	
	// get the selected content entry
	bHasAlbum = false;
	if(defAlbumName neq "") {
		for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
			if(xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.name eq defAlbumName) {
				myAlbum = xmlDoc.xmlRoot.xmlChildren[i];
				bHasAlbum = true;
				break;
			}
		}		
	} else {
		aAlbums = xmlSearch(xmlDoc,"//photoAlbum");
		if(arrayLen(aAlbums) gt 0) {
			myAlbum = aAlbums[1];
			bHasAlbum = true;
		}	
	}

</cfscript>


<cfoutput>
	
	<cfif bHasAlbum and arrayLen(myAlbum.xmlChildren) gt 0>
		<div style="text-align:center;">
			<cfloop from="1" to="#arrayLen(myAlbum.xmlChildren)#" index="i">
				<cfset tmpNode = myAlbum.xmlChildren[i]>
				<a href="#dirPhotoAlbums#/#tmpNode.xmlAttributes.src#" title="#getFileFromPath(tmpNode.xmlAttributes.src)#" rel="lighterbox">
					<img src="#dirPhotoAlbums#/#tmpNode.xmlAttributes.thumbnailSrc#"
						  style="border:1px solid black;margin:2px;"></a>
				
			</cfloop>
		</div>
		<script>
			#moduleID#.setTitle("#jsstringformat(myalbum.xmlAttributes.name)#");
		</script>
	<cfelse>
		<em>There are no pictures on this album</em>	
	</cfif>
	
	
	<cfif bIsContentOwner>
		<div class="SectionToolbar">
			<a href="javascript:#moduleID#.getPopupView('manager')"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle" alt="Mange Images"></a>
			<a href="javascript:#moduleID#.getPopupView('manager')"><strong>Manager</strong></a>
			&nbsp;&nbsp;
			&nbsp;&nbsp;
			<a href="javascript:#moduleID#.getView()"><strong>Refresh Album</strong></a>
		</div>
	</cfif>
	
	<script type="text/javascript" src="/homePortalsModules/resourceLibrary/Modules/PhotoAlbums/lighterbox2/lighterbox2.js" ></script>
</cfoutput>
	