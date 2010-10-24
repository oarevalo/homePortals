<cfset layouts = [
			loc['layouts.one_column'],
			loc['layouts.two_columns'],
			loc['layouts.three_columns'],
			loc['layouts.two_cols_right'],
			loc['layouts.two_cols_left']
		]>

<cfoutput>
	<div style="margin:10px;border:1px solid ##ccc;padding:5px;">
		<br />
		<ul style="margin:0 auto;">
			<cfloop from="1" to="#arrayLen(layouts)#" index="i">
				<li>
					<div style="float:left;width:100px;">
						<a href="##" onclick="controlPanel.setPageLayout(#i#)" class="layoutOption"><img src="images/layouts/#i#.gif" /></a>
					</div>
					<div style="float:left;line-height:30px;text-align:left;margin-left:10px;">
						#layouts[i]#
					</div>
					<br style="clear:both;"/>
				</li>
			</cfloop>
		</ul>
	</div>

</cfoutput>
