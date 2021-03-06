<cfcomponent hint="I represent a reusable resource" output="false">

	<cfproperty name="ID" type="string" />
	<cfproperty name="Type" type="string" hint="Resource type" />
	<cfproperty name="Package" type="string" hint="The package to which this resource belongs to" />
	<cfproperty name="HREF" type="string" />
	<cfproperty name="Description" type="string" />
	<cfproperty name="customProperties" type="struct" hint="holds custom properties for the resource">
	<cfproperty name="resourceLibrary" type="resourceLibrary" hint="the resource library to which this resource belongs">
	<cfproperty name="createdOn" type="date" hint="The date/time when this resource was created">

	<cfscript>
		variables.FILE_NOT_READ  = "___FILE_NOT_READ___";
		variables.HTTP_TIMEOUT = 60;
		
		// initialize here in case someone extends this and forget to call super.init() on their own init()
		variables.instance = structNew();
		variables.instance.ID = "";
		variables.instance.Type = "";
		variables.instance.Package = "";
		variables.instance.HREF = "";
		variables.instance.Description = "";
		variables.instance.customProperties = structNew();
		variables.instance.resourceLibrary = 0;
		variables.instance.fileContents = variables.FILE_NOT_READ;
		variables.instance.createdOn = createDateTime(1800,1,1,0,0,0);
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="resourceBean" hint="constructor">
		<cfargument name="resourceLibrary" type="homePortals.components.resourceLibrary" required="true">
		<cfscript>
			variables.instance.ID = "";
			variables.instance.Type = "";
			variables.instance.Package = "";
			variables.instance.HREF = "";
			variables.instance.Description = "";
			variables.instance.customProperties = structNew();
			variables.instance.resourceLibrary = arguments.resourceLibrary;
			variables.instance.createdOn = createDateTime(1800,1,1,0,0,0);
		</cfscript>
		<cfreturn this />
	</cffunction>

	<cffunction name="getMemento" hint="returns a structure with instance data" access="public" output="false" returntype="struct">
		<cfreturn duplicate(variables.instance) />
	</cffunction>
	
	<cffunction name="getHref" access="public" output="false" returntype="string" hint="Returns the internal location of the associated resource file (if any). Note that this location will not necessarily be a real filesystem or url path.">
		<cfreturn variables.instance.Href />
	</cffunction>
	
	<cffunction name="setHref" access="public" output="false" returntype="resourceBean">
		<cfargument name="Href" type="string" required="true" />
		<cfset variables.instance.Href = arguments.Href />
		<cfreturn this />
	</cffunction>

	<cffunction name="getType" access="public" output="false" returntype="string" hint="Returns the resource type">
		<cfreturn variables.instance.Type />
	</cffunction>

	<cffunction name="setType" access="public" output="false" returntype="resourceBean" hint="Sets the resource type. The resource type should not be changed after the resource has been saved to the library.">
		<cfargument name="Type" type="string" required="true" />
		<cfset variables.instance.Type = arguments.Type />
		<cfreturn this />
	</cffunction>

	<cffunction name="getPackage" access="public" output="false" returntype="string">
		<cfreturn variables.instance.Package />
	</cffunction>

	<cffunction name="setPackage" access="public" output="false" returntype="resourceBean">
		<cfargument name="Package" type="string" required="true" />
		<cfset variables.instance.Package = arguments.Package />
		<cfreturn this />
	</cffunction>

	<cffunction name="getID" access="public" output="false" returntype="string">
		<cfreturn variables.instance.ID />
	</cffunction>

	<cffunction name="setID" access="public" output="false" returntype="resourceBean">
		<cfargument name="ID" type="string" required="true" />
		<cfset variables.instance.ID = arguments.ID />
		<cfreturn this />
	</cffunction>

	<cffunction name="getDescription" access="public" output="false" returntype="string">
		<cfreturn variables.instance.Description />
	</cffunction>

	<cffunction name="setDescription" access="public" output="false" returntype="resourceBean">
		<cfargument name="Description" type="string" required="true" />
		<cfset variables.instance.Description = arguments.Description />
		<cfreturn this />
	</cffunction>

	<cffunction name="getResourceLibrary" access="public" returntype="homePortals.components.resourceLibrary">
		<cfreturn variables.instance.ResourceLibrary>
	</cffunction>

	<cffunction name="setResourceLibrary" access="public" returntype="resourceBean">
		<cfargument name="data" type="homePortals.components.resourceLibrary" required="true">
		<cfset variables.instance.ResourceLibrary = arguments.data>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getProperties" access="public" output="false" returntype="struct">
		<cfreturn duplicate(variables.instance.customProperties) />
	</cffunction>

	<cffunction name="getProperty" access="public" output="false" returntype="string">
		<cfargument name="name" type="string" required="true" />
		<cfif not structKeyExists(variables.instance.customProperties, arguments.name)>
			<cfthrow message="Invalid property name [#arguments.name#]" type="homePortals.resourceBean.invalidProperty">
		</cfif>
		<cfreturn variables.instance.customProperties[arguments.name] />
	</cffunction>
	
	<cffunction name="setProperty" access="public" output="false" returntype="resourceBean">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="value" type="string" required="true" />
		<cfset variables.instance.customProperties[arguments.name] = arguments.value />
		<cfreturn this />
	</cffunction>	

	<cffunction name="deleteProperty" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfif not structKeyExists(variables.instance.customProperties, arguments.name)>
			<cfthrow message="Invalid property name" type="homePortals.resourceBean.invalidProperty">
		</cfif>
		<cfset structDelete(variables.instance.customProperties, arguments.name) />
	</cffunction>

	<cffunction name="getCreatedOn" access="public" output="false" returntype="date">
		<cfreturn variables.instance.createdOn />
	</cffunction>
	
	<cffunction name="setCreatedOn" access="public" output="false" returntype="resourceBean">
		<cfargument name="createdOn" type="date" required="true" />
		<cfset variables.instance.createdOn = arguments.createdOn />
		<cfreturn this />
	</cffunction>
	
	
	<!--- Target File Methods --->
	<cffunction name="getFullHref" access="public" output="false" returntype="string" hint="Returns a web-accessible location for this resource">
		<cfif isExternalTarget()>
			<cfreturn getHref()>
		<cfelse>
			<cfreturn getResourceLibrary().getResourceFileHREF(this) />
		</cfif>
	</cffunction>

	<cffunction name="getFullPath" access="public" output="false" returntype="string" hint="If the resource can be reached through the file system, then returns the absolute path on the file system to the file associated with this resource">
		<cfif isExternalTarget()>
			<cfreturn "">
		<cfelse>
			<cfreturn getResourceLibrary().getResourceFilePath(this) />
		</cfif>
	</cffunction>

	<cffunction name="isExternalTarget" access="public" output="false" returntype="boolean" hint="Returns whether this resource points to an external target by using its URL address instead of a file path">
		<cfreturn (left(getHref(),4) eq "http")>
	</cffunction>

	<cffunction name="targetFileExists" access="public" output="false" returntype="boolean" hint="Returns whether the file associated with this resources exists on the local file system or not. This only works for target files within the resource library">
		<cfreturn getResourceLibrary().resourceFileExists(this) />
	</cffunction>
	
	<cffunction name="readFile" access="public" output="false" returntype="any" hint="Reads the file associated with this resource. If there is no associated file then returns a missingTargetFile error. This only works for target files stored within the resource library">
		<cfargument name="readAsBinary" type="boolean" required="false" default="false" hint="Reads the file as a binary document">
		<cfargument name="forceReload" type="boolean" required="false" default="false" hint="Forces a reload of the file">
		<cfset var doc = "">
		<cfset var href = getFullHref()>
		<cfif variables.instance.fileContents eq variables.FILE_NOT_READ or arguments.forceReload>
			<cfif isExternalTarget()>
				<cfhttp url="#href#" 
						method="get" 
						getasbinary="#arguments.readAsBinary#" 
						redirect="true" 
						throwonerror="true" 
						timeout="#variables.HTTP_TIMEOUT#">
				</cfhttp>
				<cfset variables.instance.fileContents = cfhttp.FileContent>
			<cfelse>
				<cfset variables.instance.fileContents = getResourceLibrary().readResourceFile(this, arguments.readAsBinary)>
			</cfif>
		</cfif>
		<cfreturn variables.instance.fileContents>
	</cffunction>

	<cffunction name="saveFile" access="public" output="false" returntype="void" hint="Saves a file associated to this resource">
		<cfargument name="fileName" type="string" required="true" hint="filename to use">
		<cfargument name="fileContent" type="any" required="true" hint="File contents">
		<cfset getResourceLibrary().saveResourceFile(this, arguments.fileContent, arguments.fileName)>
		<cfset variables.instance.fileContents = arguments.fileContent>
	</cffunction>

	<cffunction name="deleteFile" access="public" output="false" returntype="void" hint="Deletes the file associated with this resource">
		<cfset getResourceLibrary().deleteResourceFile(this)>
		<cfset variables.instance.fileContents = variables.FILE_NOT_READ>
	</cffunction>

</cfcomponent>