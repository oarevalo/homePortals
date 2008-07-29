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
		
 	// make sure only owner can make changes 
	if(Not bIsBlogOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";

	// parse and set default values for blog general info
	stBlog = structNew(); 			
	stBlog.title = "";
	stBlog.description = "";
	stBlog.ownerEmail = "";
	stBlog.url = "";
	stBlog.owner = "";
	stBlog.createdOn = "";

	if(isDefined("xmlDoc.xmlRoot.description"))
		stBlog.description = xmlDoc.xmlRoot.description.xmlText;

	if(StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "title"))
		stBlog.title = xmlDoc.xmlRoot.xmlAttributes.title;

	if(StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "ownerEmail"))
		stBlog.ownerEmail = xmlDoc.xmlRoot.xmlAttributes.ownerEmail;

	if(StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "url"))
		stBlog.url = xmlDoc.xmlRoot.xmlAttributes.url;

	if(StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "owner"))
		stBlog.owner = xmlDoc.xmlRoot.xmlAttributes.owner;

	if(StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "createdOn"))
		stBlog.createdOn = xmlDoc.xmlRoot.xmlAttributes.createdOn;


	// get owner's home
	csCfg = this.controller.getContentStoreConfigBean();
	tmpOwnerHome = csCfg.getAccountsRoot() & "/" & stBlog.owner;

</cfscript>


<cfoutput>
	
	<form action="##" name="frmBlogPost" method="post" class="blogPostForm" style="width:100%;margin:0px;padding:0px;">

		<table width="100%" class="BlogPostBar" cellpadding="0" cellspacing="1" border="0">
			<tr valign="middle">
				<tr>
					<td>
						<h2>#stBlog.title#</h2>
						<cfif stBlog.owner neq "">
							<div style="font-size:10px;">
								Created by 
								<a href="#tmpOwnerHome#"><b>#stBlog.owner#</b></a>
								<cfif stBlog.createdOn neq "">
									on #stBlog.createdOn#
								</cfif>
							</div>
						</cfif>
					</td>
					<td width="30">&nbsp;</td>
				</tr>
			</tr>
		</table>	
		
		<div class="BlogPostContent" style="padding:0px;">
		<table style="font-size:11px;margin-top:10px;">
			<cfif bIsBlogOwner>
				<tr>
					<td width="100">&nbsp;<strong>Blog Title:</strong></td>
					<td><input type="text" name="title" value="#stBlog.title#" style="width:320px;" #tmpDisabled#></td>
				</tr>
				<tr>
					<td>&nbsp;<strong>Owner Email:</strong></td>
					<td><input type="text" name="ownerEmail" value="#stBlog.ownerEmail#" style="width:320px;" #tmpDisabled#></td>
				</tr>
				<tr>
					<td>&nbsp;<strong>Blog URL:</strong></td>
					<td><input type="text" name="blogURL" value="#stBlog.url#" style="width:320px;" #tmpDisabled#></td>
				</tr>
				<tr valign="top">
					<td>&nbsp;<strong>Description:</strong></td>
					<td><textarea name="description"  rows="17" style="width:320px;" #tmpDisabled#>#stBlog.description#</textarea></td>
				</tr>
			<cfelse>
				<tr>
					<td width="100">&nbsp;<strong>Blog Title:</strong></td>
					<td>#stBlog.title#</td>
				</tr>
				<tr>
					<td>&nbsp;<strong>Owner Email:</strong></td>
					<td><a href="mailto:#stBlog.ownerEmail#">#stBlog.ownerEmail#</a></td>
				</tr>
				<tr>
					<td>&nbsp;<strong>Blog URL:</strong></td>
					<td><a href="#stBlog.url#" target="_blank">#stBlog.url#</a></td>
				</tr>
				<tr>
					<td>&nbsp;<strong>Description:</strong></td>
					<td><pre style="font-family:Arial, Helvetica, sans-serif;">#stBlog.description#</pre></td>
				</tr>
			</cfif>
		</table>
		</div>
		
		<table width="100%" class="BlogPostBar" cellpadding="3" cellspacing="1" border="0">
			<tr>
				<td>
					<cfif bIsBlogOwner>
						<a href="##" onclick="#moduleID#.doFormAction('saveBlog',document.frmBlogPost);#moduleID#.closeWindow();"><img src="#imgRoot#/disk.png" border="0" align="absmiddle" style="margin-right:2px;">Save Changes</a>
					</cfif>
				</td>
			</tr>
		</table>
	</form>
</cfoutput>
