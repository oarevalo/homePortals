<!--- page params ---->
<cfparam name="startRow" default="1">
<cfparam name="username" default="">
<cfparam name="email" default="">
<cfparam name="lastName" default="">

<cfscript>
	accountsRoot = getValue("accountsRoot","");
	qryAccountSearchResults = getValue("qryAccountSearchResults",0);

	// paging params 
	rowsPerPage = 15;
	nextStart = startRow + rowsPerPage;
	prevStart = startRow - rowsPerPage;
	endRowNum = nextStart;
	nextPageURL = "?event=ehAccounts.doSearch&startRow=#nextStart#&username=#username#&email=#email#&lastName=#lastName#";
	prevPageURL = "?event=ehAccounts.doSearch&startRow=#prevStart#&username=#username#&email=#email#&lastName=#lastName#";
	if(IsQuery(qryAccountSearchResults)) {
		if(nextStart gt qryAccountSearchResults.recordCount)
			endRowNum = qryAccountSearchResults.recordCount;
	}
</cfscript>

<cfoutput>
	<fieldset class="formEdit">
		<legend><b>Search Accounts</b></legend>
		<form name="frmSearch" action="index.cfm" method="post">
			<input type="hidden" name="event" value="ehAccounts.doSearch" />
			<table border="0" cellpadding="3">
				<tr>
					<td>Username:</td>
					<td><input type="text" name="username" value="#username#" class="textField" style="width:200px;"></td>
					<td width="10">&nbsp;</td>
					<td>Email:</td>
					<td><input type="text" name="email" value="#email#" class="textField" style="width:200px;"></td>
				</tr>
				<tr>
					<td>Last Name:</td>
					<td><input type="text" name="lastname" value="#lastname#" class="textField" style="width:200px;"></td>
					<td width="10">&nbsp;</td>
					<td colspan="2" align="center">
						<input type="submit" name="btn" value="Search Accounts" />
					</td>
				</tr>
			</table>
		</form>
	</fieldset>
	
	<cfif IsQuery(qryAccountSearchResults)>
		<br />
		<table class="tblGrid" width="100%">
			<tr>
				<th width="10">&nbsp;</th>
				<th>Username</th>
				<th>Name</th>
				<th align="center">Created On</th>
				<th>Account URL</th>
				<th>&nbsp;</th>
			</tr>
			<tr>
				<td colspan="6">
					<em>Displaying Rows #startRow# to #endRowNum# of #qryAccountSearchResults.recordCount#</em>
				</td>
			</tr>
			<cfloop query="qryAccountSearchResults" startrow="#startRow#" endrow="#nextStart-1#">		
				<tr>
					<td><strong>#qryAccountSearchResults.currentRow#</strong></td>
					<td><a href="?event=ehAccounts.doSetAccount&UserID=#UserID#">#Username#</a></td>
					<td>#lastName#, #firstName#</td>
					<td align="center">#LSDateFormat(createDate)#</td>
					<td>#accountsRoot#/#username#</td>
					<td align="center" width="75">
						<a href="#accountsRoot#/#username#" target="_blank"><img src="images/house.png" alt="Visit site" border="0"></a>
						<a href="?event=ehAccounts.doSetAccount&UserID=#UserID#"><img src="images/edit-page-yellow.gif" alt="edit" border="0"></a>
						<a href="javascript:doDeleteAccount('#UserID#')"><img src="images/omit-page-orange.gif" alt="delete" border="0"></a>
					</td>
				</tr>
			</cfloop>
			<cfif qryAccountSearchResults.recordCount eq 0>
				<tr><td colspan="6"><em>No Results Found!</em></tr>
			</cfif>
		</table>
			
		<table  style="padding-top:10px;" width="100%">
			<tr>
				<td style="font-size:10px;">
					<b>Legend:</b>&nbsp;
					<img src="images/house.png" alt="Visit site" border="0"> Go to Account Site &nbsp;&nbsp;&nbsp;
					<img src="images/edit-page-yellow.gif" alt="edit" border="0"> Edit Account &nbsp;&nbsp;&nbsp;
					<img src="images/omit-page-orange.gif" alt="delete" border="0"> Delete Account
				</td>
				<td align="center" width="100">
					<cfif prevStart gte 1>
						<a href="#prevPageURL#">Last Page</a>
					</cfif>			
				</td>
				<td align="center" width="100">
					<cfif nextStart lte qryAccountSearchResults.recordCount>
						<a href="#nextPageURL#">Next Page</a>
					</cfif>
				</td>
			</tr>
		</table>	
	</cfif>
	<p>
		<input type="button" name="btnNew" value="Create Account"
				onclick="document.location='?event=ehAccounts.dspCreateAccount'" />
	</p>
</cfoutput>


