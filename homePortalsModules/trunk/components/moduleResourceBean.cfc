<cfcomponent hint="I represent a reusable resource for a module" output="false" extends="homePortals.components.resourceBean">

	<cfproperty name="Owner" type="string" hint="Resource owner, must identify an account" />
	<cfproperty name="AccessType" type="string" />
	<cfproperty name="AuthorName" type="string" />
	<cfproperty name="AuthorEmail" type="string" />
	<cfproperty name="AuthorURL" type="string" />
	<cfproperty name="Screenshot" type="string" hint="URL of an image of the resource" />
	<cfproperty name="Methods" type="array" hint="For module resources, this represents a list of available operations" />
	<cfproperty name="Events" type="array" hint="For module resources, this represents a list of events raised by the module" />
	<cfproperty name="Attributes" type="array" hint="For module resources, this represent a list of attributes that can be used to configure this module" />
	<cfproperty name="Resources" type="array" hint="For module resources, this represents a list of required script or style resources that should be added to the page" />
	<cfproperty name="EventListeners" type="array" hint="For module resources, this represent a list of event listeners that will need to be added to the page" />

	<cffunction name="init" access="public" output="false" returntype="moduleResourceBean" hint="constructor">
		<cfargument name="resourceLibrary" type="homePortals.components.resourceLibrary" required="true">
		<cfscript>
			super.init(arguments.resourceLibrary);

			variables.instance.Owner = "";
			variables.instance.AccessType = "";
			variables.instance.AuthorName = "";
			variables.instance.AuthorEmail = "";
			variables.instance.AuthorURL = "";
			variables.instance.Screenshot = "";
			variables.instance.attributes = arrayNew(1);
			variables.instance.Methods = arrayNew(1);
			variables.instance.Events = arrayNew(1);
			variables.instance.Resources = arrayNew(1);
			variables.instance.EventListeners = arrayNew(1);
		</cfscript>
		<cfreturn this />
	</cffunction>

	<cffunction name="loadFromXMLNode" access="public" output="false" returntype="moduleResourceBean" hint="populates the current instance from an xml node from a resource descriptor file">
		<cfargument name="resourceNode" type="XML" hint="XML node from a descriptor document that represents the resource" required="true" />
		<cfscript>
			var xmlNode = arguments.resourceNode;
			var i = 0;
			var stSrc = 0;
			var stTgt = 0;

			// load default stuff
			super.loadFromXMLNode(arguments.resourceNode);
			
			// populate bean
			if(structKeyExists(xmlNode.xmlAttributes,"owner")) variables.instance.owner = xmlNode.xmlAttributes.owner;
			if(structKeyExists(xmlNode.xmlAttributes,"access")) variables.instance.accessType = xmlNode.xmlAttributes.access;
							
			if(structKeyExists(xmlNode,"attributes")) {
				for(i=1;i lte arrayLen(xmlNode.attributes.xmlChildren);i=i+1) {
					stSrc = xmlNode.attributes.xmlChildren[i].xmlAttributes;
					stTgt = structNew();
					stTgt.name = "";
					stTgt.label = "";
					stTgt.description = "";
					stTgt.required = false;
					stTgt.default = "";
					stTgt.type = "";		// text,number,list,resource,resourceonly
					stTgt.resourceType = "";
					stTgt.resourceField = "";
					stTgt.values = "";
					if(structKeyExists(stSrc,"name")) stTgt.name = stSrc.name;
					if(structKeyExists(stSrc,"label")) stTgt.label = stSrc.label;
					if(structKeyExists(stSrc,"description")) stTgt.description = stSrc.description;
					if(structKeyExists(stSrc,"required")) stTgt.required = stSrc.required;
					if(structKeyExists(stSrc,"default")) stTgt.default = stSrc.default;
					if(structKeyExists(stSrc,"type")) stTgt.type = stSrc.type;
					if(structKeyExists(stSrc,"resourceType")) stTgt.resourceType = stSrc.resourceType;
					if(structKeyExists(stSrc,"resourceField")) stTgt.resourceField = stSrc.resourceField;
					if(structKeyExists(stSrc,"values")) stTgt.values = stSrc.values;
					arrayAppend(variables.instance.attributes, stTgt);
				}
			}

			if(structKeyExists(xmlNode,"eventListeners")) {
				for(i=1;i lte arrayLen(xmlNode.eventListeners.xmlChildren);i=i+1) {
					stSrc = xmlNode.eventListeners.xmlChildren[i].xmlAttributes;
					stTgt = structNew();
					stTgt.eventHandler = "";
					stTgt.eventName = "";
					stTgt.objectName = "";
					if(structKeyExists(stSrc,"eventHandler")) stTgt.eventHandler = stSrc.eventHandler;
					if(structKeyExists(stSrc,"eventName")) stTgt.eventName = stSrc.eventName;
					if(structKeyExists(stSrc,"objectName")) stTgt.objectName = stSrc.objectName;
					arrayAppend(variables.instance.EventListeners, stTgt);
				}
			}

			if(structKeyExists(xmlNode,"resources")) {
				for(i=1;i lte arrayLen(xmlNode.resources.xmlChildren);i=i+1) {
					stSrc = xmlNode.resources.xmlChildren[i].xmlAttributes;
					stTgt = structNew();
					stTgt.type = "";
					stTgt.href = "";
					if(structKeyExists(stSrc,"type")) stTgt.type = stSrc.type;
					if(structKeyExists(stSrc,"href")) stTgt.href = stSrc.href;
					arrayAppend(variables.instance.resources, stTgt);
				}
			}

			if(structKeyExists(xmlNode,"api")) {
				if(structKeyExists(xmlNode.api,"methods")) {
					for(i=1;i lte arrayLen(xmlNode.api.methods.xmlChildren);i=i+1) {
						stSrc = xmlNode.api.methods.xmlChildren[i].xmlAttributes;
						stTgt = structNew();
						stTgt.name = "";
						stTgt.description = "";
						if(structKeyExists(stSrc,"description")) stTgt.description = stSrc.description;
						if(structKeyExists(stSrc,"name")) stTgt.name = stSrc.name;
						arrayAppend(variables.instance.Methods, stTgt);
					}
				}
				
				if(structKeyExists(xmlNode.api,"events")) {
					for(i=1;i lte arrayLen(xmlNode.api.events.xmlChildren);i=i+1) {
						stSrc = xmlNode.api.Events.xmlChildren[i].xmlAttributes;
						stTgt = structNew();
						stTgt.name = "";
						stTgt.description = "";
						if(structKeyExists(stSrc,"description")) stTgt.description = stSrc.description;
						if(structKeyExists(stSrc,"name")) stTgt.name = stSrc.name;
						arrayAppend(variables.instance.Events, stTgt);
					}
				}
			}

			if(structKeyExists(xmlNode,"moduleInfo")) {
				if(structKeyExists(xmlNode.moduleInfo,"AuthorName")) variables.instance.AuthorName = xmlNode.moduleInfo.authorName.xmlText;
				if(structKeyExists(xmlNode.moduleInfo,"AuthorEmail")) variables.instance.AuthorEmail = xmlNode.moduleInfo.AuthorEmail.xmlText;
				if(structKeyExists(xmlNode.moduleInfo,"AuthorURL")) variables.instance.AuthorURL = xmlNode.moduleInfo.AuthorURL.xmlText;
				if(structKeyExists(xmlNode.moduleInfo,"Screenshot")) variables.instance.Screenshot = xmlNode.moduleInfo.Screenshot.xmlText;
			}				
		</cfscript>
		<cfreturn this />
	</cffunction>

	<cffunction name="getOwner" access="public" output="false" returntype="string">
		<cfreturn variables.instance.Owner />
	</cffunction>

	<cffunction name="setOwner" access="public" output="false" returntype="void">
		<cfargument name="Owner" type="string" required="true" />
		<cfset variables.instance.Owner = arguments.Owner />
		<cfreturn />
	</cffunction>

	<cffunction name="getAccessType" access="public" output="false" returntype="string">
		<cfreturn variables.instance.AccessType />
	</cffunction>

	<cffunction name="setAccessType" access="public" output="false" returntype="void">
		<cfargument name="AccessType" type="string" required="true" />
		<cfset variables.instance.AccessType = arguments.AccessType />
		<cfreturn />
	</cffunction>

	<cffunction name="getAuthorName" access="public" output="false" returntype="string">
		<cfreturn variables.instance.AuthorName />
	</cffunction>

	<cffunction name="setAuthorName" access="public" output="false" returntype="void">
		<cfargument name="AuthorName" type="string" required="true" />
		<cfset variables.instance.AuthorName = arguments.AuthorName />
		<cfreturn />
	</cffunction>

	<cffunction name="getAuthorEmail" access="public" output="false" returntype="string">
		<cfreturn variables.instance.AuthorEmail />
	</cffunction>

	<cffunction name="setAuthorEmail" access="public" output="false" returntype="void">
		<cfargument name="AuthorEmail" type="string" required="true" />
		<cfset variables.instance.AuthorEmail = arguments.AuthorEmail />
		<cfreturn />
	</cffunction>

	<cffunction name="getAuthorURL" access="public" output="false" returntype="string">
		<cfreturn variables.instance.AuthorURL />
	</cffunction>

	<cffunction name="setAuthorURL" access="public" output="false" returntype="void">
		<cfargument name="AuthorURL" type="string" required="true" />
		<cfset variables.instance.AuthorURL = arguments.AuthorURL />
		<cfreturn />
	</cffunction>

	<cffunction name="getScreenshot" access="public" output="false" returntype="string">
		<cfreturn variables.instance.Screenshot />
	</cffunction>

	<cffunction name="setScreenshot" access="public" output="false" returntype="void">
		<cfargument name="Screenshot" type="string" required="true" />
		<cfset variables.instance.Screenshot = arguments.Screenshot />
		<cfreturn />
	</cffunction>

	<cffunction name="getMethods" access="public" output="false" returntype="array">
		<cfreturn variables.instance.Methods />
	</cffunction>

	<cffunction name="getEvents" access="public" output="false" returntype="array">
		<cfreturn variables.instance.Events />
	</cffunction>

	<cffunction name="getAttributes" access="public" output="false" returntype="any">
		<cfreturn variables.instance.Attributes />
	</cffunction>
	
	<cffunction name="getResources" access="public" output="false" returntype="array">
		<cfreturn variables.instance.Resources />
	</cffunction>

	<cffunction name="getEventListeners" access="public" output="false" returntype="any">
		<cfreturn variables.instance.EventListeners />
	</cffunction>

</cfcomponent>