<cfoutput>
	<table width="100%" cellpading="0" cellspacing="0" class="cpTable" border="0">
		<tr>
			<td colspan="2" class="cp_sectionTitle" style="padding:0px;margin:0px;">
				<table style="margin:2px;" cellpadding="0" cellspacing="0" id="cp_TitleBar" width="100%">
					<tr>
						<td>
							<img src="#variables.imgRoot#/cog.png" align="absmiddle"> Control Panel
						</td>
						<td align="right">
							<a href="javascript:controlPanel.closeEditWindow()" style="font-size:9px;color:##fff;">Close</a>
							&nbsp;&nbsp;
						</td>
					</tr>
				</table>
			</td>
		</tr>
		
		<!---- Main menu ---->
		<tr>
			<td colspan="2">
				<table width="100%" class="cpMenu" border="0" cellpadding="0" cellspacing="0">
					<cfif StructKeyExists(stUser,"username") and stUser.username neq "">
						<th style="width:100px;border-right:1px solid black;">
							<A href="javascript:controlPanel.getView('Site')" id="cp_SiteTab">My Site</A>
						</th>
						<th style="width:100px;border-right:1px solid black;border-left:1px solid white;">
							<a href="javascript:controlPanel.getView('Page')" id="cp_PageTab">My Page</a>
						</th>
					</cfif>
					<td align="right" class="cpMenuRight" style="border-left:1px solid white;">
						<cfif this.pageURL neq "">
							<img src="#variables.imgRoot#/arrow_rotate_clockwise.png" align="absmiddle">
							<a href="index.cfm?currentHome=#this.PageURL#&refresh=true&#RandRange(1,100)#">Reload</a>&nbsp;
						</cfif>

						<cfif StructKeyExists(stUser,"username") and stUser.username neq "">
							&nbsp;&nbsp;&nbsp;&nbsp;
							<img src="#variables.imgRoot#/door_in.png" align="absmiddle">
							<a href="javascript:controlPanel.doLogoff('cpContent')">Log Off</a>&nbsp;&nbsp;
						</cfif>

					</td>
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