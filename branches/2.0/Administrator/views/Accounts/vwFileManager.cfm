<cfscript>
	userID = getValue("UserID","");
	qryAccount = getValue("qryAccount");
	qryFiles = getValue("qryFiles","");
	path = getValue("path","");
	prevPath = getValue("prevPath","");
	
	tmpAccountSize = 0;
</cfscript>

<cfoutput>
	<h2>Accounts > #qryAccount.username# > Site Files</h2>
	
	<br>
	<table class="tblFiles" width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<th>Name</th>
			<th align="left">Last Modified</th>
			<th align="right">Size</th>
			<th width="100">&nbsp;</th>
		</tr>
		<tr>
			<td colspan="4" style="background-color:##ebebeb;font-size:12px;border-bottom:1px solid silver;">
				<b>#path#/</b>
			</td>
		</tr>
		<cfif prevPath neq "">
			<tr>
				<td colspan="4">
					<img src="images/folder.png" border="0" align="absmiddle" alt="Go Up">
					<a href="?event=ehAccounts.dspFileManager&userID=#userID#&path=#prevPath#">..</a>
				</td>
			</tr>
		</cfif>
		<cfloop query="qryFiles">
			<cfset pageURL = "#path#/#qryFiles.name#">
			<cfset tmpAccountSize = tmpAccountSize + qryFiles.size>
			
			<cfif qryFiles.type eq "Dir">
				<tr>
					<td colspan="4">
						<img src="images/folder.png" border="0" align="absmiddle" alt="Dir">
						<a href="?event=ehAccounts.dspFileManager&userID=#userID#&path=#path#/#qryFiles.name#">#qryFiles.name#</a>
					</td>
				</tr>
			<cfelse>
				<tr>
					<td>
						<img src="images/page_white.png" border="0" align="absmiddle" alt="File">
						#qryFiles.name#
					</td>
					<td align="left">#LsDateFormat(qryFiles.dateLastModified)# #LSTimeFormat(qryFiles.dateLastModified)#</td>
					<td align="right">#qryFiles.size#</td>
					<td align="center">
						<a href="#pageURL#" target="_blank"><img src="images/link.png" alt="view" border="0"></a>
						<a href="javascript:doDeleteFile('#UserID#','#pageURL#');"><img src="images/omit-page-orange.gif" alt="delete" border="0"></a>
					</td>
				</tr>
			</cfif>
		</cfloop>
		<tr>
			<td style="font-size:10px;border-top:1px solid black;padding-top:4px;" colspan="2">
				<b>Legend:</b>&nbsp;
				<img src="images/link.png" alt="Visit site" border="0" align="absmiddle"> View File &nbsp;&nbsp;&nbsp;
				<img src="images/omit-page-orange.gif" alt="delete" border="0" align="absmiddle"> Delete File
			</td>
			<td align="right" style="font-size:larger;border-top:1px solid black;"><b>#NumberFormat(tmpAccountSize/1024)# kb</b></td>
			<td style="border-top:1px solid black;">&nbsp;</td>
		</tr>
	</table>	

	<p>
		<input type="button" name="btnCancel" value="Return" onClick="document.location='?event=ehSite.dspSiteManager'">
	</p>
</cfoutput>
