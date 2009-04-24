<cfparam name="arguments.rss" default="">
<cfparam name="arguments.link" default="">

<cfscript>
	thisLink = "";
	thisTitle = "no title";
	thisContent = "";
	thisPubDate = "";
	thisEnclosure = structNew();
	thisEnclosure.url = "";
	thisEnclosure.length = "";
	thisEnclosure.type = "";
	moduleID = this.controller.getModuleID();

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";

	// get reader service
	oRSSReaderService = createObject("component","homePortalsModules.components.RSSService").init();

	// get current rss/atom url
	rssURL = cfg.getPageSetting("rss");
	if(arguments.rss neq "") rssURL = arguments.rss;

	// get requested post
	if(rssURL eq "") throw("<em>No RSS provided.</em>");
	feed = oRSSReaderService.getRSS(rssURL);
	myFeedNode = oRSSReaderService.getRSSPost(rssURL, arguments.link);
		
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
			thisPubDate = " Posted on #lsDateFormat(tmpDate)# (" & tmpDaysAgo & " days ago) ";
		else if(tmpDaysAgo eq 1)
			thisPubDate = " Posted yesterday. ";
		else {
			if(tmpHoursAgo gt 1)
				thisPubDate = "Posted today (" & tmpHoursAgo & " hours ago)";
			else if(tmpMinsAgo gt 0)
				thisPubDate = "Posted today (<span style='color:red;'>" & tmpMinsAgo & " minutes ago</span>)";
			else
				thisPubDate = "<span style='color:red;'>Posted today</span>";
		}
	} catch(any e) {
		// leave date as is 
	}	
	
</cfscript>


<!--- Display Post --->
<cfoutput>
	<!--- Post header --->
	<table width="100%" class="RSSReaderPostBar" style="height:30px;" cellpadding="0" cellspacing="0" border="0">
		<tr valign="middle">
			<td>
				<div style="width:470px;overflow:hidden;margin:2px;font-size:12px;color:##ff6600;line-height:15px;height:30px;">
					#thisTitle#
				</div>
			</td>
			<td width="30">&nbsp;</td>
		</tr>
	</table>	

	<!--- Post Body --->
	<div class="RSSReaderPostContent">
		<!--- if content is empty, then just put the link --->
		<cfif thisContent neq "">
			<div style="margin:3px;">
				<div style="font-size:12px;font-weight:bold;color:##666;margin-bottom:8px;">
					From <a href="#feed.link#">#feed.title#</a><br><em>#thisPubDate#</em>
				</div>
				#thisContent#
			</div>
			<br style="clear:both;"><br>
		<cfelse>
			<br><p><a href="#thisLink#" target="_blank">#thisTitle#</a></p>
		</cfif>
	</div>	

	<!--- Post tools --->
	<table width="100%" class="RSSReaderPostBar" style="height:30px;" cellpadding="0" cellspacing="0" border="0">
		<tr valign="middle">
			<td>
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
			</td>
			<td align="right">
				<cfset postIndex = myFeedNode.xmlAttributes.postIndex>
				<cfset prevPostURL = myFeedNode.xmlAttributes.prevPostURL>
				<cfset nextPostURL = myFeedNode.xmlAttributes.nextPostURL>
				
				<cfif postIndex gt 1>
					<cfset tmpID = moduleID & "_feed" & (postIndex-1)>
					<a href="javascript:#moduleID#.viewContent('#tmpID#','#URLEncodedFormat(JSStringFormat(rssURL))#','#URLEncodedFormat(JSStringFormat(prevPostURL))#')"><img src="#imgRoot#/control_rewind_blue.png" border="0" /></a>
				</cfif>
				<cfif myFeedNode.xmlAttributes.postIndex lt myFeedNode.xmlAttributes.numPosts>
					<cfset tmpID = moduleID & "_feed" & (myFeedNode.xmlAttributes.postIndex+1)>
					<a href="javascript:#moduleID#.viewContent('#tmpID#','#URLEncodedFormat(JSStringFormat(rssURL))#','#URLEncodedFormat(JSStringFormat(nextPostURL))#')"><img src="#imgRoot#/control_fastforward_blue.png" border="0" /></a>
				</cfif>
			</td>
		</tr>
	</table>
	</div>
</cfoutput>






