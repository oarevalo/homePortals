<cfcomponent hint="This component is used to manipulate a homeportals page">

	<cfscript>
		variables.instance = structNew();
		variables.instance.pageBean = 0;
		variables.instance.pageHREF = "";
	</cfscript>
	
	<!---------------------------------------->
	<!--- init					           --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="pageHelper" hint="constructor">
		<cfargument name="page" type="pageBean" required="true" hint="A page object instance on which to operate">
		<cfargument name="pageHREF" type="string" required="false" default="" hint="The location of the page as a relative address">
		<cfset setPageHREF(arguments.pageHREF)>
		<cfset setPage(arguments.page)>
		<cfreturn this>
	</cffunction>

	<!---------------------------------------->
	<!--- addModule				           --->
	<!---------------------------------------->	
	<cffunction name="addModule" access="public" returntype="string" output="False" hint="Adds a module to the page">
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
			var oPage = getPage();
			
			// define a unique id for the new module based on the module name
			moduleName =  oResourceBean.getName();
			aModules = oPage.getModules();
			
			while(keepLooping) {
				try {
					moduleID = oResourceBean.getID() & moduleIndex;
					st = oPage.getModule(moduleID);
					moduleIndex = moduleIndex + 1;
					keepLooping = true;
				
				} catch(homePortals.pageBean.moduleNotFound e) {
					keepLooping = false;
				}
			}


			// if no location is given, then add the module to the first location
			if(arguments.locationID eq "") {
				aTemp = oPage.getLayoutRegions();
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
			oPage.addModule(moduleID, stModule);


			// add resources used by this module
			aTemp = oResourceBean.getResources();
			for(i=1; i lte ArrayLen(aTemp); i=i+1) {
				if(aTemp[i].type eq "script") 	oPage.addScript(aTemp[i].href);
				if(aTemp[i].type eq "stylesheet") 	oPage.addStylesheet(aTemp[i].href);
			}


			// add event handlers for this moudule
			aTemp = oResourceBean.getEventListeners();
			for(i=1; i lte ArrayLen(aTemp); i=i+1) {
				oPage.addEventListener(aTemp[i].objectName,
													aTemp[i].eventName,
													ReplaceNoCase(aTemp[i].eventHandler,"$ID$",moduleID)
													);
			}


			return moduleID;		
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- setModuleOrder		           --->
	<!---------------------------------------->	
	<cffunction name="setModuleOrder" access="public" returntype="void" output="False" hint="Changes the order in which modules appear on the page">
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
			var oPage = getPage();
			
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
						stModule = oPage.getModule(aModules[j]);
						
						// update location in module
						stModule["location"] = thisLocation;
						
						// add module to new modules array
						arrayAppend(aNewModules, stModule);
					}
				}
			}
			
			// clear all modules from page
			oPage.removeAllModules();

			// attach all modules again in the new order
			for(i=1;i lte arrayLen(aNewModules);i=i+1) {
				oPage.addModule(aNewModules[i].id, aNewModules[i]);
			}
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- applyPageTemplate		           --->
	<!---------------------------------------->	
	<cffunction name="applyPageTemplate" access="public" returntype="void" output="False" hint="Applies a page template resource bean. Page templates determine layout, styles, but preserve existing modules.">
		<cfargument name="pageTemplateResourceBean" type="resourceBean" required="true">			
		<cfargument name="resourceRoot" default="/Home/resourceLibrary/" type="string">			

 		<cfscript>
			var oPageTemplateBean = 0;
			var xmlDoc = 0;
			var localStyleHREF = getPageCSSHREF();
			var i=0;
			var aTemp = arrayNew(1);
			var hasLocalStyle = false;
			var lstLocations = "";
			var href = getPageHREF();
			var pageTemplateHREF = "";
			var oPage = getPage();
			
			// get page template
			pageTemplateHREF = resourceRoot & "/" & pageTemplateResourceBean.getHREF();
			xmlDoc = xmlParse(expandPath(pageTemplateHREF));
			oPageTemplateBean = createObject("component","pageBean").init(xmlDoc);

			// local style
			hasLocalStyle = oPage.hasStylesheet(localStyleHREF);

			// remove all stylesheets and layouts
			oPage.removeAllStylesheets();
			oPage.removeAllLayoutRegions();
			
			// add skin from the page template (if any)
			tmpSkinID = oPageTemplateBean.getSkinID();
			if(tmpSkinID neq "")
				oPage.setSkinID(tmpSkinID);
							
			// add stylesheets from page template
			aTemp = oPageTemplateBean.getStylesheets();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				oPage.addStylesheet(aTemp[i]);
			}
			
			// add locations from page template
			aTemp = oPageTemplateBean.getLayoutRegions();
			for(i=1;i lte arrayLen(aTemp);i=i+1) {
				lstLocations = listAppend(lstLocations, aTemp[i].name);
				oPage.addLayoutRegion(argumentCollection = aTemp[i]);
			}
			
			
			// if a module location no longer exist, then move the module to the first location 
			aTemp = oPage.getModules();
			if(lstLocations neq "") {
				for(i=1;i lte arrayLen(aTemp);i=i+1) {
					if(not listFind(lstLocations, aTemp[i].location)) {
						aTemp[i]["location"] = listFirst(lstLocations);
						oPage.setModule(aTemp[i].id, aTemp[i]);
					}
				}
			}
			
			// add local style (if it had any)
			if(hasLocalStyle) {
				oPage.addStylesheet(localStyleHREF);
			}
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- savePageCSS			           --->
	<!---------------------------------------->	
	<cffunction name="savePageCSS" access="public" returntype="void" output="false" hint="Updates the local stylesheet for the page">
		<cfargument name="content" default="" type="string">			
		
		<cfset var localStyleHREF = getPageCSSHREF()>
		<cfset var tmpCSS = "">

		<!--- only save the css if it has something in it, otherwise, delete it if exists --->
		<cfif trim(arguments.content) neq ""> 

			<!--- clean the css a bit --->
			<cfset tmpCSS = trim(arguments.content)>
			<cfset tmpCSS = replaceNoCase(tmpCSS,"javascript","","ALL")>
			<cfset tmpCSS = replaceNoCase(tmpCSS,"script","","ALL")>
			<cfset tmpCSS = replaceNoCase(tmpCSS,"eval","","ALL")>
			<cfset tmpCSS = REReplaceNoCase(tmpCSS, "j.*a.*v.*a.*s.*c.*r.*i.*p.*t", "","ALL")>
			
			<!--- write the css file --->
			<cffile action="write" file="#expandpath(localStyleHREF)#" output="#tmpCSS#">

			<!--- add the style to the page --->
			<cfset getPage().addStylesheet(localStyleHREF)>
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
	<cffunction name="getPageCSS" access="public" returntype="string" output="False" hint="Returns the contents of the local stylesheet">
		<cfset var retVal = "">
		<cfset var localStyleHREF = getPageCSSHREF()>

		<cfif fileExists(expandpath(localStyleHREF))>
			<cffile action="read" file="#expandpath(localStyleHREF)#" variable="retVal">
		</cfif>
	
		<cfreturn retVal>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getPageCSSHREF		           --->
	<!---------------------------------------->	
	<cffunction name="getPageCSSHREF" access="public" returntype="string" output="False" hint="Returns the location of the local stylesheet">
		<cfreturn getPageHREF() & ".css">
	</cffunction>




	<!---------------------------------------->
	<!--- G E T T E R S  &   S E T T E R S --->
	<!---------------------------------------->	
	<cffunction name="getPageHREF" access="public" returntype="string">
		<cfreturn variables.instance.pageHREF>
	</cffunction>

	<cffunction name="setPageHREF" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.pageHREF = arguments.data>
	</cffunction>

	<cffunction name="getPage" access="public" returntype="pageBean">
		<cfreturn variables.instance.Page>
	</cffunction>

	<cffunction name="setPage" access="public" returntype="void">
		<cfargument name="data" type="pageBean" required="true">
		<cfset variables.instance.Page = arguments.data>
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