<cfparam name="arguments.rss" default="">
<cfparam name="arguments.refresh" default="false">
<!---
	RSSReaderFull
	
	This module uses the following css classes/ids, define them to style output
	.rssf_head : container for the header of the feed, this area contains the feed title and image
	.rssf_titleImage : container for the feed image (when provided by the feed)
	.rssf_body : container for the body of the feed. this area contain all the feed items
	.rssf_item : container for each item on the feed
	.rssf_itemTitle : the title of each feed item
	.rssf_itemDate : posting date for each feed title
	.rssf_itemContent : individual feed item content
	.rssf_itemFlares : container for the flares attached to each feed item
--->
<cfscript>
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	bFeedReadOK = true;
	errMessage = "";
	execMode = this.controller.getExecMode();	

	// reader settings
	rssURL = cfg.getPageSetting("rss");
	maxItems = cfg.getPageSetting("maxItems");
	displayMode = cfg.getPageSetting("displayMode","short");
	toggleItems = cfg.getPageSetting("toggleItems",false);
	
	// user info
	stUser = this.controller.getUserInfo();

	// this is to allow overriding of the page setting
	if(arguments.rss neq "") rssURL = arguments.rss;

	// get images path
	imgRoot = tmpModulePath & "/images";
	
	// get reader service
	oRSSReaderService = this.controller.getAPIObject("RSSService").init();

	// check that the feed refresh argument is boolean
	if(not isBoolean(arguments.refresh)) arguments.refresh = false;

	if(rssURL neq "") {
		feed = StructNew();
		intMaxItems = 99;
		addFeedURL = "";
		
		// read feed
		try {
			feed = oRSSReaderService.getRSS(rssURL, arguments.refresh);

			// check for max items to display
			if(IsNumeric(maxItems)) {
				intMaxItems = Min(maxItems, ArrayLen(feed.items));
			} else {
				intMaxItems = ArrayLen(feed.items);
			}
			
			bFeedReadOK = true;

			addFeedURL = "http://www.addthis.com/feed.php?pub=MP9C8OPCXUDPD6S1&h1=" & urlEncodedFormat(rssURL) & "&t1=";
			
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
				<div class="rssf_head">
					<div class="rssf_titleImage">
						<a href="#feed.Image.Link#"><img src="#feed.Image.URL#" border="0" title="#feed.Image.Title#" alt="#feed.Image.Title#" /></a>
					</div>
				</div>
			</cfif>
	
			<div class="rssf_body">
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
					
					
					// setup toggle/view content (when viewmode is short)
					tmpID = "#moduleID#_feed#i#";
					if(toggleItems) {
						tmpLink = thisLink;
						tmpOnClick = "Element.toggle('#tmpID#');return false;";
					} else {
						tmpLink = "javascript:#moduleID#.viewContent('#tmpID#','#URLEncodedFormat(JSStringFormat(rssURL))#','#URLEncodedFormat(thisLink)#');";
						tmpOnClick = "";
					}
				</cfscript>

				<cfif displayMode eq "long">
				
					<div class="rssf_item">
						<div class="rssf_itemTitle">
							<a href="#thisLink#">#thisTitle#</a> 
						</div>
						<div class="rssf_itemDate">
							#thisPubDate#
						</div>
						<cfif thisContent neq "">
							<div class="rssf_itemContent">
								#thisContent#
								<br style="clear:both;">
							</div>
						</cfif>
							
						<div class="rssf_itemFlares">
							<!--- download enclosure --->
							<cfif thisEnclosure.url neq "">
								<img src="#imgRoot#/download-page-orange.gif" align="absmiddle" alt="Download attachment">
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
	
							<!--- email item --->
							|&nbsp;<img src="#imgRoot#/email.png" align="absmiddle" alt="Email article">
							<a href="mailto:?subject=#thisLink#"><strong>Email article</strong></a> &nbsp;
							
							<!--- link to item --->
							|&nbsp;&nbsp;&nbsp;<a href="#thisLink#" target="_blank"><strong>Read More...</strong></a>
						</div>
					</div>
				
				<cfelse>
				
					<div class="rss_item">
						<div class="rss_itemTitle">
							<a href="#tmpLink#" onclick="#tmpOnClick#" id="#tmpID#Link">&raquo; #thisTitle#</a> 
							<cfif thisLink neq "">(<a href="#thisLink#" target="_blank">Link</a>)</cfif>
						</div>
						<cfif toggleItems>
							<div id="#tmpID#" class="rss_itemToggledContent" style="display:none;">
								<!--- publish date --->
								<div class="rss_itemDate">#thisPubDate#</div>
	
								<cfif thisContent neq "">
									<div class="rss_itemContent">
										#thisContent#
										<br style="clear:both;">
									</div>
								</cfif>
	
								<div class="rss_itemFlares">
	
									<!--- download enclosure --->
									<cfif thisEnclosure.url neq "">
										<img src="#imgRoot#/download-page-orange.gif" align="absmiddle" alt="Download attachment">
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
							</div>
						</cfif>
					</div>
				
				</cfif>
			</cfloop>
			</div>

			<cfif addFeedURL neq "">
				<p>
					<!--- addthis.com --->
					<cfif addFeedURL neq "">
						<a href="##" onclick="window.open('#addFeedURL#','addThis','width=620,height=650,scrollbars=1')" title="Subscribe using any feed reader!"><img src="http://s9.addthis.com/button1-fd.gif" width="125" height="16" border="0" alt="AddThis Feed Button" /></a>
					</cfif>

				</p>
			</cfif>
			
			<!--- Check if the url has a favicon for the domain --->
			<cfset tmpFavIconURL = "">
			<cfset tmpURL = "http://" & listGetAt(URLDecode(rssURL),2,"/") & "/favicon.ico">
			<cfhttp method="get" url="#tmpURL#" timeout="5" throwonerror="no"></cfhttp>
			<cfif cfhttp.statusCode eq "200 OK">
				<cfset tmpFavIconURL = tmpURL>
			</cfif>
			
			<script>
				#moduleID#.setTitle("#jsstringformat(feed.title)#");
				<cfif tmpFavIconURL neq "">
					#moduleID#.setIcon("#tmpFavIconURL#");
				</cfif>
				<cfif execMode eq "local">
					#moduleID#.attachIcon("#imgRoot#/refresh.gif","#moduleID#.getView('','',{rss:'#rssURL#',useLayout:false,refresh:true})","Refresh content");
					#moduleID#.attachIcon("#imgRoot#/feed-icon16x16.gif","window.open('#rssURL#')","View feed source");
				</cfif>
			</script>
			
		<cfelse>
			<div class="rssf_body">
				<div class="rssf_item">
					#errMessage#
				</div>
			</div>
		</cfif>
		<cfif stUser.isOwner>
			<div class="SectionToolbar">
				<a href="javascript:#moduleID#.getView('config','',{useLayout:false});"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
				<a href="javascript:#moduleID#.getView('config','',{useLayout:false});">Settings</a>
				<a href="javascript:#moduleID#.getPopupView('directory');"><img src="#imgRoot#/page_white_text.png" border="0" align="absmiddle"></a>
				<a href="javascript:#moduleID#.getPopupView('directory');">Feed Directory</a>&nbsp;&nbsp;
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








