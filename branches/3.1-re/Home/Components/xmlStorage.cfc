<cfcomponent extends="storage">

	<cfset variables.lstStorageSettings = "storageFileHREF">

	<!--------------------------------------->
	<!----  isInitialized				  ----->
	<!--------------------------------------->
	<cffunction name="isInitialized" returntype="boolean" access="public" hint="Returns whether the account storage has been initialized">
		<cfset var bRet = false>

		<cftry>
			<cfset xmlDoc = getStorage()>
			<cfset bRet = true>
			
			<cfcatch type="any">
				<cfset bRet = false>
			</cfcatch>
		</cftry>
		
		<cfreturn bRet> 
	</cffunction>

	<!--------------------------------------->
	<!----  initializeStorage 	  	  ----->
	<!--------------------------------------->
	<cffunction name="initializeStorage" access="public" hint="initializes the account storage">
		<cfset var href = oAccountsConfigBean.getStorageFileHREF()>
		<cfset var xmlDoc = xmlNew()>
		
		<cfset xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "accountStorage")>
		<cfset xmlDoc.xmlRoot.xmlAttributes["createdOn"] = lsDateFormat(now())>
		<cfset xmlDoc.xmlRoot.xmlAttributes["host"] = cgi.SERVER_NAME>
		
		<cfif href neq "">
			<cfset saveStorage(xmlDoc)>
		<cfelse>
			<cfthrow message="Storage file not defined." type="homePortals.accounts.storageFileNotDefined">
		</cfif>				
	</cffunction>

	<!--------------------------------------->
	<!----  search   				  ----->
	<!--------------------------------------->
	<cffunction name="search" access="public" returntype="query" hint="Searches account records.">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="username" type="string" required="no" default="">
		<cfargument name="lastname" type="string" required="no" default="">
		<cfargument name="email" type="string" required="no" default="">
		<cfargument name="orderBy" type="string" required="no" default="Username">
		<cfset var qry = QueryNew("userID,userName,password,firstName,middleName,lastName,email,createDate")>
		
		<!--- get account data in xml format --->
		<cfset xmlDoc = getStorage()>
		
		<!--- transform to a query --->
		<cfset aAccounts = xmlSearch(xmlDoc,"//account")>
		<cfloop from="1" to="#arrayLen(aAccounts)#" index="i">
			<cfset thisAccountAttr = aAccounts[i].xmlAttributes>
			<cfparam name="thisAccountAttr.userID" default="">
			<cfparam name="thisAccountAttr.userName" default="">
			<cfparam name="thisAccountAttr.password" default="">
			<cfparam name="thisAccountAttr.firstName" default="">
			<cfparam name="thisAccountAttr.middleName" default="">
			<cfparam name="thisAccountAttr.lastName" default="">
			<cfparam name="thisAccountAttr.email" default="">
			<cfparam name="thisAccountAttr.CreateDate" type="date">
			
			<cfset QueryAddRow(qry)>
			<cfset QuerySetCell(qry,"userID",thisAccountAttr.userID)>
			<cfset QuerySetCell(qry,"userName",thisAccountAttr.userName)>
			<cfset QuerySetCell(qry,"password",thisAccountAttr.password)>
			<cfset QuerySetCell(qry,"firstName",thisAccountAttr.firstName)>
			<cfset QuerySetCell(qry,"middleName",thisAccountAttr.middleName)>
			<cfset QuerySetCell(qry,"lastName",thisAccountAttr.lastName)>
			<cfset QuerySetCell(qry,"email",thisAccountAttr.email)>
			<cfset QuerySetCell(qry,"CreateDate",thisAccountAttr.createDate)>
		</cfloop>
		
		<!--- do the search --->
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qry
				
				<cfif arguments.userID neq "">
					WHERE userID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UserID#">
				<cfelse>
					WHERE 1=1
						<cfif arguments.username neq "">AND userName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#"></cfif>
						<cfif arguments.lastname neq "">AND lastName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.lastname#"></cfif>
						<cfif arguments.email neq "">AND email LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#"></cfif>
				</cfif>

				ORDER BY #arguments.orderBy#
		</cfquery>	

		<cfreturn qry>
	</cffunction>

	<!--------------------------------------->
	<!----  create					  ----->
	<!--------------------------------------->
	<cffunction name="create" access="public" hint="Creates a new account record." returntype="string">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="FirstName" type="string" required="no" default="">
		<cfargument name="MiddleName" type="string" required="no" default="">
		<cfargument name="LastName" type="string" required="no" default="">
		<cfargument name="Email" type="string" required="no" default="">
		
		<cfset var newUserID = createUUID()>
		<cfset var xmlDoc = getStorage()>
		
		<!--- create new node --->
		<cfset newNode = xmlElemNew(xmlDoc,"account")>
		<cfset newNode.xmlAttributes["userID"] = newUserID>
		<cfset newNode.xmlAttributes["username"] = arguments.username>
		<cfset newNode.xmlAttributes["password"] = hash(arguments.password)>
		<cfset newNode.xmlAttributes["email"] = arguments.email>
		<cfset newNode.xmlAttributes["firstName"] = arguments.firstName>
		<cfset newNode.xmlAttributes["middleName"] = arguments.middleName>
		<cfset newNode.xmlAttributes["lastName"] = arguments.lastName>
		<cfset newNode.xmlAttributes["createDate"] = now()>
		
		<!--- append node to xml document --->
		<cfset arrayAppend(xmlDoc.xmlRoot.xmlChildren, newNode)>
		
		<!--- save changes --->
		<cfset saveStorage(xmlDoc)>

		<cfreturn newUserID>
	</cffunction>

	<!--------------------------------------->
	<!----  update					  ----->
	<!--------------------------------------->
	<cffunction name="update" access="public" hint="Updates an account record.">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="firstName" type="string" required="yes">
		<cfargument name="middleName" type="string" required="yes">
		<cfargument name="lastName" type="string" required="yes">
		<cfargument name="email" type="string" required="yes">
		
		<cfset var xmlDoc = getStorage()>
		
		<cfloop from="1" to="#arrayLen(xmlDoc.xmlRoot.xmlChildren)#" index="i">
			<cfset tmpNode = xmlDoc.xmlRoot.xmlChildren[i]>
			<cfif tmpNode.xmlName eq "account" 
					and structKeyExists(tmpNode.xmlAttributes,"userID")
					and tmpNode.xmlAttributes.userID eq arguments.userID>
				<cfset tmpNode.xmlAttributes["firstName"] = arguments.firstName>
				<cfset tmpNode.xmlAttributes["middleName"] = arguments.middleName>
				<cfset tmpNode.xmlAttributes["lastName"] = arguments.lastName>
				<cfset tmpNode.xmlAttributes["email"] = arguments.email>			
			</cfif>
		</cfloop>
	
		<!--- save changes --->
		<cfset saveStorage(xmlDoc)>
	</cffunction>

	<!--------------------------------------->
	<!----  delete          			  ----->
	<!--------------------------------------->
	<cffunction name="delete" access="public" hint="Deletes an account record.">
		<cfargument name="userID" type="string" required="yes">
		<cfset var xmlDoc = getStorage()>
		<cfset var bNodeFound = false>
		
		<cfloop from="1" to="#arrayLen(xmlDoc.xmlRoot.xmlChildren)#" index="i">
			<cfset tmpNode = xmlDoc.xmlRoot.xmlChildren[i]>
			<cfif tmpNode.xmlName eq "account" 
					and structKeyExists(tmpNode.xmlAttributes,"userID")
					and tmpNode.xmlAttributes.userID eq arguments.userID>
				<cfset bNodeFound = true>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<cfif bNodeFound>
			<!--- delete node --->
			<cfset ArrayDeleteAt(xmlDoc.xmlRoot.xmlChildren,i)>

			<!--- save changes --->
			<cfset saveStorage(xmlDoc)>
		</cfif>
	</cffunction>

	<!--------------------------------------->
	<!----  changePassword   		      ----->
	<!--------------------------------------->
	<cffunction name="changePassword" access="public" hint="Change accont password.">
		<cfargument name="UserID" type="string" required="yes">
		<cfargument name="NewPassword" type="string" required="yes">

		<cfset var xmlDoc = getStorage()>
		
		<cfloop from="1" to="#arrayLen(xmlDoc.xmlRoot.xmlChildren)#" index="i">
			<cfset tmpNode = xmlDoc.xmlRoot.xmlChildren[i]>
			<cfif tmpNode.xmlName eq "account" 
					and structKeyExists(tmpNode.xmlAttributes,"userID")
					and tmpNode.xmlAttributes.userID eq arguments.userID>
				<cfset tmpNode.xmlAttributes["password"] = hash(arguments.newpassword)>
			</cfif>
		</cfloop>
	
		<!--- save changes --->
		<cfset saveStorage(xmlDoc)>
	</cffunction>



	<!------------  P R I V A T E      M E T H O D S ------------------>
	
	<!--------------------------------------->
	<!----  getStorage   				----->
	<!--------------------------------------->
	<cffunction name="getStorage" access="private" returntype="xml" hint="Reads and returns the xml document used for account storage">
		<cfset var xmlDoc = xmlNew()>
		<cfset var href = oAccountsConfigBean.getStorageFileHREF()>

		<cfif href neq "">
			<!--- check that file exists --->
			<cfif fileExists(expandPath(href))>
				<cfset xmlDoc = xmlParse(expandPath(href))>
			<cfelse>
				<cfthrow message="Storage file doesn't exist." type="homePortals.accounts.storageFileNotFound">
			</cfif>
		<cfelse>
			<cfthrow message="Storage file not defined." type="homePortals.accounts.storageFileNotDefined">
		</cfif>		
					
		<cfreturn xmlDoc>
	</cffunction>

	<!--------------------------------------->
	<!----  saveStorage 				  ----->
	<!--------------------------------------->
	<cffunction name="saveStorage" access="private" hint="Saves the xml document to disk">
		<cfargument name="xmlDoc" type="xML" required="true">
		<cfset var href = oAccountsConfigBean.getStorageFileHREF()>

		<cfif href neq "">
			<cffile action="write" 
					file="#expandPath(href)#" 
					output="#toString(arguments.xmlDoc)#"
					attributes="normal" 
					mode="644">
		<cfelse>
			<cfthrow message="Storage file not defined." type="homePortals.accounts.storageFileNotDefined">
		</cfif>				
	</cffunction>



</cfcomponent>