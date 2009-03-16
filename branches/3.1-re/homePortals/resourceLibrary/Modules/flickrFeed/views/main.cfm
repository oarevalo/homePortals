<cfparam name="arguments.userid" default="">
<cfparam name="arguments.tags" default="">
<cfparam name="arguments.username" default="">

<cfscript>
	cfg = this.controller.getModuleConfigBean();
	moduleID = this.controller.getModuleID();
	args = structNew();
	stUser = this.controller.getUserInfo();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
	bFailed = false;
	errorMessage = "";
	tmpURL = "http://api.flickr.com/services/feeds/photos_public.gne?format=rss2";
	tmpTitle = "Flickr:&nbsp;&nbsp;";
	execMode = this.controller.getExecMode();	
	
	try {
		// get settings
		args.showHeader = cfg.getPageSetting("showheader");
		args.onClickGotoFlickr = cfg.getPageSetting("onClickGotoFlickr");
		args.UserID = cfg.getPageSetting("userid");
		args.Tags = cfg.getPageSetting("tags");
		args.username = cfg.getPageSetting("username");
		args.maxItems = cfg.getPageSetting("maxItems",0);
		
		if(arguments.userID neq "") args.UserID = arguments.userID;
		if(arguments.tags neq "") args.Tags = arguments.tags;
		if(arguments.username neq "") args.username = arguments.username;
		if(args.showHeader eq "" or not IsBoolean(args.showHeader)) args.showHeader = true;
		if(args.onClickGotoFlickr eq "" or not IsBoolean(args.onClickGotoFlickr)) args.onClickGotoFlickr = false;
	
		// if we have a username then get the userID from flickr
		if(args.username neq "")
			args.userID = getUserID(args.username);

		// Prepare feed url 
		if(args.UserID neq "") {
			tmpURL = ListAppend(tmpURL, "id=" & args.UserID, "&");
			tmpTitle = tmpTitle & args.UserID & " ";
		}
		if(args.Tags neq "") {
			tmpURL = ListAppend(tmpURL, "tags=" & args.Tags, "&");
			tmpTitle = tmpTitle & args.Tags & " ";
		}
	
	
		// get and parse feed	
		oRSSReaderService = this.controller.getAPIObject("RSSService").init();
		feed = oRSSReaderService.getRSS(tmpURL);
		
		// if no number of maxItems has been given, then show all on the feed 
		if(val(args.maxItems) eq 0) args.maxItems = ArrayLen(feed.items);

		// set default title
		if(args.tags eq "" and args.userID eq "")
			tmpTitle = tmpTitle & feed.Title;

	} catch(any e) {
		bFailed = true;
		errorMessage = e.message & "<br>" & e.detail;
	}
</cfscript>

<cftry>
<!--- display images --->
<cfoutput>
	<cfif not bFailed>

		<cfif args.showHeader>
			<div style="border-bottom:1px solid ##ebebeb;margin-bottom:10px;">
				<a href="#feed.Image.Link#">
					<img src="#feed.Image.URL#" border="1" id="RSS_Image" 
							title="#feed.Image.Title#" align="absmiddle" 
							alt="#feed.Image.Title#" style="margin:3px;margin-right:10px;margin-bottom:10px;" /></a>
				<a href="#feed.Link#" target="_blank" id="RSS_Title" 
					style="font-weight:bold;font-size:18px;font-family:arial,helvetica,sans-serif;">#feed.Title#</a><br>
			</div>
		</cfif>
	
		<p align="center" style="margin:0px;">
			<cfloop from="1" to="#min(ArrayLen(feed.items),args.maxItems)#" index="i">
				<cfset thisTitle = feed.items[i].title.xmlText>
				<cfset thisContent = feed.items[i].description.xmlText>
				<cfset thisImg = feed.items[i]["media:thumbnail"]>
				<cfset thisImgBig = feed.items[i]["media:content"]>
				
				<cfif args.onClickGotoFlickr>
					<cfset thisLink = feed.items[i].link.xmlText>
				<cfelse>
					<cfset thisLink = thisImgBig.xmlAttributes.url>
				</cfif>
				
				<a href="#thisLink#" target="_blank">
					<img src="#thisImg.xmlAttributes.url#" border="0"
							height="#thisImg.xmlAttributes.height#" 
							width="#thisImg.xmlAttributes.width#"
							title="#thisTitle#" alt="#thisTitle#"
							style="border:1px solid black;margin:3px;">
				</a>
			</cfloop>
		</p>
		<cfif ArrayLen(feed.items) eq 0>
			<b>No Images Found.</b>
		</cfif>

		<!--- set module title --->
		<script>
			#moduleID#.setTitle("#jsstringformat(tmpTitle)#");
			#moduleID#.setIcon("http://www.flickr.com/favicon.ico");
			<cfif execMode eq "local">
				#moduleID#.attachIcon("#imgRoot#/feed-icon16x16.gif","window.open('#tmpURL#')","RSS Feed");
			</cfif>
		</script>
		
		<br>
	<cfelse>
		<b>Error:</b> #errorMessage#
	</cfif>

	<cfif stUser.isOwner>
		<div class="SectionToolbar">
			<a href="javascript:#moduleID#.getView('config');"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
			<a href="javascript:#moduleID#.getView('config');">Settings</a>
		</div>	
	</cfif>
	
</cfoutput>

<cfcatch type="any">
<cfdump var="#cfcatch#">
</cfcatch>
</cftry>	
