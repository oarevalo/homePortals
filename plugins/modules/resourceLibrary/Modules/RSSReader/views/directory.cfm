<cfprocessingdirective pageencoding="utf-8">
<cfparam name="searchTerm" default="">

<cfset moduleID = this.controller.getModuleID()>

<cfoutput>
	<div style="background-color:##f5f5f5;">
		<div style="padding:0px;width:490px;">
	
			<div style="margin:5px;background-color:##333;border:1px solid silver;color:##fff;">
				<div style="margin:5px;">
					<strong>RSSReader:</strong> Search Directory 
				</div>
			</div>
		
		
			<div style="margin:5px;text-align:right;background-color:##ebebeb;border:1px solid silver;">
				<div style="margin:5px;"> 
					<b>Search feeds:</b>
					<input type="text" name="txtSearch" id="h_txtSearchFeed" value="#searchTerm#">
					<input type="button" name="btnSearch" value="Search" onclick="#moduleID#.getView('contentList','cb_resourceList',{searchTerm:$('##h_txtSearchFeed').val()})">
				</div>
			</div>
		
			<div style="width:490px;margin-top:5px;">
				<div style="width:150px;height:400px;border:1px solid silver;float:left;margin-left:5px;background-color:##fff;overflow:auto;">
					<div id="cb_resourceList_BodyRegion" style="margin:3px;line-height:16px;font-size:11px;">
						Loading feeds...
					</div>
				</div>
				<div style="width:320px;height:400px;border:1px solid silver;margin-left:160px;background-color:##fff;">
					<div id="cb_resourceInfo_BodyRegion" style="margin:10px;line-height:18px;font-size:12px;">	
						Select from the directory on the left the feed you wish to add to your page.
					</div>
				</div>
			</div>
			<br style="clear:both;" />
		
		</div>
	</div>
	
	<script type="text/javascript">
		#moduleID#.getView('contentList','cb_resourceList',{searchTerm:'#jsstringFormat(searchTerm)#'});
	</script>

</cfoutput>
