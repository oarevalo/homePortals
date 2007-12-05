<cfscript>
	stAccountInfo = getValue("stAccountInfo");
	lstStorageProperties = getValue("lstStorageProperties");
	oStorage = getValue("oStorage");
	bIsAccountsSetup = getValue("bIsAccountsSetup");
</cfscript>

<div class="sectionMenu">
	<a href="?event=ehSettings.dspMain">General</a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="?event=ehSettings.dspAccounts"><strong>Accounts</strong></a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="?event=ehSettings.dspChangePassword">Change Password</a>
</div>

<cfoutput>
	<h2>Account Storage Settings</h2>
	
	<form name="frm" action="index.cfm" method="post">
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
							<input type="button" name="btnInitialize" value="Initialize Storage" onclick="document.location='?event=ehSettings.doInitializeAccountStorage'">
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
			<input type="hidden" name="event" value="ehSettings.doSaveAccountStorageSettings">
			<input type="submit" value="Apply Changes" name="btn">
			<input type="button" name="btnCancel" value="Return To Account Settings" onClick="document.location='?event=ehSettings.dspAccounts'">
		</p>
	</form>
</cfoutput>