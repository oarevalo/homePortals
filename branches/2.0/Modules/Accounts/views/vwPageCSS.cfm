<cfparam name="arguments.href" default="">

<cfset stUser = getUserInfo()>
<cfset cssContent = variables.oPage.getPageCSS()>

<cfoutput>
	<form name="frmPageCSS" style="padding:0px;margin:0px;" method="post" action="##">
		<table cellpadding="0" cellspacing="0" width="100%">
			<tr valign="top">
				<td style="width:325px;">
					<div class="cp_sectionTitle" style="width:325px;padding:0px;margin-bottom:0px;">
						<div style="margin:2px;">
							StyleSheet Editor
						</div>
					</div>
					<div class="cp_sectionBox" 
							style="margin:0px;height:330px;padding:0px;width:325px;border-top:0px;margin-left:5px;text-align:center;">
						<textarea name="cssContent" 
								  style="width:315px;font-size:11px;height:320px;border:0px solid black;margin:0px;">#cssContent#</textarea>
					</div>
				</td>
				<td rowspan="2">
					<div class="cp_sectionBox" style="margin:0px;margin-top:5px;height:380px;padding:0px;width:150px;">
						<div style="margin:4px;">
							<cfinclude template="#moduleRoot#/includes/controlPanel_CSSHelp.cfm">
						</div>
					</div>
				</td>
			</tr>
			<tr>
				<td valign="bottom">
					<div class="cp_sectionBox" 
						 style="margin:0px;padding:0px;width:325px;margin-left:6px;margin-top:5px;">
						<div style="margin:4px;">
							<a href="javascript:controlPanel.savePageCSS(document.frmPageCSS);"><img src="#imgRoot#/disk.png" align="absmiddle" border="0"></a>
							<a href="javascript:controlPanel.savePageCSS(document.frmPageCSS);">Apply Changes</a>
							&nbsp;&nbsp;&nbsp;&nbsp;
							<a href="javascript:controlPanel.getView('Page');"><img src="#imgRoot#/cross.png" align="absmiddle" border="0"></a>
							<a href="javascript:controlPanel.getView('Page');">Cancel</a>
						</div>
					</div>
				</td>
			</tr>
		</table>
	</form>
</cfoutput>
