<cfscript>
	oSite = getValue("oSite");
	oPage = getValue("oPage");
	
	aPages = oSite.getPages();
	owner = oSite.getOwner();
	title = oPage.getPageTitle();
	
	oAccounts = oSite.getAccount();
	stAccountInfo = oAccounts.getConfig();
	
	thisPageHREF = oPage.getHREF();	
	
	xmlContent = oPage.getXML();
</cfscript>

<cfoutput>
<h2>Accounts > #owner# > Page Editor > Edit XML</h2>

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
	<input type="hidden" name="event" value="ehPage.doSaveXML">
	
	<textarea name="xmlContent"  
				onkeypress="checkTab(event)" 
				onkeydown="checkTabIE()"				
				class="codeEditor" 
				wrap="off"
				style="width:610px;">#xmlContent#</textarea>
	
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