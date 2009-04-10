<cfcomponent displayname="ContentStore">

	<cfscript>
		variables.oContentStoreConfigBean = 0;
		variables.xmlDoc = xmlNew();
		variables.owner = "";
		variables.type = "";
		
		// name of the cache service used
		variables.cacheServiceName = "hpContentStoreCache";
		
		// name of the lock to use when accessing the memory cache service
		variables.lockName = "hpContentStoreCacheLock";
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
				
				if(not directoryExists(expandPath(variables.oContentStoreConfigBean.getAccountsRoot() & "/" & variables.owner)))				
					createDir(expandPath(variables.oContentStoreConfigBean.getAccountsRoot() & "/" & variables.owner));
								
				variables.oContentStoreConfigBean.setURL(tmpURL);
			}
			
			// if url is not a relative path, then default to owner's directory
			// (this is to avoid writing files in random places)
			if(listLen(tmpURL,"/") lte 1 or left(tmpURL,1) neq "/") {
				tmpURL = variables.oContentStoreConfigBean.getAccountsRoot() 
								& "/" & variables.oContentStoreConfigBean.getOwner()
								& "/" & tmpURL;

				if(not directoryExists(expandPath(variables.oContentStoreConfigBean.getAccountsRoot() & "/" & variables.oContentStoreConfigBean.getOwner())))				
					createDir(expandPath(variables.oContentStoreConfigBean.getAccountsRoot() & "/" & variables.oContentStoreConfigBean.getOwner()));
				
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
		<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
		<cfset var tmpName = "">
		
		<!--- write to file system --->
		<cffile action="write" 
				file="#ExpandPath(tmpURL)#" 
				output="#toString(variables.xmlDoc)#">

		<!--- create a name for the lock to single-thread access to this resource --->
		<cfset tmpName = replace(hash(tmpURL),"-","")>
		
		<!--- invalidate cache entry (if exists) --->	
        <cflock type="exclusive" name="#variables.lockName#_#tmpName#" timeout="30">
			<cfset oCacheRegistry.getCache(variables.cacheServiceName).flush(hash(tmpURL))>	
        </cflock>
	</cffunction>

	<!-------------------------------------->
	<!--- readStorageDoc                 --->
	<!-------------------------------------->
	<cffunction name="readStorageDoc" access="private">
		<cfscript>
			var xmlDoc = 0;
			var tmpURL = variables.oContentStoreConfigBean.getURL();
			var memCacheKey = hash(tmpURL);
			var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init();
			var oCacheService = oCacheRegistry.getCache(variables.cacheServiceName);

			// retrieve the contentStore doc from memory cache if it exists and is still valid
			try {
				variables.xmlDoc = oCacheService.retrieve(memCacheKey);

			} catch(homePortals.cacheService.itemNotFound e) {
				// file not in cache, so get it from file system
				variables.xmlDoc = xmlParse(ExpandPath(tmpURL));
				
				// store file in cache
				storeInCache(memCacheKey, variables.xmlDoc);
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
    
	<cffunction name="storeInCache" access="private" returntype="void">
    	<cfargument name="key" type="string" required="yes">
        <cfargument name="xmlDoc" type="xml" required="yes">
        
		<cfset var oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init()>
    	<cfset var oCacheService = oCacheRegistry.getCache(variables.cacheServiceName)>

		<!--- create a name for the lock to single-thread access to this resource --->
		<cfset var tmpName = replace(hash(arguments.key),"-","")>

		<cflock type="exclusive" name="#variables.lockName#_#tmpName#" timeout="30">
			<cfset oCacheService.store(arguments.key, arguments.xmlDoc)>
		</cflock>
    </cffunction>
 
	<!---------------------------------------->
	<!--- throw                            --->
	<!---------------------------------------->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string" required="yes">
		<cfthrow message="#arguments.message#">
	</cffunction>

	<cffunction name="createDir" access="private" returntype="void">
		<cfargument name="path" type="string" required="true">
		<cfdirectory action="create" directory="#arguments.path#">
	</cffunction>
</cfcomponent>