<cfinclude template="../udf.cfm"> 

<!--- get reference to accounts object --->
<cfset oAccounts = createObject("Component", appState.stConfig.moduleLibraryPath & "Accounts.accounts")>

<!--- get accounts info --->
<cfset oAccounts.loadConfig()>
<cfset stAccountInfo = oAccounts.getConfig()>

<!--- check if account storage have been setup --->
<cfif stAccountInfo.storageType neq "custom" or (stAccountInfo.storageType eq "custom" and stAccountInfo.storageCFC neq "")>
	<cfset oStorage = oAccounts.getAccountStorage()>
	<cfset bIsAccountsSetup = oStorage.isInitialized()>
	<cfset lstStorageProperties = oStorage.getStorageSettingsList()>
<cfelse>
	<cfset oStorage = 0>
	<cfset bIsAccountsSetup = false>
</cfif>

<cfoutput>
	<h1>Account Storage Settings</h1>
	<p><a href="home.cfm?view=accounts"><< Return To Accounts</a></p>
	
	<form name="frm" action="home.cfm" method="post">
		<table border="0" width="600">
			<tr>
				<td colspan="2">
					The following fields are properties specific to the type of storage selected.
				</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td width="100">Storage Type:</td>
				<td>
					<b>#replaceList(stAccountInfo.storageType,"db,xml,custom","Database,XML Document,Custom Storage (" & stAccountInfo.storageCFC & ")")#</b>
				</td>
			</tr>
			<tr>
				<td>Status:</td>
				<td>
					<cfif bIsAccountsSetup>
						<div style="color:##006600;font-weight:bold;">Initialized</div>
					<cfelseif IsSimpleValue(oStorage)>
						<div style="color:##990000;font-weight:bold;">Not Initialized. Custom Storage CFC not a valid Coldfusion component.</div>
					<cfelse>
						<div style="color:##990000;font-weight:bold;">
							Not Initialized.
							&nbsp;&nbsp;
							<input type="button" name="btnInitialize" value="Initialize Storage" onclick="document.location='home.cfm?event=initializeAccountStorage'">
						</div>
					</cfif>
				</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<cfloop list="#lstStorageProperties#" index="item">
				<cfparam name="stAccountInfo.#item#" default="">
				<tr>
					<td width="100" style="color:##000000;">#item#:</td>
					<td width="230">
						<input 
								<cfif item eq "password">
									type="password" 
								<cfelse>
									type="text" 
								</cfif>
								value="#stAccountInfo[item]#" 
								name="#item#" 
								style="width:230px;font-size:11px;border:1px solid black;padding:3px;">
					</td>
				</tr>
				<tr><td colspan="2" style="font-size:5px;">&nbsp;</td></tr>
			</cfloop>
		</table>
		<p align="center">
			<input type="hidden" name="view" value="accountStorage">
			<input type="hidden" name="event" value="saveAccountStorageInfo">
			<input type="submit" value="Save Changes" name="btn">
		</p>
	</form>
</cfoutput>