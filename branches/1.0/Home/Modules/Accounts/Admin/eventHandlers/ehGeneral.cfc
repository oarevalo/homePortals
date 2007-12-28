<cfcomponent extends="eventHandler">

	<!------------------------------------------------->
	<!--- doSearch                                 ---->
	<!------------------------------------------------->
	<cffunction name="doSearch" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 
	
		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<!--- check that at least one field is requested --->
		<cfparam name="frm.username" default="">	
		<cfparam name="frm.lastname" default="">	
		<cfparam name="frm.email" default="">	
				
		<!--- get reference to accounts object --->
		<cfset accountsCFCPath = arguments.state.stConfig.moduleLibraryPath & "Accounts/accounts.cfc">
		<cfset oAccounts = createInstance(accountsCFCPath)>
		<cfset oAccounts.loadConfig()>
		<cfset request.qrySearchResults = oAccounts.SearchUsers(frm.username, frm.lastname, frm.email)>
			
		<cfreturn arguments.state>
	</cffunction>

	<!------------------------------------------------->
	<!--- doSave                                   ---->
	<!------------------------------------------------->
	<cffunction name="doSave" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 

		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>
		<cfset var NewUserID = "">

		<!--- validate data --->
		<cfparam name="frm.userID" default="">	
		<cfparam name="frm.username" default="">	
		<cfparam name="frm.firstName" default="">	
		<cfparam name="frm.middleName" default="">	
		<cfparam name="frm.lastName" default="">	
		<cfparam name="frm.email" default="">	

		<cfscript>
			if(frm.username eq "") throw("Username cannot be empty.");
			if(frm.email eq "") throw("Email address cannot be empty.");
			if(frm.userID eq "" and frm.password eq "") throw("Password cannot be empty.");
		</cfscript>
				
		<!--- get reference to accounts object --->
		<cfset accountsCFCPath = arguments.state.stConfig.moduleLibraryPath & "Accounts/accounts.cfc">
		<cfset oAccounts = createInstance(accountsCFCPath)>
		<cfset oAccounts.loadConfig()>
		
		<cfif frm.UserID neq "">
			<cfset oAccounts.UpdateAccount(frm.userID, frm.firstName, frm.middleName, frm.lastName, frm.email)>
			<cfset arguments.state.infoMessage = "Account Updated.">
		<cfelse>
			<cfset NewUserID = oAccounts.CreateAccount(frm.username, frm.password, frm.email)>
			<cfset oAccounts.UpdateAccount(NewUserID, frm.firstName, frm.middleName, frm.lastName, frm.email)>
			<cfset arguments.state.infoMessage = "Account Created.">
		</cfif>
			
		<cfreturn arguments.state>
	</cffunction>

	<!------------------------------------------------->
	<!--- doDelete                                 ---->
	<!------------------------------------------------->
	<cffunction name="doDelete" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 

		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<!--- validate data --->
		<cfparam name="frm.userID" default="">	

		<cfscript>
			if(frm.userID eq "") throw("Please indicate the user account to delete.");
		</cfscript>

		<!--- get reference to accounts object --->
		<cfset accountsCFCPath = arguments.state.stConfig.moduleLibraryPath & "Accounts/accounts.cfc">
		<cfset oAccounts = createInstance(accountsCFCPath)>
		<cfset oAccounts.loadConfig()>
		
		<!--- delete account --->
		<cfset oAccounts.delete(frm.userID)>
		
		<cfset arguments.state.infoMessage = "Account has been deleted.">
		<cfset arguments.state.view = "accountsManager/main">
		
		<cfreturn arguments.state>
	</cffunction>


	<!------------------------------------------------->
	<!--- doChangePassword                         ---->
	<!------------------------------------------------->
	<cffunction name="doChangePassword" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 

		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<!--- validate data --->
		<cfparam name="frm.userID" default="">	
		<cfparam name="frm.newPassword" default="">	

		<cfscript>
			if(frm.userID eq "") throw("Please indicate the user account to change its password.");
			if(frm.newPassword eq "") throw("Please indicate the new password.");
		</cfscript>

		<!--- get reference to accounts object --->
		<cfset accountsCFCPath = arguments.state.stConfig.moduleLibraryPath & "Accounts/accounts.cfc">
		<cfset oAccounts = createInstance(accountsCFCPath)>
		<cfset oAccounts.loadConfig()>
		
		<!--- change account password --->
		<cfset oAccounts.changePassword(frm.userID, frm.newPassword)>
		
		<cfset arguments.state.infoMessage = "Account password has been changed.">
		
		<cfreturn arguments.state>
	</cffunction>


	<!------------------------------------------------->
	<!--- doDeleteFile                             ---->
	<!------------------------------------------------->
	<cffunction name="doDeleteFile" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 

		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<!--- validate data --->
		<cfparam name="frm.userID" default="">	

		<cfscript>
			if(frm.userID eq "") throw("Please indicate the user account to delete.");
			if(frm.href eq "") throw("Please indicate the file to delete.");
		</cfscript>

		<!--- get reference to accounts object --->
		<cfset accountsCFCPath = arguments.state.stConfig.moduleLibraryPath & "Accounts/accounts.cfc">
		<cfset oAccounts = createInstance(accountsCFCPath)>
		<cfset oAccounts.loadConfig()>
		
		<!--- get users account --->
		<cfset qryAccount = oAccounts.getAccountByUserID(frm.userID)>
		
		<!--- check that user is found --->
		<cfif qryAccount.recordCount eq 0>
			<cfset throw("The requested user account cannot be found.")>
		</cfif>
		
		<!--- check that file is located within account --->
		<cfset accountDir = oAccounts.stConfig.accountsRoot & "/" & qryAccount.username>
		<cfif left(frm.href, len(accountDir)) neq accountDir>
			<cfset throw("The file to delete must be located within the user account.")>
		</cfif>
		
		<!--- delete file --->
		<cfif FileExists(ExpandPath(frm.href))>
			<cffile action="delete" file="#ExpandPath(frm.href)#">
		</cfif>
		
		<cfset arguments.state.infoMessage = "File has been deleted.">
		<cfset arguments.state.view = "accountsManager/edit">
		
		<cfreturn arguments.state>
	</cffunction>


	<!------------------------------------------------->
	<!--- doUploadFile                             ---->
	<!------------------------------------------------->
	<cffunction name="doUploadFile" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 

		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<!--- validate data --->
		<cfparam name="frm.userID" default="">	

		<cfscript>
			if(frm.userID eq "") throw("Please indicate the user account to upload a file to.");
			if(frm.uploadFile eq "") throw("Please indicate the file to upload.");
		</cfscript>

		<!--- get reference to accounts object --->
		<cfset accountsCFCPath = arguments.state.stConfig.moduleLibraryPath & "Accounts/accounts.cfc">
		<cfset oAccounts = createInstance(accountsCFCPath)>
		<cfset oAccounts.loadConfig()>
		
		<!--- get users account --->
		<cfset qryAccount = oAccounts.getAccountByUserID(frm.userID)>
		
		<!--- check that user is found --->
		<cfif qryAccount.recordCount eq 0>
			<cfset throw("The requested user account cannot be found.")>
		</cfif>

		<!--- upload file --->
		<cfset accountDir = oAccounts.stConfig.accountsRoot & "/" & qryAccount.username>
		<cffile action="upload" destination="#expandPath(accountDir)#" filefield="uploadFile" nameconflict="error">
		
		<cfset arguments.state.infoMessage = "File has been uploaded.">
		<cfset arguments.state.view = "accountsManager/edit">
		
		<cfreturn arguments.state>
	</cffunction>

	
</cfcomponent>