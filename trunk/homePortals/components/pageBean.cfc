<cfcomponent>

	<cfscript>
		variables.DEFAULT_PAGE_TITLE = "";
		variables.DEFAULT_PAGE_SKINID = "";
		variables.DEFAULT_PAGE_TEMPLATE = "";
		variables.DEFAULT_MODULE_TITLE = "";
		variables.DEFAULT_MODULE_ICON = "";
		variables.DEFAULT_MODULE_STYLE = "";
		variables.DEFAULT_MODULE_CLASS = "";
		variables.DEFAULT_MODULE_CONTAINER = true;
		variables.DEFAULT_MODULE_OUTPUT = true;
		variables.DEFAULT_MODULE_TEMPLATE = "";

		variables.instance = structNew();
		variables.instance.title = variables.DEFAULT_PAGE_TITLE;
		variables.instance.skinID = variables.DEFAULT_PAGE_SKINID;
		variables.instance.pageTemplate = variables.DEFAULT_PAGE_TEMPLATE;
		variables.instance.aStyles = ArrayNew(1);
		variables.instance.aScripts = ArrayNew(1);
		variables.instance.aEventListeners = ArrayNew(1);
		variables.instance.aLayouts = ArrayNew(1);			// holds properties for layout sections
		variables.instance.aModules = ArrayNew(1);		// holds modules		
		variables.instance.stModuleIndex = structNew();	// an index of modules	
		variables.instance.aMeta = ArrayNew(1);			// user-defined meta tags
		variables.instance.stProperties = structNew();
	</cfscript>

	<cffunction name="init" access="public" returntype="pageBean">
		<cfargument name="pageXML" type="any" required="false" default="">
		<cfif isXML(arguments.pageXML) or isXMLDoc(arguments.pageXML)>
			<cfset loadXML(arguments.pageXML)>
		<cfelse>
			<cfset initPageProperties()>
		</cfif>
		<cfreturn this>		
	</cffunction>
	
	<cffunction name="loadXML" access="public" returntype="void" hint="Populates the bean from an XML object or string">
		<cfargument name="pageXML" type="any" required="true">
		<cfscript>
			var xmlDoc = 0;
			var st = structNew(); var xmlNode = 0;
			var i = 0; var j = 0; var oModuleBean = 0;
			var args = structNew();
				
			if(isXML(arguments.pageXML)) 
				xmlDoc = xmlParse(arguments.pageXML);
			else if(isXMLDoc(arguments.pageXML))
				xmlDoc = arguments.pageXML;
			else
				throw("Invalid argument. Argument must be either an xml string or an xml object","homePortals.pageBean.invalidArgument");
				

			// initialize default page properties
			initPageProperties();

			// read custom page properties
			for(i in xmlDoc.xmlRoot.xmlAttributes) {
				setProperty(i, xmlDoc.xmlRoot.xmlAttributes[i]);
			}

			// process top level nodes
			for(i=1;i lte ArrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				
				// get poiner to current node
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				
				switch(xmlNode.xmlName) {
				
					// title node
					case "title":
						setTitle(trim(xmlNode.xmlText));
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
								args.moduleTemplate = "";
								
								if(structKeyExists(xmlThisNode.xmlAttributes, "name")) args.name = xmlThisNode.xmlAttributes.name;
								if(structKeyExists(xmlThisNode.xmlAttributes, "type")) args.type = xmlThisNode.xmlAttributes.type; 
								if(structKeyExists(xmlThisNode.xmlAttributes, "class")) args.class = xmlThisNode.xmlAttributes.class; 
								if(structKeyExists(xmlThisNode.xmlAttributes, "style")) args.style = xmlThisNode.xmlAttributes.style; 
								if(structKeyExists(xmlThisNode.xmlAttributes, "moduleTemplate")) args.moduleTemplate = xmlThisNode.xmlAttributes.moduleTemplate; 
								if(structKeyExists(xmlThisNode.xmlAttributes, "id")) 
									args.id = xmlThisNode.xmlAttributes.id;
								else
									args.id = "h_location_#args.type#_#j#"; 
				
								addLayoutRegion(argumentCollection = args);
							}
						}
						break;	
									
					// modules/body
					case "modules":
					case "body":
						if(structKeyExists(xmlNode.xmlAttributes, "basePath"))
							variables.stPage.page.basePath = xmlNode.xmlAttributes.basePath;
				
						for(j=1;j lte ArrayLen(xmlNode.xmlChildren); j=j+1) {

							xmlThisNode = xmlNode.xmlChildren[j];
	
	
							args = structNew();	// this structure is used to hold the module attributes
							args.moduleType = xmlThisNode.xmlName;	// store the "type" of module
	
							// copy all attributes from the node into another struct
							// (modified for Railo2 compatibility)
							for(item in xmlThisNode.xmlAttributes) {
								args[item] = xmlThisNode.xmlAttributes[item];
							}

							// Provide a unique ID for each module 
							if(not structKeyExists(args,"location")) args.location = "";
							if(not structKeyExists(args,"id") or args.id eq "") args.id = "h_#xmlThisNode.xmlName#_#args.location#_#j#";
	
							oModuleBean = createObject("component","moduleBean").init( args );
	
							// add module to instance
							addModule(oModuleBean, args.location);
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
						
					// meta tags
					case "meta":
						args = structNew();
						args.name = "";
						args.content = "";

						if(StructKeyExists(xmlNode.xmlAttributes,"name")) args.name = xmlNode.xmlAttributes.name; 
						if(StructKeyExists(xmlNode.xmlAttributes,"content")) args.content = xmlNode.xmlAttributes.content; 
						
						addMetaTag(argumentCollection = args);
						break;	
						
					// skin	
					case "skin":
						setSkinID(xmlNode.xmlAttributes.id);
						break;
						
					// page template
					case "pageTemplate":
						setPageTemplate(trim(xmlNode.xmlText));
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
			var attr = ""; var st = structNew();
			var bWriteAttribute = false;

			// create a blank xml document and add the root node
			xmlDoc = xmlNew();
			xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "Page");

			// add custom properties
			st = getProperties();
			for(i in st) {
				if(not st[i].transient) {
					xmlDoc.xmlRoot.xmlAttributes[st[i].name] = st[i].value;
				}
			}

			// add title
			if(getTitle() neq "") {
				xmlNode = xmlElemNew(xmlDoc,"title");
				xmlNode.xmlText = getTitle();
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}

			// add meta tags
			aTemp = getMetaTags();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				xmlNode = xmlElemNew(xmlDoc,"meta");
				xmlNode.xmlAttributes["name"] = aTemp[i].name;
				xmlNode.xmlAttributes["content"] = aTemp[i].content;
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}

			
			// add stylesheets
			aTemp = getStylesheets();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				xmlNode = xmlElemNew(xmlDoc,"stylesheet");
				xmlNode.xmlAttributes["href"] = aTemp[i];
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}

			// add scripts
			aTemp = getScripts();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				xmlNode = xmlElemNew(xmlDoc,"script");
				xmlNode.xmlAttributes["src"] = aTemp[i];
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}
			
			// add layout regions
			aTemp = getLayoutRegions();
			if(arrayLen(aTemp) gt 0) {
				xmlNode = xmlElemNew(xmlDoc,"layout");
				for(i=1;i lte arrayLen(aTemp);i=i+1) {
					xmlNode2 = xmlElemNew(xmlDoc,"location");
					xmlNode2.xmlAttributes["name"] = aTemp[i].name;
					xmlNode2.xmlAttributes["type"] = aTemp[i].type;
					if(aTemp[i].id neq "") xmlNode2.xmlAttributes["id"] = aTemp[i].id;
					if(aTemp[i].class neq "") xmlNode2.xmlAttributes["class"] = aTemp[i].class;
					if(aTemp[i].style neq "") xmlNode2.xmlAttributes["style"] = aTemp[i].style;
					arrayAppend(xmlNode.xmlChildren, xmlNode2);
				}
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}
			
			// add event listeners
			aTemp = getEventListeners();
			if(arrayLen(aTemp) gt 0) {
				xmlNode = xmlElemNew(xmlDoc,"eventListeners");
				for(i=1;i lte arrayLen(aTemp);i=i+1) {
					xmlNode2 = xmlElemNew(xmlDoc,"event");
					xmlNode2.xmlAttributes["objectName"] = aTemp[i].objectName;
					xmlNode2.xmlAttributes["eventName"] = aTemp[i].eventName;
					xmlNode2.xmlAttributes["eventHandler"] = aTemp[i].eventHandler;
					arrayAppend(xmlNode.xmlChildren, xmlNode2);
				}
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}

			// add modules
			aTemp = getModules();
			if(arrayLen(aTemp) gt 0) {
				xmlNode = xmlElemNew(xmlDoc,"body");
				for(i=1;i lte arrayLen(aTemp);i=i+1) {
					xmlNode2 = xmlElemNew(xmlDoc,aTemp[i].getModuleType());
					st = aTemp[i].toStruct();
					for(attr in st) {
						bWriteAttribute = true;
						
						switch(attr) {
							case "id": 
								attr = "id";
								bWriteAttribute = true; 	
								break;
							case "location": 
								attr = "location";
								bWriteAttribute = true; 	
								break;
							case "moduleType":
								attr = "moduleType";
								bWriteAttribute = false; 	// this attribute is ignored
								break;
							case "container":
								attr = "container";
								bWriteAttribute = (st[attr] neq variables.DEFAULT_MODULE_CONTAINER);	
								break;
							case "output":
								attr = "output";
								bWriteAttribute = (st[attr] neq variables.DEFAULT_MODULE_OUTPUT);
								break;
							case "icon":
								attr = "icon";
								bWriteAttribute = (st[attr] neq variables.DEFAULT_MODULE_ICON);
								break;
							case "title":
								attr = "title";
								bWriteAttribute = (st[attr] neq variables.DEFAULT_MODULE_TITLE);
								break;
							case "style":
								attr = "style";
								bWriteAttribute = (st[attr] neq variables.DEFAULT_MODULE_STYLE);
								break;
							case "class":
								attr = "class";
								bWriteAttribute = (st[attr] neq variables.DEFAULT_MODULE_CLASS);
								break;
							case "moduleTemplate":
								attr = "moduleTemplate";
								bWriteAttribute = (st[attr] neq variables.DEFAULT_MODULE_TEMPLATE);
								break;
							default:
								bWriteAttribute = true;		// write down all other attributes
						}
						
						if(bWriteAttribute) xmlNode2.xmlAttributes[attr] = st[attr];
					}
					arrayAppend(xmlNode.xmlChildren, xmlNode2);
				}
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}
			
			// add skin
			if(variables.instance.skinID neq variables.DEFAULT_PAGE_SKINID) {
				xmlNode = xmlElemNew(xmlDoc,"skin");
				xmlNode.xmlAttributes["id"] = variables.instance.skinID;
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}

			// add pagetemplate
			if(variables.instance.pageTemplate neq variables.DEFAULT_PAGE_TEMPLATE) {
				xmlNode = xmlElemNew(xmlDoc,"pageTemplate");
				xmlNode.xmlText = variables.instance.pageTemplate;
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}
		</cfscript>
		<cfreturn xmlDoc>
	</cffunction>



	<!---------------------------------------->
	<!--- Title					           --->
	<!---------------------------------------->		
	<cffunction name="getTitle" access="public" returntype="string" hint="Returns the page title">
		<cfreturn variables.instance.title>
	</cffunction>

	<cffunction name="setTitle" access="public" returnType="pageBean" hint="Sets the page title">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.title = trim(arguments.data)>
		<cfreturn this>
	</cffunction>


	<!---------------------------------------->
	<!--- pageTemplate			           --->
	<!---------------------------------------->		
	<cffunction name="getPageTemplate" access="public" returntype="string" hint="Returns the page template">
		<cfreturn variables.instance.pageTemplate>
	</cffunction>

	<cffunction name="setPageTemplate" access="public" returnType="pageBean" hint="Sets the page template">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.pageTemplate = trim(arguments.data)>
		<cfreturn this>
	</cffunction>



	<!---------------------------------------->
	<!--- Stylesheets			           --->
	<!---------------------------------------->			
	<cffunction name="getStylesheets" access="public" returntype="array" hint="returns an array with all stylesheets on the page">
		<cfreturn duplicate(variables.instance.aStyles)>
	</cffunction>

	<cffunction name="addStylesheet" access="public" returnType="pageBean" hint="adds a stylesheet to the page">
		<cfargument name="href" type="string" required="true">
		<cfif not hasStylesheet(arguments.href)>
			<cfset arrayAppend(variables.instance.aStyles, arguments.href)>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="hasStylesheet" access="public" returnType="boolean" hint="checks if the page is already using a given stylesheet">
		<cfargument name="href" type="string" required="true">
		<cfloop from="1" to="#arrayLen(variables.instance.aStyles)#" index="i">
			<cfif variables.instance.aStyles[i] eq arguments.href>
				<cfreturn true>
			</cfif>
		</cfloop>
		<cfreturn false>
	</cffunction>	
	
	<cffunction name="removeStylesheet" access="public" returnType="pageBean" hint="removes a stylesheet from the page">
		<cfargument name="href" type="string" required="true">
		<cfloop from="1" to="#arrayLen(variables.instance.aStyles)#" index="i">
			<cfif variables.instance.aStyles[i] eq arguments.href>
				<cfset arrayDeleteAt(variables.instance.aStyles, i)>
				<cfreturn this>
			</cfif>
		</cfloop>
		<cfreturn this>
	</cffunction>	

	<cffunction name="removeAllStylesheets" access="public" returnType="pageBean" hint="removes all stylesheets on the page">
		<cfset variables.instance.aStyles = ArrayNew(1)>
		<cfreturn this>
	</cffunction>
	

	<!---------------------------------------->
	<!--- Scripts				           --->
	<!---------------------------------------->	
	<cffunction name="getScripts" access="public" returntype="array" hint="returns an array with all script files referenced on the page">
		<cfreturn duplicate(variables.instance.aScripts)>
	</cffunction>

	<cffunction name="addScript" access="public" returnType="pageBean" hint="adds a script reference to the page">
		<cfargument name="src" type="string" required="true">
		<cfif not hasScript(arguments.src)>
			<cfset arrayAppend(variables.instance.aScripts, arguments.src)>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="hasScript" access="public" returnType="boolean" hint="checks if the page is already using a given script">
		<cfargument name="src" type="string" required="true">
		<cfloop from="1" to="#arrayLen(variables.instance.aScripts)#" index="i">
			<cfif variables.instance.aScripts[i] eq arguments.src>
				<cfreturn true>
			</cfif>
		</cfloop>
		<cfreturn false>
	</cffunction>	
	
	<cffunction name="removeScript" access="public" returnType="pageBean" hint="removes a script from the page">
		<cfargument name="src" type="string" required="true">
		<cfloop from="1" to="#arrayLen(variables.instance.aScripts)#" index="i">
			<cfif variables.instance.aScripts[i] eq arguments.src>
				<cfset arrayDeleteAt(variables.instance.aScripts, i)>
				<cfreturn this>
			</cfif>
		</cfloop>
		<cfreturn this>
	</cffunction>	
	
	<cffunction name="removeAllScripts" access="public" returnType="pageBean" hint="removes all scripts from the page">
		<cfset variables.instance.aScripts = ArrayNew(1)>
		<cfreturn this>
	</cffunction>


	<!---------------------------------------->
	<!--- Event Listeners		           --->
	<!---------------------------------------->	
	<cffunction name="getEventListeners" access="public" returntype="array" hint="Returns an array with all event listeners on the page">
		<cfreturn duplicate(variables.instance.aEventListeners)>
	</cffunction>

	<cffunction name="addEventListener" access="public" returnType="pageBean" hint="Adds an event listener to the page">
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
		<cfreturn this>
	</cffunction>

	<cffunction name="removeEventListener" access="public" returnType="pageBean" hint="Removes the given event listener">
		<cfargument name="objectName" type="string" required="true">
		<cfargument name="eventName" type="string" required="true">
		<cfargument name="eventHandler" type="string" required="true">
		<cfset var i = 0>
		<cfset var st = structNew()>

		<cfloop from="1" to="#arrayLen(variables.instance.aEventListeners)#" index="i">
			<cfset st = variables.instance.aEventListeners[i]>
			<cfif st.objectName eq arguments.objectName and st.eventName eq arguments.eventName and st.eventHandler eq arguments.eventHandler>
				<cfset arrayDeleteAt(variables.instance.aEventListeners, i)>
				<cfreturn this>
			</cfif>
		</cfloop>
		<cfreturn this>
	</cffunction>	
	
	<cffunction name="removeAllEventListeners" access="public" returnType="pageBean" hint="removes all event listeners">
		<cfset variables.instance.aEventListeners = arrayNew(1)>
		<cfreturn this>
	</cffunction>



	<!---------------------------------------->
	<!--- Layout Regions		           --->
	<!---------------------------------------->	
	<cffunction name="getLayoutRegions" access="public" returntype="array" hint="returns an array with all layout regions">
		<cfreturn duplicate(variables.instance.aLayouts)>
	</cffunction>

	<cffunction name="addLayoutRegion" access="public" returnType="pageBean" hint="adds a layout region">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfargument name="class" type="string" required="false" default="">
		<cfargument name="style" type="string" required="false" default="">
		<cfargument name="id" type="string" required="false" default="">
		<cfset var st = structNew()>

		<cfif arguments.name eq "">
			<cfthrow message="Layout region name cannot be empty" type="homePortals.pageBean.invalidLayoutRegionName">
		</cfif>
		<cfif arguments.type eq "">
			<cfthrow message="Layout region type cannot be empty" type="homePortals.pageBean.invalidLayoutRegionType">
		</cfif>
		<cfif hasLayoutRegion(arguments.name)>
			<cfthrow message="Layout region name already exists" type="homePortals.pageBean.duplicateLayoutRegionName">
		</cfif>
		
		<cfset st.name = arguments.name>
		<cfset st.type = arguments.type>
		<cfset st.class = arguments.class>
		<cfset st.style = arguments.style>
		<cfset st.id = arguments.id>
		
		<cfset ArrayAppend(variables.instance.aLayouts, st)>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="hasLayoutRegion" access="public" returnType="boolean" hint="checks if the page contains a given layout region">
		<cfargument name="name" type="string" required="true">
		<cfloop from="1" to="#arrayLen(variables.instance.aLayouts)#" index="i">
			<cfif variables.instance.aLayouts[i].name eq arguments.name>
				<cfreturn true>
			</cfif>
		</cfloop>
		<cfreturn false>
	</cffunction>	

	<cffunction name="removeLayoutRegion" access="public" returnType="pageBean" hint="removes a layout region">
		<cfargument name="name" type="string" required="true">
		<cfloop from="1" to="#arrayLen(variables.instance.aLayouts)#" index="i">
			<cfif variables.instance.aLayouts[i].name eq arguments.name>
				<cfset arrayDeleteAt(variables.instance.aLayouts, i)>
				<cfreturn this>
			</cfif>
		</cfloop>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeAllLayoutRegions" access="public" returnType="pageBean" hint="removes all layout regions">
		<cfset variables.instance.aLayouts = arrayNew(1)>
		<cfreturn this>
	</cffunction>



	<!---------------------------------------->
	<!--- Modules				           --->
	<!---------------------------------------->	
	<cffunction name="getModules" access="public" returntype="array" hint="returns an array with all content modules on the page">
		<cfreturn duplicate(variables.instance.aModules)>
	</cffunction>

	<cffunction name="getModule" access="public" returntype="moduleBean" hint="returns a bean with information about the given module">
		<cfargument name="moduleID" type="string" required="true">
		<cfreturn duplicate(variables.instance.aModules[getModuleIndex(arguments.moduleID)])>
	</cffunction>

	<cffunction name="setModule" access="public" returntype="pageBean" hint="adds or updates a module to the page">
		<cfargument name="moduleBean" type="moduleBean" required="true">
		<cfargument name="location" type="string" required="false" default="">
		<cfscript>
			arguments.moduleBean = normalizeModule(arguments.moduleBean, arguments.location);
			variables.instance.aModules[getModuleIndex(arguments.moduleBean.getID())] = arguments.moduleBean;
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="addModule" access="public" returntype="pageBean" hint="adds a module to the page">
		<cfargument name="moduleBean" type="moduleBean" required="true">
		<cfargument name="location" type="string" required="false" default="">
		<cfscript>
			arguments.moduleBean = normalizeModule(arguments.moduleBean, arguments.location);
			if(structKeyExists(variables.instance.stModuleIndex, arguments.moduleBean.getID()))
				throw("Module ID already in use","homePortals.pageBean.duplicateModuleID");
			arrayAppend(variables.instance.aModules, arguments.moduleBean);
			indexModules();
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="removeModule" access="public" returntype="pageBean" hint="removes a module from the page">
		<cfargument name="moduleID" type="string" required="true">
		<cfset arrayDeleteAt(variables.instance.aModules, getModuleIndex(arguments.moduleID))>
		<cfset indexModules()>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeAllModules" access="public" returntype="pageBean" hint="removes all modules">
		<cfset variables.instance.aModules = arrayNew(1)>
		<cfset variables.instance.stModuleIndex = structNew()>
		<cfreturn this>
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
			<cfset variables.instance.stModuleIndex[variables.instance.aModules[i].getID()] = i>
		</cfloop>
	</cffunction>

	<cffunction name="normalizeModule" access="private" returntype="struct" hint="checks module properties and assign correct default values when needed">
		<cfargument name="moduleBean" type="moduleBean" required="true">
		<cfargument name="location" type="string" required="false" default="">
		<cfscript>
			var aRegions = getLayoutRegions();

			/* set default location */
						
			if(arguments.location neq "")
				arguments.moduleBean.setLocation(arguments.location);
			
			if(arguments.moduleBean.getLocation() eq "" 
					and arguments.location neq ""
					and arrayLen(aRegions) gt 0) {
				arguments.moduleBean.setLocation(aRegions[1]);
			}


			/* validate required fields */

			if(arguments.moduleBean.getID() eq "") 
				throw("Module ID cannot be empty","homePortals.pageBean.blankModuleID");
				
		//	if(arguments.moduleBean.getLocation() eq "") 
		//		throw("Module location cannot be empty","homePortals.pageBean.blankModuleLocation");
				
			if(arguments.moduleBean.getModuleType() eq "") 
				throw("Module type cannot be empty","homePortals.pageBean.missingModuleType");

			return arguments.moduleBean;
		</cfscript>
	</cffunction>


	<!---------------------------------------->
	<!--- User-Defined Meta Tags           --->
	<!---------------------------------------->	
	<cffunction name="getMetaTags" access="public" returntype="array" hint="returns an array with all user-defined meta tags">
		<cfreturn duplicate(variables.instance.aMeta)>
	</cffunction>

	<cffunction name="addMetaTag" access="public" returnType="pageBean" hint="adds a user-defined meta tag to the page">
		<cfargument name="name" type="string" required="true">
		<cfargument name="content" type="string" required="true">
		<cfset var st = structNew()>
		<cfif arguments.name eq "">
			<cfthrow message="A meta tag must include a non-blank name" type="homePortals.pageBean.invalidMetaTag">
		</cfif>
		<cfset st.name = arguments.name>
		<cfset st.content = arguments.content>
		<cfset ArrayAppend(variables.instance.aMeta, st)>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeMetaTag" access="public" returnType="pageBean" hint="removes a user-defined meta tag">
		<cfargument name="name" type="string" required="true">
		<cfset var i = 0>
		<cfset var st = structNew()>
		<cfloop from="1" to="#arrayLen(variables.instance.aMeta)#" index="i">
			<cfset st = variables.instance.aMeta[i]>
			<cfif st.name eq arguments.name>
				<cfset arrayDeleteAt(variables.instance.aMeta, i)>
				<cfreturn this>
			</cfif>
		</cfloop>
		<cfreturn this>
	</cffunction>	
	
	<cffunction name="removeAllMetaTags" access="public" returnType="pageBean" hint="removes all user-defined meta tags">
		<cfset variables.instance.aMeta = arrayNew(1)>
		<cfreturn this>
	</cffunction>


	<!---------------------------------------->
	<!--- SkinID				           --->
	<!---------------------------------------->		
	<cffunction name="getSkinID" access="public" returntype="string" hint="retrieves the ID of the skin used on this page">
		<cfreturn variables.instance.skinID>
	</cffunction>
	
	<cffunction name="setSkinID" access="public" returnType="pageBean" hint="sets the page skin">
		<cfargument name="skinID" type="string" required="true">
		<cfset variables.instance.skinID = arguments.skinID>
		<cfreturn this>
	</cffunction>


	<!---------------------------------------->
	<!--- Custom Properties		           --->
	<!---------------------------------------->	
	<cffunction name="getProperties" access="public" returntype="struct" hint="returns a struct with all custom properties">
		<cfreturn duplicate(variables.instance.stProperties)>
	</cffunction>

	<cffunction name="getProperty" access="public" returnType="string" hint="returns the value of a custom property">
		<cfargument name="name" type="string" required="true">
		<cfif structKeyExists(variables.instance.stProperties, arguments.name)>
			<cfreturn variables.instance.stProperties[arguments.name].value>
		<cfelse>
			<cfthrow message="Property '#arguments.name#' is not defined" type="homePortals.pageBean.invalidProperty">
		</cfif>
	</cffunction>

	<cffunction name="hasProperty" access="public" returnType="string" hint="returns whether a given custom property exists">
		<cfargument name="name" type="string" required="true">
		<cfreturn structKeyExists(variables.instance.stProperties, arguments.name)>
	</cffunction>

	<cffunction name="setProperty" access="public" returnType="pageBean" hint="sets the value of a custom property">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		<cfargument name="transient" type="boolean" required="false" default="false">
		<cfset variables.instance.stProperties[arguments.name] = structNew()>
		<cfset variables.instance.stProperties[arguments.name].name = arguments.name>
		<cfset variables.instance.stProperties[arguments.name].value = arguments.value>
		<cfset variables.instance.stProperties[arguments.name].transient = arguments.transient>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeProperty" access="public" returnType="pageBean" hint="removes a custom property">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.instance.stProperties, arguments.name,false)>
		<cfreturn this>
	</cffunction>	
	


	<!---------------------------------------->
	<!--- getMemento			           --->
	<!---------------------------------------->	
	<cffunction name="getMemento" access="public" returntype="struct" output="False">
		<cfreturn duplicate(variables.instance)>
	</cffunction>

	<!---------------------------------------->
	<!--- initPageProperties		       --->
	<!---------------------------------------->	
	<cffunction name="initPageProperties" access="private" returntype="void" hint="sets initial value for page properties">
		<cfscript>
			variables.instance = structNew();
			variables.instance.title = variables.DEFAULT_PAGE_TITLE;
			variables.instance.skinID = variables.DEFAULT_PAGE_SKINID;
			variables.instance.pageTemplate = variables.DEFAULT_PAGE_TEMPLATE;
			variables.instance.aStyles = ArrayNew(1);
			variables.instance.aScripts = ArrayNew(1);
			variables.instance.aEventListeners = ArrayNew(1);
			variables.instance.aLayouts = ArrayNew(1);			// holds properties for layout sections
			variables.instance.aModules = ArrayNew(1);		// holds modules		
			variables.instance.stModuleIndex = structNew();	// an index of modules	
			variables.instance.aMeta = ArrayNew(1);			// user-defined meta tags
			variables.instance.stProperties = structNew();
		</cfscript>	
	</cffunction>


	<!---------------------------------------->
	<!--- Utilities					       --->
	<!---------------------------------------->	
	<cffunction name="dump" access="private" hint="facade for cfdump" returntype="void">
		<cfargument name="data" type="any">
		<cfdump var="#arguments.data#">
	</cffunction>

	<cffunction name="abort" access="private" hint="facade for cfabort" returntype="void">
		<Cfabort>
	</cffunction>
	
	<cffunction name="throw" access="private" hint="facade for cfthrow" returntype="void">
		<cfargument name="message" type="string" required="true">
		<cfargument name="type" type="string" required="true"> 
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>


</cfcomponent>