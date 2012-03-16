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

<cfcomponent displayname="notes" extends="homePortals.plugins.modules.components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var csCfg = this.controller.getContentStoreConfigBean();

			cfg.setModuleClassName("notes");
			cfg.setView("htmlhead", "htmlhead");
			cfg.setView("default", "main");
			
			csCfg.setDefaultName("myNotes");
			csCfg.setType("notes");
			csCfg.setRootNode("notes");
		</cfscript>	
	</cffunction>
	
	
	<!---------------------------------------->
	<!--- save                             --->
	<!---------------------------------------->		
	<cffunction name="save" access="public" output="true">
		<cfargument name="noteID" type="string" default="">
		<cfargument name="noteBody" type="string" default="1">
		
		<cfscript>
			var moduleID = this.controller.getModuleID();
			
			// get content store
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();

			// check that we are updating the content store from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throwException("You must be signed-in and be the owner of this page to make changes.");
			}
			
			if(arguments.noteID eq "") arguments.noteID eq "CURRENT";
				
			// check if we find the entry the caller say we are updating
			aUpdateNode = xmlSearch(xmlDoc, "//note[@id='#arguments.noteID#']");

			if(arrayLen(aUpdateNode) eq 0) {
				xmlNode = xmlElemNew(xmlDoc,"note");
				xmlNode.xmlText = xmlFormat(arguments.noteBody);
				xmlNode.xmlAttributes["id"] = arguments.noteID;
				ArrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			} else {
				aUpdateNode[1].xmlText = Arguments.noteBody;
			}

			// save changes to document
			myContentStore.save(xmlDoc);
			
			// notify client of change
			this.controller.setEventToRaise("onSave");
			this.controller.setMessage("Note Saved");
			//this.controller.setScript("#moduleID#.getView()");
		</cfscript>
	</cffunction>	

	<!---------------------------------------->
	<!--- delete	                       --->
	<!---------------------------------------->	
	<cffunction name="delete" access="remote" output="true">
		<cfargument name="noteID" type="string" required="yes">
		
		<cfscript>
			var moduleID = this.controller.getModuleID();
			
			// get content store
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();

			// check that we are updating the content store from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throwException("You must be signed-in and be the owner of this page to make changes.");
			}
		
			tmpNode = xmlDoc.xmlRoot;
			for(i=1;i lte ArrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				if(xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.id eq arguments.noteID)
					ArrayClear(xmlDoc.xmlRoot.xmlChildren[i]);
			}	
			
			myContentStore.save(xmlDoc);
			this.controller.setEventToRaise("onDelete");
			this.controller.setMessage("Note Deleted");
			
			setNoteID("CURRENT");

		</cfscript>
	</cffunction>	

	<!---------------------------------------->
	<!--- setNoteID				           --->
	<!---------------------------------------->		
	<cffunction name="setNoteID" access="public" output="true">
		<cfargument name="noteID" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var pageHREF = cfg.getPageHREF();
			var tmpScript = "";
			
			cfg.setPageSetting("noteID", arguments.noteID);

			this.controller.savePageSettings();
			
			this.controller.setScript("#moduleID#.getView()");
		</cfscript>
	</cffunction>	



</cfcomponent>
