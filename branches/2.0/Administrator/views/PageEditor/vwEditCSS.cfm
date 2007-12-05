<cfscript>
	oSite = getValue("oSite");
	oPage = getValue("oPage");
	
	aPages = oSite.getPages();
	owner = oSite.getOwner();
	title = oPage.getPageTitle();
	
	oAccounts = oSite.getAccount();
	stAccountInfo = oAccounts.getConfig();
	
	thisPageHREF = oPage.getHREF();	
	
	cssContent = oPage.getPageCSS();
</cfscript>

<cfoutput>
<h2>Accounts > #owner# > Page Editor > Edit Stylesheet</h2>

<table id="tblPageDesigner" cellspacing="0" cellpadding="0">
	<tr valign="top">
		<td colspan="3" style="padding:0px;">
			<div class="cp_sectionBox" 
				 style="margin:0px;padding:0px;width:630px;margin-top:5px;overflow:hidden;">
				<table style="margin:5px;width:620px;" cellpadding="0" cellspacing="0">
					<tr>
						<td>
							<strong>Title:</strong> #title#
						</td>

						<td align="right">
							<strong>Page:</strong>
							<select name="page" style="width:120px;" onchange="document.location='?event=ehPage.doLoadPage&href=#stAccountInfo.accountsRoot#/'+this.value">
								<cfloop from="1" to="#arrayLen(aPages)#" index="i">
									<cfset pageAttributes = aPages[i]>
									<cfset pageHREF = "/#owner#/layouts/#pageAttributes.href#">
									<option value="#pageHREF#"
											<cfif getFileFromPath(pageHREF) eq getFileFromPath(thisPageHREF)>selected</cfif>>#pageAttributes.href#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
</table>

<form name="frm" method="post" action="index.cfm" style="margin:0px;padding:0px;">
	<input type="hidden" name="event" value="ehPage.doSaveCSS">
	<table style="margin:0px;padding:0px;width:100%;" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td>
				<textarea name="cssContent" 
							onkeypress="checkTab(event)" 
							onkeydown="checkTabIE()"				
							class="codeEditor">#cssContent#</textarea>
			</td>
			<td>
				<div class="cp_sectionBox" 
					 style="padding:0px;margin:10px;margin-right:0px;margin-bottom:0px;width:286px;height:340px;">
					<div style="margin:4px;">
						<h2 style="margin:1px;">Stylesheet</h2>
						Use this space to enter CSS declarations and rules
						that will be applied to the current page. This stylesheet
						is always applied after any other css pages on the page.
						
						
						<p>
							<div style="font-weight:bold;font-size:12px;border-bottom:2px solid black;">Special Classes / IDs</div>
							<li><strong style="color:##50628b;">##navMenu:</strong> Container for the navigation menu.</li>
							<li><strong style="color:##50628b;">##h_body_main:</strong> Container for the entire page</li>
							<li><strong style="color:##50628b;">.Section:</strong> Class applied to all modules that have a container.</li>
							<li><strong style="color:##50628b;">.SectionTitle:</strong> Class applied to the module title bar (only when the module container is displayed)</li>
							<li><strong style="color:##50628b;">.SectionBody:</strong> Class applied to the module contents (only when the module container is displayed)</li>
							<li>
								<span style="color:green;font-weight:bold;">TIP:</span>
								All modules are always contained within a div element with the same ID as the module ID.
							</li>
						</p>
						
						<p>
							<div style="font-weight:bold;font-size:12px;border-bottom:2px solid black;margin-top:10px;">Other CSS Resources:</div>
							<li><a href="http://en.wikipedia.org/wiki/Cascading_Style_Sheets" target="_blank" style="font-weight:normal;border-bottom:1px dashed silver;">CSS Wikipedia Entry</a></li>
							<li><a href="http://www.w3.org/Style/CSS/" target="_blank" style="font-weight:normal;border-bottom:1px dashed silver;">W3C CSS Spec</a></li>
						</p>
				</div>
			</td>
		</tr>
	</table>
	
	<p>
		<input type="button" 
				name="btnCancel" 
				value="Return To Page Editor" 
				onClick="document.location='?event=ehPage.dspPageEditor'">
		&nbsp;&nbsp;
		<input type="submit" name="btnSave" value="Apply Changes">
	</p>
</form>
</cfoutput>
