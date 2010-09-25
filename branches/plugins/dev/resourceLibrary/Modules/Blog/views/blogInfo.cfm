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

<div style="background-color:##f5f5f5;">
	<div style="padding:0px;width:490px;">
	
		<div style="margin:5px;background-color:##333;border:1px solid silver;color:##fff;">
			<div style="margin:5px;">
				<cfoutput><strong>Blog:</strong> About This Blog </cfoutput>
			</div>
		</div>
	
		<div style="margin:5px;text-align:left;background-color:##ebebeb;border:1px solid silver;">
			<div style="margin:5px;"> 
				<h2><cfif stBlog.title neq "">#stBlog.title#<cfelse><em>No Title</em></cfif></h2>
				<cfif stBlog.owner neq "">
					<div style="font-size:10px;">
						Created by 
						<a href="#tmpOwnerHome#"><b>#stBlog.owner#</b></a>
						<cfif stBlog.createdOn neq "">
							on #stBlog.createdOn#
						</cfif>
					</div>
				</cfif>
			</div>
		</div>	
	
		<div style="width:490px;height:370px;border:1px solid silver;margin:5px;background-color:##fff;">
			
			<br />
			<form action="##" name="frmBlogPost" method="post" class="blogPostForm" style="width:480px;margin:0px;padding:0px;">
				<table style="font-size:11px;">
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
							<td><textarea name="description"  rows="14" style="width:320px;" #tmpDisabled#>#stBlog.description#</textarea></td>
						</tr>
					<cfelse>
						<tr>
							<td colspan="2">
								<pre style="font-family:Arial, Helvetica, sans-serif;margin:10px;">#stBlog.description#</pre>
							</td>
						</tr>
						<cfif stBlog.url neq "">
							<tr>
								<td colspan="2"><div style="margin:10px;"><a href="#stBlog.url#" target="_blank" style="font-size:10px;"><u>#stBlog.url#</u></a></div></td>
							</tr>
						</cfif>
					</cfif>
				</table>
			</form>
	
		</div>

		<div style="margin:5px;text-align:left;background-color:##ebebeb;border:1px solid silver;">
			<div style="margin:5px;"> 
				<cfif bIsBlogOwner>
					<a href="##" onclick="#moduleID#.doFormAction('saveBlog',document.frmBlogPost);#moduleID#.closeWindow();"><img src="#imgRoot#/disk.png" border="0" align="absmiddle" style="margin-right:2px;"></a>
					<a href="##" onclick="#moduleID#.doFormAction('saveBlog',document.frmBlogPost);#moduleID#.closeWindow();"><strong>Save Changes</strong></a>
					&nbsp;&nbsp;|&nbsp;&nbsp;
				</cfif>
				<a href="##" onclick="#moduleID#.closeWindow();"><strong>Close</strong></a>
			</div>
		</div>	
	</div>
</div>
		
</cfoutput>
