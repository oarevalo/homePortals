<cfcomponent displayname="ContentStore">

	<cfscript>
		variables.oContentStoreConfigBean = 0;
		variables.xmlDoc = xmlNew();
		variables.owner = "";
		variables.type = "";
		
		// name of the cache service instance
		variables.cacheServiceName = "_hpContentStoreCache";

		// number of content store docs to cache in memory
		variables.memCacheSize = 50;
		
		// time to live in minutes for content store docs cached in memory
		// (set it to a large number because we control the only access)
		variables.memCacheTTL = 9999;
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
			
		 	// create cache service if not exists
			if(Not structKeyExists(application, variables.cacheServiceName)) {
				initCacheService();
			}
			
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
		<cfset var tmpURL = variables.oContentStoreConfigBean.getURL()>
		
		<!--- write to file system --->
		<cffile action="write" 
				file="#ExpandPath(tmpURL)#" 
				output="#toString(variables.xmlDoc)#">
				
		<!--- invalidate cache entry (if exists) --->		
		<cfset application[variables.cacheServiceName].flush(hash(tmpURL))>
	</cffunction>

	<!-------------------------------------->
	<!--- readStorageDoc                 --->
	<!-------------------------------------->
	<cffunction name="readStorageDoc" access="private">
		<cfscript>
			var xmlDoc = 0;
			var tmpURL = variables.oContentStoreConfigBean.getURL();
			var memCacheKey = hash(tmpURL);
			var oCacheService = application[variables.cacheServiceName];

			// retrieve the contentStore doc from memory cache if it exists and is still valid
			try {
				variables.xmlDoc = oCacheService.retrieve(memCacheKey);

			} catch(homePortals.cacheService.itemNotFound e) {
				// file not in cache, so get it from file system
				variables.xmlDoc = xmlParse(ExpandPath(tmpURL));
				
				// store file in cache
				oCacheService.store(memCacheKey, variables.xmlDoc);
			}

			// if the storage file has already an owner, then set the current owner to the one on the storage
			if(StructKeyExists(variables.xmlDoc.xmlRoot.xmlAttributes,"owner"))
				variables.owner = variables.xmlDoc.xmlRoot.xmlAttributes.owner;
			else {
				// storage doesnt have an owner, so we will claim it
				variables.xmlDoc.xmlRoot.xmlAttributes["owner"] = variables.owner;
			}
	
			// set a default created on date 
			if(Not StructKeyExists(variables.xmlDoc.xmlRoot.xmlAttributes,"createdOn")) {
				variables.xmlDoc.xmlRoot.xmlAttributes["createdOn"] = GetHTTPTimeString(CreateDate(2000,1,1));
			}
			
			// set the type if it doesnt have any
			if(Not StructKeyExists(variables.xmlDoc.xmlRoot.xmlAttributes,"type") and variables.type neq "") {
				variables.xmlDoc.xmlRoot.xmlAttributes["type"] = variables.type;
			}
		</cfscript>
	</cffunction>

	<cffunction name="initCacheService" access="private" returntype="void">
		<cfset var oCacheService = createObject("component","cacheService").init(variables.memCacheSize, variables.memCacheTTL)>
		<cflock scope="Application" type="exclusive" timeout="20">
			<cfset application[variables.cacheServiceName]= oCacheService>
		</cflock>
	</cffunction>

	<!---------------------------------------->
	<!--- throw                            --->
	<!---------------------------------------->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string" required="yes">
		<cfthrow message="#arguments.message#">
	</cffunction>

</cfcomponent>