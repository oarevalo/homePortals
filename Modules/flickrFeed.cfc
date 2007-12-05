<!--- FlickrFeed.cfm

This module displays pictures from a flickr feed

version: 1.1

3/21/06 - oarevalo - added error handling
--->
<cfcomponent displayname="flickrFeed" extends="Home.Components.baseModule">

	<cfset variables.moduleName = "flickrFeed">

<cffunction name="renderView" returntype="string">

	<!--- Init variables and Params --->
	<cfset args = structNew()>
	<cfset args.userID = getPageSetting("userID")>
	<cfset args.useridlist = getPageSetting("useridlist")>
	<cfset args.tags = getPageSetting("tags")>
	<cfset args.showHeader = getPageSetting("showHeader")>
	<cfset args.onClickGotoFlickr = getPageSetting("onClickGotoFlickr")>

	<!---- Prepare feed url --->
	<cfset tmpURL = "http://www.flickr.com/services/feeds/photos_public.gne?format=rss2">
	<cfif args.userid neq "">
		<cfset tmpURL = ListAppend(tmpURL, "id=" & args.userid, "&")>
	</cfif>
	<cfif args.useridlist neq "">
		<cfset tmpURL = ListAppend(tmpURL, "ids=" & args.useridlist, "&")>
	</cfif>
	<cfif args.tags neq "">
		<cfset tmpURL = ListAppend(tmpURL, "tags=" & args.tags, "&")>
	</cfif>
	
	
	
	<!--- get feed --->
	<cfhttp method="get" url="#tmpURL#" resolveurl="yes" redirect="yes"></cfhttp>
		
	<cfif Not IsXML(cfhttp.FileContent)>
		<cfthrow message="An error ocurred while contacting the Flickr website.<br><br>Flickr URL:#tmpURL#" type="custom">
	</cfif>
	
		
	<!--- parse feed --->
	<cfscript>
		xmlDoc = XMLParse(cfhttp.FileContent);
		feed = StructNew();
		feed.title = "";
		feed.link = "";
		feed.description = "";
		feed.date = "";
		feed.image = StructNew();
		feed.image.url = "";
		feed.image.title = "";
		feed.image.link = "##";
		feed.items = ArrayNew(1);
		
		if(StructKeyExists(xmlDoc.xmlRoot.channel,"item")) feed.items = xmlDoc.xmlRoot.channel.item;
		if(StructKeyExists(xmlDoc.xmlRoot.channel,"title")) feed.Title = xmlDoc.xmlRoot.channel.title.xmlText;
		if(StructKeyExists(xmlDoc.xmlRoot.channel,"link")) feed.Link = xmlDoc.xmlRoot.channel.link.xmlText;
		if(StructKeyExists(xmlDoc.xmlRoot.channel,"description")) feed.Description = xmlDoc.xmlRoot.channel.description.xmlText;
		if(StructKeyExists(xmlDoc.xmlRoot.channel,"lastBuildDate")) feed.Date = xmlDoc.xmlRoot.channel.lastBuildDate.xmlText;
		if(StructKeyExists(xmlDoc.xmlRoot.channel,"image")) {
			if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"url")) feed.Image.URL = xmlDoc.xmlRoot.channel.image.url.xmlText;
			if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"title")) feed.Image.Title = xmlDoc.xmlRoot.channel.image.title.xmlText;
			if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"link")) feed.Image.Link = xmlDoc.xmlRoot.channel.image.link.xmlText;
		}
		
		if(args.showHeader eq "" or not IsBoolean(args.showHeader))
			args.showHeader = true;
			
		if(args.onClickGotoFlickr eq "" or not IsBoolean(args.onClickGotoFlickr))
			args.onClickGotoFlickr = false;
	</cfscript>
	
	
	<!--- display images --->
	<cfsavecontent variable="tmpHTML">
		<cfoutput>
			<cfif args.showHeader>
				<div>
					<a href="#feed.Image.Link#">
						<img src="#feed.Image.URL#" border="1" id="RSS_Image" 
								title="#feed.Image.Title#" align="left" 
								alt="#feed.Image.Title#" /></a>
					<div>
						<a href="#feed.Link#" target="_blank" id="RSS_Title" style="font-weight:bold;font-size:18px;font-family:arial,helvetica,sans-serif;">#feed.Title#</a>
					</div>
					<br style="clear:both;" />
				</div>
			</cfif>
			
			<cfloop from="1" to="#ArrayLen(feed.items)#" index="i">
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
			<cfif ArrayLen(feed.items) eq 0>
				<b>No Images Found.</b>
			</cfif>
			<br>
			<a href="#tmpURL#" target="_blank"><img src="Modules/RSSReader/xml.gif" alt="View Feed XML" border="0" align="absmiddle"></a>&nbsp;
		</cfoutput>
	</cfsavecontent>



<cfreturn tmpHTML>
</cffunction>

</cfcomponent>