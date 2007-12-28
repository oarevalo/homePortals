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
<cfelse>
	<cfset oStorage = 0>
	<cfset bIsAccountsSetup = false>
</cfif>

<cfscript>
	lstKeys = "accountsRoot,homeRoot,mailServer,emailAddress,newAccountTemplate,newPageTemplate,siteTemplate,allowRegisterAccount";

	stConfigHelp = structNew();
	stConfigHelp.accountsRoot = "Base path for the HomePortals Accounts files.";
	stConfigHelp.homeRoot = "Base path for the HomePortals installation.";
	stConfigHelp.mailServer = "Mail server addresss. Leave empty to use default ColdFusion settings.";
	stConfigHelp.emailAddress = "Email address to use as sender for emails related to HomePortals accounts.";
	stConfigHelp.newAccountTemplate = "Document to use as template for the main page when creating new accounts.";
	stConfigHelp.newPageTemplate = "Document to use as template when creating a new HomePortals page.";
	stConfigHelp.siteTemplate = "Default document to use as Site descriptor file for new accounts.";
	stConfigHelp.allowRegisterAccount = "Allows open registration for new accounts.";
</cfscript>

<cfoutput>
	<h1>Accounts</h1>
	<form name="frm" action="home.cfm" method="post">
		<table border="0" width="600">
			<tr>
				<td colspan="3">
					The following fields are used to configure the HomePortals Accounts system.
				</td>
			</tr>
			<tr><td colspan="3">&nbsp;</td></tr>
			
			<!----
			<cfif Not bIsAccountsSetup>
				<tr>
					<td style="color:##990000;" colspan="3">
						Account Table has not been created. Please complete the following information
						to create the necessary tables on your database. <br><br>
						HomePortals supports automatic table setup for MS SQL Server and MySQL database,
						other databases will require you to manually create the tables.<br>
						You may also review the sql scripts (
							<a href="../docs/sql/mssql.sql">MS SQL</a> |
							<a href="../docs/sql/mysql.sql">MySQL</a>)
					</td>
				</tr>
				<tr><td colspan="3">&nbsp;</td></tr>
				<tr>
					<td width="100" style="color:##000000;">DB Type:</td>
					<td width="230">
						<select name="dbtype" style="width:230px;font-size:11px;border:1px solid black;padding:3px;">
							<option value=""></option>
							<option value="MSSQL">MS SQL Server</option>
							<option value="MySQL">MySQL</option>
						</select>
					</td>
					<td width="200" style="font-size:11px;">&nbsp;</td>
				</tr>
				<tr><td colspan="3">&nbsp;</td></tr>			
			</cfif>
			----->
			
			<tr>
				<td width="100" style="color:##000000;" valign="top">Storage Type:</td>
				<td colspan="2">
					<input type="radio" value="db" name="storageType" onclick="hideCustomStorage()" <cfif stAccountInfo.storageType eq "db">checked</cfif>>Database &nbsp;&nbsp;
					<input type="radio" value="xml" name="storageType" onclick="hideCustomStorage()" <cfif stAccountInfo.storageType eq "xml">checked</cfif>>XML File &nbsp;&nbsp;
					<input type="radio" value="custom" name="storageType" 
								onclick="selectCustomStorage(this);"
								<cfif stAccountInfo.storageType eq "custom">checked</cfif>>Custom Storage
				
					&nbsp;&nbsp;&nbsp;<input type="button" value="Settings..." onclick="document.location='home.cfm?view=accountStorage'">
					
					<div id="fld_storageCFC" style="color:##000000;display:none;margin-top:5px;">
						Storage CFC: <input type="text" value="#stAccountInfo.storageCFC#" name="storageCFC" style="width:230px;font-size:11px;border:1px solid black;padding:3px;">
					</div>
				</td>
			</tr>
			<cfif IsSimpleValue(oStorage)>
				<tr>
					<td>&nbsp;</td>
					<td style="color:##990000;" colspan="2">
						The account storage cfc does not point to a valid ColdFusion component. Please
						refer to the developers technical documentation on how to create a custom
						account storage.
					</td>
				</tr>
				
			<cfelseif Not bIsAccountsSetup>
				<tr>
					<td>&nbsp;</td>
					<td style="color:##990000;" colspan="2">
						The account storage has not been properly initialized. Please
						make sure you configured it properly. The Account Storage
						can be configured and initialized by clicking on the <b>Settings...</b>
						button.
					</td>
				</tr>
			</cfif>
			
			<tr><td colspan="3">&nbsp;</td></tr>
			
			<cfloop list="#lstKeys#" index="item">
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
					<td width="200" style="font-size:11px;">
						#stConfigHelp[item]#
					</td>
				</tr>
				<tr><td colspan="3" style="font-size:5px;">&nbsp;</td></tr>
			</cfloop>
		</table>
		<p align="center">
			<input type="hidden" name="view" value="accounts">
			<input type="hidden" name="event" value="saveAccountInfo">
			<input type="submit" value="Save Changes" name="btn">
		</p>
	</form>
	<br>
	<p>
		<b>Note:</b> For changes to be effective, you must  
		<a href="../index.cfm?currentHome=#stAccountInfo.accountsRoot#/default/layouts/public.xml&refresh=1&refreshAccountInfo=1">Click Here</a>
	</p>
</cfoutput>

