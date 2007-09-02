<cfprocessingdirective pageencoding="utf-8">
<cfparam name="searchTerm" default="">

<!---- Styles --->
<style type="text/css">
	#rd_searchBar {
		font-size:10px;
		margin:10px;
	}
	#rd_searchBar input {
		font-size:10px;
	}
	#rd_footer {
		margin:10px;
		margin-top:0px;
		border:1px solid #ccc;
		background-color:#ebebeb;
	}
</style>

<cfset setControlPanelTitle("Feed Directory","feed")>

<cfoutput>
	<div id="rd_searchBar">
		<div style="float:right;">
			<input type="text" name="txtSearch" id="h_txtSearchFeed" value="#searchTerm#">
			<input type="button" name="btnSearch" value="Search" onclick="controlPanel.getPartialView('FeedList',{searchTerm:$('h_txtSearchFeed').value},'cp_resourceList')">
		</div>
		Click on category to view available feeds
	</div>
</cfoutput>


<div style="width:490px;margin-top:5px;">
	<div style="width:150px;height:320px;border:1px solid silver;float:left;margin-left:5px;background-color:#fff;overflow:auto;">
		<div id="cp_resourceList_BodyRegion" style="margin:3px;line-height:16px;font-size:11px;">
			Loading feeds...
		</div>
	</div>
	<div style="width:320px;height:320px;border:1px solid silver;margin-left:160px;background-color:#fff;">
		<div id="cp_resourceInfo_BodyRegion" style="margin:10px;line-height:18px;font-size:12px;">	
			Select from the directory the RSS feed you wish to add to your page, or use
			the space below to type in the URL of the RSS/Atom feed.
		</div>
	</div>
</div>
<br style="clear:both;" />
<fieldset id="rd_footer">
	<legend><strong>Add Custom Feed:</strong></legend>
	<form name="frm" action="#" method="post" style="margin:0px;padding:0px;">
		<input type="hidden" name="addToMyFeeds" value="1">
		<input type="text" name="xmlUrl" value="http://" style="width:300px;">
		<input type="button" name="btnSave" value="Add Feed" onclick="addCustomFeed(this.form)"><br />
	</form>
</fieldset>

<cfoutput>
	<script type="text/javascript">
		controlPanel.getPartialView('FeedList',{searchTerm:'#jsstringFormat(searchTerm)#'},'cp_resourceList');
	</script>
</cfoutput>
	
	
