<cfparam name="arguments.href" default="">

<cfset layouts = [
			"One column",
			"Two columns",
			"Three columns",
			"Two columns, narrow right",
			"Two columns, narrow left"
		]>

<cfoutput>
	<div style="margin:10px;border:1px solid ##ccc;">
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
