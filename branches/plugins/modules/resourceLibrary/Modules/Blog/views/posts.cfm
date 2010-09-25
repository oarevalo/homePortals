
<cfscript>
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
	
	// get posts
	maxEntries = 4;
	endIndex = 1;
	aEntries = xmlSearch(xmlDoc, "//entry");
	if(arrayLen(aEntries) gt maxEntries) endIndex = arrayLen(aEntries) - maxEntries;
	
	// url to rss feed
	rssURL = "http://" & cgi.SERVER_NAME & ":" & cgi.SERVER_PORT & getDirectoryFromPath(tmpModulePath) & "rss";
	
	// get the moduleID
	moduleID = this.controller.getModuleID();
</cfscript>


<cfoutput>
	<!--- Display blog entries --->
	<cfloop from="#arrayLen(aEntries)#" to="#endIndex#" index="i" step="-1">
		<cfset thisNode = aEntries[i]>
		<cfset txtContent = thisNode.content.xmlText>
		<cfset timestamp = thisNode.created.xmlText>
		<cfset hasComments = structKeyExists(thisNode,"comments")>
		<cfset numComments = 0>
		<cfif hasComments>
			<cfset numComments = ArrayLen(thisNode.comments.xmlChildren)>
		</cfif>
		<cfset thisPostLink = rssURL & "/?blog=" & myContentStore.getURL() & "&timestamp=" & timestamp>

		<!--- Check for code blocks --->
		<cfif findNoCase("<code>",txtContent) and findNoCase("</code>",txtContent)>
			<cfset counter = findNoCase("<code>",txtContent)>
			<cfloop condition="counter gte 1">
                <cfset codeblock = reFindNoCase("(?s)(.*)(<code>)(.*)(</code>)(.*)",txtContent,1,1)> 
				<cfif arrayLen(codeblock.len) gte 6>
                    <cfset codeportion = mid(txtContent, codeblock.pos[4], codeblock.len[4])>
                    <cfif len(trim(codeportion))>
						<cfset result = renderColoredCode(codeportion, "BlogCodeBlock")>
					<cfelse>
						<cfset result = "">
					</cfif>
					<cfset newbody = mid(txtContent, 1, codeblock.len[2]) & result & mid(txtContent,codeblock.pos[6],codeblock.len[6])>
	
                    <cfset txtContent = newbody>
					<cfset counter = findNoCase("<code>",txtContent,counter)>
				<cfelse>
					<!--- bad crap, maybe <code> and no ender, or maybe </code><code> --->
					<cfset counter = 0>
				</cfif>
			</cfloop>
		</cfif>
		
	
		<div style="margin-bottom:5px;font-size:12px;">
			<div style="font-size:1.5em;font-weight:bold;">#thisNode.title.xmlText#</div>
			<div style="font-size:0.8em;margin-bottom:10px;">
				Posted by <strong>#thisNode.Author.name.xmlText#</strong> on
					<cfif ListLen(timestamp,"T") eq 2> 
						<strong>#LSDateFormat(ListFirst(timestamp,"T"))# #LSTimeFormat(ListLast(timestamp,"T"))#</strong>
					<cfelse>
						<strong>#thisNode.created.xmlText#</strong>
					</cfif>
			</div>

			#Replace(txtContent, chr(10), "<br>", "ALL")#
			
			<div style="font-size:0.8em;margin-top:20px;margin-bottom:20px;">
				<!--- only show links to edit post to blog owner --->
				<cfif bIsBlogOwner>
					<a href="javascript:#moduleID#.getPopupView('editPost',{timestamp:'#timestamp#'});"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle" alt="Edit Post"></a>
					<a href="javascript:#moduleID#.getPopupView('editPost',{timestamp:'#timestamp#'})">Edit Post</a>&nbsp;&nbsp;|&nbsp;&nbsp;
				</cfif>	

				<!--- comments --->
				<a href="javascript:#moduleID#.getView('post','',{timestamp:'#timestamp#'});"><img src="#imgRoot#/user-comment-orange.gif" border="0" align="absmiddle" alt="View/Add Comments"></a>
				<a href="javascript:#moduleID#.getView('post','',{timestamp:'#timestamp#'});">View/Add Comments (#numComments#)</a>

				<!--- digg this! --->
				&nbsp;|&nbsp;
				<a href="http://digg.com/submit?phase=2&url=#URLEncodedFormat(thisPostLink)#" target="_blank"><img src="#imgRoot#/16x16-digg-guy.gif" align="absmiddle" alt="Digg This!" border="0">
				<a href="http://digg.com/submit?phase=2&url=#URLEncodedFormat(thisPostLink)#" target="_blank">Digg This!</a> &nbsp;
			</div>
			<hr />
		</div>
	</cfloop>
	
	<cfif arrayLen(aEntries) eq 0>
		<em>There are no entries in this blog.</em><br>	
	</cfif>
	
	<br>	
	<cfif bIsBlogOwner>
		<!--- only show links to add post to blog owner --->
		<a href="javascript:#moduleID#.getPopupView('editPost');"><img src="#imgRoot#/add-page-orange.gif" border="0" align="absmiddle" alt="Add New Entry"></a>
		<a href="javascript:#moduleID#.getPopupView('editPost')">Add New Entry</a>&nbsp;|&nbsp;
	</cfif>					
	
	<a href="javascript:#moduleID#.getPopupView('blogInfo');"><img src="#imgRoot#/web-page-orange.gif" border="0" align="absmiddle" alt="About This Blog"></a>
	<a href="javascript:#moduleID#.getPopupView('blogInfo')">About This Blog</a>

	<!---RSS --->
	&nbsp;|&nbsp;
	<a href="#rssURL#?blog=#myContentStore.getURL()#" target="_blank"><img src="#imgRoot#/feed-icon16x16.gif" align="absmiddle" border="0" title="RSS Feed for this blog" alt="RSS Feed for this blog"></a>
	<a href="#rssURL#?blog=#myContentStore.getURL()#" target="_blank">RSS 2.0</a>
</cfoutput>
