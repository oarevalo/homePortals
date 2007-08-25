<!---- Blog Viewer ---->

<cfparam name="blog" default="">
<cfparam name="timestamp" default="" >
<cfparam name="maxEntries" default="5" >

<cfif blog eq "">
	<cfthrow message="No blog document has been indicated.">
</cfif>

<cfscript>
	blogViewer = CreateObject("Component","blogViewer");

	// check if we are saving a comment
	if(isDefined("btnSaveComment")) {
		blogViewer.saveBlogComment(blog, timestamp, form);
	}

	// open and parse blog xml 
	xmlDoc = xmlParse(expandpath(blog));

	// get blog details
	stBlog = blogViewer.getBlogInfo(xmlDoc);
	
	// get posts
	aAllEntries = xmlSearch(xmlDoc, "//entry");

	// get selected post (if needed)
	endIndex = 1;
	if(timestamp eq "") {
		aEntries = xmlSearch(xmlDoc, "//entry");
		if(arrayLen(aEntries) gt maxEntries) endIndex = arrayLen(aEntries) - maxEntries + 1;
	} else {
		aEntries = xmlSearch(xmlDoc, "//entry[created='#timestamp#']");
	}
	
	// url to rss feed
	rssURL = "http://" & cgi.SERVER_NAME & getDirectoryFromPath(getDirectoryFromPath(cgi.SCRIPT_NAME)) & "rss";
</cfscript>


<cfoutput>
<html>
	<head>
		<title>#stBlog.title#</title>
		<link rel="stylesheet" href="blogViewer.css" type="text/css" />
		<link rel="alternate" type="application/rss+xml" title="#stBlog.title#" href="#rssURL#" />
	</head>
	<body>
		<div class="header">
			<h1>#stBlog.title#</h1>
			#stBlog.description#
		</div>

		<cfif stBlog.url neq "">
			<div class="blogLinkNotice">
				<b>Read the complete blog at <a href="#stBlog.url#">#stBlog.url#<a/></b>
			</div>
		</cfif>

		<div class="posts">
		
			<!--- display posts index --->
			<div class="postsIndex">
				<div style="margin:10px;">
					<b>Previous Posts:</b><br>
					<cfset postFound = false>
					<cfset numPrevPosts = 0>
					<cfset prevPostsStart = 1>
					<cfset nextPostTimestamp = "">
					<cfset nextPostTitle = "">

					<cfif timestamp eq "">
						<!--- we are looking at the most recent posts, so the previous posts list
							should only contain posts made before the ones we are showing --->
						<cfif endIndex gt 1>
							<cfloop from="#endIndex-1#" to="#prevPostsStart#" index="i" step="-1">
								<cfset ixTimestamp = trim(aAllEntries[i].created.xmlText)>
								<li><a href="?blog=#blog#&timestamp=#ixTimestamp#">#aAllEntries[i].title.xmlText#</a></li>
								<cfset numPrevPosts = numPrevPosts + 1>
							</cfloop>
						<cfelse>
							<em>None</em>
						</cfif>
					<cfelse>	
						<!--- we are looking at one post in particular, so we want to
							show on the prev posts list, the ones made before this one --->
						<cfloop from="#ArrayLen(aAllEntries)#" to="1" index="i" step="-1">
							<cfset ixTimestamp = trim(aAllEntries[i].created.xmlText)>
							<cfif postFound>
								<li><a href="?blog=#blog#&timestamp=#ixTimestamp#">#aAllEntries[i].title.xmlText#</a></li>
								<cfset numPrevPosts = numPrevPosts + 1>
							</cfif>
							<cfif ixTimestamp eq timestamp>
								<cfset postFound = true>
							</cfif>
							<cfif not PostFound and ixTimestamp neq timestamp>
								<cfset nextPostTimestamp = trim(aAllEntries[i].created.xmlText)>
								<cfset nextPostTitle = aAllEntries[i].title.xmlText>
							</cfif>
						</cfloop>
						<cfif numPrevPosts eq 0>
							<em>None</em>
						</cfif>
						<cfif nextPostTimestamp neq "">
							<br>
							<b>Next Post:</b><br>
							<li><a href="?blog=#blog#&timestamp=#nextPostTimestamp#">#nextPostTitle#</a></li>
						</cfif>
					</cfif>
					
					<cfif ArrayLen(aAllEntries) eq 0>
						<em>There are no entries in this blog.</em>
					</cfif>				
				</div>
			</div>
					

			<!--- display posts --->
			<cfif ArrayLen(aEntries) gt 0>
				<cfloop from="#ArrayLen(aEntries)#" to="#endIndex#" index="i" step="-1">
					<cfset thisNode = aEntries[i]>
					<cfset txtContent = thisNode.content.xmlText>
					<cfset thisTimestamp = thisNode.created.xmlText>
					<cfset hasComments = structKeyExists(thisNode,"comments")>
					<cfset numComments = 0>
					<cfif hasComments>
						<cfset numComments = ArrayLen(thisNode.comments.xmlChildren)>
					</cfif>
					<cfset thisPostLink = rssURL & "/?blog=" & blog & "&timestamp=" & thisTimestamp>

			
					<!--- Check for code blocks --->
					<cfset txtContent = blogViewer.processCodeBlocks(txtContent)>
					
					<cfif timestamp eq "" or timestamp eq thisTimestamp>
						<h2>#thisNode.title.xmlText#</h2>
						<h3>
							Posted by <strong>#thisNode.Author.name.xmlText#</strong> on
								<cfif ListLen(thisTimestamp,"T") eq 2> 
									<strong>#LSDateFormat(ListFirst(thisTimestamp,"T"))# #LSTimeFormat(ListLast(thisTimestamp,"T"))#</strong>
								<cfelse>
									<strong>#thisNode.created.xmlText#</strong>
								</cfif>
						</h3>
	
						<div class="post">
							#Replace(txtContent, chr(10), "<br>", "ALL")#
							<div class="postTools">
								<cfif timestamp neq "">
									<!--- return to blog --->
									<a href="?blog=#blog#"><img src="Images/home-page-orange-1.gif" border="0" align="absmiddle" alt="Return To Blog"></a>
									<a href="?blog=#blog#">Return To Blog</a>
								<cfelse>
									<!--- comments --->
									<a href="?blog=#blog#&timestamp=#thisTimestamp#"><img src="Images/user-comment-orange.gif" border="0" align="absmiddle" alt="View/Add Comments"></a>
									<a href="?blog=#blog#&timestamp=#thisTimestamp#">View/Add Comments (#numComments#)</a>
								</cfif>
							</div>
							<hr />
						</div>
					</cfif>

					<!--- display comments --->
					<cfif timestamp eq thisTimestamp>
						<p><b>Comments</b></p>
						<cfloop from="1" to="#numComments#" index="i">
							<cfset thisCommentNode = thisNode.comments.xmlChildren[i]>
							<cfparam name="thisCommentNode.xmlText" default="">
							<cfparam name="thisCommentNode.xmlAttributes" default="#structNew()#">
							<cfparam name="thisCommentNode.xmlAttributes.postedByName" default="">
							<cfparam name="thisCommentNode.xmlAttributes.postedByEmail" default="">
							<cfparam name="thisCommentNode.xmlAttributes.postedOn" default="">
				
							<p>#Replace(thisCommentNode.xmlText, chr(10), "<br>", "ALL")#</p>
							
							<div style="font-size:0.8em;margin-bottom:10px;border-bottom:1px dotted silver;">
								Posted By 
								<cfif thisCommentNode.xmlAttributes.postedByEmail neq "">
									<a href="mailto:#thisCommentNode.xmlAttributes.postedByEmail#">#thisCommentNode.xmlAttributes.postedByName#</a> 
								<cfelse>
									#thisCommentNode.xmlAttributes.postedByName#
								</cfif>
								on
								<cfif ListLen(thisCommentNode.xmlAttributes.postedOn,"T") eq 2> 
									<strong>#LSDateFormat(ListFirst(thisCommentNode.xmlAttributes.postedOn,"T"))# #LSTimeFormat(ListLast(thisCommentNode.xmlAttributes.postedOn,"T"))#</strong>
								<cfelse>
									<strong>#thisCommentNode.xmlAttributes.postedOn#</strong>
								</cfif>
							</div>
						</cfloop>
						<cfif numComments eq 0>
							<em>Add your comments here</em>
						</cfif>


						<!--- display comments form --->
						<form action="index.cfm" method="post" class="blogPostForm" style="width:100%;margin-top:20px;">
							<input type="hidden" name="timestamp" value="#timestamp#">
							<input type="hidden" name="blog" value="#blog#">
							
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
											<input type="submit" name="btnSaveComment" value="Save Comment" style="width:auto;">
										</p>
									</td>
								</tr>
							</table>
						</form>
					</cfif>
					
				</cfloop>
			</cfif>
			<cfif arrayLen(aEntries) eq 0>
				<em>There are no entries in this blog.</em><br>	
			</cfif>
		</div>
		<div class="blogCredits">
			Blog viewer generated by <a href="http://www.homeportals.net">HomePortals</a>
		</div>
	</body>
</html>
</cfoutput>
