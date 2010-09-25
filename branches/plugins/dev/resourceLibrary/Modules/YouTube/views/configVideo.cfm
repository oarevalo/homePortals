<cfparam name="term" default="">
<cfparam name="mode" default="">
<cfparam name="page" default="1">

<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	errorMessage = "";
	aVideos = arrayNew(1);
	videosPerPage = 3;
	
	// get default settings
	videoID = cfg.getPageSetting("videoID","");
	width = cfg.getPageSetting("width","425");
	height = cfg.getPageSetting("height","350");
	autoplay = cfg.getPageSetting("autoplay","0");

	// get current user info
	stUser = this.controller.getUserInfo();

	// get reference to youTube service
	obj = getYouTubeService();

	// search videos
	try {
		switch(mode) {

			case "searchByID":
				xmlResults = obj.getDetails(term);
				aVideos = xmlSearch(xmlResults,"//:entry");
				break;
			
			case "searchByUser":
				xmlResults = obj.searchByUser(term,page,videosPerPage);
				aVideos = xmlSearch(xmlResults,"//:entry");
				break;
	
			case "searchByTag":
				xmlResults = obj.searchByTag(term,page,videosPerPage);
				aVideos = xmlSearch(xmlResults,"//:entry");
				break;

			default:
				mode = "search";
				if(term neq "") {
					xmlResults = obj.search(term,page,videosPerPage);
					aVideos = xmlSearch(xmlResults,"//:entry");
				}
		}

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
				<input type="radio" name="mode" value="search" <cfif mode eq "search">checked</cfif>> All &nbsp;
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
		<div style="width:500px;height:351px;overflow:auto;">
			
			<cfloop from="1" to="#arrayLen(aVideos)#" index="i">
				<cfset xmlNode = aVideos[i]>

				<cfset entry.id = listLast(xmlNode.id.xmlText,"/") />
				<cfset entry.title = xmlNode.title.xmlText />
				<cfset entry.description = xmlNode.content.xmlText  />
				<cfset entry.href = "##" />
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

				<div style="margin:5px;margin-bottom:0px;">
					<a href="##" onclick="#moduleID#.doAction('saveSettings',{videoID:'#entry.id#'});#moduleID#.closeWindow()">
						<img src="#entry.thumbnail#" alt="#entry.title#" 
							title="#entry.title#" 
							border="0" 
							style="float:left;border:1px solid black;"></a>

					<div style="margin-left:140px;font-size:11px;width:300px;">
						<div style="color:##333;font-weight:bold;">#entry.title#</div>
						#left(entry.description,100)#<br>
						<div style="margin-top:3px;font-size:10px;color:##999;">
							<strong>From:</strong> <a href="javascript:#moduleID#.search({term:'#entry.author#',mode:'searchByUser'})">#entry.author#</a><br>
							<strong>Tags:</strong> 
							<cfloop array="#entry.tags#" index="tmp">
								<a href="javascript:#moduleID#.search({term:'#jsStringFormat(tmp)#',mode:'searchByTag'})">#tmp#</a>&nbsp;
							</cfloop>
						</div>
						<div style="margin-top:3px;">
							<a href="##" onclick="#moduleID#.doAction('saveSettings',{videoID:'#entry.id#'});#moduleID#.closeWindow()"><b>Select This Video</b></a>
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

		<div style="background-color:##ebebeb;border:1px solid silver;padding:5px;">
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td>	
						<cfif page gt 1>
							<a href="##" onclick="#moduleID#.search({term:'#term#',mode:'#mode#',page:#page-1#})"><strong>Previous Page</strong></a>
						</cfif> &nbsp;
					</td>
					<td align="right">
						<cfif arrayLen(aVideos) gt 0>
							<a href="##" onclick="#moduleID#.search({term:'#term#',mode:'#mode#',page:#page+1#})"><strong>Next Page</strong></a>
						</cfif> &nbsp;
					</td>
				</tr>
			</table>
		</div>
		
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
