<cfcomponent>
	<!--- set the location of the license file --->
	<cfset licenseFileName = GetDirectoryFromPath(GetCurrentTemplatePath()) & "/../Config/license.xml">

	<!--------------------------------------->
	<!----  getLicenseKey				----->
	<!--------------------------------------->
	<cffunction name="getLicenseKey" access="public" returntype="string"
				hint="This method returns the encrypted license key for the current installation of HomePortals">
	
		<cfscript>
			var tmpXML = "";
			var xmlLicenseDoc = 0;
			var xmlNode = 0;
			var xmlThisNode = 0;
			var retVal = "";
					
			// ***** Get homeportals license ******
			tmpXML = readFile(licenseFileName);
			if(Not IsXML(tmpXML)) throw("The given HomePortals License file is corrupt or missing.");
			xmlLicenseDoc = xmlParse(tmpXML);
			
			// get license key
			aLicense = xmlSearch(xmlLicenseDoc, "//licenseKey");

			if(ArrayLen(aLicense) eq 0)
				throw("The license file is corrupt.");
				
			retVal = XMLUnFormat(aLicense[1].xmlText);
		</cfscript>		
		<cfreturn retVal>
	</cffunction>


	<!--------------------------------------->
	<!----  validateLicenseKey			----->
	<!--------------------------------------->
	<cffunction name="validateLicenseKey" access="public" returntype="boolean"
				hint="Checks that the current license key is valid for the current installation of HomePortals">
		<cfargument name="licenseKey" type="string" required="yes" hint="Encrypted license key">
		
		<cfscript>
			var retVal = false;
			var deLK = "";
			var serverKey = getServerKey();
			
			try {
				// check that license key is not empty
				if(arguments.licenseKey eq "")  throw("invalid key.");
					
				// get the actual license key	
				deLK = Decrypt(arguments.licenseKey, serverKey);
				
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
				
				retVal = true;
				
			} catch(any e) {
				retVal = false;
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

		<cfset var myKey = "">
		<cfset var bRetVal = false>
		<cfset var serverKey = getServerKey()>

		<cfscript>
			try {
				// get current key
				myKey = getLicenseKey();
			
				// check that license key is not empty
				if(myKey eq "")  throw("invalid key.");

				// decrypt the license key	
				deLK = Decrypt(myKey, serverKey);	
				
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
		<cfargument name="licenseKey" type="string" required="yes" hint="Encrypted license key">

		<cfscript>
			var tmpXML = "";
			var xmlLicenseDoc = 0;
			var serverKey = getServerKey();
			var newLicenseKey = "";

			if(arguments.licenseKey eq "")
				throw("The License Key cannot be blank");

			// ***** Get homeportals license ******
			tmpXML = readFile(licenseFileName);
			if(Not IsXML(tmpXML)) throw("The given HomePortals License file is corrupt or missing.");
			xmlLicenseDoc = xmlParse(tmpXML);
			
			// update license
			newLicenseKey = encrypt(arguments.licenseKey,serverKey);
			xmlLicenseDoc.xmlRoot.licenseKey.xmlText = newLicenseKey;
		</cfscript>		

		<cffile action="write" 
				file="#licenseFileName#" 
				output="#toString(xmlLicenseDoc)#">
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
				tmpXML = readFile(licenseFileName);
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
			tmpXML = readFile(licenseFileName);
			if(Not IsXML(tmpXML)) throw("The given HomePortals License file is corrupt or missing.");
			xmlLicenseDoc = xmlParse(tmpXML);
			
			// update license
			newPwd = hash(arguments.password);
			xmlLicenseDoc.xmlRoot.adminPwd.xmlText = newPwd;
		</cfscript>		

		<cffile action="write" 
				file="#licenseFileName#" 
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
					<cfset throw("The requested fiel [#arguments.file#] does not exist.")>
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