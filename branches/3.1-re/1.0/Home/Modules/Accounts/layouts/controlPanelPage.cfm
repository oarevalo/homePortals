<cfoutput>
	<table width="100%" cellpading="0" cellspacing="0" class="cpTable" border="0">
		
		<!---- Header ---->
		<tr>
			<td style="background-image:url(#imgRoot#/cp_header.jpg);" 
				class="cpHeader" colspan="2" align="right">
				<a href="javascript:controlPanel.closeEditWindow();">
					<img src="#imgRoot#/cp_header_close.gif" 
							alt="Close Control Panel" 
							title="Close Control Panel" border="0">
				</a>
			</td>
		</tr>
		
		<!---- Main menu ---->
		<tr>
			<td colspan="2">
				<table width="100%" class="cpMenu" border="0" cellpadding="0" cellspacing="0">
					<th style="width:100px;border-right:1px solid black;"><A href="javascript:controlPanel.getView('Site')">My Site</A></th>
					<th style="width:100px;border-right:1px solid black;border-left:1px solid white;"><a href="javascript:controlPanel.getView('Page')">My Page</a></th>
					<td align="right" class="cpMenuRight" style="border-left:1px solid white;">
						<cfif this.pageURL neq "">
							<a href="index.cfm?currentHome=#this.PageURL#&refresh=true&#RandRange(1,100)#">Reload</a>
						</cfif>

						<cfif StructKeyExists(stUser,"username") and stUser.username neq "">
							&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:controlPanel.doLogoff('cpContent')">Log Off</a>&nbsp;&nbsp;
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
</cfoutput>