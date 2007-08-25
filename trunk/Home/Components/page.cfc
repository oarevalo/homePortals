<cfcomponent hint="This component is used to manipulate a homeportals page">

	<cfscript>
		variables.pageHREF = "";
		variables.xmlDoc = 0;
		variables.autoSave = true;
		variables.lstAccessTypes = "general,owner,friend";
	</cfscript>
	
	<!---------------------------------------->
	<!--- init					           --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="page">
		<cfargument name="pageHREF" type="string" required="false" default="" hint="The location of the page as a relative address. If not empty, then loads the page">
		<cfargument name="autoSave" type="boolean" required="false" default="true" hint="This flag is to force a saving of the page everytime a change is made, if false then the save method must be called manually">		
		<cfscript>
			variables.pageHREF = arguments.pageHREF;
			variables.autoSave = arguments.autoSave;
			if(variables.pageHREF neq "") 
				variables.xmlDoc = xmlParse(expandPath(variables.pageHREF));
			else {
				// create blank page structure
				variables.xmlDoc = xmlNew();
				variables.xmlDoc.xmlRoot = xmlElemNew(variables.xmlDoc, "Page");
				arrayAppend(variables.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(variables.xmlDoc, "title"));
				arrayAppend(variables.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(variables.xmlDoc, "layout"));
				arrayAppend(variables.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(variables.xmlDoc, "modules"));
				arrayAppend(variables.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(variables.xmlDoc, "eventListeners"));
			}
		</cfscript>
		<cfreturn this>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getHREF				           --->
	<!---------------------------------------->	
	<cffunction name="getHREF" access="public" returntype="string">
		<cfreturn variables.pageHREF>
	</cffunction>

	<!---------------------------------------->
	<!--- setHREF				           --->
	<!---------------------------------------->	
	<cffunction name="setHREF" access="public" returntype="string">
		<cfargument name="pageHREF" type="string" required="true">
		<cfset variables.pageHREF = arguments.pageHREF>
	</cffunction>

	<!---------------------------------------->
	<!--- getXML				           --->
	<!---------------------------------------->	
	<cffunction name="getXML" access="public" returntype="xml">
		<cfreturn variables.xmlDoc>
	</cffunction>

	<!---------------------------------------->
	<!--- setXML				           --->
	<!---------------------------------------->	
	<cffunction name="setXML" access="public" returntype="void">
		<cfargument name="xmlDoc" required="true" type="xml">
		<cfset variables.xmlDoc = arguments.xmlDoc>
		<cfif variables.autoSave>
			<cfset save()>
		</cfif>
	</cffunction>



	<!---------------------------------------->
	<!--- getOwner				           --->
	<!---------------------------------------->	
	<cffunction name="getOwner" access="public" returntype="string" hint="returns the owner of the page">
		<cfset owner = "">
		
		<cfif structKeyExists(variables.xmlDoc.xmlRoot.xmlAttributes, "owner")>
			<cfset owner = xmlDoc.xmlRoot.xmlAttributes.owner>
		</cfif>
		
		<cfreturn owner>
	</cffunction>

	<!---------------------------------------->
	<!--- setOwner				           --->
	<!---------------------------------------->	
	<cffunction name="setOwner" access="public" returntype="void" hint="sets the owner of the page">
		<cfargument name="owner" type="string" required="true" hint="The owner of the page, must be a username of a valid account">
		<cfset xmlDoc.xmlRoot.xmlAttributes["owner"] = arguments.owner>
		<cfif variables.autoSave>
			<cfset save()>
		</cfif>
	</cffunction>

	<!---------------------------------------->
	<!--- getAccess				           --->
	<!---------------------------------------->	
	<cffunction name="getAccess" access="public" returntype="string" hint="returns the access level of the page">
		<cfset access = "">
		
		<cfif structKeyExists(variables.xmlDoc.xmlRoot.xmlAttributes, "access")>
			<cfset access = xmlDoc.xmlRoot.xmlAttributes.access>
		</cfif>
		
		<cfreturn access>
	</cffunction>

	<!---------------------------------------->
	<!--- setAccess				           --->
	<!---------------------------------------->	
	<cffunction name="setAccess" access="public" returntype="void" hint="sets the access level of the page">
		<cfargument name="access" type="string" required="true" hint="The access level of the page">
		<cfif not listFindNoCase(variables.lstAccessTypes, arguments.access)>
			<cfthrow message="Invalid access type. Valid types are: #variables.lstAccessType#" type="homePortals.page.invalidAccessType">
		</cfif>
		<cfset xmlDoc.xmlRoot.xmlAttributes["access"] = arguments.access>
		<cfif variables.autoSave>
			<cfset save()>
		</cfif>
	</cffunction>



	<!---------------------------------------->
	<!--- getModules			           --->
	<!---------------------------------------->	
	<cffunction name="getModules" access="public" returntype="array" output="False"
				hint="Returns all page modules">
		<cfscript>
			var aModuleNodes = ArrayNew(1);
			var aModules = ArrayNew(1);
			var i=0;
			var stTemp = 0;

			aModuleNodes = xmlSearch(variables.xmlDoc, "//modules/module");
			for(i=1;i lte arrayLen(aModuleNodes);i=i+1) {
				stTemp = duplicate(aModuleNodes[i].xmlAttributes);
				ArrayAppend(aModules, stTemp);
			}
		</cfscript>
		<cfreturn aModules>
	</cffunction>

	<!---------------------------------------->
	<!--- getModulesByLocation	           --->
	<!---------------------------------------->	
	<cffunction name="getModulesByLocation" access="public" returntype="array" output="False"
				hint="Returns all page modules for a given layout location">
		<cfargument name="location" type="string" required="true">
		<cfscript>
			var aModuleNodes = ArrayNew(1);
			var aModules = ArrayNew(1);
			var i=0;
			var stTemp = 0;

			aModuleNodes = xmlSearch(variables.xmlDoc,"//modules/module[@location='#arguments.location#']");
			for(i=1;i lte arrayLen(aModuleNodes);i=i+1) {
				stTemp = duplicate(aModuleNodes[i].xmlAttributes);
				ArrayAppend(aModules, stTemp);
			}
		</cfscript>
		<cfreturn aModules>
	</cffunction>

	<!---------------------------------------->
	<!--- getModule 			           --->
	<!---------------------------------------->	
	<cffunction name="getModule" access="public" returntype="struct" output="False"
				hint="Returns information about a module with the given moduleID">
		<cfargument name="moduleID" type="string" required="true">
		<cfscript>
			var aModuleNodes = 0;
			var stTemp = StructNew();

			aModuleNodes = xmlSearch(variables.xmlDoc,"//modules/module[@id='#arguments.moduleID#']");
			if(arrayLen(aModuleNodes) gt 0) {
				stTemp = duplicate(aModuleNodes[1].xmlAttributes);
			}
		</cfscript>
		<cfreturn stTemp>
	</cffunction>

	<!---------------------------------------->
	<!--- addModule				           --->
	<!---------------------------------------->	
	<cffunction name="addModule" access="public" returntype="string" output="False"
				hint="Adds a module to the page">
		<cfargument name="moduleID" type="string" required="true">
		<cfargument name="locationID" type="string" required="yes">
		<cfargument name="oCatalog" type="catalog" required="yes">
		<cfargument name="customAttributes" type="struct" required="no" default="#structNew()#">

		<cfscript>
			var oResourceBean = 0;
			var tmpNode = 0;
			var nodeIndex = 0;
			var aNodeID = 0;
			var newModuleID = 0;
			var aAttr = 0;
			var i = 0;
			var thisAttr = 0;
			var def = 0;
			var aRes = 0;
			var thisRes = 0;
			var aCHK = 0;
			var moduleindex = 0;
			var keepLooping = true;
			var aTemp = arrayNew(1);
			
			// get node info from catalog	
			oResourceBean = oCatalog.getResourceNode("module", arguments.moduleID);		
			if(isSimpleValue(oResourceBean)) throw("The given module was not found on the catalog","homePortals.page.moduleNotFound");

			// insert new node in document
			tmpNode = variables.xmlDoc.Page.modules;
			nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
			tmpNode.xmlChildren[nodeIndex] = xmlElemNew(variables.xmlDoc,"module");				
			
			// create an id for the new module based on the catalog id
			aNodeID = xmlSearch(xmlDoc,"//module[@name='" & oResourceBean.getName() & "']");
			
			moduleIndex = ArrayLen(aNodeID)+1;
			keepLooping = true;
			while(keepLooping) {
				aTemp = xmlSearch(xmlDoc,"//module[@id='#arguments.moduleID##moduleIndex#']");
				if(arrayLen(aTemp) eq 0) {
					newModuleID = arguments.moduleID & moduleIndex;
					keepLooping = false;
				}
				moduleIndex = moduleIndex + 1;
			}
			
			// if no location is given, then add the module to the first location
			if(arguments.locationID eq "") {
				qryLocations = getLocations();
				if(qryLocations.recordCount gt 0) {
					arguments.locationID = qryLocations.name;
				}
			}
			
			// add common properties
			tmpNode.xmlChildren[nodeIndex].xmlAttributes["id"] = newModuleID;
			tmpNode.xmlChildren[nodeIndex].xmlAttributes["location"] = arguments.locationID;
			tmpNode.xmlChildren[nodeIndex].xmlAttributes["name"] = oResourceBean.getName();
			tmpNode.xmlChildren[nodeIndex].xmlAttributes["title"] = newModuleID;
			
			// add default properties from catalog
			aTemp = oResourceBean.getAttributes();
			for(i=1; i lte ArrayLen(aTemp); i=i+1) {
				thisAttr = aTemp[i]; 
				def = "";
				if(structKeyExists(thisAttr, "default")) def = thisAttr.default;
				tmpNode.xmlChildren[nodeIndex].xmlAttributes[thisAttr.name] = def;
			}
			
			// add custom properties 
			for(attr in arguments.customAttributes) {
				tmpNode.xmlChildren[nodeIndex].xmlAttributes[attr] = arguments.customAttributes[attr];
			}
			
			
			
			// add resources
			aTemp = oResourceBean.getResources();
			for(i=1; i lte ArrayLen(aTemp); i=i+1) {
				thisRes = aTemp[i]; 
				if(thisRes.type eq "script") {
					aChk = XMLSearch(variables.xmlDoc,"/Page/script[@src='#thisRes.href#']");
					if(ArrayLen(aChk) eq 0) {
						// add script resource
						tmpNode = variables.xmlDoc.Page;
						nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
						tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"script");
						tmpNode.xmlChildren[nodeIndex].xmlAttributes["src"] = thisRes.href;
					}
				}

				if(thisRes.type eq "stylesheet") {
					aChk = XMLSearch(xmlDoc,"/Page/stylesheet[@href='#thisRes.href#']");
					if(ArrayLen(aChk) eq 0) {
						// add stylesheet resource
						tmpNode = variables.xmlDoc.Page;
						nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
						tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"stylesheet");
						tmpNode.xmlChildren[nodeIndex].xmlAttributes["href"] = thisRes.href;
					}
				}
			}
			
			// add event handlers
			aEvs = oResourceBean.getEventListeners();
			for(i=1; i lte ArrayLen(aEvs); i=i+1) {
				thisEv = aEvs[i]; 
				aChk = XMLSearch(variables.xmlDoc,"/Page/eventListeners");
				// add eventlisteners section (in case it doesnt exist)
				if(ArrayLen(aChk) eq 0) {
					tmpNode = variables.xmlDoc.Page;
					nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
					tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"eventListeners");
				}
				
				// add event listener
				tmpNode = variables.xmlDoc.Page.eventListeners;
				nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
				tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"event");
				tmpNode.xmlChildren[nodeIndex].xmlAttributes["eventHandler"] = ReplaceNoCase(thisEv.eventHandler,"$ID$",newModuleID);
				tmpNode.xmlChildren[nodeIndex].xmlAttributes["eventName"] = thisEv.eventName;
				tmpNode.xmlChildren[nodeIndex].xmlAttributes["objectName"] = thisEv.objectName;
			}
			
			if(variables.autoSave) save();				
		</cfscript>
		<cfreturn newModuleID>
	</cffunction>

	<!---------------------------------------->
	<!--- saveModule			           --->
	<!---------------------------------------->	
	<cffunction name="saveModule" access="public" returntype="void" output="False"
				hint="Saves changes to module properties on a page module">
		<cfargument name="moduleID" type="string" required="true">
		<cfargument name="moduleAttributes" type="struct" required="false">

		<cfscript>
			var _attribs = arguments.moduleAttributes;
			var i = 0;
			var aNodes = 0;
			var fld = "";
			var tmpNode = 0;
			var nodeIndex = 0;
			
			// update selected node
			aNodes = xmlSearch(variables.xmlDoc,"//modules/module[@id='#arguments.moduleID#']");
			
			// if node found, then this is an update, else insert node
			if(ArrayLen(aNodes) gt 0) {
				for(fld in _attribs) {
					aNodes[1].xmlAttributes[fld] = _attribs[fld];
				}
			} else {
				tmpNode = xmlElemNew(variables.xmlDoc,"module");
				for(fld in _attribs) {
					tmpNode.xmlAttributes[fld] = _attribs[fld];
				}
				ArrayAppend(variables.xmlDoc.Page.modules.xmlChildren, tmpNode);				
			}
			
			if(variables.autoSave) save();	
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- deleteModule			           --->
	<!---------------------------------------->	
	<cffunction name="deleteModule" access="public" returntype="void" output="False"
				hint="Removes a module from the page">
		<cfargument name="moduleID" type="string" required="true">
		<cfscript>
			var aNodes = 0;
			var i = 0;
			
			// delete the module from the page
			aNodes = variables.xmlDoc.Page.modules.xmlChildren;
			for(i=1;i lte ArrayLen(aNodes);i=i+1) {
				if(aNodes[i].xmlAttributes.id eq arguments.moduleID)
					ArrayDeleteAt(aNodes, i);
			}
			
			// delete eventhandlers that refer to the instance of the module
			if(structKeyExists(xmlDoc.Page, "eventListeners")) {
				aNodes = variables.xmlDoc.Page.eventListeners.xmlChildren;
				for(i=1;i lte ArrayLen(aNodes);i=i+1) {
					if(findNoCase(arguments.moduleID & ".", aNodes[i].xmlAttributes.eventHandler) ) {
						ArrayDeleteAt(aNodes, i);
					}
				}
			} 
			
			if(variables.autoSave) save();	
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- setModuleOrder		           --->
	<!---------------------------------------->	
	<cffunction name="setModuleOrder" access="public" returntype="void" output="False"
				hint="Changes the order in which modules appear on the page">
		<cfargument name="layout" type="string" required="true" hint="New layout in serialized form">
		<cfscript>
			var xmlOriginalDoc = 0;
			var aLocations = 0;
			var i = 0;
			var thisLocation = 0;
			var lstModules = 0;
			var aModules = 0;
			var j = 0;
			var tmpModuleNode = 0;
			var xmlNewModuleNode = 0;
			var stAttributes = 0;
			var attr = 0;
			
			
			// make copy of page
			xmlOriginalDoc = duplicate(variables.xmlDoc);

			// clear all modules from page
			arrayClear(variables.xmlDoc.xmlRoot.modules.xmlChildren);

			// get all locations into an array
			aLocations = listToArray(arguments.layout,":");
			
			// append modules to new page in the new order
			for(i=1;i lte arrayLen(aLocations);i=i+1) {
				if(listLen(aLocations[i],"|") gt 1) {
					thisLocation = ListGetAt(aLocations[i],1,"|");
					lstModules = ListGetAt(aLocations[i],2,"|");
					aModules = listToArray(lstModules);
				
					for(j=1;j lte arrayLen(aModules);j=j+1) {
						
						// find module node in original page
						tmpModuleNode = xmlSearch(xmlOriginalDoc,"//modules/module[@id='#aModules[j]#']");

						// create new module node
						xmlNewModuleNode = xmlElemNew(variables.xmlDoc,"module");

						if(arrayLen(tmpModuleNode) gt 0) {
							stAttributes = tmpModuleNode[1].xmlAttributes;
							for(attr in stAttributes) {
								xmlNewModuleNode.xmlAttributes[attr] = stAttributes[attr];
							}
							xmlNewModuleNode.xmlAttributes["location"] = '#thisLocation#';
							
							// append new module
							arrayAppend(variables.xmlDoc.xmlRoot.modules.xmlChildren, xmlNewModuleNode);
						}
					}
				}
			}

			// save page
			if(variables.autoSave) save();	
		</cfscript>
	</cffunction>




	<!---------------------------------------->
	<!--- getStylesheets		           --->
	<!---------------------------------------->	
	<cffunction name="getStylesheets" access="public" returntype="array" output="False"
				hint="Returns all stylesheet resources">
		<cfscript>
			var aNodes = 0;
			var aResources = ArrayNew(1);
			var i = 0;

			aNodes = xmlSearch(variables.xmlDoc,"//stylesheet");
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				ArrayAppend(aResources, aNodes[i].xmlAttributes.href);
			}
		</cfscript>
		<cfreturn aResources>
	</cffunction>

	<!---------------------------------------->
	<!--- saveStylesheet		           --->
	<!---------------------------------------->	
	<cffunction name="saveStylesheet" access="public" returntype="void" output="False"
				hint="Adds or updates a stylesheet resource">
		<cfargument name="index" type="numeric" required="true">
		<cfargument name="value" type="string" required="true">
		<cfscript>
			var aNodes = xmlSearch(variables.xmlDoc,"//stylesheet");
			var tmpNode = variables.xmlDoc.Page;
					
			if(ArrayLen(aNodes) gt 0 and arguments.index gt 0) {
				aNodes[arguments.index].xmlAttributes["href"] = arguments.value;
			} else {			
				nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
				tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc, "stylesheet");
				tmpNode.xmlChildren[nodeIndex].xmlAttributes["href"] = arguments.value;
			}
			
			if(variables.autoSave) save();	
		</cfscript>
	</cffunction>
	
	<!---------------------------------------->
	<!--- deleteStylesheet		           --->
	<!---------------------------------------->	
	<cffunction name="deleteStylesheet" access="public" returntype="void" output="False"
				hint="Removes a stylesheet resource from the page">
		<cfargument name="index" type="numeric" required="true">
		<cfscript>
			var aNodes = xmlSearch(variables.xmlDoc,"//stylesheet");
			if(arrayLen(aNodes) gte arguments.index) {
				ArrayDeleteAt(aNodes, arguments.index);
				if(variables.autoSave) save();	
			}
		</cfscript>
	</cffunction>




	<!---------------------------------------->
	<!--- getScripts			           --->
	<!---------------------------------------->	
	<cffunction name="getScripts" access="public" returntype="array" output="False"
				hint="Returns all script resources">
		<cfscript>
			var aNodes = 0;
			var aResources = ArrayNew(1);
			var i = 0;

			aNodes = xmlSearch(variables.xmlDoc,"//script");
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				ArrayAppend(aResources, aNodes[i].xmlAttributes.src);
			}
		</cfscript>
		<cfreturn aResources>
	</cffunction>

	<!---------------------------------------->
	<!--- saveScripts			           --->
	<!---------------------------------------->	
	<cffunction name="saveScripts" access="public" returntype="void" output="False"
				hint="Adds or updates a script resource">
		<cfargument name="index" type="numeric" required="true">
		<cfargument name="value" type="string" required="true">
		<cfscript>
			var aNodes = xmlSearch(variables.xmlDoc,"//script");
			var tmpNode = variables.xmlDoc.Page;
					
			if(ArrayLen(aNodes) gt 0 and arguments.index gt 0) {
				aNodes[arguments.index].xmlAttributes["src"] = arguments.value;
			} else {			
				nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
				tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc, "script");
				tmpNode.xmlChildren[nodeIndex].xmlAttributes["src"] = arguments.value;
			}
			
			if(variables.autoSave) save();	
		</cfscript>
	</cffunction>
	
	<!---------------------------------------->
	<!--- deleteScript			           --->
	<!---------------------------------------->	
	<cffunction name="deleteScript" access="public" returntype="void" output="False"
				hint="Removes a script resource from the page">
		<cfargument name="index" type="numeric" required="true">
		<cfscript>
			var aNodes = xmlSearch(variables.xmlDoc,"//script");
			if(arrayLen(aNodes) gte arguments.index) {
				ArrayDeleteAt(aNodes, arguments.index);
				if(variables.autoSave) save();		
			}
		</cfscript>
	</cffunction>



	<!---------------------------------------->
	<!--- getEventHandlers		           --->
	<!---------------------------------------->	
	<cffunction name="getEventHandlers" access="public" returntype="query" output="False"
				hint="Returns all page event handlers">
		<cfscript>
			var aNodes = 0;
			var qry = queryNew("objectName,eventName,eventHandler");
			var i = 0;

			aNodes = xmlSearch(variables.xmlDoc,"//eventListeners/event");
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				queryAddRow(qry);
				if(structKeyExists(aNodes[i].xmlAttributes,"objectName"))
					querySetCell(qry,"objectName",aNodes[i].xmlAttributes.objectName);
				if(structKeyExists(aNodes[i].xmlAttributes,"eventName"))
					querySetCell(qry,"eventName",aNodes[i].xmlAttributes.eventName);
				if(structKeyExists(aNodes[i].xmlAttributes,"eventHandler"))
					querySetCell(qry,"eventHandler",aNodes[i].xmlAttributes.eventHandler);
			}
		</cfscript>
		<cfreturn qry>
	</cffunction>

	<!---------------------------------------->
	<!--- saveEventHandler		           --->
	<!---------------------------------------->	
	<cffunction name="saveEventHandler" access="public" returntype="void" output="False"
				hint="Adds or updates a page event handler">
		<cfargument name="index" type="numeric" required="true">
		<cfargument name="objectName" type="string" required="true">
		<cfargument name="eventName" type="string" required="true">
		<cfargument name="eventHandler" type="string" required="true">
		<cfscript>
			var aNodes = xmlSearch(variables.xmlDoc,"//eventListeners/event");
			var tmpNode = variables.xmlDoc.Page;
			var tmpNewNode = 0;
					
			if(ArrayLen(aNodes) gt 0 and arguments.index gt 0) {
				aNodes[arguments.index].xmlAttributes["objectName"] = arguments.objectName;
				aNodes[arguments.index].xmlAttributes["eventName"] = arguments.eventName;
				aNodes[arguments.index].xmlAttributes["eventHandler"] = arguments.eventHandler;
			} else {		
				tmpNewNode = xmlElemNew(variables.xmlDoc,"event");
				tmpNewNode.xmlAttributes["objectName"] = arguments.objectName;
				tmpNewNode.xmlAttributes["eventName"] = arguments.eventName;
				tmpNewNode.xmlAttributes["eventHandler"] = arguments.eventHandler;
				ArrayAppend(variables.xmlDoc.xmlRoot.eventListeners.xmlChildren, tmpNewNode);
			}
			
			if(variables.autoSave) save();	
		</cfscript>
	</cffunction>
	
	<!---------------------------------------->
	<!--- deleteEventHandler		       --->
	<!---------------------------------------->	
	<cffunction name="deleteEventHandler" access="public" returntype="void" output="False"
				hint="Removes a page event handler from the page">
		<cfargument name="index" type="numeric" required="true">
		<cfscript>
			var aNodes = xmlSearch(variables.xmlDoc,"//eventListeners/event");
			if(arrayLen(aNodes) gte arguments.index) {
				ArrayDeleteAt(variables.xmlDoc.xmlRoot.eventListeners.xmlChildren, arguments.index);
				if(variables.autoSave) save();	
			}
		</cfscript>
	</cffunction>



	<!---------------------------------------->
	<!--- getLocations			           --->
	<!---------------------------------------->	
	<cffunction name="getLocations" access="public" returntype="query" output="False"
				hint="Returns a query with all layout locations defined on the page">
		<cfscript>
			var aNodes = 0;
			var qry = queryNew("name,type,class,id");
			var i = 0;

			aNodes = xmlSearch(variables.xmlDoc,"//layout/location");
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				queryAddRow(qry);
				if(structKeyExists(aNodes[i].xmlAttributes,"name"))
					querySetCell(qry,"name",aNodes[i].xmlAttributes.name);
				if(structKeyExists(aNodes[i].xmlAttributes,"type"))
					querySetCell(qry,"type",aNodes[i].xmlAttributes.type);
				if(structKeyExists(aNodes[i].xmlAttributes,"class"))
					querySetCell(qry,"class",aNodes[i].xmlAttributes.class);
				if(structKeyExists(aNodes[i].xmlAttributes,"id"))
					querySetCell(qry,"id",aNodes[i].xmlAttributes.id);
				else
					querySetCell(qry,"id","h_location_#aNodes[i].xmlAttributes.type#_#i#");
			}
		</cfscript>
		<cfreturn qry>
	</cffunction>

	<!---------------------------------------->
	<!--- getLocationTypes		           --->
	<!---------------------------------------->	
	<cffunction name="getLocationTypes" access="public" returntype="array" output="False"
				hint="Returns an array with possible values for layout location types">
		<cfscript>
			var aLocationTypes = ArrayNew(1);
			aLocationTypes[1] = "header";
			aLocationTypes[2] = "column";
			aLocationTypes[3] = "footer";
		</cfscript>
		<cfreturn aLocationTypes>
	</cffunction>

	<!---------------------------------------->
	<!--- getLocationsByType	           --->
	<!---------------------------------------->	
	<cffunction name="getLocationsByType" access="public" returntype="query" output="False"
				hint="Returns a query with all layout locations defined on the page for a given type">
		<cfargument name="locationType" type="string" required="true">
		<cfscript>
			var aNodes = 0;
			var qry = queryNew("name,type,class");
			var i = 0;

			aNodes = xmlSearch(variables.xmlDoc,"//layout/location[@type='#arguments.locationType#']");
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				queryAddRow(qry);
				if(structKeyExists(aNodes[i].xmlAttributes,"name"))
					querySetCell(qry,"name",aNodes[i].xmlAttributes.name);
				if(structKeyExists(aNodes[i].xmlAttributes,"type"))
					querySetCell(qry,"type",aNodes[i].xmlAttributes.type);
				if(structKeyExists(aNodes[i].xmlAttributes,"class"))
					querySetCell(qry,"class",aNodes[i].xmlAttributes.class);
			}
		</cfscript>
		<cfreturn qry>
	</cffunction>

	<!---------------------------------------->
	<!--- addLocation			           --->
	<!---------------------------------------->	
	<cffunction name="addLocation" access="public" output="false">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfargument name="class" type="string" required="false" default="">

		<cfscript>
			var lstLocationTypes = "";
			var aNodes = 0;
			var i = 0;
			var xmlNode = 0;

			// validate type
			lstLocationTypes = arrayToList(getLocationTypes());
			if(Not ListFindNoCase(lstLocationTypes, arguments.type)) throw("Invalid location type. Allowed values are: #lstLocationTypes#");
			
			// validate name
			if(arguments.name eq "") throw("Location name cannot be empty");
			
			// search location nodes to see if that node already exists
			aNodes = xmlSearch(variables.xmlDoc,"//layout/location[@name='#arguments.name#']");
			if(arrayLen(aNodes) gt 0) throw("A location with that name already exists");
			
			// make sure the layout section exists
			if(Not StructKeyExists(variables.xmlDoc.xmlRoot,"layout")) {
				xmlNode = xmlElemNew(variables.xmlDoc,"layout");
				arrayAppend(variables.xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}
			
			// build and append the new location node
			xmlNode = xmlElemNew(variables.xmlDoc,"location");
			xmlNode.xmlAttributes["name"] = arguments.name;
			xmlNode.xmlAttributes["type"] = arguments.type;
			if(arguments.class neq "") xmlNode.xmlAttributes["class"] = arguments.class;
			arrayAppend(variables.xmlDoc.xmlRoot.layout.xmlChildren, xmlNode);
			
			if(variables.autoSave) save();			
		</cfscript>
	</cffunction>
	
	<!---------------------------------------->
	<!--- saveLocation			           --->
	<!---------------------------------------->	
	<cffunction name="saveLocation" access="public" output="false">
		<cfargument name="name" type="string" required="true">
		<cfargument name="newName" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfargument name="class" type="string" required="false" default="">

		<cfscript>
			var lstLocationTypes = "";
			var aNodes = 0;
			var i = 0;
			var bFound = false;
			var xmlNode = 0;

			// validate type
			lstLocationTypes = arrayToList(getLocationTypes());
			if(Not ListFindNoCase(lstLocationTypes, arguments.type)) throw("Invalid location type. Allowed values are: #lstLocationTypes#");
			
			// validate name
			if(arguments.name eq "") throw("Location name cannot be empty");
			
			// search location nodes to see if we are updating a node
			aNodes = xmlSearch(variables.xmlDoc,"//layout/location[@name='#arguments.name#']");
			if(arrayLen(aNodes) eq 0) throw("Location not found.");
			
			// update node
			aNodes[1].xmlAttributes["name"] = arguments.newName;
			aNodes[1].xmlAttributes["type"] = arguments.type;
			if(arguments.class neq "") 
				aNodes[1].xmlAttributes["class"] = arguments.class;
			else
				structDelete(aNodes[1].xmlAttributes, "class", false);
			
			// if the location name has changed, then update
			// all of the modules on this location
			if(arguments.newName neq arguments.name) {
				aModules = getModulesByLocation(arguments.name);
				for(i=1;i lte arrayLen(aModules);i=i+1) {
					stModule = aModules[i];
					stModule.location = arguments.newName;
					saveModule(stModule.ID, stModule);
				}
			}
			
			if(variables.autoSave) save();			
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- deleteLocation		           --->
	<!---------------------------------------->	
	<cffunction name="deleteLocation" access="public" output="false">
		<cfargument name="name" type="string" required="true">
		<cfscript>
			var aNodes = 0;
			var i = 0;
			
			aNodes = variables.xmlDoc.xmlRoot.layout.xmlChildren;
			for(i=1;i lte ArrayLen(aNodes);i=i+1) {
				if(aNodes[i].xmlAttributes.name eq arguments.name) {
					// node found, now we need to move any modules
					// on this section to another section
					aModules = getModulesByLocation(arguments.name);
					qryLocations = getLocations();
					if(qryLocations.recordCount gt 0) {
						for(j=1;j lte arrayLen(aModules);j=j+1) {
							stModule = aModules[j];
							stModule.location = qryLocations.name[1];
							saveModule(stModule.ID, stModule);
						}
					}
					
					// delete layout node
					arrayDeleteAt(aNodes,i);
					
					// save document
					if(variables.autoSave) save();	
					break;
				}
			}
		</cfscript>
	</cffunction>

    <!---------------------------------------->
    <!--- getLocationByName                   --->
    <!---------------------------------------->   
    <cffunction name="getLocationByName" access="public" returntype="query" output="False"
                hint="Returns info about a location">
        <cfargument name="name" type="string" required="true">
        <cfset var qry = getLocations()>
        <cfquery name="qry" dbtype="query">
            SELECT *
                FROM qry
                WHERE name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfreturn qry>
    </cffunction>
	

	<!---------------------------------------->
	<!--- setPageTitle			           --->
	<!---------------------------------------->	
	<cffunction name="setPageTitle" access="public" returntype="void" output="False"
				hint="Sets the title for the page">
		<cfargument name="title" type="string" required="true">
		<cfset variables.xmlDoc.xmlRoot.title.xmlText = xmlFormat(arguments.title)>
		<cfif variables.autoSave>
			<cfset save()>
		</cfif>		
	</cffunction>

	<!---------------------------------------->
	<!--- getPageTitle			           --->
	<!---------------------------------------->	
	<cffunction name="getPageTitle" access="public" returntype="string" output="False"
				hint="Returns the page title">
		<cfreturn variables.xmlDoc.xmlRoot.title.xmlText>
	</cffunction>


	<!---------------------------------------->
	<!--- setSkin				           --->
	<!---------------------------------------->	
	<cffunction name="setSkin" access="public" returntype="void" output="False"
				hint="Selects a skin from the catalog">
		<cfargument name="skinHREF" default="" type="string">			
		<cfscript>
			var localStyleHREF = "";
			var i=0;
			var tmpNode = 0;
			var nodeIndex = 0;
			var hasLocalStyle = false;
			
			// local style
			localStyleHREF = ReplaceNoCase(variables.pageHREF,"/layouts/","/styles/") & ".css";
			hasLocalStyle = fileExists(expandPath(localStyleHREF));
	
			// remove all stylesheets
			for(i=1;i lte ArrayLen(variables.xmlDoc.Page.xmlChildren);i=i+1) {
				tmpNode = variables.xmlDoc.Page.xmlChildren[i];
				if(tmpNode.xmlName eq "stylesheet") {
					ArrayDeleteAt(variables.xmlDoc.Page.xmlChildren,i);
					i=i-1;
				}
			}
		
			// add new stylesheet
			if(arguments.skinHREF neq "") {
				nodeIndex = ArrayLen(variables.xmlDoc.Page.xmlChildren)+1;
				variables.xmlDoc.Page.xmlChildren[nodeIndex] = xmlElemNew(variables.xmlDoc,"stylesheet");
				variables.xmlDoc.Page.xmlChildren[nodeIndex].xmlAttributes["href"] = arguments.skinHREF;
			}
			
			// add local style (if it had any)
			if(hasLocalStyle) {
				nodeIndex = ArrayLen(variables.xmlDoc.Page.xmlChildren)+1;
				variables.xmlDoc.Page.xmlChildren[nodeIndex] = xmlElemNew(variables.xmlDoc,"stylesheet");
				variables.xmlDoc.Page.xmlChildren[nodeIndex].xmlAttributes["href"] = localStyleHREF;
			}
			
			// save page
			if(variables.autoSave) save();	
		</cfscript>
	</cffunction>


	<!---------------------------------------->
	<!--- applyPageTemplate		           --->
	<!---------------------------------------->	
	<cffunction name="applyPageTemplate" access="public" returntype="void" output="False"
				hint="Applies a page template. Page templates determine layout, styles, but preserve existing modules.">
		<cfargument name="pageTemplateHREF" default="" type="string">			
		<cfscript>
			var localStyleHREF = "";
			var i=0;
			var tmpNode = 0;
			var nodeIndex = 0;
			var hasLocalStyle = false;
			var xmlPTDoc = 0;
			var xmlNode = 0;
			var lstLocations = "";
			
			// get page template
			if(Not fileExists(expandPath(arguments.pageTemplateHREF))) throw("The given page template does not exist.");
			xmlPTDoc = xmlParse(expandPath(arguments.pageTemplateHREF));
			
			// local style
			localStyleHREF = ReplaceNoCase(variables.pageHREF,"/layouts/","/styles/") & ".css";
			hasLocalStyle = fileExists(expandPath(localStyleHREF));

			// remove all stylesheets
			for(i=1;i lte ArrayLen(variables.xmlDoc.Page.xmlChildren);i=i+1) {
				tmpNode = variables.xmlDoc.Page.xmlChildren[i];
				if(tmpNode.xmlName eq "stylesheet") {
					ArrayDeleteAt(variables.xmlDoc.Page.xmlChildren,i);
					i=i-1;
				}
			}

			// remove all layouts
			for(i=1;i lte ArrayLen(variables.xmlDoc.Page.layout.xmlChildren);i=i+1) {
				ArrayDeleteAt(variables.xmlDoc.Page.layout.xmlChildren,i);
				i=i-1;
			}
		
			// add stylesheets from page template
			for(i=1;i lte ArrayLen(xmlPTDoc.Page.xmlChildren);i=i+1) {
				tmpNode = xmlPTDoc.Page.xmlChildren[i];
				if(tmpNode.xmlName eq "stylesheet") {
					xmlNode = xmlElemNew(variables.xmlDoc,"stylesheet");
					xmlNode.xmlAttributes["href"] = tmpNode.xmlAttributes["href"];
					ArrayAppend(variables.xmlDoc.Page.xmlChildren,xmlNode);
				}
			}

			// add locations from page template
			for(i=1;i lte ArrayLen(xmlPTDoc.Page.layout.xmlChildren);i=i+1) {
				tmpNode = xmlPTDoc.Page.layout.xmlChildren[i];
				xmlNode = xmlElemNew(variables.xmlDoc,"location");
				xmlNode.xmlAttributes["type"] = tmpNode.xmlAttributes["type"];
				xmlNode.xmlAttributes["name"] = tmpNode.xmlAttributes["name"];
				xmlNode.xmlAttributes["class"] = tmpNode.xmlAttributes["class"];
				lstLocations = listAppend(lstLocations, tmpNode.xmlAttributes["name"]);
				ArrayAppend(variables.xmlDoc.Page.layout.xmlChildren,xmlNode);
			}


			// if the module location doesn't exist, then move the module to the first location 
			for(i=1;i lte ArrayLen(variables.xmlDoc.Page.modules.xmlChildren);i=i+1) {
				tmpNode = variables.xmlDoc.Page.modules.xmlChildren[i];
				if(not listFind(lstLocations, tmpNode.xmlAttributes.location))
					tmpNode.xmlAttributes.location = listFirst(lstLocations);
			}

			// add local style (if it had any)
			if(hasLocalStyle) {
				nodeIndex = ArrayLen(variables.xmlDoc.Page.xmlChildren)+1;
				variables.xmlDoc.Page.xmlChildren[nodeIndex] = xmlElemNew(variables.xmlDoc,"stylesheet");
				variables.xmlDoc.Page.xmlChildren[nodeIndex].xmlAttributes["href"] = localStyleHREF;
			}
					
			// save page
			if(variables.autoSave) save();	
		</cfscript>
	</cffunction>




	<!---------------------------------------->
	<!--- savePageCSS			           --->
	<!---------------------------------------->	
	<cffunction name="savePageCSS" access="public" returntype="void" output="False"
				hint="Updates the local stylesheet for the page">
		<cfargument name="content" default="" type="string">			
		
		<cfset var localStyleHREF = "">
		<cfset var stylesPath = "">
		<cfset var tmpCSS = "">
		<cfset var aStyleNode = 0>

		<!--- compose the name of the local css --->
		<cfset localStyleHREF = ReplaceNoCase(variables.pageHREF,"/layouts/","/styles/") & ".css">
		<cfset stylesPath = ReplaceNoCase(localStyleHREF, getFileFromPath(variables.pageHREF) & ".css", "")>
		
		<!--- only save the css if it has something in it, otherwise, delete it if exists --->
		<cfif trim(arguments.content) neq ""> 
			<!--- make sure the styles directory exists --->
			<cfif Not DirectoryExists(expandPath(stylesPath))>
				<cfdirectory action="create" directory="#expandPath(stylesPath)#">
			</cfif>

			<!--- clean the css a bit --->
			<cfset tmpCSS = trim(arguments.content)>
			<cfset tmpCSS = replaceNoCase(tmpCSS,"javascript","","ALL")>
			<cfset tmpCSS = replaceNoCase(tmpCSS,"script","","ALL")>
			<cfset tmpCSS = replaceNoCase(tmpCSS,"eval","","ALL")>
			<cfset tmpCSS = REReplaceNoCase(tmpCSS, "j.*a.*v.*a.*s.*c.*r.*i.*p.*t", "","ALL")>
			
			<!--- write the css file --->
			<cffile action="write" file="#expandpath(localStyleHREF)#" output="#tmpCSS#">

			<!--- add the style to the page only if it doesnt exist --->
			<cfscript>
				aStyleNode = xmlSearch(variables.xmlDoc,"//stylesheet[@href='#localStyleHREF#']");
				if(ArrayLen(aStyleNode) eq 0 ) {
					saveStylesheet(0, localStyleHREF);
				}
			</cfscript>
		<cfelse>
			<!--- if local css exists, then delete it --->
			<cfif fileExists(expandpath(localStyleHREF))>
				<cffile action="delete" file="#expandpath(localStyleHREF)#">
			</cfif>
		</cfif>
	</cffunction>

	<!---------------------------------------->
	<!--- getPageCSS			           --->
	<!---------------------------------------->	
	<cffunction name="getPageCSS" access="public" returntype="string" output="False"
				hint="Returns the contents of the local stylesheet">
		<cfset var retVal = "">
		<cfset var localStyleHREF = "">

		<!--- compose the name of the local css --->
		<cfset localStyleHREF = ReplaceNoCase(variables.pageHREF,"/layouts/","/styles/") & ".css">

		<cfif fileExists(expandpath(localStyleHREF))>
			<cffile action="read" file="#expandpath(localStyleHREF)#" variable="retVal">
		</cfif>
	
		<cfreturn retVal>
	</cffunction>
	


	
	<!---------------------------------------->
	<!--- F I L E   O P E R A T I O N S    --->
	<!---------------------------------------->	

	<!--- these methods are autocommitted --->

	<!---------------------------------------->
	<!--- save					           --->
	<!---------------------------------------->	
	<cffunction name="save" access="public" hint="Saves the site xml">
		<!--- check that is a valid xml file --->
		<cfif Not IsXML(variables.xmlDoc)>
			<cfset throw("The given site doc is not a valid XML document.")>
		</cfif>		
		<!--- store page --->
		<cffile action="write" file="#expandpath(variables.pageHREF)#" output="#toString(variables.xmlDoc)#">
	</cffunction>
	
	<!---------------------------------------->
	<!--- renamePage			           --->
	<!---------------------------------------->	
	<cffunction name="renamePage" access="public" returntype="void" output="False"
				hint="Changes the page name">
		<cfargument name="pageName" type="string" required="true">

		<cfset var short_name = "">
		<cfset var full_name = "">
		<cfset var newPageURL = "">

		<!--- get the name with and without extension (in case user gave one) --->
		<cfset short_name = replaceNoCase(arguments.pageName,".xml","")>
		<cfset full_name = short_name & ".xml">

		<!--- build the full path to the new page --->
		<cfset newPageURL = replaceNoCase(variables.pageHREF, getFileFromPath(variables.pageHREF), full_name)>
					
		<!--- rename file --->
		<cffile action="rename" source="#expandPath(variables.pageHREF)#" destination="#expandPath(newPageURL)#">

		<!--- update instance --->
		<cfset variables.pageHREF = newPageURL>
	</cffunction>



	
	
	<!---------------------------------------->
	<!--- P R I V A T E     M E T H O D S  --->
	<!---------------------------------------->	
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="type" type="string" required="false" default="homePortals.page.exception">
		<cfthrow  message="#arguments.message#" type="#arguments.type#">
	</cffunction>

	<cffunction name="dump" access="private">
		<cfargument name="data" type="any">
		<cfdump var="#arguments.data#">
	</cffunction>	
	
	<cffunction name="abort" access="private">
		<cfabort>
	</cffunction>		
</cfcomponent>	