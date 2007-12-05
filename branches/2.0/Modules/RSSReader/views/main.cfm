<cfparam name="arguments.rss" default="">

<cfscript>
	cfg = this.controller.getModuleConfigBean();
	rssURL = cfg.getPageSetting("rss");
	maxItems = cfg.getPageSetting("maxItems");
	
	bFeedReadOK = true;
	errMessage = "";

	// get the moduleID
	moduleID = this.controller.getModuleID();

	if(arguments.rss neq "") rssURL = arguments.rss;

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	

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
			<ul style="margin:0px; padding-left:10px;">
				<cfloop from="1" to="#intMaxItems#" index="i">
					<cfset thisLink = "">
					<cfset thisTitle = "no title">
					<cfset thisContent = "">
					<cfset thisPubDate = "">
					<cfset thisEnclosure = structNew()>
					<cfset thisEnclosure.url = "">
					<cfset thisEnclosure.length = "">
					<cfset thisEnclosure.type = "">
	
					<cfif StructKeyExists(feed.items[i],"link")> 
						<cfset thisLink = tostring(feed.items[i].link.xmlText)>
					</cfif>
					<cfif StructKeyExists(feed.items[i],"title")>
						<cfset thisTitle = tostring(feed.items[i].title.xmlText)>
					</cfif>
					<cfif StructKeyExists(feed.items[i],"content")>  <!--- atom --->
						<cfset thisContent = tostring(feed.items[i].content)>
					</cfif>
					<cfif thisContent eq "" and StructKeyExists(feed.items[i],"description")> <!--- rss --->
						<cfset thisContent = feed.items[i].description.xmlText>
					</cfif>
					<cfif StructKeyExists(feed.items[i],"pubDate")> <!--- rss --->
						<cfset thisPubDate = feed.items[i].pubDate.xmlText>
					</cfif>
					<cfif StructKeyExists(feed.items[i],"created")> <!--- atom --->
						<cfset thisPubDate = feed.items[i].created.xmlText>
					</cfif>
					<cfif StructKeyExists(feed.items[i],"enclosure")> <!--- rss --->
						<cfset tmpEncAttr = duplicate(feed.items[i].enclosure.xmlAttributes)>
						<cfparam name="tmpEncAttr.url" default="">
						<cfparam name="tmpEncAttr.length" default="">
						<cfparam name="tmpEncAttr.type" default="">
						<cfset thisEnclosure.url = tmpEncAttr.url>
						<cfset thisEnclosure.length = tmpEncAttr.length>
						<cfset thisEnclosure.type = tmpEncAttr.type>
					</cfif>						
					
					<cfset tmpID = "#moduleID#_feed#i#">
					<li>
						<cfset tmpLinkRead = "javascript:#moduleID#.viewContent('#tmpID#','#URLEncodedFormat(JSStringFormat(rssURL))#','#URLEncodedFormat(thisLink)#')"> 
						<a href="#tmpLinkRead#" id="#tmpID#Link" style="font-weight:bold;">#thisTitle#</a> 
						<cfif thisLink neq "">(<a href="#thisLink#" target="_blank">Link</a>)</cfif>
						<!----
						<div id="#tmpID#" style="display:none;border:1px solid ##cccccc;background-color:##EAEEED;padding:4px;margin-top:5px;">
							<cfif thisContent neq "">
								#thisContent#
								<br style="clear:both;"><br>
							</cfif>
							
							<!--- publish date --->
							<span style="font-size:9px;">#thisPubDate#</span>&nbsp;
							
							<!--- download enclosure --->
							<cfif thisEnclosure.url neq "">
								|&nbsp;<a href="#thisEnclosure.url#" target="_blank"><strong>Download</strong></a>&nbsp;
							</cfif>
							
							<cfif thisLink neq "">
								<!--- post to delicious --->
								|&nbsp;<a href="http://del.icio.us/post?url=#thisLink#" target="_blank"><strong>del.icio.us</strong></a>&nbsp;
								
								<!--- technorati links --->
								|&nbsp;<a href="http://www.technorati.com/cosmos/links.html?url=#thisLink#" target="_blank"><strong>Technorati Links</strong></a> &nbsp;
								
								<!--- link to item --->
								|&nbsp;<a href="#thisLink#" target="_blank"><strong>Read More...</strong></a>
							</cfif>
						</div><br>
						---->
					</li>
				</cfloop>
			</ul>
		<cfelse>
			#errMessage#
		</cfif>
	</cfoutput>
		
<cfelse>
	<cfoutput>
		Please use the configuration panel for this module to enter the URL of a valid RSS or Atom feed.
	</cfoutput>
</cfif>
