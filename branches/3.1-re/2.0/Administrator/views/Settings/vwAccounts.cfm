<cfscript>
	stAccountInfo = getValue("stAccountInfo");
	stConfigHelp = getValue("stConfigHelp");
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
	<form name="frm" action="index.cfm" method="post">
		<table class="dataFormTable">
			<tr>
				<td width="100" style="color:##000000;" valign="top">Storage Type:</td>
				<td>
					<input type="radio" value="db" name="storageType" onclick="hideCustomStorage()" <cfif stAccountInfo.storageType eq "db">checked</cfif>>Database &nbsp;&nbsp;
					<input type="radio" value="xml" name="storageType" onclick="hideCustomStorage()" <cfif stAccountInfo.storageType eq "xml">checked</cfif>>XML File &nbsp;&nbsp;
					<input type="radio" value="custom" name="storageType" 
								onclick="selectCustomStorage(this);"
								<cfif stAccountInfo.storageType eq "custom">checked</cfif>>Custom Storage
				
					&nbsp;&nbsp;&nbsp;<input type="button" value="Configure..." onclick="document.location='?event=ehSettings.dspAccountStorage'">
					
					<div id="fld_storageCFC" style="color:##000000;display:none;margin-top:5px;">
						Storage CFC: <input type="text" value="#stAccountInfo.storageCFC#" name="storageCFC" style="width:230px;font-size:11px;border:1px solid black;padding:3px;">
					</div>
				</td>
			</tr>
			<cfif IsSimpleValue(oStorage)>
				<tr>
					<td>&nbsp;</td>
					<td style="color:##990000;">
						The account storage cfc does not point to a valid ColdFusion component. Please
						refer to the developers technical documentation on how to create a custom
						account storage.
					</td>
				</tr>
				
			<cfelseif Not bIsAccountsSetup>
				<tr>
					<td>&nbsp;</td>
					<td style="color:##990000;">
						The account storage has not been properly initialized. Please
						make sure you configured it properly. The Account Storage
						can be configured and initialized by clicking on the <b>Settings...</b>
						button.
					</td>
				</tr>
			</cfif>
			
			<tr><td colspan="2">&nbsp;</td></tr>
			
			<tr valign="top">
				<td width="100" style="color:##000000;">Accounts Root:</td>
				<td>
					<input type="text" value="#stAccountInfo.accountsRoot#" name="accountsRoot" class="textField">
					<div class="formFieldTip">
						#stConfigHelp.accountsRoot#
					</div>
				</td>
			</tr>
			<tr valign="top">
				<td width="100" style="color:##000000;">HomePortals Root:</td>
				<td>
					<input type="text" value="#stAccountInfo.homeRoot#" name="homeRoot" class="textField">
					<div class="formFieldTip">
						#stConfigHelp.homeRoot#
					</div>
				</td>
			</tr>
			<tr valign="top">
				<td width="100" style="color:##000000;">Allow Account Registration:</td>
				<td>
					<input type="radio" value="true" name="allowRegisterAccount" <cfif stAccountInfo.allowRegisterAccount>checked</cfif>> Yes &nbsp;&nbsp;
					<input type="radio" value="false" name="allowRegisterAccount" <cfif not stAccountInfo.allowRegisterAccount>checked</cfif>> No
					<div class="formFieldTip">
						#stConfigHelp.allowRegisterAccount#
					</div>
				</td>
			</tr>

			<tr><td colspan="2">&nbsp;</td></tr>
			<tr><td colspan="2"><b>Templates:</b></td></tr>
			<tr><td colspan="2">These fields are used to provide documents that will be used as templates when creating new accounts and new pages.</td></tr>
			<tr><td colspan="2">&nbsp;</td></tr>

			<tr valign="top">
				<td width="100" style="color:##000000;">New account default page:</td>
				<td>
					<input type="text" value="#stAccountInfo.newAccountTemplate#" name="newAccountTemplate" class="textField">
					<div class="formFieldTip">
						#stConfigHelp.newAccountTemplate#
					</div>
				</td>
			</tr>

			<tr valign="top">
				<td width="100" style="color:##000000;">New page:</td>
				<td>
					<input type="text" value="#stAccountInfo.newPageTemplate#" name="newPageTemplate" class="textField">
					<div class="formFieldTip">
						#stConfigHelp.newPageTemplate#
					</div>
				</td>
			</tr>

			<tr valign="top">
				<td width="100" style="color:##000000;">New account site:</td>
				<td>
					<input type="text" value="#stAccountInfo.siteTemplate#" name="siteTemplate" class="textField">
					<div class="formFieldTip">
						#stConfigHelp.siteTemplate#
					</div>
				</td>
			</tr>
		</table>
		<div style="text-align:center;">
			<input type="hidden" name="event" value="ehSettings.doSaveAccountSettings">
			<input type="submit" value="Apply Changes" name="btn">
		</div>
	</form>
	<p>
		<b>Note:</b> For changes to be effective, you must  
		<a href="../index.cfm?refresh=1&refreshAccountInfo=1">Click Here</a>
	</p>			
</cfoutput>
