<cfcomponent displayname="ContentStore">

	<cfscript>
		variables.oContentStoreConfigBean = 0;
		variables.xmlDoc = xmlNew();
		variables.owner = "";
		variables.type = "";
	</cfscript>
		
	<!---------------------------------------->
	<!--- init				               --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="ContentStore">
		<cfargument name="contentStoreConfigBean" type="contentStoreConfigBean" required="true"> 
		
		<cfscript>
			var bStorageExists = false;
			var tmpURL = "";
			var hpPagePath = "";
			var tmp = "";
			var ext = "";
			
			// store settings
			variables.oContentStoreConfigBean = arguments.contentStoreConfigBean;
			variables.owner = variables.oContentStoreConfigBean.getOwner();
			variables.type = variables.oContentStoreConfigBean.getType();
			
			// get document file extension to use
			ext = variables.oContentStoreConfigBean.getExtension();
			
			tmpURL = variables.oContentStoreConfigBean.getURL();

			// if not storage URL is given, then use the default storage
			if(tmpURL eq "") {
				tmpURL = variables.oContentStoreConfigBean.getAccountsRoot() 
								& "/" & variables.owner
								& "/" & variables.oContentStoreConfigBean.getDefaultName()
								& "." & ext;
				variables.oContentStoreConfigBean.setURL(tmpURL);
			}
			
			// if url is not a relative path, then default to owner's directory
			// (this is to avoid writing files in random places)
			if(listLen(tmpURL,"/") lte 1 or left(tmpURL,1) neq "/") {
				tmpURL = variables.oContentStoreConfigBean.getAccountsRoot() 
								& "/" & variables.oContentStoreConfigBean.getOwner()
								& "/" & tmpURL;
				
				// append .xml if necessary
				if(listLast(tmpURL,".") neq ext)
					tmpURL = listAppend(tmpURL,ext,".");
				
				variables.oContentStoreConfigBean.setURL(tmpURL);
			}

			// check if storage URL exists
			bStorageExists = FileExists(ExpandPath(tmpURL));
			
			// if doesnt exist and createStorage flag is on, then create it else throw error
			if(Not bStorageExists) {
				if(variables.oContentStoreConfigBean.getCreateStorage()) {
					createStorageDoc();
					saveStorageDoc();
				} else {
					throw("The given storage document does not exist. Please provide the URL of an existing storage location. Requested document was #tmpURL#");
				}
			}
			
			//  read and parse storage document
			readStorageDoc();
		</cfscript>
		
		<cfreturn this>
	</cffunction>

	<!---------------------------------------->
	<!--- save				               --->
	<!---------------------------------------->	
	<cffunction name="save" access="public">
		<cfargument name="xmlDoc" type="xml" required="true">
		<cfset variables.xmlDoc = arguments.xmlDoc>
		<cfset saveStorageDoc()>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getURL               			   --->
	<!---------------------------------------->	
	<cffunction name="getURL" access="public" returntype="string" output="false">
		<cfreturn variables.oContentStoreConfigBean.getURL()>
	</cffunction>

	<!---------------------------------------->
	<!--- getXMLData		               --->
	<!---------------------------------------->	
	<cffunction name="getXMLData" access="public" returntype="xml" output="false">
		<cfreturn variables.xmlDoc>
	</cffunction>

	<!---------------------------------------->
	<!--- getOwner			               --->
	<!---------------------------------------->	
	<cffunction name="getOwner" access="public" returntype="string" output="false">
		<cfreturn variables.xmlDoc.xmlRoot.xmlAttributes.owner>
	</cffunction>

	<!---------------------------------------->
	<!--- getCreateDate		               --->
	<!---------------------------------------->	
	<cffunction name="getCreateDate" access="public" returntype="string" output="false">
		<cfreturn variables.xmlDoc.xmlRoot.xmlAttributes.createdOn>
	</cffunction>



	<!------------  P R I V A T E    M E T H O D S   -------------------------->

	<!-------------------------------------->
	<!--- createStorageDoc               --->
	<!-------------------------------------->
	<cffunction name="createStorageDoc" access="private">
		<cfset variables.xmlDoc = xmlNew()>
		<cfset variables.xmlDoc.xmlRoot = xmlElemNew(variables.xmlDoc, variables.oContentStoreConfigBean.getRootNode())>
		<cfset variables.xmlDoc.xmlRoot.xmlAttributes["owner"] = variables.owner>
		<cfset variables.xmlDoc.xmlRoot.xmlAttributes["createdOn"] = GetHTTPTimeString(now())>
		<cfset variables.xmlDoc.xmlRoot.xmlAttributes["type"] = variables.type>
	</cffunction>

	<!-------------------------------------->
	<!--- saveStorageDoc                 --->
	<!-------------------------------------->
	<cffunction name="saveStorageDoc" access="private">
		<cffile action="write" 
				file="#ExpandPath(variables.oContentStoreConfigBean.getURL())#" 
				output="#toString(variables.xmlDoc)#">
	</cffunction>

	<!-------------------------------------->
	<!--- readStorageDoc                 --->
	<!-------------------------------------->
	<cffunction name="readStorageDoc" access="private">
		<cfset var txtDoc = "">
		<cfset var tmpURL = variables.oContentStoreConfigBean.getURL()>
		<cfset var tmpHshFile = hash(tmpURL)>

		<!--- create the request cache if not exists --->
		<cfif not structKeyExists(request,"dataFiles")>
			<cfset request.dataFiles = structNew()>
		</cfif>
		
		<!--- check if this file has already been read into
				the request cache, if not, put it there --->
		<cfif not structKeyExists(request.dataFiles, tmpHshFile)>		
			<cffile action="read" file="#ExpandPath(tmpURL)#" variable="txtDoc">

			<!--- check that the given file is a valid xml --->
			<cfif not IsXML(txtDoc)>
				<cfthrow message="The given storage document is not valid xml.">
			</cfif>

			<cfset request.dataFiles[tmpHshFile] = xmlParse(txtDoc)>
		</cfif>

		<!--- get parsed xml content from request cache --->
		<cfset variables.xmlDoc = request.dataFiles[tmpHshFile]>

		<!--- if the storage file has already an owner, then set the current owner to the one on the storage --->
		<cfif StructKeyExists(variables.xmlDoc.xmlRoot.xmlAttributes,"owner")>
			<cfset variables.owner = variables.xmlDoc.xmlRoot.xmlAttributes.owner>
		<cfelse>
			<!--- storage doesnt have an owner, so we will claim it --->
			<cfset variables.xmlDoc.xmlRoot.xmlAttributes["owner"] = variables.owner>
		</cfif> 

		<!--- set a default created on date --->
		<cfif Not StructKeyExists(variables.xmlDoc.xmlRoot.xmlAttributes,"createdOn")>
			<cfset variables.xmlDoc.xmlRoot.xmlAttributes["createdOn"] = GetHTTPTimeString(CreateDate(2000,1,1))>
		</cfif> 	
		
		<!--- set the type if it doesnt have any --->
		<cfif Not StructKeyExists(variables.xmlDoc.xmlRoot.xmlAttributes,"type") and variables.type neq "">
			<cfset variables.xmlDoc.xmlRoot.xmlAttributes["type"] = variables.type>
		</cfif> 	
		
	</cffunction>

	<!---------------------------------------->
	<!--- throw                            --->
	<!---------------------------------------->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string" required="yes">
		<cfthrow message="#arguments.message#">
	</cffunction>

</cfcomponent>