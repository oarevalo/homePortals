<cfcomponent>

	<cfscript>
		variables.instance = structNew();
		variables.instance.href = "";
		variables.instance.title = "";
		variables.instance.owner = "";
		variables.instance.access = "general";
		variables.instance.aStyles = ArrayNew(1);
		variables.instance.aScripts = ArrayNew(1);
		variables.instance.aEventListeners = ArrayNew(1);
		variables.instance.stLayouts = StructNew();			// holds properties for layout sections
		variables.instance.aModules = ArrayNew(1);		// holds modules		
		variables.instance.stModuleIndex = structNew();	// an index of modules	
		
		variables.LAYOUT_REGION_TYPES = "header,column,footer";
		variables.ACCESS_TYPES = "general,owner,friend";
	</cfscript>

	<cffunction name="init" access="public" returntype="pageBean">
		<cfargument name="href" type="string" required="false" default="">
		
		<cfif arguments.href neq "">
			<cfif Not fileExists(expandPath(arguments.href))>
				<cfthrow message="Page not found" type="homePortals.pageBean.fileNotFound">
			</cfif>
			<cfset load(expandPath(arguments.href))>
			<cfset setHREF(arguments.href)>
		<cfelse>
			<cfset initPageProperties()>
		</cfif>

		<cfreturn this>		
	</cffunction>
	
	<cffunction name="load" access="private" returntype="void" hint="load and parse xml file">
		<cfargument name="pagePath" type="string" required="false" default="">
		<cfscript>
			var xmlDoc = 0;
			var st = structNew(); var xmlNode = 0;
			var i = 0; var j = 0;
			var args = structNew();
				
			// read page document
			xmlDoc = xmlParse(arguments.pagePath);

			// initialize default page properties
			initPageProperties();

			// set page owner
			if(structKeyExists(xmlDoc.xmlRoot.xmlAttributes, "owner"))
				setOwner(xmlDoc.xmlRoot.xmlAttributes.owner);

			// set page access level
			if(structKeyExists(xmlDoc.xmlRoot.xmlAttributes, "access"))
				setAccess(xmlDoc.xmlRoot.xmlAttributes.access);

			// process top level nodes
			for(i=1;i lte ArrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				
				// get poiner to current node
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				
				switch(xmlNode.xmlName) {
				
					// title node
					case "title":
						setTitle(xmlNode.xmlText);
						break;
						
					// stylesheets
					case "stylesheet":
						addStylesheet(xmlNode.xmlAttributes.Href);
						break;
						
					// script
					case "script":
						addScript(xmlNode.xmlAttributes.src);
						break;
				
					// layout
					case "layout":
						for(j=1;j lte ArrayLen(xmlNode.xmlChildren); j=j+1) {
							if(xmlNode.xmlChildren[j].xmlName eq "location") {
								xmlThisNode = xmlNode.xmlChildren[j];
								args = structNew();
								args.name = "";
								args.type = "";
								args.class = "";
								args.style = "";
								args.id = "";
								
								if(structKeyExists(xmlThisNode.xmlAttributes, "name")) args.name = xmlThisNode.xmlAttributes.name;
								if(structKeyExists(xmlThisNode.xmlAttributes, "type")) args.type = xmlThisNode.xmlAttributes.type; 
								if(structKeyExists(xmlThisNode.xmlAttributes, "class")) args.class = xmlThisNode.xmlAttributes.class; 
								if(structKeyExists(xmlThisNode.xmlAttributes, "style")) args.style = xmlThisNode.xmlAttributes.style; 
								if(structKeyExists(xmlThisNode.xmlAttributes, "id")) 
									args.id = xmlThisNode.xmlAttributes.id;
								else
									args.id = "h_location_#args.type#_#j#"; 
				
								addLayoutRegion(argumentCollection = args);
							}
						}
						break;	
									
					// modules
					case "modules":
						if(structKeyExists(xmlNode.xmlAttributes, "basePath"))
							variables.stPage.page.basePath = xmlNode.xmlAttributes.basePath;
	
						for(j=1;j lte ArrayLen(xmlNode.xmlChildren); j=j+1) {
							if(xmlNode.xmlChildren[j].xmlName eq "module") {
								xmlThisNode = xmlNode.xmlChildren[j];

								// copy all attributes from the node into another struct
								// (modified for Railo2 compatibility)
								args = structNew();
								for(item in xmlThisNode.xmlAttributes) {
									args[item] = xmlThisNode.xmlAttributes[item];
								}
								
								// validate module attributes
								if(Not structKeyExists(args, "id")) args.id = ""; 
								if(Not structKeyExists(args, "name")) args.name = "";
								if(Not structKeyExists(args, "location")) args.location = "";
								if(Not structKeyExists(args, "title")) args.title = args.name; 
								if(Not structKeyExists(args, "container")) args.container = true; 
								if(Not structKeyExists(args, "display")) args.display = "normal";  // normal, collapsed, hidden
								if(Not structKeyExists(args, "output")) args.output = true; 
								if(Not structKeyExists(args, "style")) args.style = ""; 
								if(Not structKeyExists(args, "icon")) args.icon = ""; 
	
								// make sure there is a unique ID for each module 
								if(args.id eq "") args.id = "h_module_#args.location#_#j#";
	
								addModule(args.id, args);
							}
						}
	
						break;
							
					// event handlers
					case "eventListeners":
						for(j=1;j lte ArrayLen(xmlNode.xmlChildren); j=j+1) {
							if(xmlNode.xmlChildren[j].xmlName eq "event") {
								xmlThisNode = xmlNode.xmlChildren[j];

								args = structNew();
								args.objectName = "";
								args.eventName = "";
								args.eventHandler = "";

								if(StructKeyExists(xmlThisNode.xmlAttributes,"objectName")) args.objectName = xmlThisNode.xmlAttributes.objectName; 
								if(StructKeyExists(xmlThisNode.xmlAttributes,"eventName")) args.eventName = xmlThisNode.xmlAttributes.eventName; 
								if(StructKeyExists(xmlThisNode.xmlAttributes,"eventHandler")) args.eventHandler= xmlThisNode.xmlAttributes.eventHandler; 
								
								addEventListener(argumentCollection = args);
							}
						}
						break;	
				}
			}		
		</cfscript>
	</cffunction>

	<cffunction name="toXML" access="public" returnType="xml" hint="Returns the page as an XML document">
		<cfscript>
			var xmlDoc = 0;
			var xmlNode = 0;
			var i = 0; var j = 0;
			var aTemp = arrayNew(1);
			var attr = "";

			// create a blank xml document and add the root node
			xmlDoc = xmlNew();
			xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "Page");

			xmlDoc.xmlRoot.xmlAttributes["owner"] = xmlFormat(getOwner());
			xmlDoc.xmlRoot.xmlAttributes["access"] = xmlFormat(getAccess());
			
			// add title
			xmlNode = xmlElemNew(xmlDoc,"title");
			xmlNode.xmlText = xmlFormat(getTitle());
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);

			// add stylesheets
			aTemp = getStylesheets();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				xmlNode = xmlElemNew(xmlDoc,"stylesheet");
				xmlNode.xmlAttributes["href"] = xmlFormat(aTemp[i]);
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}

			// add scripts
			aTemp = getScripts();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				xmlNode = xmlElemNew(xmlDoc,"script");
				xmlNode.xmlAttributes["src"] = xmlFormat(aTemp[i]);
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}
			
			// add layout regions
			xmlNode = xmlElemNew(xmlDoc,"layout");
			aTemp = getLayoutRegions();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				xmlNode2 = xmlElemNew(xmlDoc,"location");
				xmlNode2.xmlAttributes["name"] = xmlFormat(aTemp[i].name);
				xmlNode2.xmlAttributes["type"] = xmlFormat(aTemp[i].type);
				if(aTemp[i].id neq "") xmlNode2.xmlAttributes["id"] = xmlFormat(aTemp[i].id);
				if(aTemp[i].class neq "") xmlNode2.xmlAttributes["class"] = xmlFormat(aTemp[i].class);
				if(aTemp[i].style neq "") xmlNode2.xmlAttributes["style"] = xmlFormat(aTemp[i].style);
				arrayAppend(xmlNode.xmlChildren, xmlNode2);
			}
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			
			// add event listeners
			xmlNode = xmlElemNew(xmlDoc,"eventListeners");
			aTemp = getEventListeners();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				xmlNode2 = xmlElemNew(xmlDoc,"event");
				xmlNode2.xmlAttributes["objectName"] = xmlFormat(aTemp[i].objectName);
				xmlNode2.xmlAttributes["eventName"] = xmlFormat(aTemp[i].eventName);
				xmlNode2.xmlAttributes["eventHandler"] = xmlFormat(aTemp[i].eventHandler);
				arrayAppend(xmlNode.xmlChildren, xmlNode2);
			}
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);

			// add modules
			xmlNode = xmlElemNew(xmlDoc,"modules");
			aTemp = getModules();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				xmlNode2 = xmlElemNew(xmlDoc,"module");
				for(attr in aTemp[i]) {
					xmlNode2.xmlAttributes[attr] = xmlFormat(aTemp[i][attr]);
				}
				arrayAppend(xmlNode.xmlChildren, xmlNode2);
			}
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
		</cfscript>
		<cfreturn xmlDoc>
	</cffunction>



	<!---------------------------------------->
	<!--- HREF					           --->
	<!---------------------------------------->	
	<cffunction name="getHREF" access="public" returntype="string">
		<cfreturn variables.instance.href>
	</cffunction>

	<cffunction name="setHREF" access="public" returntype="string">
		<cfargument name="data" type="string" required="true">
		<cfif arguments.data eq "">
			<cfthrow message="Page href cannot be empty" type="homePortals.pageBean.hrefIsEmpty">
		</cfif>
		<cfset variables.instance.href = arguments.data>
	</cffunction>


	<!---------------------------------------->
	<!--- Title					           --->
	<!---------------------------------------->		
	<cffunction name="getTitle" access="public" returntype="string">
		<cfreturn variables.instance.title>
	</cffunction>

	<cffunction name="setTitle" access="public" returnType="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.title = trim(arguments.data)>
	</cffunction>


	<!---------------------------------------->
	<!--- Owner					           --->
	<!---------------------------------------->	
	<cffunction name="getOwner" access="public" returntype="string">
		<cfreturn variables.instance.owner>
	</cffunction>
	
	<cffunction name="setOwner" access="public" returnType="void">
		<cfargument name="data" type="string" required="true">
		<cfif arguments.data eq "">
			<cfthrow message="Page owner cannot be empty" type="homePortals.pageBean.ownerIsEmpty">
		</cfif>
		<cfset variables.instance.owner = trim(arguments.data)>
	</cffunction>
		

	<!---------------------------------------->
	<!--- Access				           --->
	<!---------------------------------------->		
	<cffunction name="getAccess" access="public" returntype="string">
		<cfreturn variables.instance.access>
	</cffunction>
	
	<cffunction name="setAccess" access="public" returnType="void">
		<cfargument name="accessType" type="string" required="true">
		<cfif not listFindNoCase(variables.ACCESS_TYPES, arguments.accessType)>
			<cfthrow message="Invalid access type. Valid types are: #variables.ACCESS_TYPES#" type="homePortals.pageBean.invalidAccessType">
		</cfif>
		<cfset variables.instance.access = arguments.accessType>
	</cffunction>
				
		
	<!---------------------------------------->
	<!--- Stylesheets			           --->
	<!---------------------------------------->			
	<cffunction name="getStylesheets" access="public" returntype="array">
		<cfreturn variables.instance.aStyles>
	</cffunction>

	<cffunction name="addStylesheet" access="public" returnType="void">
		<cfargument name="href" type="string" required="true">
		<cfset arrayAppend(variables.instance.aStyles, arguments.href)>
	</cffunction>
	
	<cffunction name="removeStylesheet" access="public" returnType="void">
		<cfargument name="href" type="string" required="true">
		<cfloop from="1" to="#arrayLen(variables.instance.aStyles)#" index="i">
			<cfif variables.instance.aStyles[i] eq arguments.href>
				<cfset arrayDeleteAt(variables.instance.aStyles, i)>
				<cfexit>
			</cfif>
		</cfloop>
	</cffunction>	

	<cffunction name="removeAllStylesheets" access="public" returnType="void">
		<cfset variables.instance.aStyles = ArrayNew(1)>
	</cffunction>
	

	<!---------------------------------------->
	<!--- Scripts				           --->
	<!---------------------------------------->	
	<cffunction name="getScripts" access="public" returntype="array">
		<cfreturn variables.instance.aScripts>
	</cffunction>

	<cffunction name="addScript" access="public" returnType="void">
		<cfargument name="src" type="string" required="true">
		<cfset arrayAppend(variables.instance.aScripts, arguments.src)>
	</cffunction>
	
	<cffunction name="removeScript" access="public" returnType="void">
		<cfargument name="src" type="string" required="true">
		<cfloop from="1" to="#arrayLen(variables.instance.aScripts)#" index="i">
			<cfif variables.instance.aScripts[i] eq arguments.src>
				<cfset arrayDeleteAt(variables.instance.aScripts, i)>
				<cfexit>
			</cfif>
		</cfloop>
	</cffunction>	
	
	<cffunction name="removeAllScripts" access="public" returnType="void">
		<cfset variables.instance.aScripts = ArrayNew(1)>
	</cffunction>


	<!---------------------------------------->
	<!--- Event Listeners		           --->
	<!---------------------------------------->	
	<cffunction name="getEventListeners" access="public" returntype="array">
		<cfreturn variables.instance.aEventListeners>
	</cffunction>

	<cffunction name="addEventListener" access="public" returnType="void">
		<cfargument name="objectName" type="string" required="true">
		<cfargument name="eventName" type="string" required="true">
		<cfargument name="eventHandler" type="string" required="true">
		<cfset var st = structNew()>
		<cfif arguments.objectName eq "" or arguments.eventName eq "" or arguments.eventHandler eq "">
			<cfthrow message="An event listener must include object, event and event handler" type="homePortals.pageBean.invalidEventListener">
		</cfif>
		<cfset st.objectName = arguments.objectName>
		<cfset st.eventName = arguments.eventName>
		<cfset st.eventHandler = arguments.eventHandler>
		<cfset ArrayAppend(variables.instance.aEventListeners, st)>
	</cffunction>

	<cffunction name="removeEventListener" access="public" returnType="void">
		<cfargument name="objectName" type="string" required="true">
		<cfargument name="eventName" type="string" required="true">
		<cfargument name="eventHandler" type="string" required="true">
		<cfset var i = 0>
		<cfset var st = structNew()>
		<cfloop from="1" to="#arrayLen(variables.aEventHandlers)#" index="i">
			<cfset st = variables.instance.aEventListeners[i]>
			<cfif st.objectName eq arguments.objectName and st.eventName eq arguments.eventName and st.eventHandler eq arguments.eventHandler>
				<cfset arrayDeleteAt(variables.instance.aEventListeners, i)>
				<cfexit>
			</cfif>
		</cfloop>
	</cffunction>	
	
	<cffunction name="removeAllEventListeners" access="public" returnType="void">
		<cfset variables.instance.aEventListeners = arrayNew(1)>
	</cffunction>



	<!---------------------------------------->
	<!--- Layout Regions		           --->
	<!---------------------------------------->	
	<cffunction name="getLayoutRegions" access="public" returntype="array">
		<cfset var aRet = arrayNew(1)>
		<cfloop collection="#variables.instance.stLayouts#" item="key">
			<cfset arrayAppend(aRet, variables.instance.stLayouts[key])>
		</cfloop>
		<cfreturn aRet>
	</cffunction>

	<cffunction name="addLayoutRegion" access="public" returnType="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfargument name="class" type="string" required="false" default="">
		<cfargument name="style" type="string" required="false" default="">
		<cfargument name="id" type="string" required="false" default="">
		<cfset var st = structNew()>

		<cfif arguments.name eq "">
			<cfthrow message="Layout region name cannot be empty" type="homePortals.pageBean.invalidLayoutRegionName">
		</cfif>

		<cfif not listFindNoCase(variables.LAYOUT_REGION_TYPES, arguments.type)>
			<cfthrow message="Invalid layout region type. Valid types are: #variables.LAYOUT_REGION_TYPES#" type="homePortals.pageBean.invalidLayoutRegionType">
		</cfif>
		
		<cfset st.name = arguments.name>
		<cfset st.type = arguments.type>
		<cfset st.class = arguments.class>
		<cfset st.style = arguments.style>
		<cfset st.id = arguments.id>
		
		<cfset variables.instance.stLayouts[arguments.name] = duplicate(st)>
	</cffunction>

	<cffunction name="removeLayoutRegion" access="public" returnType="void">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.instance.stLayouts, arguments.name)>
	</cffunction>

	<cffunction name="removeAllLayoutRegions" access="public" returnType="void">
		<cfset variables.instance.stLayouts = structNew()>
	</cffunction>



	<!---------------------------------------->
	<!--- Modules				           --->
	<!---------------------------------------->	
	<cffunction name="getModules" access="public" returntype="array">
		<cfreturn variables.instance.aModules>
	</cffunction>

	<cffunction name="getModule" access="public" returntype="struct">
		<cfargument name="moduleID" type="string" required="true">
		<cfreturn variables.instance.aModules[getModuleIndex(arguments.moduleID)]>
	</cffunction>

	<cffunction name="setModule" access="public" returntype="void">
		<cfargument name="moduleID" type="string" required="true">
		<cfargument name="moduleAttributes" type="struct" required="false">
		
		<cfif arguments.moduleID eq "">
			<cfthrow message="module ID cannot be empty" type="homePortals.pageBean.blankModuleID">
		</cfif>
		<cfif not structKeyExists(arguments.moduleAttributes,"id") or arguments.moduleAttributes.id eq "">
			<cfthrow message="module ID cannot be empty" type="homePortals.pageBean.blankModuleID">
		</cfif>
		<cfif arguments.moduleID neq arguments.moduleAttributes.id>
			<cfthrow message="module ID attribute mismatch" type="homePortals.pageBean.mismatchModuleID">
		</cfif>
		<cfif not structKeyExists(arguments.moduleAttributes,"location") or arguments.moduleAttributes.location eq "">
			<cfthrow message="module location cannot be empty" type="homePortals.pageBean.blankModuleLocation">
		</cfif>
		
		<cfset variables.instance.aModules[getModuleIndex(arguments.moduleID)] = arguments.moduleAttributes>
	</cffunction>

	<cffunction name="addModule" access="public" returntype="void">
		<cfargument name="moduleID" type="string" required="true">
		<cfargument name="moduleAttributes" type="struct" required="false">
		<cfif structKeyExists(variables.instance.stModuleIndex, arguments.moduleID)>
			<cfthrow message="Module ID already in use" type="homePortals.pageBean.duplicateModuleID">
		</cfif>
		<cfif arguments.moduleID eq "">
			<cfthrow message="module ID cannot be empty" type="homePortals.pageBean.blankModuleID">
		</cfif>
		<cfif not structKeyExists(arguments.moduleAttributes,"id") or arguments.moduleAttributes.id eq "">
			<cfthrow message="module ID cannot be empty" type="homePortals.pageBean.blankModuleID">
		</cfif>
		<cfif arguments.moduleID neq arguments.moduleAttributes.id>
			<cfthrow message="module ID attribute mismatch" type="homePortals.pageBean.mismatchModuleID">
		</cfif>
		<cfif not structKeyExists(arguments.moduleAttributes,"location") or arguments.moduleAttributes.location eq "">
			<cfthrow message="module location cannot be empty" type="homePortals.pageBean.blankModuleLocation">
		</cfif>
		<cfset arrayAppend(variables.instance.aModules, arguments.moduleAttributes)>
		<cfset indexModules()>
	</cffunction>

	<cffunction name="removeModule" access="public" returntype="void">
		<cfargument name="moduleID" type="string" required="true">
		<cfset arrayDeleteAt(variables.instance.aModules, getModuleIndex(arguments.moduleID))>
		<cfset indexModules()>
	</cffunction>

	<cffunction name="removeAllModules" access="public" returntype="void">
		<cfset variables.instance.aModules = arrayNew(1)>
		<cfset variables.instance.stModuleIndex = structNew()>
	</cffunction>

	<cffunction name="getModuleIndex" access="private" returntype="numeric" hint="returns the index of a given module on the modules array">
		<cfargument name="moduleID" type="string" required="true">
		<cfif not structKeyExists(variables.instance.stModuleIndex, arguments.moduleID)>
			<cfthrow message="Module ID not found" type="homePortals.pageBean.moduleNotFound">
		</cfif>
		<cfreturn variables.instance.stModuleIndex[arguments.moduleID]>
	</cffunction>

	<cffunction name="indexModules" access="private" returntype="void" hint="creates an index of modules on the modules array">
		<cfset variables.instance.stModuleIndex = structNew()>
		<cfloop from="1" to="#arrayLen(variables.instance.aModules)#" index="i">
			<cfset variables.instance.stModuleIndex[variables.instance.aModules[i].id] = i>
		</cfloop>
	</cffunction>




	<!---------------------------------------->
	<!--- getLocationTypes		           --->
	<!---------------------------------------->	
	<cffunction name="getLocationTypes" access="public" returntype="array" output="False"
				hint="Returns an array with possible values for layout location types">
		<cfreturn listToArray(variables.LAYOUT_REGION_TYPES)>
	</cffunction>

	<!---------------------------------------->
	<!--- getAccessTypes		           --->
	<!---------------------------------------->	
	<cffunction name="getAccessTypes" access="public" returntype="array" output="False"
				hint="Returns an array with possible values for page access">
		<cfreturn listToArray(variables.ACCESS_TYPES)>
	</cffunction>

	<!---------------------------------------->
	<!--- getMemento			           --->
	<!---------------------------------------->	
	<cffunction name="getMemento" access="public" returntype="struct" output="False">
		<cfreturn variables.instance>
	</cffunction>

	<!---------------------------------------->
	<!--- initPageProperties		       --->
	<!---------------------------------------->	
	<cffunction name="initPageProperties" access="private" returntype="void" hint="sets initial value for page properties">
		<cfscript>
			variables.instance.title = "";
			variables.instance.owner = "";
			variables.instance.access = "general";
			variables.instance.aStyles = arrayNew(1);
			variables.instance.aScripts = arrayNew(1);
			variables.instance.aEventListeners = ArrayNew(1);
			variables.instance.stLayouts = StructNew();			
			variables.instance.aModules = ArrayNew(1);				
			variables.instance.stModuleIndex = structNew();
		</cfscript>	
	</cffunction>

</cfcomponent>