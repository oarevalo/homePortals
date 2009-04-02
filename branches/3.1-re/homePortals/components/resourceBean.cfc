<cfcomponent hint="I represent a reusable resource" output="false">

	<cfproperty name="ID" type="string" />
	<cfproperty name="Type" type="string" hint="Resource type" />
	<cfproperty name="Package" type="string" hint="The package to which this resource belongs to" />
	<cfproperty name="HREF" type="string" />
	<cfproperty name="Description" type="string" />
	<cfproperty name="infoHREF" type="string" hint="the location of the package descriptor file that describes this resource" />
	<cfproperty name="resLibPath" type="string" hint="the location of the resource library where this resource is located" />
	<cfproperty name="customProperties" type="struct" hint="holds custom properties for the resource">

	<cfscript>
		// initialize here in case someone extends this and forget to call super.init() on their own init()
		variables.instance = structNew();
		variables.instance.ID = "";
		variables.instance.Type = "";
		variables.instance.Package = "";
		variables.instance.HREF = "";
		variables.instance.Description = "";
		variables.instance.infoHREF = "";
		variables.instance.resLibPath = "";
		variables.instance.customProperties = structNew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="resourceBean" hint="constructor">
		<cfscript>
			variables.instance.ID = "";
			variables.instance.Type = "";
			variables.instance.Package = "";
			variables.instance.HREF = "";
			variables.instance.Description = "";
			variables.instance.infoHREF = "";
			variables.instance.resLibPath = "";
			variables.instance.customProperties = structNew();
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

	<cffunction name="getInfoHREF" access="public" output="false" returntype="string">
		<cfreturn variables.instance.infoHREF />
	</cffunction>

	<cffunction name="setInfoHREF" access="public" output="false" returntype="void">
		<cfargument name="infoHREF" type="string" required="true" />
		<cfset variables.instance.infoHREF = arguments.infoHREF />
		<cfreturn />
	</cffunction>
	
	<cffunction name="getResLibPath" access="public" output="false" returntype="string">
		<cfreturn variables.instance.resLibPath />
	</cffunction>

	<cffunction name="setResLibPath" access="public" output="false" returntype="void">
		<cfargument name="resLibPath" type="string" required="true" />
		<cfset variables.instance.resLibPath = arguments.resLibPath />
		<cfreturn />
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

</cfcomponent>