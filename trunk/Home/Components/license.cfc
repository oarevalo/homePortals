<cfcomponent>
	<!--- set the location of the license file --->
	<cfset variables.licenseFileName = GetDirectoryFromPath(GetCurrentTemplatePath()) & "/../Config/license.xml.cfm">
	<cfset variables.trialLength = 30>
	
	<!--------------------------------------->
	<!----  getLicenseKey				----->
	<!--------------------------------------->
	<cffunction name="getLicenseKey" access="public" returntype="struct"
				hint="This method returns an encrypted structure with the license key for the current installation of HomePortals, and for trial versions, returns the expiration date">
		<cfscript>
			var tmpXML = "";
			var xmlLicenseDoc = 0;
			var xmlNode = 0;
			var xmlThisNode = 0;
			var retVal = structNew();
			var aNodes = arrayNew(1);
					
			// ***** Get homeportals license ******
			tmpXML = readFile(variables.licenseFileName);
			if(Not IsXML(tmpXML)) throw("The given HomePortals License file is corrupt or missing.");
			xmlLicenseDoc = xmlParse(tmpXML);
			
			// get license key
			aNodes = xmlSearch(xmlLicenseDoc, "//licenseKey");
			if(ArrayLen(aNodes) eq 0)	throw("The license file is corrupt.");
			retVal.licenseKey = XMLUnFormat(aNodes[1].xmlText);

			// get expiration date
			aNodes = xmlSearch(xmlLicenseDoc, "//expiresOn");
			if(ArrayLen(aNodes) eq 0)	throw("The license file is corrupt.");
			retVal.expiresOn = XMLUnFormat(aNodes[1].xmlText);
		</cfscript>		
		<cfreturn retVal>
	</cffunction>


	<!--------------------------------------->
	<!----  validateLicenseKey			----->
	<!--------------------------------------->
	<cffunction name="validateLicenseKey" access="public" returntype="struct"
				hint="Checks that the current license key is valid for the current installation of HomePortals">
		<cfargument name="licenseKeyStruct" type="struct" required="yes" hint="Encrypted structure with license key">
		
		<cfscript>
			var retVal = structNew();
			var deLK = "";
			var deExpOn = "";
			var serverKey = getServerKey();
			
			retVal.valid = false;
			retVal.message = "invalid key.";
			
			try {
				// check that license key is not empty
				if(arguments.licenseKeyStruct.licenseKey eq "")  throw("invalid key.");
					
				// get the actual license key	
				deLK = Decrypt(arguments.licenseKeyStruct.licenseKey, serverKey);
				if(arguments.licenseKeyStruct.expiresOn neq "")
					deExpOn = Decrypt(arguments.licenseKeyStruct.expiresOn, serverKey);
				
				// validate key
				if(deLK eq "TRIAL") {
					// validate trial 
					retVal.valid = (dateCompare(now(),deExpOn) lt 1);
					if(Not retVal.valid) 
						retVal.message = "The current HomePortals trial version has expired. Please contact CFEmpire corp. to purchase a valid key.";

				} else {
					// validate real key
					
					// check key length
					if(len(deLK) neq 19) throw("invalid key.");
					
					// check key format
					if(listLen(deLK,"-") neq 4) throw("invalid key.");
					
					// check subkeys
					for(i=1;i lte 4;i=i+1) {
						lowLimit = 65;
						tmpSubKey = ListGetAt(deLK,i,"-");
						if(Len(tmpSubKey) neq 4)  throw("invalid key.");
						for(j=1;j lte 4;j=j+1) {
							tmpChar = Mid(tmpSubKey,j,1);
							if(asc(tmpChar) lt lowLimit or asc(tmpChar) gt lowLimit+4)
								throw("invalid key.");
							lowLimit = lowLimit + 5;
						}
					}

					retVal.valid = true;
				}
				
				
			} catch(any e) {
				retVal.valid = false;
			}
		</cfscript>
		
		<cfreturn retVal>
	</cffunction>


	<!--------------------------------------->
	<!----  verifyLicenseKey	        ----->
	<!--------------------------------------->
	<cffunction name="verifyLicenseKey" access="public" returntype="boolean" output="true"
				hint="Checks if the given key is equal to the key of the current installation">
		<cfargument name="licenseKey" type="string" required="yes" hint="license key to verify">

		<cfset var myKey = structNew()>
		<cfset var bRetVal = false>
		<cfset var serverKey = getServerKey()>

		<cfscript>
			try {
				// get current key
				myKey = getLicenseKey();
			
				// decrypt the license key	
				deLK = Decrypt(myKey.licenseKey, serverKey);	
				
				// check if they are equal
				bRetVal = (deLK eq arguments.licenseKey);
				
			} catch(any e) {
				bRetVal = false;
			}			
		</cfscript>
		
		<cfreturn bRetVal>
	</cffunction>


	<!--------------------------------------->
	<!----  saveLicenseKey  			----->
	<!--------------------------------------->
	<cffunction name="saveLicenseKey" access="public"
				hint="Encrypts and stores the license key for the current installation of HomePortals">
		<cfargument name="licenseKey" type="string" required="yes" hint="license key">
		<cfargument name="isTrial" type="boolean" required="yes" hint="flag for trial edition">

		<cfscript>
			var tmpXML = "";
			var xmlLicenseDoc = 0;
			var serverKey = getServerKey();
			var trialExpirationDate = dateAdd("d",variables.trialLength,now());

			if(arguments.licenseKey eq "" and Not arguments.isTrial)
				throw("The License Key cannot be blank");

			if(arguments.licenseKey neq "" and arguments.isTrial)
				throw("When installing the trial edition the license key must be empty.");

			// ***** Get homeportals license file ******
			tmpXML = readFile(variables.licenseFileName);
			if(Not IsXML(tmpXML)) throw("The given HomePortals License file is corrupt or missing.");
			xmlLicenseDoc = xmlParse(tmpXML);
			
			// update license
			if(arguments.isTrial) {
				// check that this is not a second trial
				if(xmlLicenseDoc.xmlRoot.expiresOn.xmlText neq "")
					throw("The free 30-day trial for HomePortals has already been used. Please purchase a valid license to continue using HomePortals.");
				
				// if this is the trial edition set the expiration date
				xmlLicenseDoc.xmlRoot.licenseKey.xmlText = encrypt("TRIAL", serverKey);
				xmlLicenseDoc.xmlRoot.expiresOn.xmlText = encrypt(dateFormat(trialExpirationDate,"mm/dd/yyyy"), serverKey);
			} else {
				// this is the normal version
				xmlLicenseDoc.xmlRoot.licenseKey.xmlText = encrypt(arguments.licenseKey, serverKey);
				xmlLicenseDoc.xmlRoot.expiresOn.xmlText = "";
			}
		</cfscript>		

		<cffile action="write" 
				file="#variables.licenseFileName#" 
				output="#toString(xmlLicenseDoc)#">
	</cffunction>

	<!--------------------------------------->
	<!----  getTrialExpirationDate		----->
	<!--------------------------------------->
	<cffunction name="getTrialExpirationDate" returntype="string" access="public" hint="Returns the expiration date for trial versions. For full versions, returns an empty string">
		<cfscript>
			var retVal = "";
			var serverKey = getServerKey();
			var stLicense = getLicenseKey();

			if(stLicense.expiresOn neq "")
				retVal = Decrypt(stLicense.expiresOn, serverKey);

			return retVal;
		</cfscript>
	</cffunction>


	<!--------------------------------------->
	<!----  verifyAdminPassword	        ----->
	<!--------------------------------------->
	<cffunction name="verifyAdminPassword" access="public" returntype="boolean" output="true"
				hint="Checks if the given admin password is equal to the saved password.">
		<cfargument name="password" type="string" required="yes">

		<cfset var bRetVal = false>
		<cfset var tmpXML = "">

		<cfscript>
			try {
				// get current password
				tmpXML = readFile(variables.licenseFileName);
				if(Not IsXML(tmpXML)) throw("The given HomePortals License file is corrupt or missing.");
				xmlLicenseDoc = xmlParse(tmpXML);
				aPwd = xmlSearch(xmlLicenseDoc, "//adminPwd");
				if(ArrayLen(aPwd) eq 0)	throw("The license file is corrupt.");
							
				// check that license key is not empty
				if(arguments.password eq "")  throw("Password cannot be empty.");

				// check if pwd given is equal to saved pwd
				bRetVal = (hash(arguments.password) eq XMLUnFormat(aPwd[1].xmlText));
				
			} catch(any e) {
				bRetVal = false;
			}			
		</cfscript>
		
		<cfreturn bRetVal>
	</cffunction>


	<!--------------------------------------->
	<!----  saveAdminPassword  			----->
	<!--------------------------------------->
	<cffunction name="saveAdminPassword" access="public"
				hint="Encrypts and stores the admin password for the current installation of HomePortals">
		<cfargument name="password" type="string" required="yes">

		<cfscript>
			var tmpXML = "";
			var xmlLicenseDoc = 0;
			var serverKey = getServerKey();
			var newLicenseKey = "";

			if(arguments.password eq "")  throw("Password cannot be empty.");

			// ***** Get homeportals license ******
			tmpXML = readFile(variables.licenseFileName);
			if(Not IsXML(tmpXML)) throw("The given HomePortals License file is corrupt or missing.");
			xmlLicenseDoc = xmlParse(tmpXML);
			
			// update license
			newPwd = hash(arguments.password);
			xmlLicenseDoc.xmlRoot.adminPwd.xmlText = newPwd;
		</cfscript>		

		<cffile action="write" 
				file="#variables.licenseFileName#" 
				output="#toString(xmlLicenseDoc)#">
	</cffunction>


	<!--- /****** Private Methods ******/ --->
	<cffunction name="getServerKey" access="private" returntype="string" hint="returns the key used to encrypt values on this server.">
		<cfset var myServerKey = "cotahuasi_#cgi.HTTP_HOST#">
		<cfreturn myServerKey>
	</cffunction>

	<cffunction name="dump" access="private">
		<cfargument name="var" type="any">
		<cfdump var="#arguments.var#">
	</cffunction>
	
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>
	
	<cffunction name="readFile" returntype="string" access="private" hint="reads a file from the filesystem and returns its contents">
		<cfargument name="file" type="string">
		<cftry>
			<cffile action="read" file="#arguments.file#" variable="tmp"> 
			
			<cfcatch type="any">
				<cfif cfcatch.Type eq "Application" and FindNoCase("FileNotFound",cfcatch.Detail)>
					<cfset throw("The requested file [#arguments.file#] does not exist.")>
				<cfelse>
					<cfrethrow>
				</cfif>
			</cfcatch>
		</cftry>
		<cfreturn tmp>
	</cffunction>


	<cffunction name="XMLUnFormat" access="private" returntype="string">
		<cfargument name="string" type="string" default="">
		<cfscript>
			var resultString=arguments.string;
			resultString=ReplaceNoCase(resultString,"&apos;","'","ALL");
			resultString=ReplaceNoCase(resultString,"&quot;","""","ALL");
			resultString=ReplaceNoCase(resultString,"&lt;","<","ALL");
			resultString=ReplaceNoCase(resultString,"&gt;",">","ALL");
			resultString=ReplaceNoCase(resultString,"&amp;","&","ALL");
		</cfscript>
		<cfreturn resultString>
	</cffunction>

</cfcomponent>