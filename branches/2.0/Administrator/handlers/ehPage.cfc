<cfcomponent name="ehPage" extends="ehBase">
	
	<!--- ************************************************************* --->
	<!--- 
		This method should not be altered, unless you want code to be executed
		when this handler is instantiated. This init method should be on all
		event handlers, usually left untouched.
	--->
	<cffunction name="init" access="public" returntype="Any">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->


	<!------------------------------------------------->
	<!--- dspPageEditor                            ---->
	<!------------------------------------------------->
	<cffunction name="dspPageEditor" access="public" returntype="void">
		<cfscript>
			var oPage = 0;
			var oSite = 0;
			var oCatalog = 0;
			
			try {

				// check if we have a site and page cfcs loaded 
				if(Not structKeyExists(session,"currentSite")) throw("Please select an account.");
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				
				// get site and page from session
				oSite = session.currentSite;
				oPage = session.currentPage;
				oCatalog = createInstance("../Components/catalog.cfc");
				oCatalog.init(getSetting("HomeRoot"));

				// pass values to view
				setValue("oSite", oSite );
				setValue("oPage", oPage );
				setValue("oCatalog", oCatalog );
				
				session.mainMenuOption = "Accounts";
				setView("PageEditor/vwPageEditor");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehSite.dspSiteManager");
			}
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- dspEditXML	                           ---->
	<!------------------------------------------------->
	<cffunction name="dspEditXML" access="public" returntype="void">
		<cfscript>
			var oPage = 0;
			var oSite = 0;
			
			try {
				// check if we have a site and page cfcs loaded 
				if(Not structKeyExists(session,"currentSite")) throw("Please select an account.");
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				
				// get site and page from session
				oSite = session.currentSite;
				oPage = session.currentPage;

				// pass values to view
				setValue("oSite", oSite );
				setValue("oPage", oPage );
				
				session.mainMenuOption = "Accounts";
				setView("PageEditor/vwEditXML");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehSite.dspSiteManager");
			}
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- dspEditCSS	                           ---->
	<!------------------------------------------------->
	<cffunction name="dspEditCSS" access="public" returntype="void">
		<cfscript>
			var oPage = 0;
			var oSite = 0;
			
			try {
				// check if we have a site and page cfcs loaded 
				if(Not structKeyExists(session,"currentSite")) throw("Please select an account.");
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				
				// get site and page from session
				oSite = session.currentSite;
				oPage = session.currentPage;

				// pass values to view
				setValue("oSite", oSite );
				setValue("oPage", oPage );
				
				session.mainMenuOption = "Accounts";
				setView("PageEditor/vwEditCSS");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehSite.dspSiteManager");
			}
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- dspModuleProperties                      ---->
	<!------------------------------------------------->
	<cffunction name="dspModuleProperties" access="public" returntype="void">
		<cfscript>
			var oPage = 0;
			var moduleID = getValue("moduleID","");

			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
				
				stModule = oPage.getModule(moduleID);
				
				setValue("stModule", stModule);
				setView("PageEditor/vwModuleProperties");
				setLayout("Layout.None");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- dspEditModuleProperties	               ---->
	<!------------------------------------------------->
	<cffunction name="dspEditModuleProperties" access="public" returntype="void">
		<cfscript>
			var oPage = 0;
			var oSite = 0;
			var oCatalog = 0;
			var moduleID = getValue("moduleID","");
			var moduleCatID = "";
			
			try {
				// check if we have a site and page cfcs loaded 
				if(Not structKeyExists(session,"currentSite")) throw("Please select an account.");
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				
				// get site and page from session
				oSite = session.currentSite;
				oPage = session.currentPage;

				oCatalog = createInstance("../Components/catalog.cfc");
				oCatalog.init(getSetting("HomeRoot"));

				stModule = oPage.getModule(moduleID);
				tmpModuleInfo = oCatalog.getModuleByName(stModule.name);
				setValue("xmlModuleInfo", tmpModuleInfo);

				// pass values to view
				setValue("oSite", oSite );
				setValue("oPage", oPage );
				setValue("stModule", stModule);
				
				session.mainMenuOption = "Accounts";
				setView("PageEditor/vwEditModuleProperties");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- dspEventHandlers                         ---->
	<!------------------------------------------------->
	<cffunction name="dspEventHandlers" access="public" returntype="void">
		<cfscript>
			var oPage = 0;
			var oSite = 0;
			var oCatalog = 0;
			
			try {
				// check if we have a site and page cfcs loaded 
				if(Not structKeyExists(session,"currentSite")) throw("Please select an account.");
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				
				// get site and page from session
				oSite = session.currentSite;
				oPage = session.currentPage;
				oCatalog = createInstance("../Components/catalog.cfc");
				oCatalog.init(getSetting("HomeRoot"));
				
				// pass values to view
				setValue("oSite", oSite );
				setValue("oPage", oPage );
				setValue("oCatalog", oCatalog );
				
				session.mainMenuOption = "Accounts";
				setView("PageEditor/vwEventHandlers");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}
		</cfscript>
	</cffunction>

	
	<!------------------------------------------------->
	<!--- doLoadPage                               ---->
	<!------------------------------------------------->
	<cffunction name="doLoadPage" access="public" returntype="void">
		<cfscript>
			var href = getValue("href","");
			var oPage = 0;
			
			try {
				// check if we have a site cfc loaded 
				if(Not structKeyExists(session,"currentSite")) {
					throw("Please select an account first.");
				}
				
				// create page object and instantiate for this page
				oPage = createInstance("../Components/page.cfc");
				oPage.init(href);
				session.currentPage = oPage;
				
				// go to the page editor
				setNextEvent("ehPage.dspPageEditor");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehAccounts.dspMain");
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- doAddLayoutLocation                      ---->
	<!------------------------------------------------->
	<cffunction name="doAddLayoutLocation" access="public" returntype="void">
		<cfscript>
			var locationType = getValue("locationType","");
			var oPage = 0;
			var newLocationName = "";
			var testLocationName = "";
			var i = 1;
			var j = 0;
			var qryLocationsByType = 0;
			var bCanUseName = true;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				// create a name for the new location
				qryLocationsByType = oPage.getLocationsByType(locationType);
				while(newLocationName eq "") {
					testLocationName = locationType & i;
					bCanUseName = true;
					for(j=1; j lte qryLocationsByType.recordCount; j=j+1) {
						if(qryLocationsByType.name[j] eq testLocationName) bCanUseName = false;
					}
					if(bCanUseName) newLocationName = testLocationName;
					i = i + 1;
				}
		
				oPage.addLocation(newLocationName, locationType);
				
				// go to the page editor
				setNextEvent("ehPage.dspPageEditor");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- doSaveLayoutLocation                     ---->
	<!------------------------------------------------->
	<cffunction name="doSaveLayoutLocation" access="public" returntype="void">
		<cfscript>
			var locationType = getValue("locationType","");
			var locationOriginalName = getValue("locationOriginalName","");
			var locationNewName = getValue("locationNewName","");
			var locationClass = getValue("locationClass","");
			var oPage = 0;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				oPage.saveLocation(locationOriginalName, locationNewName, locationType, locationClass);
				
				// go to the page editor
				setNextEvent("ehPage.dspPageEditor");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- doDeleteLayoutLocation                   ---->
	<!------------------------------------------------->
	<cffunction name="doDeleteLayoutLocation" access="public" returntype="void">
		<cfscript>
			var locationName = getValue("locationName","");
			var oPage = 0;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
				
				// delete location		
				oPage.deleteLocation(locationName);
				
				// go to the page editor
				setNextEvent("ehPage.dspPageEditor");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- doUpdateModuleOrder                      ---->
	<!------------------------------------------------->
	<cffunction name="doUpdateModuleOrder" access="public" returntype="void">
		<cfscript>
			var layout = getValue("layout","");
			var oPage = 0;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				oPage.setModuleOrder(layout);
				
				// go to the page editor
				setNextEvent("ehPage.dspPageEditor");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- doAddModule		                       ---->
	<!------------------------------------------------->
	<cffunction name="doAddModule" access="public" returntype="void">
		<cfscript>
			var moduleID = getValue("moduleID","");
			var locationName = getValue("locationName","");
			var oPage = 0;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				oCatalog = createInstance("../Components/catalog.cfc");
				oCatalog.init(getSetting("HomeRoot"));
		
				oPage.addModule(moduleID, locationName, oCatalog);
				
				// go to the page editor
				setNextEvent("ehPage.dspPageEditor");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- doDeleteModule	                       ---->
	<!------------------------------------------------->
	<cffunction name="doDeleteModule" access="public" returntype="void">
		<cfscript>
			var moduleID = getValue("moduleID","");
			var oPage = 0;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				oPage.deleteModule(moduleID);
				
				// go to the page editor
				setNextEvent("ehPage.dspPageEditor");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- doApplySkin		                       ---->
	<!------------------------------------------------->
	<cffunction name="doApplySkin" access="public" returntype="void">
		<cfscript>
			var skinHREF = getValue("href","");
			var oPage = 0;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				oPage.setSkin(skinHREF);
				
				// go to the page editor
				setNextEvent("ehPage.dspPageEditor");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- doApplyPageTemplate                      ---->
	<!------------------------------------------------->
	<cffunction name="doApplyPageTemplate" access="public" returntype="void">
		<cfscript>
			var href = getValue("href","");
			var oPage = 0;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				oPage.applyPageTemplate(href);
				getPlugin("messagebox").setMessage("info", "The page template has been applied.");
				
				// go to the page editor
				setNextEvent("ehPage.dspPageEditor");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- doSaveCSS			                       ---->
	<!------------------------------------------------->
	<cffunction name="doSaveCSS" access="public" returntype="void">
		<cfscript>
			var cssContent = getValue("cssContent","");
			var oPage = 0;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				getPlugin("messagebox").setMessage("info", "Page Stylesheet Changed.");
				oPage.savePageCSS(cssContent);
				
				// go to the page editor
				setNextEvent("ehPage.dspEditCSS");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- doSaveXML			                       ---->
	<!------------------------------------------------->
	<cffunction name="doSaveXML" access="public" returntype="void">
		<cfscript>
			var xmlContent = getValue("xmlContent","");
			var oPage = 0;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				oPage.setXML(xmlContent);
				
				// go to the xml editor
				getPlugin("messagebox").setMessage("info", "Page XML Changed");
				setNextEvent("ehPage.doLoadPage","href=#oPage.getHREF()#");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- doSaveModule		                       ---->
	<!------------------------------------------------->
	<cffunction name="doSaveModule" access="public" returntype="void">
		<cfscript>
			var moduleID = getValue("id","");
			var oPage = 0;
			var stAttribs = structNew();
			var lstAllAttribs = "";
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				// create a structure with the module attributes
				lstAllAttribs = form["_allAttribs"];
				for(i=1;i lte listLen(lstAllAttribs);i=i+1) {
					fld = listGetAt(lstAllAttribs,i);
					if(structKeyExists(form,fld)) stAttribs[fld] = form[fld];
				}
		
				if(not StructKeyExists(form,"container")) stAttribs.container = false;
		
				oPage.saveModule(moduleID, stAttribs);
				
				// go to the page editor
				setNextEvent("ehPage.dspPageEditor");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>	

	<!------------------------------------------------->
	<!--- doRenamePage		                       ---->
	<!------------------------------------------------->
	<cffunction name="doRenamePage" access="public" returntype="void">
		<cfscript>
			var pageTitle = getValue("pageTitle","");
			var oPage = 0;
			var oSite = 0;
			var originalPageHREF = "";
			var newPageHREF = "";
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
				oSite = session.currentSite;
		
				if(pageTitle eq "") throw("The page title cannot be blank.");
		
				// get the original location of the page
				originalPageHREF = oPage.getHREF();
		
				// rename the actual page 
				oPage.setPageTitle(pageTitle);
				oPage.renamePage(pageTitle);
				newPageHREF = oPage.getHREF();
				
				// update the site definition
				oSite.setPageHREF(originalPageHREF, newPageHREF);
				
				getPlugin("messagebox").setMessage("info", "Page title changed.");
				
				// go to the page editor
				setNextEvent("ehPage.dspPageEditor");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- doAddEventHandler	                       ---->
	<!------------------------------------------------->
	<cffunction name="doAddEventHandler" access="public" returntype="void">
		<cfscript>
			var eventName = getValue("eventName","");
			var eventHandler = getValue("eventHandler","");
			var oPage = 0;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				oPage.saveEventHandler(0, listFirst(eventName,"."), listLast(eventName,"."), eventHandler);
				getPlugin("messagebox").setMessage("info", "Event handler saved.");
				
				// go to the event hander view
				setNextEvent("ehPage.dspEventHandlers");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- doDeleteEventHandler	                   ---->
	<!------------------------------------------------->
	<cffunction name="doDeleteEventHandler" access="public" returntype="void">
		<cfscript>
			var index = getValue("index",0);
			var oPage = 0;
			
			try {
				// check if we have a page cfc loaded 
				if(Not structKeyExists(session,"currentPage")) throw("Please select a page.");
				oPage = session.currentPage;
		
				oPage.deleteEventHandler(index);
				getPlugin("messagebox").setMessage("info", "Event handler deleted.");
				
				// go to the event hander view
				setNextEvent("ehPage.dspEventHandlers");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehPage.dspPageEditor");
			}			
		</cfscript>
	</cffunction>
</cfcomponent>