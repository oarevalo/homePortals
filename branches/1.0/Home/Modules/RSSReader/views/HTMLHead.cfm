<cfset targetID = this.controller.getModuleConfigBean().getPageSetting("targetID")>
<cfset moduleID = this.controller.getModuleID()>

<cfoutput>
	<script>
		#moduleID#.viewContent = function(id,rss,link) {
			var l = $(id+"Link");
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
	
	<cfif this.controller.isFirstInClass()>
		<style type="text/css">
			.RSSReaderPostBar {
				font-size:12px;
				font-weight:bold;
				border:1px solid silver;
				background-color:##fefcd8;
			}	
			.RSSReaderPostContent {
				border-left:1px solid silver;
				border-right:1px solid silver;
				padding:2px;
				height:410px;
				background-color:white;
				overflow:auto;
				text-align:left;
			}	
			.RSSSettings {
				background-color:##fefcd8;
				padding:10px;
				margin:0px;
				border:1px solid ##cccccc;
			}
			.RSSSettings input {
				border:1px solid black;
				font-size:11px;
				padding:1px;
			}	
		</style>
	</cfif>
	
	
	<style type="text/css">
		.#moduleID#_Divider {
			clear:both;
			border-bottom:1px solid ##000066;
			margin-bottom:5px;
		}
		###moduleID#_RSSTitle {
			margin-top:2px;
			margin-bottom:2px;
		}
		###moduleID#_RSSTitle a {
			font-size:16px !important;
			font-weight:bold !important;
		}
		###moduleID#_toolbar {
			border:1px solid silver;
			background-color:##fefcd8;
			margin:0px;
			color:##993300;
			margin-top:10px;
			padding:2px;
			font-size:12px;
		}
		###moduleID#_toolbar a {
			color:##333333 !important;
			font-weight:bold;
			font-size:10px;
		}	
	</style>

</cfoutput>
