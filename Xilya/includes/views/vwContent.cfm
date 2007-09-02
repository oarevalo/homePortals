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
		border:1px solid #ccc;
		background-color:#ebebeb;
	}
</style>

<cfset setControlPanelTitle("Content Directory","page_white_text")>

<cfoutput>
	<div id="rd_searchBar">
		<div style="float:right;">
			<input type="text" name="txtSearch" id="h_txtSearchFeed" value="#searchTerm#">
			<input type="button" name="btnSearch" value="Search" onclick="controlPanel.getPartialView('ContentList',{searchTerm:$('h_txtSearchFeed').value},'cp_resourceList')">
		</div>
		Click on category to view available content
	</div>
</cfoutput>

<div style="width:490px;margin-top:5px;">
	<div style="width:150px;height:320px;border:1px solid silver;float:left;margin-left:5px;background-color:#fff;overflow:auto;">
		<div id="cp_resourceList_BodyRegion" style="margin:3px;line-height:16px;font-size:11px;">
			Loading content list...
		</div>
	</div>
	<div style="width:320px;height:320px;border:1px solid silver;margin-left:160px;background-color:#fff;">
		<div id="cp_resourceInfo_BodyRegion" style="margin:10px;line-height:18px;font-size:12px;">	
			Select from the directory the content element you wish to add to your page.
		</div>
	</div>
</div>
<br style="clear:both;" />
<fieldset id="rd_footer">
	<input type="button" name="btnSave" value="Create Custom Content" onclick="controlPanel.getView('CreateContentResource')"><br />
</fieldset>

<cfoutput>
	<script type="text/javascript">
		controlPanel.getPartialView('ContentList',{searchTerm:'#jsstringFormat(searchTerm)#'},'cp_resourceList');
	</script>
</cfoutput>
	
	

