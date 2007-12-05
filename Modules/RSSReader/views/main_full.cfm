<cfparam name="arguments.rss" default="">

<cfscript>
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	

	// reader settings
	rssURL = cfg.getPageSetting("rss");
	maxItems = cfg.getPageSetting("maxItems");

	// user info
	stUser = this.controller.getUserInfo();

	// this is to allow overriding of the page setting
	if(arguments.rss neq "") rssURL = arguments.rss;

	// get images path
	imgRoot = tmpModulePath & "/images";
	
	// get reader service
	oRSSReaderService = createObject("Component","#tmpModulePath#/RSSReaderService");

	if(rssURL neq "") {
		feed = StructNew();
		intMaxItems = 99;
		
		// read feed
		try {
			feed = oRSSReaderService.getRSS(rssURL);

			// check for max items to display
			if(IsNumeric(maxItems)) {
				intMaxItems = Min(maxItems, ArrayLen(feed.items));
			} else {
				intMaxItems = ArrayLen(feed.items);
			}
			
			bFeedReadOK = true;

		} catch(any e) {
			bFeedReadOK = false;
			errMessage = "<b>Error:</b> #e.message#";
		}
	}
</cfscript>

<cfif rssURL neq "">
	<cfoutput>
		<cfif bFeedReadOK>
			<cfif feed.Image.URL neq "">
				<a href="#feed.Image.Link#">
					<img src="#feed.Image.URL#" border="0" id="RSS_Image"
							title="#feed.Image.Title#" 
							alt="#feed.Image.Title#" /></a>
			</cfif>
	
			<div id="#moduleID#_RSSTitle" style="margin-bottom:30px;">
				<a href="#feed.Link#" target="_blank">#feed.Title#</a>
				<a href="javascript:#moduleID#.getView('','',{rss:'#rssURL#',useLayout:false})"><img src="#imgRoot#/refresh.gif" alt="Refresh Feed" title="Refresh Feed" border="0" align="baseline"></a>&nbsp;
				<a href="#rssURL#" target="_blank"><img src="#imgRoot#/feed-icon16x16.gif" alt="View Feed XML" title="View Feed" border="0" align="baseline"></a>&nbsp;
			</div>
	
			<cfloop from="1" to="#intMaxItems#" index="i">
				
				<cfscript>
					thisLink = "";
					thisTitle = "no title";
					thisContent = "";
					thisPubDate = "";
					thisEnclosure = structNew();
					thisEnclosure.url = "";
					thisEnclosure.length = "";
					thisEnclosure.type = "";
					myFeedNode = feed.items[i];
		
					// make sure we have all the values we need
					if(StructKeyExists(myFeedNode,"link")) thisLink = tostring(myFeedNode.link.xmlText);
					if(StructKeyExists(myFeedNode,"title")) thisTitle = tostring(myFeedNode.title.xmlText);
					if(StructKeyExists(myFeedNode,"content")) thisContent = tostring(myFeedNode.content); //atom 
					if(thisContent eq "" and StructKeyExists(myFeedNode,"description")) thisContent = myFeedNode.description.xmlText; // rss
					if(StructKeyExists(myFeedNode,"pubDate")) thisPubDate = myFeedNode.pubDate.xmlText; // rss 
					if(StructKeyExists(myFeedNode,"created")) thisPubDate = myFeedNode.created.xmlText;  // atom 
					if(StructKeyExists(myFeedNode,"enclosure")) { 
						tmpEncAttr = duplicate(myFeedNode.enclosure.xmlAttributes);
						if(StructKeyExists(tmpEncAttr,"url")) thisEnclosure.url = tmpEncAttr.url;
						if(StructKeyExists(tmpEncAttr,"length")) thisEnclosure.length = tmpEncAttr.length;
						if(StructKeyExists(tmpEncAttr,"type")) thisEnclosure.type = tmpEncAttr.type;
					}
				
					// parse date
					try {
						tmpDate = parseDateTime(thisPubDate);
						tmpDaysAgo = DateDiff("d",tmpDate,now());
						tmpHoursAgo = DateDiff("h",tmpDate,now());
						tmpMinsAgo = DateDiff("m",tmpDate,now());
							
						if(tmpDaysAgo gt 1) 
							thisPubDate = "<b>Posted on #lsDateFormat(tmpDate)# (" & tmpDaysAgo & " days ago)</b>";
						else if(tmpDaysAgo eq 1)
							thisPubDate = "<b>Posted yesterday.</b>";
						else {
							if(tmpHoursAgo gt 1)
								thisPubDate = "<b>Posted today (" & tmpHoursAgo & " hours ago)</b>";
							else if(tmpMinsAgo gt 0)
								thisPubDate = "<b>Posted today (<span style='color:red;'>" & tmpMinsAgo & " minutes ago</span>)</b>";
							else
								thisPubDate = "<b style='color:red;'>Posted today</b>";
						}
					} catch(any e) {
						// leave date as is 
					}				
				</cfscript>
				
				<p>
					<a href="#thisLink#" style="font-weight:bold;"><h2>#thisTitle#</h2></a> 
					<span style="font-size:9px;">#thisPubDate#</span>&nbsp;
	
					<div>
						<cfif thisContent neq "">
							#thisContent#
							<br style="clear:both;">
						</cfif>
						
						<div class="RSSReaderPostBar" style="padding:3px;margin-top:10px;">
							<!--- download enclosure --->
							<cfif thisEnclosure.url neq "">
								<img src="#imgRoot#/download-page-orange.gif" align="absmiddle" alt="Post to del.icio.us">
								<a href="#thisEnclosure.url#" target="_blank"><strong>Download</strong></a>&nbsp;|&nbsp;
							</cfif>
					
							<!--- post to delicious --->
							<img src="#imgRoot#/delicious.small.gif" align="absmiddle" alt="Post to del.icio.us">
							<a href="http://del.icio.us/post?url=#thisLink#" target="_blank"><strong>del.icio.us</strong></a>&nbsp;
							
							<!--- technorati links --->
							|&nbsp;<img src="#imgRoot#/technotag.gif" align="absmiddle" alt="Links">
							<a href="http://www.technorati.com/cosmos/links.html?url=#thisLink#" target="_blank"><strong>Links</strong></a> &nbsp;
					
							<!--- digg this! --->
							|&nbsp;<img src="#imgRoot#/16x16-digg-guy.gif" align="absmiddle" alt="Digg This!">
							<a href="http://digg.com/submit?phase=2&url=#URLEncodedFormat(thisLink)#" target="_blank"><strong>Digg This!</strong></a> &nbsp;
							
							<!--- link to item --->
							|&nbsp;&nbsp;&nbsp;<a href="#thisLink#" target="_blank"><strong>Read More...</strong></a>
						</div>
					</div><br>
	
				</p>
			</cfloop>
		<cfelse>
			#errMessage#
		</cfif>
		<cfif stUser.isOwner>
			<div id="#moduleID#_toolbar">
				<a href="javascript:#moduleID#.getView('config','',{useLayout:false});"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
				<a href="javascript:#moduleID#.getView('config','',{useLayout:false});">Change Feed URL</a>
			</div>
		</cfif>
	</cfoutput>
<cfelse>
	<cfoutput>
		<cfif stUser.isOwner>
			#this.controller.render(view = 'config', useLayout=false)#
		<cfelse>
			<em>No RSS feed has been set.</em>
		</cfif>
	</cfoutput>
</cfif>
