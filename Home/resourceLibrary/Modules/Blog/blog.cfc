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
			
			csCfg.setDefaultName("myBlog.xml");
			csCfg.setRootNode("blog");
		</cfscript>	
	</cffunction>




	<!-------------------------------------->
	<!--- savePost                       --->
	<!-------------------------------------->
	<cffunction name="savePost">
		<cfargument name="title" type="string" default="">
		<cfargument name="author" type="string" default="">
		<cfargument name="content" type="string" default="">
		<cfargument name="created" type="string" default="">
		
		<cfscript>
			var moduleID = this.controller.getModuleID();
			
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
				xmlNode.title.xmlText = xmlFormat(arguments.Title);
				
				xmlNode.xmlChildren[2] = xmlElemNew(xmlDoc,"author");
				xmlNode.author.xmlChildren[1] = xmlElemNew(xmlDoc,"name");
				xmlNode.author.name.xmlText = xmlFormat(arguments.author);
				
				xmlNode.xmlChildren[3] = xmlElemNew(xmlDoc,"created");
				xmlNode.created.xmlText = DateFormat(Now(),"yyyy-mm-dd") & "T" & TimeFormat(Now(),"HH:mm:ss");

				xmlNode.xmlChildren[4] = xmlElemNew(xmlDoc,"content");
				xmlNode.content.xmlText = arguments.Content;
				
				// add to document
				ArrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);

			} else {
				// update existing node
				aUpdateNode[1].title.xmlText = xmlFormat(arguments.title);
				aUpdateNode[1].author.name.xmlText = xmlFormat(arguments.author);
				aUpdateNode[1].content.xmlText = arguments.Content;
			}
			
			// save changes to document
			myContentStore.save(xmlDoc);
			
			// notify client of change
			this.controller.setEventToRaise("onPostSaved");
			this.controller.setMessage("Post Saved");
			this.controller.setScript("#moduleID#.getView()");
		</cfscript>
	</cffunction>

	<!-------------------------------------->
	<!--- deletePost                     --->
	<!-------------------------------------->
	<cffunction name="deletePost" access="public">
		<cfargument name="timestamp" type="string" required="yes">

		<cfscript>
			var xmlDoc = 0;
			var tmpNode = 0;
			var moduleID = this.controller.getModuleID();

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
			this.controller.setEventToRaise("onPostDeleted");
			this.controller.setMessage("Post Deleted");
			this.controller.setScript("#moduleID#.getView()");
		</cfscript>
	</cffunction>

	<!-------------------------------------->
	<!--- saveComment                    --->
	<!-------------------------------------->
	<cffunction name="saveComment" access="public">
		<cfargument name="name" type="string" default="Anonymous">
		<cfargument name="email" type="string" default="##">
		<cfargument name="comment" type="string" default="">
		<cfargument name="timestamp" type="string" default="">

		<cfscript>
			var xmlDoc = 0;
			var aUpdateNode = 0;
			var moduleID = this.controller.getModuleID();

			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();


			// check if we find the entry the caller say we are updating
			aUpdateNode = xmlSearch(xmlDoc, "//entry[created='#arguments.timestamp#']");

			if(arguments.comment neq "" and arrayLen(aUpdateNode) gt 0) {
				// create comment 
				xmlNode = xmlElemNew(xmlDoc,"comment");
				xmlNode.xmlText = xmlFormat(arguments.comment);
				xmlNode.xmlAttributes["postedByName"] = xmlFormat(arguments.name);
				xmlNode.xmlAttributes["postedByEmail"] = xmlFormat(arguments.email);
				xmlNode.xmlAttributes["postedOn"] = DateFormat(Now(),"yyyy-mm-dd") & "T" & TimeFormat(Now(),"HH:mm:ss");

				// check if comments branch exist
				if(Not structKeyExists(aUpdateNode[1], "comments")) {
					ArrayAppend(aUpdateNode[1].xmlChildren, xmlElemNew(xmlDoc,"comments"));
				}
				
				// add comment 
				ArrayAppend(aUpdateNode[1].comments.xmlChildren, xmlNode);

				myContentStore.save(xmlDoc);
				this.controller.setEventToRaise("onCommentSaved");
				this.controller.setMessage("Comment saved");
				this.controller.setScript("#moduleID#.getView()");
			}
		</cfscript>
	</cffunction>

	<!-------------------------------------->
	<!--- saveBlogInfo                   --->
	<!-------------------------------------->
	<cffunction name="saveBlog" access="public">
		<cfargument name="title" type="string" default="">
		<cfargument name="description" type="string" default="">
		<cfargument name="ownerEmail" type="string" default="">
		<cfargument name="blogURL" type="string" default="">

		<cfscript>
			var xmlDoc = 0;
			var moduleID = this.controller.getModuleID();

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
			xmlDoc.xmlRoot.description.xmlText = xmlFormat(arguments.description);
			
			xmlDoc.xmlRoot.xmlAttributes.title = xmlFormat(arguments.title);
			xmlDoc.xmlRoot.xmlAttributes.ownerEmail = xmlFormat(arguments.ownerEmail);
			xmlDoc.xmlRoot.xmlAttributes.url = xmlFormat(arguments.blogURL);
			
			// save changes
			myContentStore.save(xmlDoc);
			this.controller.setEventToRaise("onBlogInfoChanged");
			this.controller.setMessage("Blog information changed");
			this.controller.setScript("#moduleID#.getView()");
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

<!--- 
Copyright for coloredCode function. Also note that Jeff Coughlin made some mods to this as well.
=============================================================
	Utility:	ColdFusion ColoredCode v3.2
	Author:		Dain Anderson
	Email:		webmaster@cfcomet.com
	Revised:	June 7, 2001
	Download:	http://www.cfcomet.com/cfcomet/utilities/
============================================================= 
--->
	<cffunction name="renderColoredCode" output="false" returnType="string" access="public"
			   hint="Colors code">
		<cfargument name="dataString" type="string" required="true">
		<cfargument name="class" type="string" required="true">

		<cfset var data = trim(arguments.dataString) />
		<cfset var eof = 0>
		<cfset var bof = 1>
		<cfset var match = "">
		<cfset var orig = "">
		<cfset var chunk = "">

		<cfscript>
		/* Convert special characters so they do not get interpreted literally; italicize and boldface */
		data = REReplaceNoCase(data, '&([[:alpha:]]{2,});', '�strong��em�&amp;\1;�/em��/strong�', 'ALL');
	
		/* Convert many standalone (not within quotes) numbers to blue, ie. myValue = 0 */
		data = REReplaceNoCase(data, "(gt|lt|eq|is|,|\(|\))([[:space:]]?[0-9]{1,})", "\1�span style='color: ##0000ff'�\2�/span�", "ALL");
	
		/* Convert normal tags to navy blue */
		data = REReplaceNoCase(data, "<(/?)((!d|b|c(e|i|od|om)|d|e|f(r|o)|h|i|k|l|m|n|o|p|q|r|s|t(e|i|t)|u|v|w|x)[^>]*)>", "�span style='color: ##000080'�<\1\2>�/span�", "ALL");
	
		/* Convert all table-related tags to teal */
		data = REReplaceNoCase(data, "<(/?)(t(a|r|d|b|f|h)([^>]*)|c(ap|ol)([^>]*))>", "�span style='color: ##008080'�<\1\2>�/span�", "ALL");
	
		/* Convert all form-related tags to orange */
		data = REReplaceNoCase(data, "<(/?)((bu|f(i|or)|i(n|s)|l(a|e)|se|op|te)([^>]*))>", "�span style='color: ##ff8000'�<\1\2>�/span�", "ALL");
	
		/* Convert all tags starting with 'a' to green, since the others aren't used much and we get a speed gain */
		data = REReplaceNoCase(data, "<(/?)(a[^>]*)>", "�span style='color: ##008000'�<\1\2>�/span�", "ALL");
	
		/* Convert all image and style tags to purple */
		data = REReplaceNoCase(data, "<(/?)((im[^>]*)|(sty[^>]*))>", "�span style='color: ##800080'�<\1\2>�/span�", "ALL");
	
		/* Convert all ColdFusion, SCRIPT and WDDX tags to maroon */
		data = REReplaceNoCase(data, "<(/?)((cf[^>]*)|(sc[^>]*)|(wddx[^>]*))>", "�span style='color: ##800000'�<\1\2>�/span�", "ALL");
	
		/* Convert all inline "//" comments to gray (revised) */
		data = REReplaceNoCase(data, "([^:/]\/{2,2})([^[:cntrl:]]+)($|[[:cntrl:]])", "�span style='color: ##808080'��em�\1\2�/em��/span�", "ALL");
	
		/* Convert all multi-line script comments to gray */
		data = REReplaceNoCase(data, "(\/\*[^\*]*\*\/)", "�span style='color: ##808080'��em�\1�/em��/span�", "ALL");
	
		/* Convert all HTML and ColdFusion comments to gray */	
		/* The next 10 lines of code can be replaced with the commented-out line following them, if you do care whether HTML and CFML 
		   comments contain colored markup. */

		while(NOT EOF) {
			Match = REFindNoCase("<!--" & "-?([^-]*)-?-->", data, BOF, True);
			if (Match.pos[1]) {
				Orig = Mid(data, Match.pos[1], Match.len[1]);
				Chunk = REReplaceNoCase(Orig, "�(/?[^�]*)�", "", "ALL");
				BOF = ((Match.pos[1] + Len(Chunk)) + 38); // 38 is the length of the SPAN tags in the next line
				data = Replace(data, Orig, "�span style='color: ##808080'��em�#Chunk#�/em��/span�");
			} else EOF = 1;
		}


		/* Convert all quoted values to blue */
		data = REReplaceNoCase(data, """([^""]*)""", "�span style=""color: ##0000ff""�""\1""�/span�", "all");

		/* Convert left containers to their ASCII equivalent */
		data = REReplaceNoCase(data, "<", "&lt;", "ALL");

		/* Convert right containers to their ASCII equivalent */
		data = REReplaceNoCase(data, ">", "&gt;", "ALL");

		/* Revert all pseudo-containers back to their real values to be interpreted literally (revised) */
		data = REReplaceNoCase(data, "�([^�]*)�", "<\1>", "ALL");

		/* ***New Feature*** Convert all FILE and UNC paths to active links (i.e, file:///, \\server\, c:\myfile.cfm) */
		data = REReplaceNoCase(data, "(((file:///)|([a-z]:\\)|(\\\\[[:alpha:]]))+(\.?[[:alnum:]\/=^@*|:~`+$%?_##& -])+)", "<a target=""_blank"" href=""\1"">\1</a>", "ALL");

		/* Convert all URLs to active links (revised) */
		data = REReplaceNoCase(data, "([[:alnum:]]*://[[:alnum:]\@-]*(\.[[:alnum:]][[:alnum:]-]*[[:alnum:]]\.)?[[:alnum:]]{2,}(\.?[[:alnum:]\/=^@*|:~`+$%?_##&-])+)", "<a target=""_blank"" href=""\1"">\1</a>", "ALL");

		/* Convert all email addresses to active mailto's (revised) */
		data = REReplaceNoCase(data, "(([[:alnum:]][[:alnum:]_.-]*)?[[:alnum:]]@[[:alnum:]][[:alnum:].-]*\.[[:alpha:]]{2,})", "<a href=""mailto:\1"">\1</a>", "ALL");
		</cfscript>

		<!--- mod by ray --->
		<!--- change line breaks at end to <br /> 
		<cfset data = replace(data,chr(13),"<br />","all") />--->
		<!--- replace tab with 3 spaces --->
		<cfset data = replace(data,chr(9),"&nbsp;&nbsp;&nbsp;","all") />
		<cfset data = "<div class=""#arguments.class#"">" & data &  "</div>" />
		
		<cfreturn data>
	</cffunction>	
</cfcomponent>
