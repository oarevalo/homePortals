<cfoutput>
	<table width="100%" cellpading="0" cellspacing="0" class="cpTable" border="0">
		<tr>
			<td colspan="2" class="cp_sectionTitle" style="padding:0px;margin:0px;">
				<table style="margin:2px;" cellpadding="0" cellspacing="0" id="cp_TitleBar" border="0">
					<tr>
						<td>
							<img src="#variables.imgRoot#/#variables.controlPanelIcon#.png" align="absmiddle" id="cp_TitleBar_icon"> 
							<span id="cp_TitleBar_label">#variables.controlPanelTitle#</span>
						</td>
						<td align="right">
							<a href="javascript:controlPanel.closeEditWindow()" style="font-size:9px;">Close</a>
							<a href="javascript:controlPanel.closeEditWindow();"><img src="#variables.imgRoot#/cross.png" align="absmiddle" border="0"></a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		
		<tr valign="top">
			<td class="cpLeft" colspan="2">
				<div id="cpContent_BodyRegion">#arguments.html#</div>
			</td>
		</tr>
		
		<tr>
			<td id="cp_status_BodyRegion" colspan="2">&nbsp;</td>
		</tr>
	</table>
	<script type="text/javascript">
		d = $("editContent_BodyRegion");
		h = $("cp_TitleBar");
		d.setDragHandle(h);	
	</script>
</cfoutput>