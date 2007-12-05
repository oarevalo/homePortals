<!--- 
vwAddPage

Allows user to enter the name of the new page to add,
also displays the list of published pages

** This file should be included from addContent.cfc

History:
1/19/06 - oarevalo - created
---->

<cfset aPages = variables.oSite.getPages()>
<cfset aCatalogPages = variables.oCatalog.getPages()>

<cfoutput>
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr valign="top">
			<td style="width:325px;">
				<div class="cp_sectionTitle" style="width:325px;padding:0px;margin-bottom:0px;">
					<div style="margin:2px;">
						Add New Page
					</div>
				</div>
				<div class="cp_sectionBox" style="margin-top:0px;height:323px;padding:0px;margin-bottom:0px;width:325px;border-top:0px;">
					<div style="margin:10px;">
						<p>
							<img src="#imgRoot#/cp_bullet.gif" border="0" alt=">">
							<strong>Add a blank page</strong><br>
							<form name="frm1" action="##" method="post" style="margin-left:20px;">
								Name: 
								<input type="text" name="pageName" value="" style="width:150px;">
								<input type="button" value="Go" onclick="controlPanel.addPage(this.form.pageName.value)">
							</form>
						</p><br>
						<p>
							<img src="#imgRoot#/cp_bullet.gif" border="0" alt=">">
							<strong>Copy existing page:</strong><br>
							<form name="frm2" action="##" method="post" style="margin-left:20px;">
								Select page to copy:
								<select name="pageHREF" style="width:100px;">
									<cfloop from="1" to="#arrayLen(aPages)#" index="i">
										<option value="#aPages[i].href#">#aPages[i].title#</option>
									</cfloop>
									<option value="">------------</option>
									<cfloop from="1" to="#arrayLen(aCatalogPages)#" index="i">
										<option value="#aCatalogPages[i].href#">#aCatalogPages[i].id#</option>
									</cfloop>
								</select>
								<input type="button" value="Go" onclick="controlPanel.addPage('',this.form.pageHREF.value)">
							</form>
						</p><br>
					</div>		
				</div>
			</td>
			<td rowspan="2">
				<div class="cp_sectionBox" style="margin:0px;margin-top:5px;height:380px;padding:0px;width:150px;">
					<div style="margin:4px;">
						<cfinclude template="#moduleRoot#/includes/controlPanel_AddPageHelp.cfm">
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<td valign="bottom">
				<div class="cp_sectionBox" 
					 style="margin:0px;padding:0px;width:325px;margin-left:6px;margin-top:0px;">
					<div style="margin:4px;">
						<a href="javascript:controlPanel.getView('Site');"><img src="#imgRoot#/cross.png" align="absmiddle" border="0"></a>
						<a href="javascript:controlPanel.getView('Site');">Cancel</a>
					</div>
				</div>
			</td>
		</tr>
	</table>

</cfoutput>
