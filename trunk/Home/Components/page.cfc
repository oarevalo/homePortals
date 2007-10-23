<cfcomponent hint="This component is used to manipulate a homeportals page">

	<cfscript>
		variables.oPageBean = 0;
		variables.autoSave = true;
	</cfscript>
	
	<!---------------------------------------->
	<!--- init					           --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="page">
		<cfargument name="pageHREF" type="string" required="false" default="" hint="The location of the page as a relative address. If not empty, then loads the page">
		<cfargument name="autoSave" type="boolean" required="false" default="true" hint="This flag is to force a saving of the page everytime a change is made, if false then the save method must be called manually">		
		<cfscript>
			variables.autoSave = arguments.autoSave;
			variables.oPageBean = createObject("Component","pageBean").init(arguments.pageHREF);
		</cfscript>
		<cfreturn this>
	</cffunction>

	<!---------------------------------------->
	<!--- getPage				           --->
	<!---------------------------------------->	
	<cffunction name="getPage" access="public" returntype="pageBean">
		<cfreturn variables.oPageBean>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getHREF				           --->
	<!---------------------------------------->	
	<cffunction name="getHREF" access="public" returntype="string">
		<cfreturn variables.oPageBean.getHREF()>
	</cffunction>

	<!---------------------------------------->
	<!--- setHREF				           --->
	<!---------------------------------------->	
	<cffunction name="setHREF" access="public" returntype="string">
		<cfargument name="pageHREF" type="string" required="true">
		<cfset variables.oPageBean.setHREF(arguments.pageHREF)>
	</cffunction>

	<!---------------------------------------->
	<!--- getXML				           --->
	<!---------------------------------------->	
	<cffunction name="getXML" access="public" returntype="xml">
		<cfreturn variables.oPageBean.toXML()>
	</cffunction>


	<!---------------------------------------->
	<!--- getOwner				           --->
	<!---------------------------------------->	
	<cffunction name="getOwner" access="public" returntype="string" hint="returns the owner of the page">
		<cfreturn variables.oPageBean.getOwner()>
	</cffunction>

	<!---------------------------------------->
	<!--- setOwner				           --->
	<!---------------------------------------->	
	<cffunction name="setOwner" access="public" returntype="void" hint="sets the owner of the page">
		<cfargument name="owner" type="string" required="true" hint="The owner of the page, must be a username of a valid account">
		<cfset variables.oPageBean.setOwner(arguments.owner)>
		<cfif variables.autoSave>
			<cfset save()>
		</cfif>
	</cffunction>

	<!---------------------------------------->
	<!--- getAccess				           --->
	<!---------------------------------------->	
	<cffunction name="getAccess" access="public" returntype="string" hint="returns the access level of the page">
		<cfreturn variables.oPageBean.getAccess()>
	</cffunction>

	<!---------------------------------------->
	<!--- setAccess				           --->
	<!---------------------------------------->	
	<cffunction name="setAccess" access="public" returntype="void" hint="sets the access level of the page">
		<cfargument name="access" type="string" required="true" hint="The access level of the page">
		<cfset variables.oPageBean.setAccess(arguments.access)>
		<cfif variables.autoSave>
			<cfset save()>
		</cfif>
	</cffunction>



	<!---------------------------------------->
	<!--- getModules			           --->
	<!---------------------------------------->	
	<cffunction name="getModules" access="public" returntype="array" output="False"
				hint="Returns all page modules">
		<cfreturn variables.oPageBean.getModules()>
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

			aModuleNodes = variables.oPageBean.getModules();
			for(i=1;i lte arrayLen(aModuleNodes);i=i+1) {
				if(aModuleNodes[i].location eq arguments.location) {
					ArrayAppend(aModules, aModuleNodes[i]);
				}
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
		<cfreturn variables.oPageBean.getModule(arguments.moduleID)>
	</cffunction>

	<!---------------------------------------->
	<!--- addModule				           --->
	<!---------------------------------------->	
	<cffunction name="addModule" access="public" returntype="string" output="False"
				hint="Adds a module to the page">
		<cfargument name="moduleResourceBean" type="resourceBean" required="true">
		<cfargument name="locationID" type="string" required="yes">
		<cfargument name="customAttributes" type="struct" required="no" default="#structNew()#">

		<cfscript>
			var oResourceBean = arguments.moduleResourceBean;
			var stModule = structNew();
			var moduleID = "";
			var aModules = arrayNew(1);
			var moduleName = "";
			var keepLooping = true;
			var moduleIndex = 1;
			var st = structNew();
			var aTemp = arrayNew(1);
			var i = 0;
			var thisAttr = "";
			var def = "";
			
			// define a unique id for the new module based on the module name
			moduleName =  oResourceBean.getName();
			moduleID =  oResourceBean.getName();
			aModules = variables.oPageBean.getModules();
			
			while(keepLooping) {
				try {
					moduleID = moduleName & moduleIndex;
					st = variables.oPageBean.getModule(moduleID);
					moduleIndex = moduleIndex + 1;
					keepLooping = true;
				
				} catch(homePortals.pageBean.moduleNotFound e) {
					keepLooping = false;
				}
			}


			// if no location is given, then add the module to the first location
			if(arguments.locationID eq "") {
				aTemp = variables.oPageBean.getLayoutRegions();
				if(arrayLen(aTemp) gt 0) {
					arguments.locationID = aTemp[1].name;
				}
			}


			// add basic properties to module
			stModule["id"] = moduleID;
			stModule["location"] = arguments.locationID;
			stModule["name"] = oResourceBean.getName();
			stModule["title"] = moduleID;
			
			// add default properties from resourceBean
			aTemp = oResourceBean.getAttributes();
			for(i=1; i lte ArrayLen(aTemp); i=i+1) {
				thisAttr = aTemp[i]; 
				def = "";
				if(structKeyExists(thisAttr, "default")) def = thisAttr.default;
				stModule[thisAttr.name] = def;
			}
			
			// add custom properties 
			for(attr in arguments.customAttributes) {
				stModule[attr] = arguments.customAttributes[attr];
			}

			// add module to page
			variables.oPageBean.addModule(moduleID, stModule);


			// add resources used by this module
			aTemp = oResourceBean.getResources();
			for(i=1; i lte ArrayLen(aTemp); i=i+1) {
				if(aTemp[i].type eq "script") 	variables.oPageBean.addScript(aTemp[i].href);
				if(aTemp[i].type eq "stylesheet") 	variables.oPageBean.addStylesheet(aTemp[i].href);
			}


			// add event handlers for this moudule
			aTemp = oResourceBean.getEventListeners();
			for(i=1; i lte ArrayLen(aTemp); i=i+1) {
				variables.oPageBean.addEventListener(aTemp[i].objectName,
													aTemp[i].eventName,
													ReplaceNoCase(aTemp[i].eventHandler,"$ID$",moduleID)
													);
			}


			// save page			
			if(variables.autoSave) save();				
		</cfscript>
		<cfreturn moduleID>
	</cffunction>

	<!---------------------------------------->
	<!--- saveModule			           --->
	<!---------------------------------------->	
	<cffunction name="saveModule" access="public" returntype="void" output="False"
				hint="Saves changes to module properties on a page module">
		<cfargument name="moduleID" type="string" required="true">
		<cfargument name="moduleAttributes" type="struct" required="false">
		<cfscript>
			variables.oPageBean.setModule(arguments.moduleID, arguments.moduleAttributes);
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
			variables.oPageBean.removeModule(arguments.moduleID);
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
			var aLocations = 0;
			var i = 0;
			var thisLocation = 0;
			var lstModules = 0;
			var aModules = arrayNew(1);
			var aNewModules = arrayNew(1);
			var stModule = structNew();
			var j = 0;
			
			// in this array we will put the modules in the new order
			aNewModules = arrayNew(1);

			// get all locations into an array
			aLocations = listToArray(arguments.layout,":");
			
			// arrange all modules into the new array in the desired order
			for(i=1;i lte arrayLen(aLocations);i=i+1) {
				if(listLen(aLocations[i],"|") gt 1) {
					thisLocation = ListGetAt(aLocations[i],1,"|");
					lstModules = ListGetAt(aLocations[i],2,"|");
					aModules = listToArray(lstModules);
				
					for(j=1;j lte arrayLen(aModules);j=j+1) {
						// find module node in original page
						stModule = variables.oPageBean.getModule(aModules[j]);
						
						// update location in module
						stModule["location"] = thisLocation;
						
						// add module to new modules array
						arrayAppend(aNewModules, stModule);
					}
				}
			}
			
			// clear all modules from page
			variables.oPageBean.removeAllModules();

			// attach all modules again in the new order
			for(i=1;i lte arrayLen(aNewModules);i=i+1) {
				variables.oPageBean.addModule(aNewModules[i].id, aNewModules[i]);
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
		<cfreturn variables.oPageBean.getStylesheets()>
	</cffunction>

	<!---------------------------------------->
	<!--- saveStylesheet		           --->
	<!---------------------------------------->	
	<cffunction name="saveStylesheet" access="public" returntype="void" output="False"
				hint="Adds or updates a stylesheet resource">
		<cfargument name="index" type="numeric" required="true">
		<cfargument name="value" type="string" required="true">
		<cfscript>
			var aStylesheets = variables.oPageBean.getStylesheets();
					
			if(arguments.index gt 0) {
				variables.oPageBean.removeStylesheet(aStylesheets[arguments.index]);
			}
			variables.oPageBean.addStylesheet(arguments.value);
			
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
			var aStylesheets = variables.oPageBean.getStylesheets();
			if(arrayLen(aStylesheets) gte arguments.index) {
				variables.oPageBean.removeStylesheet(aStylesheets[arguments.index]);
				if(variables.autoSave) save();	
			}
		</cfscript>
	</cffunction>




	<!---------------------------------------->
	<!--- getScripts			           --->
	<!---------------------------------------->	
	<cffunction name="getScripts" access="public" returntype="array" output="False"
				hint="Returns all script resources">
		<cfreturn variables.oPageBean.getScripts()>
	</cffunction>

	<!---------------------------------------->
	<!--- saveScripts			           --->
	<!---------------------------------------->	
	<cffunction name="saveScripts" access="public" returntype="void" output="False"
				hint="Adds or updates a script resource">
		<cfargument name="index" type="numeric" required="true">
		<cfargument name="value" type="string" required="true">
		<cfscript>
			var aScripts = variables.oPageBean.getScripts();
					
			if(arguments.index gt 0) {
				variables.oPageBean.removeScript(aScripts[arguments.index]);
			}
			variables.oPageBean.addScript(arguments.value);
			
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
			var aScripts = variables.oPageBean.getScripts();
			if(arrayLen(aScripts) gte arguments.index) {
				variables.oPageBean.removeScript(aScripts[arguments.index]);
				if(variables.autoSave) save();	
			}
		</cfscript>
	</cffunction>



	<!---------------------------------------->
	<!--- getEventHandlers		           --->
	<!---------------------------------------->	
	<cffunction name="getEventHandlers" access="public" returntype="query" output="False"
				hint="Returns all page event listeners">
		<cfscript>
			var aNodes = 0;
			var qry = queryNew("objectName,eventName,eventHandler");
			var i = 0;

			aNodes = variables.oPageBean.getEventListeners();
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				queryAddRow(qry);
				querySetCell(qry,"objectName",aNodes[i].objectName);
				querySetCell(qry,"eventName",aNodes[i].eventName);
				querySetCell(qry,"eventHandler",aNodes[i].eventHandler);
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
			aNodes = variables.oPageBean.getEventListeners();

			// remove existing event listener
			if(arguments.index gt 0 and arrayLen(aNodes) gte arguments.index) {
				variables.oPageBean.removeEventListener(aNodes[i].objectName, 
														aNodes[i].eventName, 
														aNodes[i].eventHandler);
			}	
				
			// insert event listener	
			variables.oPageBean.addEventListener(arguments.objectName, 
												arguments.eventName, 
												arguments.eventHandler);
					
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
			aNodes = variables.oPageBean.getEventListeners();
			
			if(arrayLen(aNodes) gte arguments.index) {
				variables.oPageBean.removeEventListener(aNodes[arguments.index].objectName, 
														aNodes[arguments.index].eventName, 
														aNodes[arguments.index].eventHandler);
			}	
			
			if(variables.autoSave) save();	
		</cfscript>
	</cffunction>



	<!---------------------------------------->
	<!--- getLocations			           --->
	<!---------------------------------------->	
	<cffunction name="getLocations" access="public" returntype="query" output="False"
				hint="Returns a query with all layout locations defined on the page">
		<cfscript>
			var aNodes = 0;
			var qry = queryNew("name,type,class,style,id");
			var i = 0;

			aNodes = variables.oPageBean.getLayoutRegions();
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				queryAddRow(qry);
				querySetCell(qry,"name",aNodes[i].name);
				querySetCell(qry,"type",aNodes[i].type);
				querySetCell(qry,"class",aNodes[i].class);
				querySetCell(qry,"style",aNodes[i].style);
				querySetCell(qry,"id",aNodes[i].id);
			}
		</cfscript>
		<cfreturn qry>
	</cffunction>

	<!---------------------------------------->
	<!--- getLocationTypes		           --->
	<!---------------------------------------->	
	<cffunction name="getLocationTypes" access="public" returntype="array" output="False"
				hint="Returns an array with possible values for layout location types">
		<cfreturn variables.oPageBean.getLocationTypes()>
	</cffunction>

	<!---------------------------------------->
	<!--- getLocationsByType	           --->
	<!---------------------------------------->	
	<cffunction name="getLocationsByType" access="public" returntype="query" output="False"
				hint="Returns a query with all layout locations defined on the page for a given type">
		<cfargument name="locationType" type="string" required="true">
		<cfscript>
			var aNodes = 0;
			var qry = queryNew("name,type,class,style,id");
			var i = 0;

			aNodes = variables.oPageBean.getLayoutRegions();
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				if(aNodes[i].type eq arguments.locationType) {
					queryAddRow(qry);
					querySetCell(qry,"name",aNodes[i].name);
					querySetCell(qry,"type",aNodes[i].type);
					querySetCell(qry,"class",aNodes[i].class);
					querySetCell(qry,"style",aNodes[i].style);
					querySetCell(qry,"id",aNodes[i].id);
				}
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
			variables.oPageBean.addLayoutRegion(arguments.name, arguments.type, arguments.class);
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

			if(arguments.newName eq "" and arguments.name neq "") arguments.newName = arguments.name;

			// remove layout region
			removeLayoutRegion(arguments.name);

			// add new region
			variables.oPageBean.addLayoutRegion(arguments.newName, arguments.type, arguments.class);

			// if the location name has changed, then update
			// all of the modules on this location
			if(arguments.newName neq arguments.name) {
				aModules = getModulesByLocation(arguments.name);
				for(i=1;i lte arrayLen(aModules);i=i+1) {
					stModule = aModules[i];
					stModule.location = arguments.newName;
					variables.oPageBean.setModule(stModule.ID, stModule);
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
			variables.oPageBean.removeLayoutRegion(arguments.newName);
			if(variables.autoSave) save();	
		</cfscript>
	</cffunction>

    <!---------------------------------------->
    <!--- getLocationByName                   --->
    <!---------------------------------------->   
    <cffunction name="getLocationByName" access="public" returntype="query" output="False"
                hint="Returns info about a location">
        <cfargument name="name" type="string" required="true">
		<cfscript>
			var aNodes = 0;
			var qry = queryNew("name,type,class,style,id");
			var i = 0;

			aNodes = variables.oPageBean.getLayoutRegions();
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				if(aNodes[i].name eq arguments.name) {
					queryAddRow(qry);
					querySetCell(qry,"name",aNodes[i].name);
					querySetCell(qry,"type",aNodes[i].type);
					querySetCell(qry,"class",aNodes[i].class);
					querySetCell(qry,"style",aNodes[i].style);
					querySetCell(qry,"id",aNodes[i].id);
				}
			}
		</cfscript>
        <cfreturn qry>
    </cffunction>
	

	<!---------------------------------------->
	<!--- setPageTitle			           --->
	<!---------------------------------------->	
	<cffunction name="setPageTitle" access="public" returntype="void" output="False"
				hint="Sets the title for the page">
		<cfargument name="title" type="string" required="true">
		<cfset variables.oPageBean.setTitle(arguments.title)>
		<cfif variables.autoSave>
			<cfset save()>
		</cfif>		
	</cffunction>

	<!---------------------------------------->
	<!--- getPageTitle			           --->
	<!---------------------------------------->	
	<cffunction name="getPageTitle" access="public" returntype="string" output="False"
				hint="Returns the page title">
		<cfreturn variables.oPageBean.getTitle()>
	</cffunction>


	<!---------------------------------------->
	<!--- setSkin				           --->
	<!---------------------------------------->	
	<cffunction name="setSkin" access="public" returntype="void" output="False"
				hint="Selects a skin from the catalog">
		<cfargument name="skinHREF" default="" type="string">			
		<cfscript>
			var localStyleHREF = "";
			var hasLocalStyle = false;
			var href = variables.oPageBean.getHREF();
			
			// local style
			localStyleHREF = ReplaceNoCase(href,"/layouts/","/styles/") & ".css";
			hasLocalStyle = variables.oPageBean.hasStylesheet(localStyleHREF);
	
			// remove all stylesheets
			variables.oPageBean.removeAllStylesheets();
			
			// add new stylesheet
			if(arguments.skinHREF neq "") {
				hasLocalStyle = variables.oPageBean.addStylesheet(arguments.skinHREF);
			}
			
			// add local style (if it had any)
			if(hasLocalStyle) {
				variables.oPageBean.addStylesheet(localStyleHREF);
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
			var oPageTemplateBean = 0;
			var localStyleHREF = "";
			var i=0;
			var aTemp = arrayNew(1);
			var hasLocalStyle = false;
			var lstLocations = "";
			var href = variables.oPageBean.getHREF();
			
			// get page template
			oPageTemplateBean = createObject("component","pageBean").init(arguments.pageTemplateHREF);

			// local style
			localStyleHREF = ReplaceNoCase(href,"/layouts/","/styles/") & ".css";
			hasLocalStyle = variables.oPageBean.hasStylesheet(localStyleHREF);

			// remove all stylesheets and layouts
			variables.oPageBean.removeAllStylesheets();
			variables.oPageBean.removeAllLayoutRegions();
			
			// add stylesheets from page template
			aTemp = oPageTemplateBean.getStylesheets();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				variables.oPageBean.addStylesheet(aTemp[i]);
			}
			
			// add locations from page template
			aTemp = oPageTemplateBean.getLayoutRegions();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				lstLocations = listAppend(lstLocations, aTemp[i].name);
				variables.oPageBean.addLayoutRegion(argumentCollection = aTemp[i]);
			}
			
			
			// if a module location no longer exist, then move the module to the first location 
			aTemp = variables.oPageBean.getModules();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				if(not listFind(lstLocations, aTemp[i].location)) {
					aTemp[i]["location"] = listFirst(lstLocations);
					variables.oPageBean.setModule(aTemp[i].id, aTemp[i]);
				}
			}
			
			// add local style (if it had any)
			if(hasLocalStyle) {
				variables.oPageBean.addStylesheet(localStyleHREF);
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
		<cfset var href = variables.oPageBean.getHREF()>

		<!--- compose the name of the local css --->
		<cfset localStyleHREF = ReplaceNoCase(href,"/layouts/","/styles/") & ".css">
		<cfset stylesPath = ReplaceNoCase(localStyleHREF, getFileFromPath(href) & ".css", "")>
		
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

			<!--- add the style to the page --->
			<cfset variables.oPageBean.addStylesheet(localStyleHREF)>
			<cfif variables.autoSave>
				<cfset save()>
			</cfif>
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
		<cfset var href = variables.oPageBean.getHREF()>

		<!--- compose the name of the local css --->
		<cfset localStyleHREF = ReplaceNoCase(href,"/layouts/","/styles/") & ".css">

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
		<cfset var xmlDoc = variables.oPageBean.toXML()>
		<cfset var href = variables.oPageBean.getHREF()>	
		<!--- store page --->
		<cffile action="write" file="#expandpath(href)#" output="#toString(xmlDoc)#">
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
		<cfset var href = variables.oPageBean.getHREF()>

		<!--- get the name with and without extension (in case user gave one) --->
		<cfset short_name = replaceNoCase(arguments.pageName,".xml","")>
		<cfset full_name = short_name & ".xml">

		<!--- build the full path to the new page --->
		<cfset newPageURL = replaceNoCase(href, getFileFromPath(href), full_name)>
					
		<!--- rename file --->
		<cffile action="rename" source="#expandPath(href)#" destination="#expandPath(newPageURL)#">

		<!--- update instance --->
		<cfset variables.oPageBean.setHREF(newPageURL)>
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