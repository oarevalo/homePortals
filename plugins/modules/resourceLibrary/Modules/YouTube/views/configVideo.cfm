<cfparam name="term" default="">
<cfparam name="mode" default="">
<cfparam name="page" default="1">

<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	errorMessage = "";
	
	// get default settings
	videoID = cfg.getPageSetting("videoID","");
	width = cfg.getPageSetting("width","425");
	height = cfg.getPageSetting("height","350");
	autoplay = cfg.getPageSetting("autoplay","0");

	// get current user info
	stUser = this.controller.getUserInfo();

	// get reference to youTube service
	obj = getYouTubeService();

	if(mode eq "") mode = "searchByTag";

	// search videos
	try {
		switch(mode) {

			case "searchByID":
				xmlResults = obj.getDetails(term);
				break;
			
			case "searchByUser":
				xmlResults = obj.searchByUser(term,page,3);
				break;
	
			default:
				xmlResults = obj.searchByTag(term,page,3);
		}
		aVideos = xmlSearch(xmlResults,"//video_list/video/");

	} catch(any e) {
		errorMessage = e.message;
	}
	
 	// make sure only owner can make changes 
	if(Not stUser.isOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";
</cfscript>

<cfoutput>
		<a href="http://www.youtube.com"><img src="http://www.youtube.com/img/pic_youtubelogo_123x63.gif" align="left" border="0" style="margin-left:10px;"></a>
		<div style="text-align:center;padding-top:10px;">
			<form name="frmYTV_Settings" action="##" method="post" style="margin:0px;padding:0px;">
				<cfif Not stUser.isOwner>
					<div style="font-weight:bold;color:red;">Only the owner of this page can make changes.</div><br>
				</cfif>
				Search: <input type="text" name="term" value="#term#" id="ytv_term">
				<input type="button" value="Go" onclick="#moduleID#.doSearch(this.form)"><br>
				<input type="radio" name="mode" value="searchByUser" <cfif mode eq "searchByUser">checked</cfif>> Users &nbsp;
				<input type="radio" name="mode" value="searchByTag" <cfif mode eq "searchByTag">checked</cfif>> Tags &nbsp;
				<input type="radio" name="mode" value="searchByID" <cfif mode eq "searchByID">checked</cfif>> ID 
			</form>
		</div>
		<br style="clear:both;" />
		<div style="background-color:##ebebeb;border:1px solid silver;padding:5px;margin-top:5px;font-size:10px;">
			<form name="frmYTV_Size" action="##" method="post" style="margin:0px;padding:0px;">
				<b>Video Size:</b> &nbsp;&nbsp;
				Width: <input type="text" name="width" value="#width#" style="width:50px;font-size:11px;" />&nbsp;&nbsp;
				Height: <input type="text" name="height" value="#height#" style="width:50px;font-size:11px;" />
				&nbsp;&nbsp;&nbsp;&nbsp;
				<b>Autoplay?</b>
				<input type="checkbox" name="autoplay" value="1" <cfif isBoolean(autoplay) and autoplay>checked</cfif>>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="button" value="Apply" onclick="#moduleID#.doFormAction('saveSize',this.form)">
			</form>
		</div>
		<div style="width:500px;height:368px;overflow:auto;">
			
			<div style="margin-top:20px;margin-bottom:10px;">
				<cfloop from="1" to="#arrayLen(aVideos)#" index="i">
					<cfset xmlNode = aVideos[i]>

					<div style="margin-bottom:10px;margin-top:2px;">
						<a href="##" onclick="#moduleID#.doAction('saveSettings',{videoID:'#xmlNode.id.xmlText#'});#moduleID#.closeWindow()">
							<img src="#xmlNode.thumbnail_url.xmlText#" alt="#xmlNode.title.xmlText#" 
								title="#xmlNode.title.xmlText#" 
								border="0" 
								style="float:left;border:1px solid black;"></a>

						<div style="margin-left:140px;font-size:11px;">
							<div style="color:##333;font-weight:bold;">#xmlNode.title.xmlText#</div>
							#left(xmlNode.description.xmlText,100)#<br>
							<div style="margin-top:3px;font-size:10px;color:##999;">
								<strong>From:</strong> <a href="javascript:#moduleID#.search({term:'#xmlNode.author.xmlText#',mode:'searchByUser'})">#xmlNode.author.xmlText#</a><br>
								<strong>Tags:</strong> 
								<cfloop list="#xmlNode.tags.xmlText#" index="tag" delimiters=" ">
									<a href="javascript:#moduleID#.search({term:'#tag#',mode:'searchByTag'})">#tag#</a>&nbsp;
								</cfloop>
							</div>
							<div style="margin-top:3px;">
								<a href="##" onclick="#moduleID#.doAction('saveSettings',{videoID:'#xmlNode.id.xmlText#'});#moduleID#.closeWindow()"><b>Select This Video</b></a>
							</div>
						</div>
					</div>
					<br style="clear:both;" />
				</cfloop>
				<cfif errorMessage neq "">
					<b>#errorMessage#</b>
				<cfelseif arrayLen(aVideos) eq 0>
					<cfif term neq "">
						<p align="center"><b>No videos found!</b></p>
					</cfif>
				</cfif>
			</div>
		</div>

		<cfif arrayLen(aVideos) gt 0>
			<div style="background-color:##ebebeb;border:1px solid silver;padding:5px;">
				<table width="100%" cellpadding="0" cellspacing="0">
					<tr>
						<cfif page gt 1>
							<td><a href="##" onclick="#moduleID#.search({term:'#term#',mode:'#mode#',page:#page-1#})"><strong>Previous Page</strong></a></td>
						</cfif>
						<td align="right"><a href="##" onclick="#moduleID#.search({term:'#term#',mode:'#mode#',page:#page+1#})"><strong>Next Page</strong></a></td>
					</tr>
				</table>
			</div>
		</cfif>
		
		<cfsavecontent variable="tmpHead">
			<script>
				#moduleID#.search = function(args) {
					if(!args.term || args.term==undefined) args.term="";
					if(!args.mode || args.mode==undefined) args.mode="";
					if(!args.page || args.page==undefined) args.page=1;
					this.getPopupView('configVideo', args)
				}
				#moduleID#.doSearch = function(frm) {
					var mode = "";
					
					for (var i=0; i < frm.mode.length; i++) {
						if (frm.mode[i].checked) mode = frm.mode[i].value;
					}
					
					this.getPopupView('configVideo', {term:frm.term.value, mode:mode, page:1});
				}
			</script>
		</cfsavecontent>
		<cfhtmlhead text="#tmpHead#">		

<!--- 
		
		<strong>Video ID:</strong><br>
		<input type="text" name="videoID" value="#videoID#" size="15" #tmpDisabled#><br><br>
		<div style="font-size:9px;font-weight:normal;">
			This is the ID assigned by YouTube to each video.
		</div><br>

		<br>
		
		<input type="button" value="Save" onclick="#moduleID#.doFormAction('saveSettings',this.form)" #tmpDisabled#>
		<input type="button" value="Close" onclick="#moduleID#.getView()"> --->
	</form>
</cfoutput>
