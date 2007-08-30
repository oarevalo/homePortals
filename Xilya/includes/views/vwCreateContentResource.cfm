<cfparam name="contentName" default="">

<cfset setControlPanelTitle("Create Custom Content","page_white_text")>

<div class="cp_sectionBox" 
	 style="padding:0px;margin:0px;width:475px;margin:10px;">
	<div style="margin:4px;">
		You can create your own custom content to add to your page. Use this feature to import any HTML code or text.
	</div>
</div>

<form name="frmContent" action="index.cfm" method="post" style="margin:0px;padding:0px;">
	
<div style="margin:10px;border:1px solid #ccc;background-color:#fff;line-height:18px;margin-top:0px;">
	<cfoutput>
		<table style="margin:10px;">
			<tr>
				<td width="100"><b>Name:</b></td>
				<td><input type="text" name="contentName" value="#contentName#" style="width:300px;"></td>
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
				<td><textarea name="description" style="width:300px;" rows="2"></textarea></td>
			</tr>
			<tr valign="top">
				<td>
					<b>HTML/Text:</b>
					<div style="font-size:9px;line-height:11px;">
						Use the following space to paste the HTML code
						of the content you wish to display.
					</div>
				</td>
				<td><textarea name="body" style="width:300px;" rows="6"></textarea></td>
			</tr>
		</table>
	</cfoutput>
</div>

<fieldset style="margin:10px;border:1px solid #ccc;background-color:#ebebeb;">
	<input type="button" value="Save" onclick="controlPanel.addToMyContent(this.form)">
	<input type="button" value="Return To Content Directory" onclick="controlPanel.getView('Content')">
</fieldset>

</form>