<!--- Accounts Manager Search View --->
<cfinclude template="../../udf.cfm"> 

<!--- page params ---->
<cfparam name="startRow" default="1">
<cfparam name="username" default="">
<cfparam name="email" default="">
<cfparam name="lastName" default="">

<!--- paging params ---->
<cfset rowsPerPage = 15>
<cfset nextStart = startRow + rowsPerPage>
<cfset prevStart = startRow - rowsPerPage>
<cfset nextPageURL = "home.cfm?event=accountsManager.doSearch&startRow=#nextStart#&username=#username#&email=#email#&lastName=#lastName#">
<cfset prevPageURL = "home.cfm?event=accountsManager.doSearch&startRow=#prevStart#&username=#username#&email=#email#&lastName=#lastName#">

<!--- get reference to accounts object --->
<cfset accountsCFCPath = appState.stConfig.moduleLibraryPath & "Accounts/accounts.cfc">
<cfset oAccounts = createInstance(accountsCFCPath)>
<cfset oAccounts.loadConfig()>

<!--- check if account storage have been setup --->
<cfset oStorage = oAccounts.getAccountStorage()>
<cfset bIsAccountsSetup = oStorage.isInitialized()>



<h1>Accounts Manager</h1>

<cfif Not bIsAccountsSetup>
	<p>
		HomePortals Accounts settings have not been properly setup. 
		Please setup HomePortals Accounts before using the Accounts Manager.
	</p>
	<cfexit>
</cfif>

<cfoutput>
	<form name="frmSearch" action="home.cfm" method="post">
		<input type="hidden" name="event" value="accountsManager.doSearch" />
		<input type="hidden" name="view" value="accountsManager/main" />
		<table style="background-color:##CCCCCC;border:1px solid black;border-collapse:collapse;" border="0" cellpadding="3" width="600">
			<tr>
				<td>Username:</td>
				<td><input type="text" name="username" value="#username#"></td>
				<td width="10">&nbsp;</td>
				<td>Email:</td>
				<td><input type="text" name="email" value="#email#"></td>
			</tr>
			<tr>
				<td>Last Name:</td>
				<td><input type="text" name="lastname" value="#lastname#"></td>
				<td width="10">&nbsp;</td>
				<td colspan="2" align="center">
					<input type="submit" name="btn" value="Search Accounts" />
				</td>
			</tr>
		</table>
	</form>

	<cfif StructKeyExists(request, "qrySearchResults")>
		<br />
		<table class="tblGrid" width="600">
			<tr>
				<th width="10">&nbsp;</th>
				<th>Username</th>
				<th>Name</th>
				<th>Created On</th>
				<th>Home</th>
				<th>&nbsp;</th>
			</tr>
			<tr>
				<td colspan="6"><em>Displaying Rows #startRow# to #startRow+rowsPerPage# of #request.qrySearchResults.recordCount#</em></td>
			</tr>
			<cfloop query="request.qrySearchResults" startrow="#startRow#" endrow="#nextStart-1#">		
				<tr>
					<td><strong>#request.qrySearchResults.currentRow#</strong></td>
					<td>#Username#</td>
					<td>#lastName#, #firstName#</td>
					<td align="center">#LSDateFormat(createDate)#</td>
					<td>
						<a href="#oAccounts.stConfig.accountsRoot#/#username#" target="_blank">#oAccounts.stConfig.accountsRoot#/#username#</a>
					</td>
					<td align="center" width="75">
						<a href="home.cfm?view=accountsManager/edit&UserID=#UserID#">Edit/View</a>
					</td>
				</tr>
			</cfloop>
			<cfif request.qrySearchResults.recordCount eq 0>
				<tr><td colspan="6"><em>There are no accounts created.</em></tr>
			</cfif>
		</table>
			
		<table width="600">
			<tr>
				<td align="left">
					<cfif prevStart gte 1>
						<a href="#prevPageURL#">Last Page</a>
					</cfif>			
				</td>
				<td align="right">
					<cfif nextStart lte request.qrySearchResults.recordCount>
						<a href="#nextPageURL#">Next Page</a>
					</cfif>
				</td>
			</tr>
		</table>	
	</cfif>
	<p>
		<input type="button" name="btnNew" value="Create Account"
				onclick="document.location='home.cfm?view=accountsManager/edit'" />
	</p>
</cfoutput>


