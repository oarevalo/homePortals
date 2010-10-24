<cfinclude template="../../config/widgets-config.cfm">

<cfoutput>
	<div style="font-size:12px;font-weight:bold;border-bottom:1px solid ##666;line-height:15px;">
		<div style="margin:6px;">
			Add RSS Feed:
			<form name="frm" action="##" method="post" style="margin:0px;padding:0px;">
				<input type="hidden" name="addToMyFeeds" value="1">
				<input type="text" name="xmlUrl" value="" placeholder="http://" style="width:230px;font-size:12px;">
				<input type="button" name="btnSave" value="Add" style="font-size:11px;width:40px;" 
						onclick="controlPanel.addFeed(this.form.xmlUrl.value)"><br />
			</form>
		</div>
	</div>

	<div id="cp_content">
		<table width="100%">
			<tr>
				<td style="width:50%">
					<div id="sidePanelWidgetList">
					<cfloop from="1" to="#arrayLen(widgets)#" index="i" step="2">
						<cfset c = widgets[i]>
						<div style="background:url('#c.img#') no-repeat top left" class="sidePanelWidgetItem">
							<a href="##" onclick="#c.onclick#">#c.label#</a>
						</div>
					</cfloop>
					</div>
				</td>
				<td>
					<div id="sidePanelWidgetList">
					<cfloop from="2" to="#arrayLen(widgets)#" index="i" step="2">
						<cfset c = widgets[i]>
						<div style="background:url('#c.img#') no-repeat top left" class="sidePanelWidgetItem">
							<a href="##" onclick="#c.onclick#">#c.label#</a>
						</div>
					</cfloop>
					</div>
				</td>
			</tr>
		</table>
	</div>
</cfoutput>


