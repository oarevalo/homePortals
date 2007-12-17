<cfparam name="arguments.href" default="">

<cfset cssContent = variables.oPage.getPageCSS()>

<cfset setControlPanelTitle("Workspace Layout","chart_organisation")>

<cfoutput>
	<form name="frmPageLayout" style="padding:0px;margin:0px;" method="post" action="##">
		<div class="cp_sectionBox" 
			 style="padding:0px;margin:0px;width:475px;margin:10px;">
			<div style="margin:4px;">
				Select from the form below the layout to apply to the current workspace. The layout determines
				the areas where you can place modules on the page.
			</div>
		</div>

		<table cellpadding="0" cellspacing="0" width="100%" style="margin-top:10px;">
			<tr valign="top">
				<td align="center">
					<img src="#imgRoot#/layouts/layout1.gif"><br>
					<input type="radio" name="layout" value="3-col-wide-center">
				</td>
				<td align="center">
					<img src="#imgRoot#/layouts/layout2.gif"><br>
					<input type="radio" name="layout" value="2-col-wide-right">
				</td>
				<td align="center">
					<img src="#imgRoot#/layouts/layout3.gif"><br>
					<input type="radio" name="layout" value="2-col-wide-left">
				</td>
			</tr>
			<tr><td colspan="3">&nbsp;</td></tr>
			<tr valign="top">
				<td align="center">
					<img src="#imgRoot#/layouts/layout4.gif"><br>
					<input type="radio" name="layout" value="3-col-equal">
				</td>
				<td align="center">
					<img src="#imgRoot#/layouts/layout5.gif"><br>
					<input type="radio" name="layout" value="2-col-header-wide-right">
				</td>
				<td align="center">
					<img src="#imgRoot#/layouts/layout6.gif"><br>
					<input type="radio" name="layout" value="3-col-header-wide-center">
				</td>
			</tr>
			<tr>
				<td valign="bottom" colspan="3">
					<div class="cp_sectionBox" 
						 style="padding:0px;margin:0px;width:475px;margin:10px;margin-top:38px;">
						<div style="margin:4px;">
							<a href="javascript:controlPanel.applyPageTemplate(document.frmPageLayout);"><img src="#imgRoot#/disk.png" align="absmiddle" border="0"></a>
							<a href="javascript:controlPanel.applyPageTemplate(document.frmPageLayout);">Apply Changes</a>
						</div>
					</div>
				</td>
			</tr>
		</table>
	</form>
</cfoutput>
