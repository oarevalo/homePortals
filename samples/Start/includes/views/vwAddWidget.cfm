<cfinclude template="../../config/widgets-config.cfm">

<cfoutput>
	<div style="font-size:12px;font-weight:bold;border-bottom:1px solid ##666;line-height:15px;">
		<div style="margin:6px;">
			Add RSS Feed:
			<form name="frm" action="##" method="post" style="margin:0px;padding:0px;">
				<input type="hidden" name="addToMyFeeds" value="1">
				<input type="text" name="xmlUrl" value="" placeholder="http://" style="width:230px;font-size:12px;">
				<input type="button" name="btnSave" value="Add" style="font-size:10px;width:30px;" 
						onclick="controlPanel.addFeed(this.form.xmlUrl.value)"><br />
			</form>
		</div>
	</div>

	<div id="cp_content">
		<div id="sidePanelWidgetList">
			<cfloop array="#widgets#" index="c">
				<div style="background:url('#c.img#') no-repeat top left" class="sidePanelWidgetItem">
					<a href="##" onclick="#c.onclick#">#c.label#</a>
				</div>
			</cfloop>
		</div>
	</div>
</cfoutput>


