<cfparam name="rssURL" default="http://">
<cfscript>
	errMessage = "";
	feedName = "";
	feedDescription = "";
	lstInvalidChars = "',<,>,?,\,/,!,@,##,$,%,^,&,*";
	
	// get reader service
	oRSSReaderService = createObject("Component","Home.resourceLibrary.Modules.RSSReader.RSSReaderService");

	try {
		feed = oRSSReaderService.getRSS(rssURL);
		bFeedReadOK = true;
		feedName = feed.title;
		feedDescription = feed.description;
		
	} catch(any e) {
		bFeedReadOK = false;
		errMessage = "<b>Error:</b> #e.message#";
	}	
</cfscript>

<cfset setControlPanelTitle("Add Custom Feed","feed")>

<div class="cp_sectionBox" 
	 style="padding:0px;margin:0px;width:475px;margin:10px;">
	<div style="margin:4px;">
		You can add your own feeds to the feed directory and, if you want, you can share them with other users. Use
		the form below to enter the details of the feed.
	</div>
</div>

<div style="margin:10px;border:1px solid #ccc;background-color:#fff;line-height:18px;margin-top:0px;">
	<cfoutput>
		<cfif not bFeedReadOK>
			<p align="center"><b>A problem ocurred while trying to read the feed. #errMessage#</b></p>
		</cfif>
		
		<form name="frmFeed" action="index.cfm" method="post" style="margin:10px;">
			<table>
				<tr>
					<td><b>Name:</b></td>
					<td><input type="text" name="feedName" value="#feedName#" style="width:300px;"></td>
				</tr>
				<tr>
					<td><b>URL:</b></td>
					<td><input type="text" name="rssURL" value="#rssURL#" style="width:300px;"></td>
				</tr>
				<tr valign="top">
					<td><b>Share with:</b></td>
					<td>
						<input type="radio" name="access" value="general"> Everyone<br>
						<input type="radio" name="access" value="friend" checked> Only My Friends<br>
						<input type="radio" name="access" value="owner"> Only Me<br>
					
					</td>
				</tr>
				<tr valign="top">
					<td><b>Description:</b></td>
					<td><textarea name="description" style="width:300px;" rows="4">#feedDescription#</textarea></td>
				</tr>
			</table>
			<br>
			<input type="button" value="Add To My Feeds" onclick="controlPanel.addToMyFeeds(this.form)">
			<input type="button" value="Return To Feeds Directory" onclick="controlPanel.getView('Feeds')">
		</form>
		
	</cfoutput>
</div>