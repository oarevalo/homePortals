<cfcomponent hint="I represent a reusable resource" output="false">

	<cfproperty name="ID" type="string" />
	<cfproperty name="Type" type="string" hint="Resource type" />
	<cfproperty name="Package" type="string" hint="The package to which this resource belongs to" />
	<cfproperty name="HREF" type="string" />
	<cfproperty name="Description" type="string" />
	<cfproperty name="customProperties" type="struct" hint="holds custom properties for the resource">
	<cfproperty name="resourceLibrary" type="resourceLibrary" hint="the resource library to which this resource belongs">

	<cfscript>
		// initialize here in case someone extends this and forget to call super.init() on their own init()
		variables.instance = structNew();
		variables.instance.ID = "";
		variables.instance.Type = "";
		variables.instance.Package = "";
		variables.instance.HREF = "";
		variables.instance.Description = "";
		variables.instance.customProperties = structNew();
		variables.instance.resourceLibrary = 0;
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
		</cfscript>
		<cfreturn this />
	</cffunction>

	<cffunction name="loadFromXMLNode" access="public" output="false" returntype="resourceBean" hint="populates the current instance from an xml node from a resource descriptor file">
		<cfargument name="resourceNode" type="XML" hint="XML node from a descriptor document that represents the resource" required="true" />
		<cfscript>
			var xmlNode = arguments.resourceNode;
			var i = 0;
			var stSrc = 0;
			var stTgt = 0;

			// populate bean
			variables.instance.id = xmlNode.xmlAttributes.id;

			if(structKeyExists(xmlNode.xmlAttributes,"href")) variables.instance.href = xmlNode.xmlAttributes.href;
							
			if(structKeyExists(xmlNode,"description")) {
				variables.instance.description = xmlNode.description.xmlText;
			}

			if(structKeyExists(xmlNode,"property")) {
				for(i=1;i lte arrayLen(xmlNode.xmlChildren);i=i+1) {
					stSrc = xmlNode.xmlChildren[i];
					if(stSrc.xmlName eq "property" and structKeyExists(stSrc.xmlAttributes,"name")) {
						variables.instance.customProperties[stSrc.xmlAttributes.name] = stSrc.xmlText;
					}
				}
			}
		</cfscript>
		<cfreturn this />
	</cffunction>

	<cffunction name="toXMLNode" access="public" output="false" returntype="xml" hint="creates the xml node corresponding to this resource instance on the resource descriptor file">
		<cfargument name="xmlDoc" type="XML" hint="XML object representing the resource descriptor file" required="true" />
		<cfscript>
			var xmlNode = 0;
			var xmlNode2 = 0;
			var stProps = 0;
			var key = 0;
			
			xmlNode = xmlElemNew(arguments.xmlDoc, "resource");
			xmlNode.xmlAttributes["id"] = getID();
			xmlNode.xmlAttributes["HREF"] = getHREF();

			if(getDescription() neq "") {
				xmlNode2 = xmlElemNew(arguments.xmlDoc, "description");
				xmlNode2.xmlText = getDescription();
				arrayAppend(xmlNode.xmlChildren, xmlNode2);
			}

			// set custom properties (if any)
			stProps = getProperties();
			if(not structIsEmpty(stProps)) {
				for(key in stProps) {
					xmlNode2 = xmlElemNew(arguments.xmlDoc, "property");
					xmlNode2.xmlAttributes["name"] = key;
					xmlNode2.xmlText = stProps[key];
					arrayAppend(xmlNode.xmlChildren, xmlNode2);
				}
			}
			
			return xmlNode;
		</cfscript>
	</cffunction>

	<cffunction name="getMemento" hint="returns a structure with instance data" access="public" output="false" returntype="struct">
		<cfreturn duplicate(variables.instance) />
	</cffunction>
	
	<cffunction name="getHref" access="public" output="false" returntype="string">
		<cfreturn variables.instance.Href />
	</cffunction>

	<cffunction name="getFullHref" access="public" output="false" returntype="string">
		<cfset var resLibPath = getResourceLibrary().getPath()>
		<cfset var href = getHref()>
		
		<cfif right(resLibPath,1) neq "/">
			<cfreturn resLibPath & "/" & href />
		<cfelse>
			<cfreturn resLibPath & href />
		</cfif>
	</cffunction>
	
	<cffunction name="setHref" access="public" output="false" returntype="void">
		<cfargument name="Href" type="string" required="true" />
		<cfset variables.instance.Href = arguments.Href />
		<cfreturn />
	</cffunction>

	<cffunction name="getType" access="public" output="false" returntype="string">
		<cfreturn variables.instance.Type />
	</cffunction>

	<cffunction name="setType" access="public" output="false" returntype="void">
		<cfargument name="Type" type="string" required="true" />
		<cfset variables.instance.Type = arguments.Type />
		<cfreturn />
	</cffunction>

	<cffunction name="getPackage" access="public" output="false" returntype="string">
		<cfreturn variables.instance.Package />
	</cffunction>

	<cffunction name="setPackage" access="public" output="false" returntype="void">
		<cfargument name="Package" type="string" required="true" />
		<cfset variables.instance.Package = arguments.Package />
		<cfreturn />
	</cffunction>

	<cffunction name="getID" access="public" output="false" returntype="string">
		<cfreturn variables.instance.ID />
	</cffunction>

	<cffunction name="setID" access="public" output="false" returntype="void">
		<cfargument name="ID" type="string" required="true" />
		<cfset variables.instance.ID = arguments.ID />
		<cfreturn />
	</cffunction>

	<cffunction name="getDescription" access="public" output="false" returntype="string">
		<cfreturn variables.instance.Description />
	</cffunction>

	<cffunction name="setDescription" access="public" output="false" returntype="void">
		<cfargument name="Description" type="string" required="true" />
		<cfset variables.instance.Description = arguments.Description />
		<cfreturn />
	</cffunction>

	<cffunction name="getResourceLibrary" access="public" returntype="homePortals.components.resourceLibrary">
		<cfreturn variables.instance.ResourceLibrary>
	</cffunction>

	<cffunction name="setResourceLibrary" access="public" returntype="void">
		<cfargument name="data" type="homePortals.components.resourceLibrary" required="true">
		<cfset variables.instance.ResourceLibrary = arguments.data>
	</cffunction>
	
	
	<cffunction name="getProperties" access="public" output="false" returntype="struct">
		<cfreturn duplicate(variables.instance.customProperties) />
	</cffunction>

	<cffunction name="getProperty" access="public" output="false" returntype="string">
		<cfargument name="name" type="string" required="true" />
		<cfif not structKeyExists(variables.instance.customProperties, arguments.name)>
			<cfthrow message="Invalid property name" type="homePortals.resourceBean.invalidProperty">
		</cfif>
		<cfreturn variables.instance.customProperties[arguments.name] />
	</cffunction>
	
	<cffunction name="setProperty" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="value" type="string" required="true" />
		<cfset variables.instance.customProperties[arguments.name] = arguments.value />
	</cffunction>	

	<cffunction name="deleteProperty" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfif not structKeyExists(variables.instance.customProperties, arguments.name)>
			<cfthrow message="Invalid property name" type="homePortals.resourceBean.invalidProperty">
		</cfif>
		<cfset structDelete(variables.instance.customProperties, arguments.name) />
	</cffunction>

	
	<!--- Target File Methods --->

	<cffunction name="targetFileExists" access="public" output="false" returntype="boolean" hint="Returns whether the file associated with this resources exists on the local file system or not. This only works for target files within the resource library">
		<cfreturn getHref() neq "" and fileExists(expandPath(getFullHref()))>
	</cffunction>
	
	<cffunction name="readFile" access="public" output="false" returntype="any" hint="Reads the file associated with this resource. If there is no associated file then returns a missingTargetFile error. This only works for target files stored within the resource library">
		<cfargument name="readAsBinary" type="boolean" required="false" default="false" hint="Reads the file as a binary document">
		<cfset var doc = "">
		<cfset var href = getFullHref()>
		<cfif targetFileExists()>
			<cfif arguments.readAsBinary>
				<cffile action="readbinary" file="#expandPath(href)#" variable="doc">
			<cfelse>
				<cffile action="read" file="#expandPath(href)#" variable="doc">
			</cfif>
		<cfelse>
			<cfthrow message="Resource has no associated file or file does not exists" type="homePortals.resourceBean.missingTargetFile">
		</cfif>
		<cfreturn doc>
	</cffunction>

	<cffunction name="saveFile" access="public" output="false" returntype="void" hint="Saves a file associated to this resource">
		<cfargument name="fileName" type="string" required="true" hint="filename to use">
		<cfargument name="fileContent" type="any" required="true" hint="File contents">
		
		<cfset var rt = getResourceLibrary().getResourceType( getType() )>
		<cfset var defaultExtension = listFirst(rt.getFileTypes())>
		<cfset var href = "">
		
		<cfif arguments.fileName eq "">
			<cfthrow message="resource file name cannot be empty" type="homePortals.resourceBean.blankFileName">
		</cfif>

		<cfset href = rt.getFolderName() 
					& "/" 
					& getPackage() 
					& "/" 
					& arguments.fileName>
		
		<cfset setHREF(href)>
		
		<cffile action="write" file="#expandPath(getFullHREF())#" output="#arguments.fileContent#">
	</cffunction>

	<cffunction name="deleteFile" access="public" output="false" returntype="void" hint="Deletes the file associated with this resource">
		<cfset var href = getFullHref()>
		<cfif targetFileExists()>
			<cffile action="delete" file="#expandPath(href)#">
		</cfif>
		<cfset setHREF("")>
	</cffunction>

</cfcomponent>