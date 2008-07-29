<cfparam name="arguments.timeStamp" default="">

<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();

	// get image path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";
			
	// get content store
	setContentStoreURL();
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();
	
	// get current user info
	stUser = this.controller.getUserInfo();
	
	// check that we are updating the blog from the owners page
	bIsBlogOwner = (stUser.username eq myContentStore.getOwner());

	// get posts
	aEntries = xmlSearch(xmlDoc, "//entry[created='#arguments.timestamp#']");
	
	// make sure user is the owner
	if(Not bIsBlogOwner)
		throw("You must be signed-in as the owner of this page in order to add or modify blog postings.");

	stEntry = StructNew();
	if(arrayLen(aEntries) eq 0) {
		stEntry.title = "";
		stEntry.author = stUser.username;
		stEntry.content = "";
	} else {
		stEntry.title = aEntries[1].title.xmlText;
		stEntry.author = aEntries[1].Author.name.xmlText;
		stEntry.content = aEntries[1].content.xmlText;
	}
</cfscript>


<!--- Display blog entry (edit mode) --->
<cfoutput>
	<form action="##" name="frmBlogPost" method="post" class="blogPostForm" style="margin:0px;padding:0px;">
		<input type="hidden" name="created" value="#arguments.timestamp#">

		<!--- Post header --->
		<table width="100%" class="BlogPostBar" cellpadding="0" cellspacing="1" border="0">
			<tr valign="middle">
				<tr>
					<td width="90">&nbsp;Title:</td>
					<td><input type="text" name="title" value="#stEntry.title#" style="width:330px;"></td>
					<td width="30" rowspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td>&nbsp;Post By:</td>
					<td><input type="text" name="author" value="#stEntry.author#" style="width:330px;"></td>
				</tr>
			</tr>
		</table>	
			
		<textarea name="content" 
				  rows="22"
				  onkeypress="BlogCheckTab(event)" 
				  onkeydown="BlogCheckTabIE()"
				  class="BlogPostContent">#htmlEditFormat(stEntry.content)#</textarea>

		<table width="100%" class="BlogPostBar" cellpadding="3" cellspacing="1" border="0">
			<tr valign="middle">
				<td>
					<a href="##" onclick="#moduleID#.doFormAction('savePost',document.frmBlogPost);#moduleID#.closeWindow();"><img src="#imgRoot#/disk.png" border="0" align="absmiddle" style="margin-right:2px;">Save Changes</a>
					<cfif arguments.timestamp neq "">
						&nbsp;&nbsp;&nbsp;
						<a href="##" onclick="if(confirm('Delete post?')) {#moduleID#.doAction('deletePost',{timestamp:'#arguments.timestamp#'});#moduleID#.closeWindow();}"><img src="#imgRoot#/cross.png" border="0" align="absmiddle" style="margin-right:2px;">Delete</a>
					</cfif>
				</td>
				<td align="right" style="font-size:9px;color:##333;font-weight:bold;">
					<cfif arguments.timestamp neq "">
						Posted on 
						#LSDateFormat(ListFirst(arguments.timestamp,"T"))# 
						#LSTimeFormat(ListLast(arguments.timestamp,"T"))#
						&nbsp;&nbsp;&nbsp;
					</cfif>
				</td>
			</tr>
		</table>			
	</form>
</cfoutput>
		