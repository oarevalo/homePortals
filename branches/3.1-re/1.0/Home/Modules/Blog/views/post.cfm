<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();
		
	// get module path
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
	
	// get post
	numComments = 0;
	aEntries = xmlSearch(xmlDoc, "//entry[created='#arguments.timestamp#']");

	// url to rss feed
	rssURL = "http://" & cgi.SERVER_NAME & getDirectoryFromPath(tmpModulePath) & "rss";

</cfscript>



<!--- Display blog entries --->
<cfif arrayLen(aEntries) gt 0>
	<cfset txtContent = aEntries[1].content.xmlText>
	<cfset timestamp = aEntries[1].created.xmlText>

	<!--- check for comments --->		
	<cfset hasComments = structKeyExists(aEntries[1],"comments")>
	<cfif hasComments>
		<cfset numComments = ArrayLen(aEntries[1].comments.xmlChildren)>
	</cfif>		
	<cfset thisPostLink = rssURL & "/?blog=" & myContentStore.getURL() & "&timestamp=" & timestamp>

	<cfoutput>
		<div style="margin-bottom:5px;font-size:12px;">
			<div style="font-size:1.5em;font-weight:bold;">#aEntries[1].title.xmlText#</div>
			<div style="font-size:0.8em;margin-bottom:10px;">
				Posted by <strong>#aEntries[1].Author.name.xmlText#</strong> on
					<cfif ListLen(timestamp,"T") eq 2> 
						<strong>#LSDateFormat(ListFirst(timestamp,"T"))# #LSTimeFormat(ListLast(timestamp,"T"))#</strong>
					<cfelse>
						<strong>#aEntries[1].created.xmlText#</strong>
					</cfif>
			</div>
			
			#txtContent#
			
			<div style="font-size:0.8em;margin-top:20px;margin-bottom:20px;">
				<!--- return to blog --->
				<a href="javascript:#moduleID#.getView();"><img src="#imgRoot#/home-page-orange-1.gif" border="0" align="absmiddle" alt="Return To Blog"></a>
				<a href="javascript:#moduleID#.getView()">Return To Blog</a>&nbsp;&nbsp;|&nbsp;&nbsp;
			
				<!--- only show links to edit post to blog owner --->
				<cfif bIsBlogOwner>
					<a href="javascript:#moduleID#.getPopupView('editPost',{timestamp:'#timestamp#'});"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle" alt="Edit Post"></a>
					<a href="javascript:#moduleID#.getPopupView('editPost',{timestamp:'#timestamp#'})">Edit Post</a>&nbsp;&nbsp;|&nbsp;&nbsp;
				</cfif>	

				<!--- digg this! --->
				<a href="http://digg.com/submit?phase=2&url=#URLEncodedFormat(thisPostLink)#" target="_blank"><img src="#imgRoot#/16x16-digg-guy.gif" align="absmiddle" alt="Digg This!" border="0">
				<a href="http://digg.com/submit?phase=2&url=#URLEncodedFormat(thisPostLink)#" target="_blank">Digg This!</a> &nbsp;
			</div>
		</div>
	
		<!--- display comments --->
		<hr />
		<p><b>Comments</b></p>
		<cfloop from="1" to="#numComments#" index="i">
			<cfset thisNode = aEntries[1].comments.xmlChildren[i]>
			<cfparam name="thisNode.xmlText" default="">
			<cfparam name="thisNode.xmlAttributes" default="#structNew()#">
			<cfparam name="thisNode.xmlAttributes.postedByName" default="">
			<cfparam name="thisNode.xmlAttributes.postedByEmail" default="">
			<cfparam name="thisNode.xmlAttributes.postedOn" default="">
			<p>#thisNode.xmlText#</p>
			<div style="font-size:0.8em;margin-bottom:10px;border-bottom:1px dotted silver;">
				Posted By <a href="mailto:#thisNode.xmlAttributes.postedByEmail#">#thisNode.xmlAttributes.postedByName#</a> on 
				<cfif ListLen(thisNode.xmlAttributes.postedOn,"T") eq 2> 
					<strong>#LSDateFormat(ListFirst(thisNode.xmlAttributes.postedOn,"T"))# #LSTimeFormat(ListLast(thisNode.xmlAttributes.postedOn,"T"))#</strong>
				<cfelse>
					<strong>#thisNode.xmlAttributes.postedOn#</strong>
				</cfif>
			</div>
		</cfloop>
		<cfif numComments eq 0>
			<em>Add your comments here</em>
		</cfif>
		
		<!--- display comments form --->
		<form action="##" method="post" class="blogPostForm" style="width:100%;margin-top:20px;">
			<input type="hidden" name="timestamp" value="#timestamp#">
			
			<b>Post a Comment</b>						
			<table style="width:100%;">
				<tr>
					<td width="100">Name:</td>
					<td><input type="text" name="name" value=""></td>
				</tr>
				<tr>
					<td>Email:</td>
					<td><input type="text" name="email" value=""></td>
				</tr>
				<tr>
					<td colspan="2">
						<textarea name="comment" rows="8" style="width:90%;"></textarea>
						<p>
							<input type="button" name="btnAction" value="Save" onclick="#moduleID#.doFormAction('saveComment',this.form)" style="width:auto;">
							<input type="button" name="btnAction" value="Cancel" onclick="#moduleID#.getView()" style="width:auto;">
						</p>
					</td>
				</tr>
			</table>
		</form>
	</cfoutput>
</cfif>


