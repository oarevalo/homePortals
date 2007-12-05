<!--- editBox.cfc
	This component provides content editing functionality to the editBox module.
	Version: 1.2
	
	
	Changelog:
    - 1/13/05 - oarevalo - If no URL is given, use a default file to store content
						 - save owner when creating the datafile, only owner can add or change content
	- 3/9/06 - oarevalo - fixed owner intialization bug
	- 7/7/06 - oarevalo - added request-level cache, speeds up loading time when there
							are many editboxes on the same page with staticContent set to true
--->

<cfcomponent displayname="editBox" extends="Home.Components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var csCfg = this.controller.getContentStoreConfigBean();

			cfg.setModuleClassName("editBox");
			cfg.setView("default", "page");
			cfg.setView("htmlHead", "HTMLHead");
			
			csCfg.setDefaultName("myContent.xml");
			csCfg.setRootNode("editBoxes");
		</cfscript>	
	</cffunction>
	
	
	<!---------------------------------------->
	<!--- save                             --->
	<!---------------------------------------->		
	<cffunction name="save" access="public" output="true">
		<cfargument name="content" type="string" default="1">
		<cfargument name="contentID" type="string" default="">
		
		<cfscript>
			var moduleID = this.controller.getModuleID();
			
			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();

			// check that we are updating the content store from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throw("You must be signed-in and be the owner of this page to make changes.");
			}
			
			if(arguments.contentID eq "") throw("Please enter a title for this entry.");
				
			// check if we find the entry the caller say we are updating
			aUpdateNode = xmlSearch(xmlDoc, "//content[@id='#arguments.contentID#']");

			if(arrayLen(aUpdateNode) eq 0) {
				xmlNode = xmlElemNew(xmlDoc,"content");
				xmlNode.xmlText = arguments.content;
				xmlNode.xmlAttributes["id"] = arguments.contentID;
				ArrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			} else {
				aUpdateNode[1].xmlText = Arguments.content;
			}

			// save changes to document
			myContentStore.save(xmlDoc);
			
			// notify client of change
			this.controller.setEventToRaise("onSave");
			this.controller.setMessage("Content Saved");
			this.controller.setScript("#moduleID#.getView()");
		</cfscript>
	</cffunction>	

	<!---------------------------------------->
	<!--- deleteEntry                      --->
	<!---------------------------------------->	
	<cffunction name="deleteEntry" access="remote" output="true">
		<cfargument name="contentID" type="string" required="yes">
		
		<cfscript>
			var moduleID = this.controller.getModuleID();
			
			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();

			// check that we are updating the content store from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throw("You must be signed-in and be the owner of this page to make changes.");
			}
		
			tmpNode = xmlDoc.xmlRoot;
			for(i=1;i lte ArrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				if(xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.id eq arguments.contentID)
					ArrayClear(xmlDoc.xmlRoot.xmlChildren[i]);
			}	
			
			myContentStore.save(xmlDoc);
			this.controller.setEventToRaise("onDelete");
			this.controller.setMessage("Content Deleted");
			this.controller.setScript("#moduleID#.getView()");
		</cfscript>
	</cffunction>	

	<!---------------------------------------->
	<!--- toggleDefaultContentID           --->
	<!---------------------------------------->		
	<cffunction name="toggleDefaultContentID" access="public" output="true">
		<cfargument name="contentID" type="string" default="">
		<cfargument name="state" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var pageHREF = cfg.getPageHREF();
			var tmpScript = "";
			
			if(arguments.state) {
				cfg.setPageSetting("contentID", arguments.contentID);
				this.controller.setMessage("Default content set");
			} else {
				cfg.setPageSetting("contentID", "");
				this.controller.setMessage("Default content cleared");
			}
			this.controller.savePageSettings();
		</cfscript>
		<cfsavecontent variable="tmpScript">
			#moduleID#.getView();
			if(confirm("Reload page?")) {
				window.location.href='index.cfm?currentHome=#pageHREF#&refresh=true';
			}
		</cfsavecontent>
		<cfset this.controller.setScript(tmpScript)>
	</cffunction>	



	<!---- *********************** PRIVATE FUNCTIONS *************************** --->
	
	<!-------------------------------------->
	<!--- setContentStoreURL             --->
	<!-------------------------------------->
	<cffunction name="setContentStoreURL" access="private" output="false"
				hint="Sets the content store URL specified on the page.">
		<cfset var tmpURL = this.controller.getModuleConfigBean().getPageSetting("url")>
		<cfset this.controller.getContentStoreConfigBean().setURL(tmpURL)>
	</cffunction>

</cfcomponent>
