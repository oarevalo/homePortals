<cfcomponent hint="This cfc manages access to friends of an account">
	
	<cfset variables.oAccountsConfigBean = structNew()>
	<cfset variables.docName = "friends.xml">
	<cfset variables.clientDAOPath = "homePortalsAccounts.components.db."> <!--- here is where the DAO objects are located --->
	<cfset variables.oDataProvider = 0>	<!--- provides access to account data storage --->

	<cffunction name="init" returntype="friends" access="public">
		<cfargument name="configBean" type="Struct" required="true" hint="accounts config bean">
		<cfset variables.oAccountsConfigBean = arguments.configBean>
		<cfset loadDataProvider()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getFriends" returntype="query" access="public" hint="Returns a query with all friends of the given account">
		<cfargument name="accountName" type="string" required="yes">
		<cfset var dao = getFriendsDAO()>
		<cfset var qry = dao.search(accountName = arguments.accountName,
									confirmed = true)>
		<cfset var qryRet = queryNew("accountName")>
		
		<cfloop query="qry">
			<cfset queryAddRow(qryRet)>
			<cfset querySetCell(qryRet,"accountName",qry.accountName_friend)>
		</cfloop>
		
		<cfreturn qryRet>
	</cffunction>

	<cffunction name="isFriend" returntype="boolean" access="public" hint="Returns whether the given accounts are friends">
		<cfargument name="accountName" type="string" required="yes">
		<cfargument name="accountName_to_check" type="string" required="yes">
		<cfscript>
			var dao = getFriendsDAO();
			var qry = dao.search(accountName = arguments.accountName,
								 accountName_friend = arguments.accountName_to_check,
								 confirmed = true);
			
			return (qry.recordCount gt 0);
		</cfscript>
		<cfreturn rtn>
	</cffunction>

	<cffunction name="remove" returntype="void" access="public" hint="Removes a friendship relationship">
		<cfargument name="accountName" type="string" required="yes">
		<cfargument name="accountName_to_remove" type="string" required="yes">
		<cfscript>
			var dao = getFriendsDAO();
			var qry = dao.search(accountName = arguments.accountName,
								 accountName_friend = arguments.accountName_to_remove);
			
			if(qry.recordCount gt 0) {
				dao.delete(friendID = qry.friendID);
			}
		</cfscript>
	</cffunction>

	
	<!--- Friendship Requests --->
	
	<cffunction name="getFriendRequests" returntype="query" access="public" hint="Returns a query with all friends requests of the given account">
		<cfargument name="accountName" type="string" required="yes">
		<cfscript>
			var dao = getFriendsDAO();
			var qryRet = queryNew("sender,recipient,requestDate");
			var qry = 0;
			
			
			// get all outgoing friendship requests
			qry = dao.search(accountName = arguments.accountName,
							 confirmed = false);
			
			for(i=1;i lte qry.recordCount;i=i+1) {
				queryAddRow(qryRet);
				querySetcell(qryRet,"sender",qry.accountName[i]);
				querySetcell(qryRet,"recipient",qry.accountName_friend[i]);
				querySetcell(qryRet,"requestDate",qry.requestDate[i]);
			}

			// get all incoming friendship requests
			qry = dao.search(accountName_friend = arguments.accountName,
							 confirmed = false);
			
			for(i=1;i lte qry.recordCount;i=i+1) {
				queryAddRow(qryRet);
				querySetcell(qryRet,"sender",qry.accountName[i]);
				querySetcell(qryRet,"recipient",qry.accountName_friend[i]);
				querySetcell(qryRet,"requestDate",qry.requestDate[i]);
			}
			
			return qryRet;
		</cfscript>
	</cffunction>

	<cffunction name="hasFriendRequest" returntype="boolean" access="public" hint="Returns whether the given account has a friendship request">
		<cfargument name="sender" type="string" required="yes">
		<cfargument name="recipient" type="string" required="yes">
		<cfscript>
			var dao = getFriendsDAO();
			var qry = dao.search(accountName = arguments.sender,
								 accountName_friend = arguments.recipient,
								 confirmed = false);

			return (qry.recordCount gt 0);
		</cfscript>
		<cfreturn rtn>
	</cffunction>
	
	<cffunction name="addFriendshipRequest" returntype="void" access="public" hint="Saves a friendship request">
		<cfargument name="sender" type="string" required="yes">
		<cfargument name="recipient" type="string" required="yes">

		<cfscript>
			var dao = getFriendsDAO();
					
			// check if the frienship exists 
			if(isFriend(arguments.sender, arguments.recipient))
				throw("#arguments.sender# and #arguments.recipient# are already friends","homeportals.friends.friendshipExists");

			// check if the frienship request exists 
			if(hasFriendRequest(arguments.sender, arguments.recipient) or hasFriendRequest(arguments.recipient, arguments.sender))
				throw("The is already a frdiendship request between #arguments.sender# and #arguments.recipient#","homeportals.friends.alreadyInvited");
			
			// add friendship request
			dao.save(accountName = arguments.sender,
					 accountName_friend = arguments.recipient,
					 confirmed = false,
					 requestDate = now());
		</cfscript>
	</cffunction>
		
	<cffunction name="removeFriendshipRequest" returntype="void" access="public" hint="Removes a friendship request">
		<cfargument name="accountName" type="string" required="yes">
		<cfargument name="accountName_to_remove" type="string" required="yes">
		<cfscript>
			var dao = getFriendsDAO();
			var qry = dao.search(accountName = arguments.accountName,
								 accountName_friend = arguments.accountName_to_remove,
								 confirmed = false);
								 
			if(qry.recordCount gt 0) {
				dao.delete(friendID = qry.friendID);
			}		
		</cfscript>
	</cffunction>		
		
	<cffunction name="acceptFriendshipRequest" returntype="void" access="public" hint="Accepts a friendship request from the given account. The request has to be accepted by the recipient">
		<cfargument name="sender" type="string" required="yes" hint="The username of the account that sent the request">
		<cfargument name="recipient" type="string" required="yes" hint="The username of the account that received the friendship request">
		<cfscript>
			var dao = getFriendsDAO();
			var qry = dao.search(accountName = arguments.sender,
								 accountName_friend = arguments.recipient,
								 confirmed = false);

			if(qry.recordCount gt 0) {
				dao.save(id = qry.friendID, confirmed = true);
			}
		</cfscript>
	</cffunction>
		


		
	<!------ Private Methods ----->
			
	<cffunction name="loadDataProvider" access="private" returntype="void" hint="Loads and configures the instance of the dataprovider to be used">
		<cfscript>
			var storageType = variables.oAccountsConfigBean.getStorageType();
			var pkgPath = "homePortalsAccounts.components.lib.DAOFactory.";
			var oConfigBean = 0;

			// check that dataprovider exists
			if(not fileExists(expandPath("/homePortalsAccounts/components/lib/DAOFactory/" & storageType & "DataProviderConfigBean.cfc")))
				throw("Accounts storage type [#storageType#] is not supported","","homePortals.accounts.invalidStorageType");
					
			// create config		
			oConfigBean = createObject("component", pkgPath & storageType & "DataProviderConfigBean").init();
			
			// configure bean
			switch(storageType) {
				case "db":
					oConfigBean.setDSN( variables.oAccountsConfigBean.getDatasource() );
					oConfigBean.setUsername( variables.oAccountsConfigBean.getUsername() );
					oConfigBean.setPassword( variables.oAccountsConfigBean.getPassword() );
					oConfigBean.setDBType( variables.oAccountsConfigBean.getDBType() );
					break;
					
				case "xml":
					oConfigBean.setDataRoot( variables.oAccountsConfigBean.getDataRoot() );
					break;
			}

			// initialize dataProvider
			variables.oDataProvider = createObject("component", pkgPath & storageType & "DataProvider").init(oConfigBean);
		</cfscript>	
	</cffunction>	

	<cffunction name="getFriendsDAO" access="package" returntype="homePortalsAccounts.components.lib.DAOFactory.DAO" hint="returns a properly configured instance of a DAO">
		<cfset var oDAO = createObject("component", variables.clientDAOPath & "friendsDAO")>
		<cfset oDAO.init(variables.oDataProvider)>
		<cfreturn oDAO>
	</cffunction>	
				
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>
				
</cfcomponent>