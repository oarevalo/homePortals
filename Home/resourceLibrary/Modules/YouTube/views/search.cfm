<cfparam name="term" default="">
<cfparam name="mode" default="">
<cfparam name="p" default="1">
<cftry>
<cfscript>
	cfg =  this.controller.getModuleConfigBean();
	moduleID = this.controller.getModuleID();
	aVideos = ArrayNew(1);
	errorMessage = "";

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";

	stUser = this.controller.getUserInfo();	
	onClickGotoURL = cfg.getPageSetting("onClickGotoURL",true);
	configMode = cfg.getPageSetting("mode","searchByTag");
	configTerm = cfg.getPageSetting("term","");
	
	if(term eq "") term = configTerm;	
	if(mode eq "") mode = configMode;	
	
	obj = getYouTubeService();
	
	// search videos
	try {
		switch(mode) {
			
			case "searchByUser":
				xmlResults = obj.searchByUser(term,p,5);
				break;
	
			case "listFeatured":
				xmlResults = obj.listFeatured();
				break;
	
			case "listPopular":
				xmlResults = obj.listPopular('all');
				break;
			
			default:
				xmlResults = obj.searchByTag(term,p,5);
		}
		aVideos = xmlSearch(xmlResults,"//video_list/video/");

	} catch(any e) {
		errorMessage = e.message;
	}
	
</cfscript>

<cfoutput>
	<cfif mode eq "searchByUser">
		<div style="background-color:##ebebeb;border:1px solid silver;padding:5px;">
			Search By User: <input type="text" name="term" value="#term#" id="yt_term">
			<input type="button" value="Go" onclick="#moduleID#.search({term:$('yt_term').value,mode:'#mode#'})">
		</div>
	<cfelseif mode eq "searchByTag">
		<div style="background-color:##ebebeb;border:1px solid silver;padding:5px;">
			Search By Tags: <input type="text" name="term" value="#term#" id="yt_term">
			<input type="button" value="Go" onclick="#moduleID#.search({term:$('yt_term').value,mode:'#mode#'})">
		</div>
	<cfelseif mode eq "listPopular">
		<b>Most Popular Videos</b>
	<cfelseif mode eq "listFeatured">
		<b>Featured Videos</b>
	</cfif>
	
	<div style="margin-top:10px;margin-bottom:10px;">
		<cfloop from="1" to="#arrayLen(aVideos)#" index="i">
			<cfset xmlNode = aVideos[i]>
			<cfset tmpHREF = "##">
			
			<cfif onClickGotoURL>
				<cfset tmpHREF = xmlNode.url.xmlText>
			</cfif>
			
			<div style="margin-bottom:2px;margin-top:2px;">
				<a href="#tmpHREF#" onclick="#moduleID#.raiseEvent('onSelectVideo',{videoID:'#xmlNode.id.xmlText#',url:'#xmlNode.url.xmlText#',text:'#jsstringFormat(xmlNode.title.xmlText)#'})">
					<img src="#xmlNode.thumbnail_url.xmlText#" alt="#xmlNode.title.xmlText#" 
						title="#xmlNode.title.xmlText#" 
						border="0" 
						style="float:left;border:1px solid black;"></a>
				<div style="margin-left:140px;font-size:11px;">
					<a style="color:##333;" href="#tmpHREF#"><b>#xmlNode.title.xmlText#</b></a><br>
					#left(xmlNode.description.xmlText,100)#<br>
					<div style="margin-top:3px;font-size:10px;color:##999;">
						<strong>From:</strong> <a href="javascript:#moduleID#.search({term:'#xmlNode.author.xmlText#',mode:'searchByUser'})">#xmlNode.author.xmlText#</a><br>
						<strong>Tags:</strong> 
						<cfloop list="#xmlNode.tags.xmlText#" index="tag" delimiters=" ">
							<a href="javascript:#moduleID#.search({term:'#tag#',mode:'searchByTag'})">#tag#</a>&nbsp;
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

	<cfif listFind("searchByTag,searchByUser",mode)>
		<div style="background-color:##ebebeb;border:1px solid silver;padding:5px;">
			<table width="100%">
				<tr>
					<cfif p gt 1>
						<td><a href="##" onclick="#moduleID#.search({term:'#term#',mode:'#mode#',p:#p-1#})"><strong>Previous Page</strong></a></td>
					</cfif>
					<td align="right"><a href="##" onclick="#moduleID#.search({term:'#term#',mode:'#mode#',p:#p+1#})"><strong>Next Page</strong></a></td>
				</tr>
			</table>
		</div><br>
	</cfif>

	<cfif stUser.isOwner>
		<div id="toolbar">
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
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>
