<cfset moduleID = this.controller.getModuleID()>
<cfset stUser = this.controller.getUserInfo()>
<cfset useTinyMCE = this.controller.getModuleConfigBean().getProperty("useTinyMCE")>

<cfoutput>
	<style type="text/css">
		###moduleID# textarea {
			font-size:10px;
			border:1px solid silver;
			width:99%;
			height:200px;
			font-family:Arial, Helvetica, sans-serif;
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
		###moduleID#_toolbar select{
			font-size:10px;
			padding:1px;
			color:##333333;
		}	
		###moduleID#_toolbar a {
			color:##333333 !important;
			font-weight:bold;
			font-size:10px;
		}
	</style>

	<!--- if owner is logged in and useTinyMCE flag is on, then enable wisiwyg text editing --->
	<cfif stUser.isOwner and (isBoolean(useTinyMCE) and useTinyMCE)>
		<!--- add the tiny_mce script only for the first ocurrence of this module on the page --->
		<cfif this.controller.isFirstInClass()>
			<script type="text/javascript" src="/tiny_mce/tiny_mce.js"></script>
		</cfif>
		<!--- initialize tiny_mce object --->
		<script type="text/javascript">
			tinyMCE.init({
				mode : "exact",
				elements : "#moduleID#_edit",
				theme : "advanced",
				plugins : "table",
				theme_advanced_toolbar_location : "top",
				theme_advanced_toolbar_align : "left",
				theme_advanced_path : "false",
				theme_advanced_buttons1 : "bold,italic,underline,separator,justifyleft,justifycenter,justifyright,separator,bullist,numlist,separator,outdent,indent,separator,link,unlink,separator,image,hr,separator,forecolor,backcolor,separator,help",
				theme_advanced_buttons2 : "fontselect,fontsizeselect,formatselect",
				theme_advanced_buttons3 : "tablecontrols"
				//valid_elements : "*[*]"
			});
		</script>
	</cfif>

	<cfif (isBoolean(useTinyMCE) and useTinyMCE)>
		<script type="text/javascript">
			#moduleID#.saveContent = function(frm) {
				var editor_id = this.moduleID + "_edit";
				var myMCE = tinyMCE.getInstanceById(editor_id);
				tinyMCE.selectedInstance = myMCE;
				frm.content.value = tinyMCE.getContent();
				#moduleID#.doFormAction('save',frm);
			};
		</script>
	</cfif>

	<script type="text/javascript">
		#moduleID#.getContent = function(contentID) {
			if(!contentID) contentID = "";
			#moduleID#.getView('page','',{contentID:contentID})
		};
	</script>
</cfoutput>


