<cfparam name="term" default="">
<cfparam name="mode" default="">
<cfparam name="p" default="1">
<cftry>
<cfscript>
	cfg =  this.controller.getModuleConfigBean();
	moduleID = this.controller.getModuleID();
	aVideos = ArrayNew(1);
	errorMessage = "";
	xmlResults = xmlNew();

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";

	stUser = this.controller.getUserInfo();	
	onClickGotoURL = cfg.getPageSetting("onClickGotoURL",true);
	configMode = cfg.getPageSetting("mode","listFeatured");
	configTerm = cfg.getPageSetting("term","");
	videosPerPage = cfg.getPageSetting("videosPerPage",5);
	
	if(term eq "") term = configTerm;	
	if(mode eq "") mode = configMode;	
	
	obj = getYouTubeService();
	
	// search videos
	try {
		switch(mode) {
			
			case "searchByTag":
				xmlResults = obj.searchByTag(term,p,videosPerPage);
				aVideos = xmlSearch(xmlResults,"//:entry");
				break;

			case "searchByUser":
				xmlResults = obj.searchByUser(term,p,videosPerPage);
				aVideos = xmlSearch(xmlResults,"//:entry");
				break;
	
			case "listFeatured":
				xmlResults = obj.list("recently_featured","",p,videosPerPage);
				aVideos = xmlSearch(xmlResults,"//:entry");
				break;
	
			case "listPopular":
				xmlResults = obj.list("most_popular","",p,videosPerPage);
				aVideos = xmlSearch(xmlResults,"//:entry");
				break;
			
			default:
				mode = "search";
				if(term neq "") {
					xmlResults = obj.search(term,p,videosPerPage);
					aVideos = xmlSearch(xmlResults,"//:entry");
				}
		}

	} catch(any e) {
		errorMessage = e.message;
	}
</cfscript>

<cfoutput>
	<div style="background-color:##ebebeb;border:1px solid silver;padding:5px;">
		Search: <input type="text" name="term" value="#term#" id="yt_term">
		<input type="button" value="Go" onclick="#moduleID#.search({term:$('yt_term').value,mode:'search'})">
		<br />
		<a href="##" onclick="#moduleID#.search({mode:'listFeatured'})" <cfif mode eq "listFeatured">style="font-weight:bold;"</cfif>>Featured Videos</a>
		&nbsp;|&nbsp;
		<a href="##" onclick="#moduleID#.search({mode:'listPopular'})" <cfif mode eq "listPopular">style="font-weight:bold;"</cfif>>Most Popular</a>
	</div>

	<div style="margin-top:10px;margin-bottom:10px;">
		<cfloop from="1" to="#arrayLen(aVideos)#" index="i">
			<cfset xmlNode = aVideos[i]>

			<cfset entry.id = listLast(xmlNode.id.xmlText,"/") />
			<cfset entry.title = HTMLSafe(xmlNode.title.xmlText) />
			<cfset entry.description = HTMLSafe(xmlNode.content.xmlText)  />
			<cfset entry.href = "##" />
			<cfset entry.clickhref = "##">
			<cfset entry.viewhref = "##" />
			<cfset entry.tags = arrayNew(1) />
			<cfset entry.author = xmlNode.author.name.xmlText />
			<cfset entry.authorURL = xmlNode.author.uri.xmlText />
			<cfset entry.thumbnail = "">
	
			<cfloop array="#xmlNode.xmlChildren#" index="tmp">
				<cfswitch expression="#tmp.xmlName#">
					<cfcase value="link">
						<cfif tmp.xmlAttributes.rel eq "alternate">
							<cfset entry.viewhref = tmp.xmlAttributes.href />
						</cfif>
						<cfif tmp.xmlAttributes.rel eq "self">
							<cfset entry.href = tmp.xmlAttributes.href />
						</cfif>
					</cfcase>
					<cfcase value="category">
						<cfif left(tmp.xmlAttributes.term,7) neq "http://">
							<cfset arrayAppend(entry.tags,tmp.xmlAttributes.term) />
						</cfif>
					</cfcase>
					<cfcase value="media:group">
						<cfloop array="#tmp.xmlChildren#" index="tmp2">
							<cfif tmp2.xmlName eq "media:thumbnail">
								<cfset entry.thumbnail = tmp2.xmlAttributes.url />
								<cfbreak>
							</cfif>
						</cfloop>
					</cfcase>
				</cfswitch>
			</cfloop>

			<cfif onClickGotoURL>
				<cfset entry.clickhref = entry.viewhref />
			</cfif>

			<cfset onclick = "#moduleID#.raiseEvent('onSelectVideo',{videoID:'#entry.id#',url:'#entry.viewhref#',text:'#jsStringFormat(entry.title)#'})">

			<div style="margin-bottom:2px;margin-top:2px;">
				<a href="#entry.clickhref#" onclick="#onclick#">
					<img src="#entry.thumbnail#" 
						alt="#entry.title#" 
						title="#entry.title#"
						border="0" 
						style="float:left;border:1px solid black;width:120px;"></a>
				<div style="margin-left:140px;font-size:11px;">
					<a style="color:##333;" href="#entry.clickhref#" onclick="#onclick#"><b>#entry.title#</b></a><br>
					#left(entry.description,100)#<br>
					<div style="margin-top:3px;font-size:10px;color:##999;">
						<strong>From:</strong> <a href="javascript:#moduleID#.search({term:'#entry.author#',mode:'searchByUser'})"
													alt="Search videos uploaded by '#entry.author#'"
													title="Search videos uploaded by '#entry.author#'">#entry.author#</a><br>
						<strong>Tags:</strong> 
						<cfloop array="#entry.tags#" index="tmp">
							<a href="javascript:#moduleID#.search({term:'#jsStringFormat(tmp)#',mode:'searchByTag'})"
								alt="Search videos tagged '#htmlEditFormat(tmp)#'"
								title="Search videos tagged '#htmlEditFormat(tmp)#'">#tmp#</a>&nbsp;
						</cfloop>
					</div>
				</div>
			</div>
			<br style="clear:both;" />
		</cfloop>
		<cfif errorMessage neq "">
			<b>#errorMessage#</b>
		<cfelseif arrayLen(aVideos) eq 0>
			<b>No videos found!</b>
		</cfif>
	</div>


	<div style="background-color:##ebebeb;border:1px solid silver;padding:5px;">
		<table width="100%">
			<tr>
				<cfif p gt 1>
					<td><a href="##" onclick="#moduleID#.search({term:'#jsStringFormat(term)#',mode:'#mode#',p:#p-1#})"><strong>Previous Page</strong></a></td>
				</cfif>
				<cfif arrayLen(aVideos) gt 0>
					<td align="right"><a href="##" onclick="#moduleID#.search({term:'#jsStringFormat(term)#',mode:'#mode#',p:#p+1#})"><strong>Next Page</strong></a></td>
				</cfif>
			</tr>
		</table>
	</div><br>

	<!--- set module icon --->
	<script type="text/javascript">
		#moduleID#.setIcon("http://www.youtube.com/favicon.ico");
	</script>

	<cfif stUser.isOwner>
		<div class="SectionToolbar">
			<a href="javascript:#moduleID#.getView('configSearch');"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
			<a href="javascript:#moduleID#.getView('configSearch');">Change Settings</a>
		</div>
	</cfif>		
		
	<cfsavecontent variable="tmpHead">
		<script>
			#moduleID#.search = function(args) {
				if(!args.term || args.term==undefined) args.term="";
				if(!args.mode || args.mode==undefined) args.mode="";
				if(!args.page || args.page==undefined) args.page=1;
				this.getView('', '', args)
			}
		</script>
	</cfsavecontent>
	<cfhtmlhead text="#tmpHead#">
</cfoutput>
	<cfcatch type="any">
		<cfoutput>#cfcatch.Message#
		<cfdump var="#cfcatch#"></cfoutput>
	</cfcatch>
</cftry>

<cfscript>
/**
 * Coverts special characters to character entities, making a string safe for display in HTML.
 * Version 2 update by Eli Dickinson (eli.dickinson@gmail.com)
 * Fixes issue of lists not being equal and adding bull
 * v3, extra semicolons
 * 
 * @param string 	 String to format. (Required)
 * @return Returns a string. 
 * @author Gyrus (eli.dickinson@gmail.comgyrus@norlonto.net) 
 * @version 3, August 30, 2006 
 */
function HTMLSafe(string) {
	// Initialise
	var badChars = "&,"",#Chr(161)#,#Chr(162)#,#Chr(163)#,#Chr(164)#,#Chr(165)#,#Chr(166)#,#Chr(167)#,#Chr(168)#,#Chr(169)#,#Chr(170)#,#Chr(171)#,#Chr(172)#,#Chr(173)#,#Chr(174)#,#Chr(175)#,#Chr(176)#,#Chr(177)#,#Chr(178)#,#Chr(179)#,#Chr(180)#,#Chr(181)#,#Chr(182)#,#Chr(183)#,#Chr(184)#,#Chr(185)#,#Chr(186)#,#Chr(187)#,#Chr(188)#,#Chr(189)#,#Chr(190)#,#Chr(191)#,#Chr(215)#,#Chr(247)#,#Chr(192)#,#Chr(193)#,#Chr(194)#,#Chr(195)#,#Chr(196)#,#Chr(197)#,#Chr(198)#,#Chr(199)#,#Chr(200)#,#Chr(201)#,#Chr(202)#,#Chr(203)#,#Chr(204)#,#Chr(205)#,#Chr(206)#,#Chr(207)#,#Chr(208)#,#Chr(209)#,#Chr(210)#,#Chr(211)#,#Chr(212)#,#Chr(213)#,#Chr(214)#,#Chr(216)#,#Chr(217)#,#Chr(218)#,#Chr(219)#,#Chr(220)#,#Chr(221)#,#Chr(222)#,#Chr(223)#,#Chr(224)#,#Chr(225)#,#Chr(226)#,#Chr(227)#,#Chr(228)#,#Chr(229)#,#Chr(230)#,#Chr(231)#,#Chr(232)#,#Chr(233)#,#Chr(234)#,#Chr(235)#,#Chr(236)#,#Chr(237)#,#Chr(238)#,#Chr(239)#,#Chr(240)#,#Chr(241)#,#Chr(242)#,#Chr(243)#,#Chr(244)#,#Chr(245)#,#Chr(246)#,#Chr(248)#,#Chr(249)#,#Chr(250)#,#Chr(251)#,#Chr(252)#,#Chr(253)#,#Chr(254)#,#Chr(255)#";
	var goodChars = "&amp;,&quot;,&iexcl;,&cent;,&pound;,&curren;,&yen;,&brvbar;,&sect;,&uml;,&copy;,&ordf;,&laquo;,&not;,&shy;,&reg;,&macr;,&deg;,&plusmn;,²,³,&acute;,&micro;,&para;,&middot;,&cedil;,¹,&ordm;,&raquo;,¼,½,¾,&iquest;,&times;,&divide;,&Agrave;,&Aacute;,&Acirc;,&Atilde;,&Auml;,&Aring;,&AElig;,&Ccedil;,&Egrave;,&Eacute;,&Ecirc;,&Euml;,&Igrave;,&Iacute;,&Icirc;,&Iuml;,&ETH;,&Ntilde;,&Ograve;,&Oacute;,&Ocirc;,&Otilde;,&Ouml;,&Oslash;,&Ugrave;,&Uacute;,&Ucirc;,&Uuml;,&Yacute;,&THORN;,&szlig;,&agrave;,&aacute;,&acirc;,&atilde;,&auml;,&aring;,&aelig;,&ccedil;,&egrave;,&eacute;,&ecirc;,&euml;,&igrave;,&iacute;,&icirc;,&iuml;,&eth;,&ntilde;,&ograve;,&oacute;,&ocirc;,&otilde;,&ouml;,&oslash;,&ugrave;,&uacute;,&ucirc;,&uuml;,&yacute;,&thorn;,&yuml;,&##338;,&##339;,&##352;,&##353;,&##376;,&##710;,&##8211;,&##8212;,&##8216;,&##8217;,&##8218;,&##8220;,&##8221;,&##8222;,&##8224;,&##8225;,&##8240;,&##8249;,&##8250;,&##8364;,<sup><small>TM</small></sup>,&bull;";

	if (Val(Left(Server.ColdFusion.ProductVersion, 1)) LT 6) {
		// Pre-MX/Unicode matches
		badChars = "#badChars#,#Chr(140)#,#Chr(156)#,#Chr(138)#,#Chr(154)#,#Chr(159)#,#Chr(136)#,#Chr(150)#,#Chr(151)#,#Chr(145)#,#Chr(146)#,#Chr(130)#,#Chr(147)#,#Chr(148)#,#Chr(132)#,#Chr(134)#,#Chr(135)#,#Chr(137)#,#Chr(139)#,#Chr(155)#,#Chr(128)#,#Chr(153)#,#Chr(149)#";
	} else {
		// MX/Unicode matches
		badChars = "#badChars#,#Chr(338)#,#Chr(339)#,#Chr(352)#,#Chr(353)#,#Chr(376)#,#Chr(710)#,#Chr(8211)#,#Chr(8212)#,#Chr(8216)#,#Chr(8217)#,#Chr(8218)#,#Chr(8220)#,#Chr(8221)#,#Chr(8222)#,#Chr(8224)#,#Chr(8225)#,#Chr(8240)#,#Chr(8249)#,#Chr(8250)#,#Chr(8364)#,#Chr(8482)#,#Chr(8226)#";
	}

	// Return immediately if blank string
	if (NOT Len(Trim(string))) return string;
	
	// Do replacing
	return ReplaceList(string, badChars, goodChars);

}
</cfscript>
