<cfcomponent hint="This cfc manages access to friends of an account">
	
	<cfset variables.oAccountsConfigBean = structNew()>
	<cfset variables.docName = "friends.xml">
	
	<cffunction name="init" returntype="friends" access="public">
		<cfargument name="configBean" type="Struct" required="true" hint="accounts config bean">
		<cfset variables.oAccountsConfigBean = arguments.configBean>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getFriends" returntype="query" access="public" hint="Returns a query with all friends of the given account">
		<cfargument name="userName" type="string" required="yes">
		<cfscript>
			var xmlDoc = 0;
			var qry = queryNew("username");
			var i = 0;
			var xmlNode = 0;
			
			// get the xml document for the friends
			xmlDoc = getFriendsXML(arguments.userName);

			// convert xml document into query
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				if(xmlNode.xmlName eq "friend") {
					queryAddRow(qry);
					querySetCell(qry,"username",xmlNode.xmlAttributes.userName);
				}
			}
			
			return qry;
		</cfscript>
	</cffunction>

	<cffunction name="isFriend" returntype="boolean" access="public" hint="Returns whether the given accounts are friends">
		<cfargument name="userName" type="string" required="yes">
		<cfargument name="userName_to_check" type="string" required="yes">
		<cfscript>
			var rtn = false;
			var xmlDoc = 0;
			var aFriend = arrayNew(1);
			
			// get the xml document for the friends
			xmlDoc = getFriendsXML(arguments.userName);

			aFriend = xmlSearch(xmlDoc, "//friend[@userName='#arguments.userName_to_check#']");
			
			rtn = (arrayLen(aFriend) gt 0);
		</cfscript>
		<cfreturn rtn>
	</cffunction>

	<cffunction name="remove" returntype="void" access="public" hint="Removes a friendship relationship">
		<cfargument name="userName" type="string" required="yes">
		<cfargument name="userName_to_remove" type="string" required="yes">
		<cfscript>
			var xmlDoc = 0;
			var i = 0;
			var xmlNode = 0;

			// get the xml document for the friends
			xmlDoc = getFriendsXML(arguments.userName);
						
			// get the xml document for the friends
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				if(xmlNode.xmlName eq "friend" and xmlNode.xmlAttributes.userName eq arguments.userName_to_remove) {
					arrayDeleteAt(xmlDoc.xmlRoot.xmlChildren, i);
					break;
				}
			}
			
			// save changes
			saveFriendsXML(arguments.userName, xmlDoc);
		
		</cfscript>
	</cffunction>

	<cffunction name="addFriendship" returntype="void" access="public" hint="Saves a friendship relationship">
		<cfargument name="userName1" type="string" required="yes">
		<cfargument name="userName2" type="string" required="yes">
		
		<cfscript>
			var xmlDoc = 0;
			var xmlNode = 0;
			
			// check that both accounts exist
			if(Not verifyAccount(arguments.userName1)) throw("Account #arguments.userName1# does not exist","homeportals.friends.accountNotFound");
			if(Not verifyAccount(arguments.userName2)) throw("Account #arguments.userName2# does not exist","homeportals.friends.accountNotFound");
			
			// if the frienship exists then get out
			if(isFriend(arguments.userName1, arguments.userName2))
				throw("#arguments.userName1# and #arguments.userName2# are already friends","homeportals.friends.friendshipExists");
	
			// friend doesnt exist, so create the relationship
			xmlDoc = getFriendsXML(arguments.userName1);
			xmlNode = xmlElemNew(xmlDoc, "friend");
			xmlNode.xmlAttributes["userName"] = arguments.userName2;
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			
			
			// save the updated document
			saveFriendsXML(arguments.userName1, xmlDoc);
		</cfscript>
		
	</cffunction>
	
	
	<!--- Friendship Requests --->
	
	<cffunction name="getFriendRequests" returntype="query" access="public" hint="Returns a query with all friends requests of the given account">
		<cfargument name="userName" type="string" required="yes">
		<cfscript>
			var xmlDoc = 0;
			var qry = queryNew("sender,recipient,requestDate");
			var i = 0;
			var xmlNode = 0;
			
			// get the xml document for the friends
			xmlDoc = getFriendsXML(arguments.userName);

			// convert xml document into query
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				if(xmlNode.xmlName eq "friendRequest") {
					queryAddRow(qry);
					querySetCell(qry,"sender",xmlNode.xmlAttributes.sender);
					querySetCell(qry,"recipient",xmlNode.xmlAttributes.recipient);
					if(structKeyExists(xmlNode.xmlAttributes,"requestDate"))
						querySetCell(qry,"requestDate",xmlNode.xmlAttributes.requestDate);
				}
			}
			
			return qry;
		</cfscript>
	</cffunction>

	<cffunction name="hasFriendRequest" returntype="boolean" access="public" hint="Returns whether the given account has a friendship request">
		<cfargument name="accountToCheck" type="string" required="yes">
		<cfargument name="sender" type="string" required="yes">
		<cfargument name="recipient" type="string" required="yes">
		<cfscript>
			var rtn = false;
			var xmlDoc = 0;
			var aFriend = arrayNew(1);
			
			// get the xml document for the friends
			xmlDoc = getFriendsXML(arguments.accountToCheck);

			aFriend = xmlSearch(xmlDoc, "//friendRequest[@sender='#arguments.sender#' and @recipient='#arguments.recipient#']");
			
			rtn = (arrayLen(aFriend) gt 0);
		</cfscript>
		<cfreturn rtn>
	</cffunction>
	
	<cffunction name="addFriendshipRequest" returntype="void" access="public" hint="Saves a friendship request">
		<cfargument name="sender" type="string" required="yes">
		<cfargument name="recipient" type="string" required="yes">

		<cfscript>
			var xmlDoc = 0;
			var xmlNode = 0;
			
			// check that both accounts exist
			if(Not verifyAccount(arguments.sender)) throw("Account #arguments.userName1# does not exist","homeportals.friends.accountNotFound");
			if(Not verifyAccount(arguments.recipient)) throw("Account #arguments.userName2# does not exist","homeportals.friends.accountNotFound");
			
			// check if the frienship exists 
			if(isFriend(arguments.sender, arguments.recipient))
				throw("#arguments.sender# and #arguments.recipient# are already friends","homeportals.friends.friendshipExists");

			// check if the frienship request exists 
			if(hasFriendRequest(arguments.sender, arguments.sender, arguments.recipient))
				throw("#arguments.sender# and #arguments.recipient# are already friends","homeportals.friends.alreadyInvited");
			
			// add friendship request to both accounts
			xmlDoc = getFriendsXML(arguments.sender);
			xmlNode = xmlElemNew(xmlDoc, "friendRequest");
			xmlNode.xmlAttributes["sender"] = arguments.sender;
			xmlNode.xmlAttributes["recipient"] = arguments.recipient;
			xmlNode.xmlAttributes["requestDate"] = dateFormat(now(),"mm/dd/yyyy");
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			saveFriendsXML(arguments.sender, xmlDoc);

			xmlDoc = getFriendsXML(arguments.recipient);
			xmlNode = xmlElemNew(xmlDoc, "friendRequest");
			xmlNode.xmlAttributes["sender"] = arguments.sender;
			xmlNode.xmlAttributes["recipient"] = arguments.recipient;
			xmlNode.xmlAttributes["requestDate"] = dateFormat(now(),"mm/dd/yyyy");
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			saveFriendsXML(arguments.recipient, xmlDoc);
		</cfscript>
	</cffunction>
		
	<cffunction name="removeFriendshipRequest" returntype="void" access="public" hint="Removes a friendship request">
		<cfargument name="userName" type="string" required="yes">
		<cfargument name="userName_to_remove" type="string" required="yes">
		<cfscript>
			var xmlDoc = 0;
			var i = 0;
			var xmlNode = 0;

			// get the xml document for the friends
			xmlDoc = getFriendsXML(arguments.userName);
						
			// get the xml document for the friends
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				if(xmlNode.xmlName eq "friendRequest" and 
						(xmlNode.xmlAttributes.recipient eq arguments.userName_to_remove
							or xmlNode.xmlAttributes.sender eq arguments.userName_to_remove
						)
					)						{
					arrayDeleteAt(xmlDoc.xmlRoot.xmlChildren, i);
					break;
				}
			}
			
			// save changes
			saveFriendsXML(arguments.userName, xmlDoc);
		</cfscript>
	</cffunction>		
		
	<cffunction name="acceptFriendshipRequest" returntype="void" access="public" hint="Accepts a friendship request from the given account. The request has to be accepted by the recipient">
		<cfargument name="sender" type="string" required="yes" hint="The username of the account that sent the request">
		<cfargument name="recipient" type="string" required="yes" hint="The username of the account that received the friendship request">
		<cfscript>
		
			// check that both accounts exist
			if(Not verifyAccount(arguments.sender)) throw("Account #arguments.sender# does not exist","homeportals.friends.accountNotFound");
			if(Not verifyAccount(arguments.recipient)) throw("Account #arguments.recipient# does not exist","homeportals.friends.accountNotFound");
		
			// check that there is a friend request received (this is to enforce that requests must be accepted by the recipient)
			if(Not hasFriendRequest(arguments.recipient, arguments.recipient, arguments.sender))
				throw("#arguments.recipient# has not received any friendship request from #arguments.sender#","homePortals.homeportals.friendRequestNotFound");

			// add the friendship relation on both accounts
			addFriendship(arguments.sender, arguments.recipient);
			addFriendship(arguments.recipient, arguments.sender);
			
			// remove the friendship request on the recipient
			removeFriendshipRequest(arguments.sender, arguments.recipient);
			removeFriendshipRequest(arguments.recipient, arguments.sender);
		</cfscript>
	</cffunction>
		


		
	<!------ Private Methods ----->

	<cffunction name="getFriendsXML" returntype="xml" access="private" hint="Returns the contents of the friends xml document. If the document doesn't exist, returns an empty friend xml object.">
		<cfargument name="userName" type="string" required="yes">
	
		<cfset var xmlDoc = 0>
		<cfset var docPath = oAccountsConfigBean.getAccountsRoot() & "/" & arguments.userName & "/" & variables.docName>
		
		<!--- check that account directory exists, we use this as a check of account existence --->
		<cfif Not verifyAccount(arguments.userName)>
			<cfthrow message="Account does not exist" type="homeportals.friends.accountNotFound">
		</cfif>
		
		<cfif fileExists(expandPath(docPath))>
			<cflock name="readFriendDoc_#arguments.userName#" timeout="30">
				<cfset xmlDoc = xmlParse(expandPath(docPath))>
			</cflock>
		<cfelse>
			<cfset xmlDoc = xmlNew()>
			<cfset xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "friends")>
		</cfif>

		<cfreturn xmlDoc>		
	</cffunction>	
		
	<cffunction name="saveFriendsXML" returntype="void" access="private" hint="Saves the friends xml document for the given account">
		<cfargument name="userName" type="string" required="yes">
		<cfargument name="xmlDoc" type="xml" required="true">
		
		<cfset var docPath = oAccountsConfigBean.getAccountsRoot() & "/" & arguments.userName & "/" & variables.docName>
		
		<cflock name="readFriendDoc_#arguments.userName#" timeout="30">
			<cffile action="write" file="#expandPath(docPath)#" output="#toString(arguments.xmlDoc)#">
		</cflock>
	</cffunction>	
	
	<cffunction name="verifyAccount" returntype="boolean" access="private" hint="Checks if the given account exists">
		<cfargument name="userName" type="string" required="yes">
		<!--- To check if the account exists we will only check that the account directory exists --->
		<!--- TO DO: we should actually go to the account storage and check for existence, but that's for later --->
		<cfreturn DirectoryExists(expandPath(oAccountsConfigBean.getAccountsRoot() & "/" & arguments.userName))>
	</cffunction>
		
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>
			
</cfcomponent>