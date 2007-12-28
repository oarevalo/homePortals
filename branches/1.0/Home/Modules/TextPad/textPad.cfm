<!--- textPad v0.1
This module displays an editor to display and edit html content.
The text editor used it TinyMCE by MoxieCode systems
released under a LGPL open source license.
--->

<!--- module parameters --->
<cfparam name="Attributes.moduleID">
<cfparam name="Attributes.module.xmlAttributes.URL">
<cfparam name="Attributes.module.xmlAttributes.contentID" default="">
<cfset instanceName = Attributes.moduleID>
<cfset args = Attributes.module.xmlAttributes>

<!--- Initialize server-side component  --->
<cfset oTextPad = CreateObject("Component","home.modules.TextPad.textPad")>
<cfset oTextPad.init(instanceName, 
						args.URL, 
						args.contentID,
						true)>

<!--- get info on current user --->						
<cfset stUser = oTextPad.getUserInfo()>

<!--- client-side initialization --->
<cfsavecontent variable="tmpHead">
	<cfoutput>	
		<script type="text/javascript">
			#instanceName# = new textPadClient();
			#instanceName#.id = '#instanceName#';
			#instanceName#.URL = '#args.URL#';
			#instanceName#.contentID = '#args.contentID#';
		</script>		

		<!--- if owner is logged in, then enable text editing --->
		<cfif stUser.isOwner>
			<!--- set a request-level flag to let other instances of this same module know
				that we already included the tiny_mce script --->
			<cfif Not StructKeyExists(request,"tiny_mce_set")>
				<script type="text/javascript" src="/tiny_mce/tiny_mce.js"></script>
				<cfset request.tiny_mce_set = true>		
			</cfif>
			<script type="text/javascript">
				tinyMCE.init({
					mode : "exact",
					elements : "#instanceName#_edit",
					theme : "advanced",
					theme_advanced_toolbar_location : "top",
					theme_advanced_toolbar_align : "left",
					theme_advanced_path_location : "bottom",
					theme_advanced_resizing : true,
					theme_advanced_buttons1 : "bold,italic,underline,separator,justifyleft,justifycenter,justifyright,separator,bullist,numlist,separator,outdent,indent",
					theme_advanced_buttons2 : "fontselect,fontsizeselect,formatselect",
					theme_advanced_buttons3 : "link,unlink,separator,image,code,hr,separator,forecolor,backcolor,separator,help",
					//valid_elements : "*[*]"
				});
				
				#instanceName#.getContentSelector();
				#instanceName#.mode = "edit";
			</script>
		</cfif>

		<style type="text/css">
			###instanceName# {
				font-size:11px;
				font-family:Arial, Helvetica, sans-serif;
			}
			###instanceName# textarea {
				border:1px solid silver;
				width:99%;
				height:200px;
			}
			###instanceName#_toolbar {
				margin:0px;
				width:93%;
				margin-bottom:5px;
				font-size:11px;
			}
			###instanceName#_toolbar th {
				border-bottom:2px solid ##990000;
				color:##993300;
				font-size:11px;
			}
			###instanceName#_toolbar select{
				font-size:10px;
				padding:1px;
			}			
		</style>
	</cfoutput> 	
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">


<!--- generate initial content --->
<cfoutput>
	<cfif stUser.isOwner>
		<!--- show editor only to page owner --->
		<form action="##" method="post" name="frmEditBox" style="margin:0px;padding:0px;" id="#instanceName#_form">
			<table id="#instanceName#_toolbar" align="center">
				<tr>
					<th align="left">
						<b>Title:</b> <input type="text" name="contentID" value="" style="width:80%;border:1px solid silver;">
					</th>
					<th align="right" style="border-bottom:2px solid ##990000;" id="#instanceName#_selector_BodyRegion">
						#oTextPad.getContentSelector(instanceName)#
					</th>
				</tr>
				<tr>
					<td colspan="2">
						<textarea name="content" wrap="off" id="#instanceName#_edit"></textarea>
					</td>
				</tr>
				<tr>
					<td>
						<input type="button" name="btnNew" onclick="#InstanceName#.newDocument();" value="New" style="font-size:11px;">&nbsp;&nbsp;
						<input type="button" name="btnSave" onclick="#InstanceName#.save();" value="Save" style="font-size:11px;">&nbsp;&nbsp;
						<input type="button" name="btnDelete" onclick="#InstanceName#.deleteEntry();" value="Delete"  style="font-size:11px;" disabled="true">
					</td>
					<td id="#instanceName#_status_BodyRegion" style="font-weight:bold;"></td>
				</tr>
			</table>
		</form>		
		<cfif args.contentID neq "">
			<script>
				#instanceName#.getContent('#args.contentID#');
			</script>
		</cfif>
	<cfelse>
		<!--- for everyone else show the actual content --->
		<cfset oTextPad.getView(instanceName, Attributes.module.xmlAttributes.contentID)>
	</cfif>
</cfoutput>
