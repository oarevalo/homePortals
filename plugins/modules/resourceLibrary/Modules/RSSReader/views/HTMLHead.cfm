<cfset targetID = this.controller.getModuleConfigBean().getPageSetting("targetID")>
<cfset moduleID = this.controller.getModuleID()>

<cfoutput>
	<script>
		#moduleID#.viewContent = function(id,rss,link) {
			var l = $("##"+id+"Link");
			if(l) l.style.fontWeight = "normal";	
			
			var args = {
				rss:rss,
				link:link,
				useLayout:false
			};
			this.getPopupView('post',args);
		};					
		#moduleID#.getFeed = function(args) {
			this.getView('','',{rss:args.url});
		};					
	</script>
</cfoutput>

<cfif this.controller.isFirstInClass()>
	<style type="text/css">
		.rssf_head {
			margin-bottom:20px;
		}
		.rss_head {
			margin-bottom:10px;
		}
		.rssf_head a, .rss_head a {
			font-size:18px;
			font-weight:bold;
		}
		.rssf_titleImage, .rss_titleImage {
			margin-bottom:8px;
		}
		.rssf_body, .rss_body {
			margin-bottom:10px;
		}
		.rssf_item {
			margin-bottom:25px;
		}
		.rss_item {
			margin-bottom:3px;
		}
		.rssf_itemTitle a {
			font-size:14px;
			font-weight:bold;
		}
		.rss_itemTitle a {
			font-weight:normal;
		}
		.rssf_itemDate, .rss_itemDate {
			font-size:9px;
		}
		.rssf_itemContent, .rss_itemContent {
			margin-top:5px;
			line-height:1.3em;
		}
		.rss_itemToggledContent {
			border:1px solid #ccc;
			background-color:#EAEEED;
			padding:4px;
			margin-top:5px;
			margin-bottom:10px;		
		}
		.rssf_itemFlares, .rss_itemFlares {
			margin-top:8px;
		}
		.rss_itemFlares {
			margin-bottom:5px;
		}
		.rssf_itemFlares a, .rss_itemFlares a {
			font-size:10px;
		}

		.RSSReaderPostBar {
			font-size:12px;
			font-weight:bold;
			border:1px solid silver;
			background-color:#ebebeb;
			font-family:"Trebuchet Ms",sans-serif;
		}	
		.RSSReaderPostContent {
			font-family:"Trebuchet Ms",sans-serif;
			border-left:1px solid silver;
			border-right:1px solid silver;
			padding:2px;
			height:420px;
			background-color:white;
			overflow:auto;
			text-align:left;
		}	

	</style>
</cfif>
