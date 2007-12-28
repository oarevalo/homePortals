<!--- Accounts Manager Edit View --->
<cfinclude template="../../udf.cfm"> 

<cfparam name="UserID" default="">

<!--- get reference to accounts object --->
<cfset accountsCFCPath = appState.stConfig.moduleLibraryPath & "Accounts/accounts.cfc">
<cfset oAccounts = createInstance(accountsCFCPath)>
<cfset oAccounts.loadConfig()>
<cfset qryAccount = oAccounts.getAccountByUserID(userID)>

<h1>Edit Account</h1>

<p><a href="home.cfm?view=accountsManager/main"><< Return To Search</a></p>

<cfoutput>
	<form name="frm" action="home.cfm" method="post">
	<table width="600">
		<cfif userID eq "">
			<tr>
				<td width="100">Username:</td>
				<td><input type="text" name="username" value="#qryAccount.username#" size="30"></td>
			</tr>
			<tr>
				<td width="100">Password:</td>
				<td><input type="text" name="password" value="#qryAccount.password#" size="30"></td>
			</tr>
		<cfelse>
			<tr>
				<td width="100">Username:</td>
				<td>
					<input type="text" name="username1" value="#qryAccount.username#" size="30" disabled="yes">
					<input type="hidden" name="username" value="#qryAccount.username#">
				</td>
			</tr>
		</cfif>
		<tr>
			<td>First Name:</td>
			<td><input type="text" name="firstName" value="#qryAccount.firstName#" size="30"></td>
		</tr>
		<tr>
			<td>Middle Name:</td>
			<td><input type="text" name="middleName" value="#qryAccount.middleName#" size="30"></td>
		</tr>
		<tr>
			<td>Last Name:</td>
			<td><input type="text" name="lastName" value="#qryAccount.lastName#" size="30"></td>
		</tr>
		<tr>
			<td>Email:</td>
			<td><input type="text" name="email" value="#qryAccount.email#" size="30"></td>
		</tr>
		<cfif UserID neq "">
			<tr>
				<td>Home:</td>
				<td><a href="#oAccounts.stConfig.accountsRoot#/#qryAccount.username#" target="_blank">#oAccounts.stConfig.accountsRoot#/#qryAccount.username#</a></td>
			</tr>
			<tr>
				<td colspan="2" style="font-size:9px;font-weight:bold;">
					Account Creted On #lsDateFormat(qryAccount.createDate)# #lsTimeFormat(qryAccount.createDate)#
				</td>
			</tr>
		</cfif>
		<tr><td colspan="2">&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<input type="hidden" name="UserID" value="#UserID#">
				<input type="hidden" name="event" value="accountsManager.doSave">
				<input type="submit" name="btnSave" value="Apply Changes">
				<cfif UserID neq "">
					<input type="button" name="btnResetPwd" value="Reset Password" onclick="doResetPassword('#UserID#')">
					<input type="button" name="btnDelete" value="Delete Account" onclick="doDeleteAccount('#UserID#')">
				</cfif>
			</td>
		</tr>
	</table>
	</form>
	
	<cfif UserID neq "">
		<cfset accountDir = oAccounts.stConfig.accountsRoot & "/" & qryAccount.username>
		<cfset siteURL = accountDir & "/site.xml">
		
		<cfif DirectoryExists(expandPath(accountDir))>
			
			<hr>
	
			<br><b>Account Files:</b>	
			<table class="tblGrid" width="600">
				<tr>
					<th width="10">&nbsp;</th>
					<th>Name</th>
					<th>Type</th>
					<th>Last Modified</th>
					<th>Size</th>
					<th>&nbsp;</th>
				</tr>
				<cfset tmpAccountSize = 0>
				#displayDirFiles(accountDir)#
				<tr>
					<td colspan="4" align="right" style="font-size:larger;"><strong>Account Size:</strong></td>
					<td align="right" style="font-size:larger;"><b>#NumberFormat(tmpAccountSize/1024)# kb</b></td>
					<td>&nbsp;</td>
				</tr>
			</table>	
			<form name="frmUpload" method="post" action="home.cfm" enctype="multipart/form-data">
				Upload File: <input type="file" name="uploadFile" value="">
				<input type="submit" name="btnUpload" value="Upload">
				<input type="hidden" name="event" value="accountsManager.doUploadFile">
				<input type="hidden" name="userID" value="#userID#">
			</form>
	
			<br><b>Site.xml</b>			
			<cfif FileExists(ExpandPath(siteURL))>
				<cffile action="read" file="#ExpandPath(siteURL)#" variable="txtDoc">
				<cfset xmlDoc = xmlParse(txtDoc)>
				<cfset aPages = xmlSearch(xmlDoc,"//page")>
				<cfset aCatalogs = xmlSearch(xmlDoc,"//catalog")>
				
				<br><em>Pages:</em>
				<cfif ArrayLen(aPages) gt 0>
					<table class="tblGrid" width="600">
						<tr>
							<th width="10">&nbsp;</th>
							<th>Title</th>
							<th>HREF</th>
							<th>Default?</th>
							<th>Private</th>
						</tr>
						<cfloop from="1" to="#arrayLen(aPages)#" index="i">
							<cfset tmpNode = aPages[i].xmlAttributes>
							<cfparam name="tmpNode.default" default="">
							<cfparam name="tmpNode.private" default="">
							<cfset pageURL = "#accountDir#/layouts/#tmpNode.href#">
							<cfset hpURL = "/home/home.cfm?currentHome=#pageURL#">
							<tr>
								<td><strong>#i#</strong></td>
								<td>#tmpNode.title#</td>
								<td>
									#tmpNode.href#
									[<a href="#pageURL#" target="_blank">xml</a>] 
									[<a href="#hpURL#" target="_blank">page</a>]								
								</td>
								<td align="center">#tmpNode.default#</td>
								<td align="center">#tmpNode.private#</td>
							</tr>
						</cfloop>
					</table>
				<cfelse>
					<b style="color:red;">No pages registered.</b>
				</cfif>
	
				<br><em>Catalogs:</em>
				<cfif ArrayLen(aCatalogs) gt 0>
					<table class="tblGrid" width="600">
						<tr>
							<th width="10">&nbsp;</th>
							<th>Name</th>
							<th>HREF</th>
						</tr>
						<cfloop from="1" to="#arrayLen(aCatalogs)#" index="i">
							<cfset tmpNode = aCatalogs[i].xmlAttributes>
							<tr>
								<td><strong>#i#</strong></td>
								<td>#tmpNode.Name#</td>
								<td>#tmpNode.href#</td>
							</tr>
						</cfloop>
					</table>
				<cfelse>
					<b style="color:red;">No catalogs registered.</b>
				</cfif>	
			<cfelse>
				<b style="color:red;">Site.xml missing!</b>
			</cfif>

		<cfelse>
			<b style="color:red;">Account directory missing!</b>
		</cfif>
	</cfif>
	
	
</cfoutput>


<!--- Javascript Functions --->
<cfsavecontent variable="tmpHead">
	<script type="text/javascript">
		function doResetPassword(userID) {
			var newPwd = prompt("Enter the new Password","Reset Password");
			if(newPwd!="") {
				document.location = 'home.cfm?event=accountsManager.doChangePassword&newPassword=' + newPwd + '&UserID=' + userID;	
			} else {
				alert("The new password cannot be empty.");	
			}
		}

		function doDeleteAccount(userID) {
			if(confirm('Are you sure you wish to delete this account and all related files?'))
				document.location = 'home.cfm?event=accountsManager.doDelete&UserID=' + userID;	
		}

		function doDeleteFile(userID,href) {
			if(confirm('Are you sure you wish to delete this file?'))
				document.location = 'home.cfm?event=accountsManager.doDeleteFile&UserID=' + userID + '&href=' + href;	
		}
	</script>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">



<!---- ColdFusion Functions ---->
<cffunction name="displayDirFiles">
	<cfargument name="path" required="true" type="string">
	<cfargument name="depth" required="false" type="numeric" default="0">
	
	<cfset var qryFiles = QueryNew("")>
	<cfdirectory action="list" name="qryFiles" directory="#ExpandPath(arguments.path)#">
	<cfquery name="qryFiles" dbtype="query">
		SELECT *
			FROM qryFiles
			ORDER BY Type DESC, Name
	</cfquery>

	<cfoutput query="qryFiles">
		<cfset pageURL = "#arguments.path#/#qryFiles.name#">
		<cfif qryFiles.type neq "Dir">
			<tr>
				<td><b>#qryFiles.currentRow#</b></td>
				<td>
					#repeatString("&nbsp;&nbsp;",arguments.depth)#
					#qryFiles.name#
					 [<a href="#pageURL#" target="_blank">link</a>]
				</td>
				<td align="center">#qryFiles.type#</td>
				<td align="center">#LsDateFormat(qryFiles.dateLastModified)# #LSTimeFormat(qryFiles.dateLastModified)#</td>
				<td align="right">#qryFiles.size#</td>
				<td align="center">
					<a href="javascript:doDeleteFile('#UserID#','#pageURL#');">Delete</a>
				</td>
			</tr>
		<cfelse>
			<tr>
				<td colspan="6"><b>#qryFiles.name#\</b></td>
			</tr>
			#displayDirFiles(pageURL, arguments.depth+1)#
		</cfif>
		<cfset tmpAccountSize = tmpAccountSize + qryFiles.size>
	</cfoutput>	
</cffunction>
