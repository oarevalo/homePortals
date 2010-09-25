<cfcomponent displayname="photoAlbum" extends="homePortals.plugins.modules.components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var csCfg = this.controller.getContentStoreConfigBean();

			cfg.setModuleClassName("photoAlbum");
			cfg.setView("default", "album");
			cfg.setView("htmlHead", "htmlHead");
			
			csCfg.setDefaultName("myPhotos.xml");
			csCfg.setRootNode("photoAlbums");
		</cfscript>	
	</cffunction>

	<cffunction name="createAlbum" access="public" hint="Creates a new photo album.">
		<cfargument name="albumName" type="string" required="true">
		<cfscript>
			var moduleID = this.controller.getModuleID();
			var stUser = this.controller.getUserInfo();
			var myContentStore = 0;
			var xmlDoc = 0;
			
			// get content store
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();
					
			// check that we are updating the content store from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throw("You must be signed-in and be the owner of this page to make changes.");
			}

			// create new photoAlbum 
			nodeIndex = ArrayLen(xmlDoc.xmlRoot.xmlChildren)+1;
			xmlDoc.xmlRoot.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"photoAlbum");
			xmlDoc.xmlRoot.xmlChildren[nodeIndex].xmlAttributes["name"] = arguments.albumName;
			xmlDoc.xmlRoot.xmlChildren[nodeIndex].xmlAttributes["createDate"] = GetHTTPTimeString(now());
			myContentStore.save(xmlDoc);
			
			// set message
			this.controller.setMessage("Photo Album Created");
			this.controller.setScript("#moduleID#.getView()");
		</cfscript>
	</cffunction>

	<cffunction name="deleteAlbum" access="public" hint="Deletes a photo album.">
		<cfargument name="albumName" type="string" required="true">
		<cfscript>
			var moduleID = this.controller.getModuleID();
			var stUser = this.controller.getUserInfo();
			var myContentStore = 0;
			var xmlDoc = 0;
			var tmpNode = 0;
			var i = 0;
			var dirPhotoAlbums = "";
			var csCfg = this.controller.getContentStoreConfigBean();
			
			// get photo album directory
			dirPhotoAlbums = csCfg.getAccountsRoot() & "/#stUser.owner#/photoAlbum";
			
			// get content store
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();

			// check that we are updating the content store from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throw("You must be signed-in and be the owner of this page to make changes.");
			}

			// delete photoAlbum 
			tmpNode = xmlDoc.xmlRoot;
			for(i=1;i lte ArrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				tmpNode = xmlDoc.xmlRoot.xmlChildren[i];
				if(tmpNode.xmlAttributes.name eq arguments.albumName) {
					for(j=1;j lte ArrayLen(tmpNode.xmlChildren);j=j+1) {					
						deleteFile(expandPath(dirPhotoAlbums & "/" & tmpNode.xmlChildren[j].xmlAttributes.src));
						deleteFile(expandPath(dirPhotoAlbums & "/" & tmpNode.xmlChildren[j].xmlAttributes.thumbnailSrc));
					}
					arrayDeleteAt(xmlDoc.xmlRoot.xmlChildren,i);
					break;
				}
			}	
			myContentStore.save(xmlDoc);
			
			// set message
			this.controller.setMessage("Photo Album Deleted");
			this.controller.setScript("#moduleID#.getView()");
		</cfscript>
	</cffunction>

	<cffunction name="deleteImage" access="public" hint="Deletes a photo album.">
		<cfargument name="albumName" type="string" required="true">
		<cfargument name="src" type="string" required="true">
		<cfscript>
			var moduleID = this.controller.getModuleID();
			var stUser = this.controller.getUserInfo();
			var myContentStore = 0;
			var xmlDoc = 0;
			var i = 0;
			var j = 0;
			var tmpNode = 0;
			var dirPhotoAlbums = "";
			var csCfg = this.controller.getContentStoreConfigBean();
			
			// get photo album directory
			dirPhotoAlbums = csCfg.getAccountsRoot() & "/#stUser.owner#/photoAlbum";
						
			// get content store
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();
					
			// check that we are updating the content store from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throw("You must be signed-in and be the owner of this page to make changes.");
			}

			// delete image
			for(i=1;i lte ArrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				if(xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.name eq arguments.albumName) {
					tmpNode = xmlDoc.xmlRoot.xmlChildren[i];
					for(j=1;j lte ArrayLen(tmpNode.xmlChildren);j=j+1) {
						if(tmpNode.xmlChildren[j].xmlAttributes.src eq arguments.src) {
							deleteFile(expandPath(dirPhotoAlbums & "/" & tmpNode.xmlChildren[j].xmlAttributes.src));
							deleteFile(expandPath(dirPhotoAlbums & "/" & tmpNode.xmlChildren[j].xmlAttributes.thumbnailSrc));
							arrayDeleteAt(tmpNode.xmlChildren,j);
							break;
						}
					}
				}
			}	
			myContentStore.save(xmlDoc);
			
			// set message
			this.controller.setMessage("Image Deleted");
			this.controller.setScript("#moduleID#.getView()");
		</cfscript>
	</cffunction>
	
	<cffunction name="toggleDefaultAlbum" access="public" output="true">
		<cfargument name="albumName" type="string" default="">
		<cfargument name="state" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var pageHREF = cfg.getPageHREF();
			var tmpScript = "";
			
			if(arguments.state) {
				cfg.setPageSetting("albumName", arguments.albumName);
				this.controller.setMessage("Default album set");
			} else {
				cfg.setPageSetting("albumName", "");
				this.controller.setMessage("Default album cleared");
			}
			this.controller.savePageSettings();
		</cfscript>
		<cfsavecontent variable="tmpScript">
			#moduleID#.getView();
			if(confirm("Reload page?")) {
				window.location.href='index.cfm?currentHome=#pageHREF#&refresh=true';
			}
		</cfsavecontent>
		<cfset this.controller.setScript(tmpScript)>
	</cffunction>

	<cffunction name="upload" access="public" hint="Uploads a file to the account directory. Returns the cffile structure." returntype="struct">
		<cfargument name="albumName" type="string" required="true">
		<cfargument name="fileField" type="string" required="yes" hint="The field name containing the file to upload">

		<cfscript>
			var moduleID = this.controller.getModuleID();
			var stUser = this.controller.getUserInfo();
			var csCfg = this.controller.getContentStoreConfigBean();
			var tgt = "";
			var tgtDir = "";
			var myContentStore = 0;
			var xmlDoc = 0;
			var imgObj = 0;
			var tmpsrc = "";
			var tmptgt = "";
			
			// get destination directory
			tgt = csCfg.getAccountsRoot() & "/#stUser.owner#/photoAlbum";
			tgtDir = expandPath(tgt);
			if(Not DirectoryExists(tgtDir)) createDirectory(tgtDir);

			// get content store
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();
					
			// check that we are updating the content store from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throw("You must be signed-in and be the owner of this page to make changes.");
			}
		</cfscript>
		
		<cffile action="upload" 
				accept="image/jpeg,image/jpg,image/gif,image/png,image/pjpeg" 
				filefield="#arguments.fileField#" 
				nameconflict="makeunique" 
				destination="#tgtDir#">

		<cfscript>
			// create a thumbnail
			tmpsrc = tgt & "/" & cffile.serverFile;
			tmptgt = tgt & "/thumb_" & cffile.serverFile;

			imgObj = CreateObject("component", "tmt.tmt_img");
			if(cffile.contentSubType eq "png") imgObj.init("png");
			imgObj.resize(expandPath(tmpsrc), expandPath(tmptgt), 100);

			// update photoAlbum content store
			for(i=1;i lte ArrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				if(xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.name eq arguments.albumName) {
					tmpNode = xmlDoc.xmlRoot.xmlChildren[i];
					nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
					tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"image");
					tmpNode.xmlChildren[nodeIndex].xmlAttributes["src"] = cffile.serverFile;
					tmpNode.xmlChildren[nodeIndex].xmlAttributes["thumbnailSrc"] = "thumb_#cffile.serverFile#";
					tmpNode.xmlChildren[nodeIndex].xmlAttributes["uploadDate"] = GetHTTPTimeString(now());
					myContentStore.save(xmlDoc);
					break;
				}
			}	
		</cfscript>

		<cfreturn cffile>
	</cffunction>

	<cffunction name="deleteFile" access="private" hint="Deletes a file">
		<cfargument name="fileToDelete" type="string" required="true">
		<cfif FileExists(arguments.fileToDelete)>
			<cffile action="delete" file="#arguments.fileToDelete#">
		</cfif>
	</cffunction>

	<cffunction name="createDirectory" access="private" hint="Creates directory">
		<cfargument name="path" type="string" required="true">
		<cfdirectory action="create" directory="#arguments.path#">
	</cffunction>
	
	<cffunction name="xmlUnFormat" access="private" hint="reverses xml format">
		<cfargument name="string" type="string" required="true">
		<cfscript>
			var resultString = arguments.string;
			resultString=ReplaceNoCase(resultString,"&apos;","'","ALL");
			resultString=ReplaceNoCase(resultString,"&quot;","""","ALL");
			resultString=ReplaceNoCase(resultString,"&lt;","<","ALL");
			resultString=ReplaceNoCase(resultString,"&gt;",">","ALL");
			resultString=ReplaceNoCase(resultString,"&amp;","&","ALL");
		</cfscript>
		<cfreturn resultString>
	</cffunction>

</cfcomponent>