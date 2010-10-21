<cfoutput>
	<div id="cp_sectionTitle">
		<div style="float:right;">
			<a href="javascript:controlPanel.closePanel();"><img src="images/closePanel.gif" align="absmiddle" border="0"></a>
		</div>
		<a href="##" onclick="controlPanel.getView('AddFeed')" class="cp_tab <cfif variables.view eq "AddFeed">cp_selectedTab</cfif>" id="cp_tabFeeds">&nbsp;</a>
		<a href="##" onclick="controlPanel.getView('AddWidget')" class="cp_tab <cfif variables.view eq "AddWidget">cp_selectedTab</cfif>" id="cp_tabWidgets">&nbsp;</a>
	</div>

	<div id="cp_content" style="clear:both;">#arguments.html#</div>

	<div id="cp_status_BodyRegion"></div>

</cfoutput>
