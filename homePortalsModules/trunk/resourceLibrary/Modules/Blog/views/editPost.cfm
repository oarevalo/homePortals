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

<div style="background-color:##f5f5f5;">
	<div style="padding:0px;width:490px;">
	
		<div style="margin:5px;background-color:##333;border:1px solid silver;color:##fff;">
			<div style="margin:5px;">
				<cfoutput><strong>Blog:</strong> Add/Edit Entry </cfoutput>
			</div>
		</div>
	
		<form action="##" name="frmBlogPost" method="post" class="blogPostForm" style="margin:0px;padding:0px;">
			<input type="hidden" name="created" value="#arguments.timestamp#">
	
			<div style="margin:5px;text-align:left;background-color:##ebebeb;border:1px solid silver;">
				<div style="margin:5px;"> 
					<table width="100%" cellpadding="0" cellspacing="1" border="0">
						<tr valign="middle">
							<tr>
								<td width="90">&nbsp;Title:</td>
								<td><input type="text" name="title" value="#stEntry.title#" style="width:330px;"></td>
							</tr>
							<tr>
								<td>&nbsp;Post By:</td>
								<td><input type="text" name="author" value="#stEntry.author#" style="width:330px;"></td>
							</tr>
						</tr>
					</table>	
				</div>
			</div>	
			
			<div >
				<textarea name="content" 
						  style="width:470px;height:330px;border:1px solid silver;margin:5px;background-color:##fff;padding:3px;"	
						  rows="20" 
						  onkeypress="BlogCheckTab(event)" 
						  onkeydown="BlogCheckTabIE()"
						  class="BlogPostContent">#htmlEditFormat(stEntry.content)#</textarea>
	
			</div>
			
		</form>	
	
		<div style="margin:5px;text-align:left;background-color:##ebebeb;border:1px solid silver;">
			<div style="margin:5px;"> 
				<table width="100%" cellspacing="1" border="0">
					<tr valign="middle">
						<td>
							<a href="##" onclick="#moduleID#.doFormAction('savePost',document.frmBlogPost);#moduleID#.closeWindow();"><img src="#imgRoot#/disk.png" border="0" align="absmiddle" style="margin-right:2px;"></a>
							<a href="##" onclick="#moduleID#.doFormAction('savePost',document.frmBlogPost);#moduleID#.closeWindow();"><strong>Save Changes</strong></a>
							&nbsp;&nbsp;|&nbsp;&nbsp;
							<cfif arguments.timestamp neq "">
								<a href="##" onclick="if(confirm('Delete post?')) {#moduleID#.doAction('deletePost',{timestamp:'#arguments.timestamp#'});#moduleID#.closeWindow();}"><img src="#imgRoot#/cross.png" border="0" align="absmiddle" style="margin-right:2px;"></a>
								<a href="##" onclick="if(confirm('Delete post?')) {#moduleID#.doAction('deletePost',{timestamp:'#arguments.timestamp#'});#moduleID#.closeWindow();}"><strong>Delete</strong></a>
								&nbsp;&nbsp;|&nbsp;&nbsp;
							</cfif>
							<a href="##" onclick="#moduleID#.closeWindow();"><strong>Close</strong></a>
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
			</div>
		</div>	
	

		<!--- Post header --->
			


</cfoutput>
		