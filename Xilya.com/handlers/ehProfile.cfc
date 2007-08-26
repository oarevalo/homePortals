<cfcomponent name="ehGeneral" extends="coldbox.system.eventhandler">

	<cffunction name="dspProfile" access="public" returntype="string">
		<cfscript>
			var bLoggedIn = false;
			var oUserRegistry = 0;
			var stUserInfo = 0;
			var avatarHREF = "/xilya/includes/images/avatar.jpg";
			
			// get info on current user
			oUserRegistry = createObject("component","Home.Components.userRegistry").init();
			stUserInfo = oUserRegistry.getUserInfo();
			
			if(stUserInfo.userID neq "") {
				bLoggedIn = true;
				qryUser = stUserInfo.userData;
			} 
			
			if(not bLoggedIn) {
				getPlugin("messagebox").setMessage("error", "You must first login to your account before editing your profile");
				setNextEvent("ehGeneral.dspLogin");
			}
			
			// get member info
			o = createObject("component","xilya.components.members");
			o.init();	
			qryMember = o.getByAccountID(qryUser.userID);
			
			// check if user has avatar pic
			if(fileExists(expandPath("/Accounts/#stUserInfo.userName#/avatar.jpg")))
				avatarHREF = "/Accounts/#stUserInfo.userName#/avatar.jpg";
			
			setValue("qryUser", qryUser);	
			setValue("qryMember", qryMember);	
			setValue("avatarHREF", avatarHREF);	

			setView("vwProfile");
		</cfscript>
	</cffunction>

	<cffunction name="doUpdate" access="public" returntype="string">
		<cfscript>
			var o = 0;
			var accountID = 0;
			var email = getValue("email","");
			var firstName = getValue("firstName","");
			var middleName = getValue("middleName","");
			var lastName = getValue("lastName","");
			var avatar = getValue("avatar","");
			var args = structNew();
			var bLoggedIn = false;
			var qryUser = 0;
			var qryAccount = 0;
			var oUserRegistry = 0;
			var stUserInfo = 0;
			
			try {
				// get info on current user
				oUserRegistry = createObject("component","Home.Components.userRegistry").init();
				stUserInfo = oUserRegistry.getUserInfo();

				if(stUserInfo.userID neq "") {
					bLoggedIn = true;
					qryUser = stUserInfo.userData;
				} 

				if(not bLoggedIn) {
					getPlugin("messagebox").setMessage("error", "You must first login to your account before editing your profile");
					setNextEvent("ehGeneral.dspLogin");
				}

				// validate form
				if(email eq "") throw("Please enter your email address.");
				if(reReplace(email,"^.+@[^\.].*\.[a-z]{2,}$","OK") neq "OK") throw("Please enter a valid email address.");
				
				// create and initialize account object
				o = getAccountsService();	
				
				// get info on HomePortals account
				qryAccount = o.getAccountByUsername(qryUser.username);		
				
				// update account
				o.updateAccount(qryUser.userID, firstName, middleName, lastName, email);
				
				// crate and initialize members object
				o = createObject("component","xilya.components.members");
				o.init();	
	
				// update member info	
				qryMember = o.getByAccountID(qryUser.userID);
				args.ID = qryMember.MemberID;
				args.firstName = firstName;
				args.middleName = middleName;
				args.lastName = lastName;
				args.email = email;
				args.password = qryMember.password;
				args.type = qryMember.type;
				args.accountID = qryMember.accountID;
				o.save(argumentCollection = args);
				o.commit();

				// upload image if sent
				if(avatar neq "") {
					tmpDestPath = "/accounts/#stUserInfo.username#/avatar.jpg";
					
					// upload file
					stInfo = fileUpload("avatar",tmpDestPath);
					
					// resize the image
					imgObj = CreateObject("component", "xilya.components.tmt_img");
					if(stInfo.contentSubType eq "png") imgObj.init("png");
					imgObj.resize(expandPath(tmpDestPath), expandPath(tmpDestPath), 30);
					
					newHeight = imgObj.getHeight(expandPath(tmpDestPath));
					if(newHeight gt 30) {
						imgObj.cropResize(expandPath(tmpDestPath), expandPath(tmpDestPath), 30, 30, 30);
					}
					
				}

				getPlugin("messagebox").setMessage("info", "Member profile updated");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message);
			}
	
			setNextEvent("ehProfile.dspProfile");
		</cfscript>
	</cffunction>	
	
	
	<cffunction name="doChangePassword" access="public" returntype="string">
		<cfscript>
			var o = 0;
			var accountID = 0;
			var hpRoot = "/Home";
			var password = getValue("password","");
			var password2 = getValue("password2","");
			var args = structNew();
			var bLoggedIn = false;
			var qryUser = 0;
			var qryAccount = 0;
			var oUserRegistry = 0;
			var stUserInfo = 0;

			try {
				// get info on current user
				oUserRegistry = createObject("component","Home.Components.userRegistry").init();
				stUserInfo = oUserRegistry.getUserInfo();

				if(stUserInfo.userID neq "") {
					bLoggedIn = true;
					qryUser = stUserInfo.userData;
				} 
				
				if(not bLoggedIn) {
					getPlugin("messagebox").setMessage("error", "You must first login to your account before editing your profile");
					setNextEvent("ehGeneral.dspLogin");
				}

				// validate form
				if(password eq "") throw("Password cannot be empty");
				if(len(password) lt 6) throw("Passwords must be at least 6 characters long");
				if(password neq password2) throw("The password confirmation does not match the selected passwords. Please correct.");
				
				// create and initialize account object
				o = getAccountsService();	
				
				// update account
				o.changePassword(qryUser.userID, password);
				
				// crate and initialize members object
				o = createObject("component","xilya.components.members");
				o.init();	
	
				// update member info	
				qryMember = o.getByAccountID(qryUser.userID);
				args.ID = qryMember.MemberID;
				args.firstName = qryMember.firstName;
				args.middleName = qryMember.middleName;
				args.lastName = qryMember.lastName;
				args.email = qryMember.email;
				args.password = password;
				args.type = qryMember.type;
				args.accountID = qryMember.accountID;
				o.save(argumentCollection = args);
				o.commit();

				getPlugin("messagebox").setMessage("info", "Member profile updated");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message);
				setNextEvent("ehProfile.dspProfile");
			}
		</cfscript>
	</cffunction>		
	
	
	<cffunction name="getAccountsService" returntype="Home.Components.accounts" access="package">
		<cfscript>
			var	configFilePath = "/xilya/config/homePortals-config.xml";
			var oHomePortalsConfigBean = 0;
			var oAccountsService  = 0;
			
			oHomePortalsConfigBean = createObject("component", "Home.Components.homePortalsConfigBean").init(expandPath(configFilePath));
			oAccountsService = CreateObject("component", "Home.Components.accounts").init(oHomePortalsConfigBean);
			return oAccountsService;
		</cfscript>	
	</cffunction>
		
	<cffunction name="fileUpload" access="public">
		<cfargument name="fieldName" type="string" required="true">
		<cfargument name="destPath" type="string" required="true">
		
		<cfset var stFile = structNew()>
		
		<cffile action="upload" accept="image/jpg,image/jpeg,image/png" 
				filefield="#arguments.fieldName#" 
				nameconflict="overwrite"  result="stFile"
				destination="#expandPath(arguments.destPath)#">
		
		<cfreturn stFile>
	</cffunction>	
		
</cfcomponent>
	