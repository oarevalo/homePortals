<!--- Blog.cfc
	This component provides blog functionality to the blog module.
	Version: 1.1 
	
	
	Changelog:
    - 1/13/05 - oarevalo - fixed bug that allowed any signed-in user to alter the blog,
							only the blog owner can alter the blog.
			   			- Display blog owner and creation date on blog details (readonly)
						- Add link to edit blog details in main view, visible only to owner.
						- reverse post order in getPostIndex
						- Blog details are visible to anyone, but may be changed only the owner
	- 2/8/06 - oarevalo - added icon & link to get RSS feed for the blog
--->

<cfcomponent displayname="Blog" extends="Home.Components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var csCfg = this.controller.getContentStoreConfigBean();

			cfg.setModuleClassName("blog");
			cfg.setView("default", "posts");
			cfg.setView("htmlHead", "HTMLHead");
			cfg.setModuleRoot("/Home/Modules/Blog/");
			
			csCfg.setDefaultName("myBlog.xml");
			csCfg.setRootNode("blog");
		</cfscript>	
	</cffunction>




	<!-------------------------------------->
	<!--- savePost                       --->
	<!-------------------------------------->
	<cffunction name="savePost" output="true">
		<cfargument name="title" type="string" default="">
		<cfargument name="author" type="string" default="">
		<cfargument name="content" type="string" default="">
		<cfargument name="created" type="string" default="">
		
		<cfscript>
			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();


			// check that we are updating the blog from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throw("Only the owner of this blog can make changes.");
			}
		
			// check if we find the entry the caller say we are updating
			aUpdateNode = xmlSearch(xmlDoc, "//entry[created='#arguments.created#']");

			if(arguments.created eq "" or arrayLen(aUpdateNode) eq 0) {
				// create new node
				xmlNode = xmlElemNew(xmlDoc,"entry");
				xmlNode.xmlChildren[1] = xmlElemNew(xmlDoc,"title");
				xmlNode.title.xmlText = arguments.Title;
				
				xmlNode.xmlChildren[2] = xmlElemNew(xmlDoc,"author");
				xmlNode.author.xmlChildren[1] = xmlElemNew(xmlDoc,"name");
				xmlNode.author.name.xmlText = arguments.author;
				
				xmlNode.xmlChildren[3] = xmlElemNew(xmlDoc,"created");
				xmlNode.created.xmlText = DateFormat(Now(),"yyyy-mm-dd") & "T" & TimeFormat(Now(),"HH:mm:ss");

				xmlNode.xmlChildren[4] = xmlElemNew(xmlDoc,"content");
				xmlNode.content.xmlText = arguments.Content;
				
				// add to document
				ArrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);

			} else {
				// update existing node
				aUpdateNode[1].title.xmlText = arguments.title;
				aUpdateNode[1].author.name.xmlText = arguments.author;
				aUpdateNode[1].content.xmlText = arguments.content;
			}
			
			// save changes to document
			myContentStore.save(xmlDoc);
			
			// notify client of change
			this.controller.setEventToRaise("Blog","PostSaved");
			this.controller.setMessage("Post Saved");
		</cfscript>
	</cffunction>

	<!-------------------------------------->
	<!--- deletePost                     --->
	<!-------------------------------------->
	<cffunction name="deletePost" access="remote" output="true">
		<cfargument name="timestamp" type="string" required="yes">

		<cfscript>
			var xmlDoc = 0;
			var tmpNode = 0;

			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();


			// check that we are updating the blog from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throw("Only the owner of this blog can make changes.");
			}
		
			tmpNode = xmlDoc.blog;
			for(i=1;i lte ArrayLen(tmpNode.xmlChildren);i=i+1) {
				if(StructKeyExists(tmpNode.xmlChildren[i],"created") and tmpNode.xmlChildren[i].created.xmlText eq arguments.timestamp)
					ArrayClear(tmpNode.xmlChildren[i]);
			}	
			
			myContentStore.save(xmlDoc);
			this.controller.setEventToRaise("Blog","PostDeleted");
			this.controller.setMessage("Post Deleted");
		</cfscript>
	</cffunction>

	<!-------------------------------------->
	<!--- saveComment                    --->
	<!-------------------------------------->
	<cffunction name="saveComment" access="remote" output="true">
		<cfargument name="name" type="string" default="Anonymous">
		<cfargument name="email" type="string" default="##">
		<cfargument name="comment" type="string" default="">
		<cfargument name="timestamp" type="string" default="">

		<cfscript>
			var xmlDoc = 0;
			var aUpdateNode = 0;

			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();


			// check if we find the entry the caller say we are updating
			aUpdateNode = xmlSearch(xmlDoc, "//entry[created='#arguments.timestamp#']");

			if(arguments.comment neq "" and arrayLen(aUpdateNode) gt 0) {
				// create comment 
				xmlNode = xmlElemNew(xmlDoc,"comment");
				xmlNode.xmlText = arguments.comment;
				xmlNode.xmlAttributes["postedByName"] = arguments.name;
				xmlNode.xmlAttributes["postedByEmail"] = arguments.email;
				xmlNode.xmlAttributes["postedOn"] = DateFormat(Now(),"yyyy-mm-dd") & "T" & TimeFormat(Now(),"HH:mm:ss");

				// check if comments branch exist
				if(Not structKeyExists(aUpdateNode[1], "comments")) {
					ArrayAppend(aUpdateNode[1].xmlChildren, xmlElemNew(xmlDoc,"comments"));
				}
				
				// add comment 
				ArrayAppend(aUpdateNode[1].comments.xmlChildren, xmlNode);

				myContentStore.save(xmlDoc);
				this.controller.setEventToRaise("Blog","CommentSaved");
				this.controller.setMessage("Comment saved");
			}
		</cfscript>
	</cffunction>

	<!-------------------------------------->
	<!--- saveBlogInfo                   --->
	<!-------------------------------------->
	<cffunction name="saveBlog" access="remote" output="true">
		<cfargument name="title" type="string" default="">
		<cfargument name="description" type="string" default="">
		<cfargument name="ownerEmail" type="string" default="">
		<cfargument name="blogURL" type="string" default="">

		<cfscript>
			var xmlDoc = 0;

			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();


			// check that we are updating the blog from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throw("Only the owner of this blog can make changes.");
			}
		
			if(Not isDefined("xmlDoc.xmlRoot.description"))
				xmlDoc.xmlRoot.description = XMLElemNew(xmlDoc, "description");
			xmlDoc.xmlRoot.description.xmlText = arguments.description;
			
			xmlDoc.xmlRoot.xmlAttributes.title = arguments.title;
			xmlDoc.xmlRoot.xmlAttributes.ownerEmail = arguments.ownerEmail;
			xmlDoc.xmlRoot.xmlAttributes.url = arguments.blogURL;
			
			// save changes
			myContentStore.save(xmlDoc);
			this.controller.setEventToRaise("Blog","BlogInfoChanged");
			this.controller.setMessage("Blog information changed");
		</cfscript>
	</cffunction>



	<!---- *********************** PRIVATE FUNCTIONS *************************** --->
	
	<!-------------------------------------->
	<!--- setContentStoreURL             --->
	<!-------------------------------------->
	<cffunction name="setContentStoreURL" access="private" output="false"
				hint="Sets the content store URL specified on the page.">
		<cfset var tmpURL = this.controller.getModuleConfigBean().getPageSetting("url")>
		<cfset this.controller.getContentStoreConfigBean().setURL(tmpURL)>
	</cffunction>
	
</cfcomponent>
