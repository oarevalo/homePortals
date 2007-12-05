<!--- bookmarks2.cfc
	This component provides functionality to interact with a bookmarks list.
	Version: 1.2 
	
	Changelog:
    - 1/13/06 - oarevalo - save owner when creating the datafile, only owner can add or change content
						 - show footnote with owner and create date (if available)
						 - when owner is not signed in, do not show buttons to add or delete items, disable save item
	- 2/22/06 - oarevalo - changed UI for editing; now when owner is signed in, two icons are displayed next to 
							each item (edit / delete) for editing tasks.
					     - Removed "getEditView" and "getAddItem" methods (no longer used)
						 - Fixed bug that changed attribute values when saving to file.
	- 2/23/06 - oarevalo - Added proper initialization of text attribute on items (when it was missing it was giving an error)
	- 3/9/06 - oarevalo - fixed owner intialization bug
--->

<cfcomponent displayname="bookmarks2" extends="Home.Components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var csCfg = this.controller.getContentStoreConfigBean();

			cfg.setModuleClassName("bookmarks2");
			cfg.setView("default", "main");
			cfg.setView("htmlHead", "HTMLHead");
			
			csCfg.setDefaultName("myBookmarks.xml");
			csCfg.setRootNode("opml");
		</cfscript>	
	</cffunction>


	<!-------------------------------------->
	<!--- saveItem                       --->
	<!-------------------------------------->
	<cffunction name="saveItem" access="remote" output="true">
		<cfscript>
			var tmpHTML = "";
			var stForm = Duplicate(Arguments);
			var _attribs = "text,url,type,onclick,target,htmlURL,xmlURL";

			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();

			// check that we are updating the content store from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throw("You must be signed-in and be the owner of this page to make changes.");
			}
				
			// Remove the arguments for this method from the arguments scope, so that we
			// can recreate the original form
			if(StructKeyExists(stForm,"_")) StructDelete(stForm,"_");

			// make sure the <body> node exists
			if(not structKeyExists(xmlDoc.xmlRoot, "body")) {
				tmpNode = xmlElemNew(xmlDoc, "body");
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, tmpNode);
			}

			tmpNode = xmlDoc.xmlRoot.body;
			
			if(stForm.index gt 0) {
				nodeIndex = stForm.index;
			} else {
				nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
			}
			tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"outline");

			for(i=1;i lte ListLen(_attribs);i=i+1) {
				fld = ListGetAt(_attribs,i);
				if(fld neq "" and stForm[fld] neq "undefined") tmpNode.xmlChildren[nodeIndex].xmlAttributes[fld] = stForm[fld];
			}

			// save changes to document
			myContentStore.save(xmlDoc);
			
			// notify client of change
			this.controller.setEventToRaise("onSave");
			this.controller.setMessage("Bookmark Saved");
			this.controller.setScript("#this.controller.getModuleID()#.getView()");
		</cfscript>
	</cffunction>		

	<!---------------------------------------->
	<!--- deleteItem                       --->
	<!---------------------------------------->	
	<cffunction name="deleteItem" access="remote" output="true">
		<cfargument name="index" type="numeric" required="yes">
		
		<cfscript>
			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();

			// check that we are updating the content store from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throw("You must be signed-in and be the owner of this page to make changes.");
			}
		
			if(arguments.index lte arrayLen(xmlDoc.xmlRoot.body.xmlChildren))
				ArrayDeleteAt(xmlDoc.xmlRoot.body.xmlChildren, arguments.index);
			
			myContentStore.save(xmlDoc);
			this.controller.setEventToRaise("onDelete");
			this.controller.setMessage("Bookmark Deleted");
			this.controller.setScript("#this.controller.getModuleID()#.getView()");
		</cfscript>
	</cffunction>	

	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="url" type="string" default="">
		<cfargument name="followLink" type="string" default="false">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var tmpScript = "";
			var regExp = "^\w+$";
	
			if(arguments.url neq "" and not REFind(regExp, arguments.url))
				this.controller.setMessage("Names may only contain alphabet letters and the _ character.");
			else {
				cfg.setPageSetting("url", arguments.url);
				cfg.setPageSetting("followLink", arguments.followLink);
				this.controller.setMessage("Settings changed");
				this.controller.setScript("#moduleID#.getView();");
				this.controller.savePageSettings();
			}
		</cfscript>
	</cffunction>	


	<!---- *********************** PRIVATE FUNCTIONS *************************** --->
	
	<!-------------------------------------->
	<!--- setContentStoreURL             --->
	<!-------------------------------------->
	<cffunction name="setContentStoreURL" access="private" output="false"
				hint="Sets the content store URL specified on the page.">
		<cfscript>
			var tmpURL = "";
			var cfg = 0;
			var cs_cfg = 0;
			var owner = "";
			var accountsRoot = "";
			
			// get environment info 
			cfg = this.controller.getModuleConfigBean();
			cs_cfg = this.controller.getContentStoreConfigBean();
			owner = this.controller.getUserInfo().owner;
			
			// get the URL provided by the user
			tmpURL = cfg.getPageSetting("url");
			
			if(tmpURL neq "") {
				// if the url param is not a relative path, then put it in the owner's account directory
				if(left(tmpURL,1) neq "/") 
					tmpURL = cs_cfg.getAccountsRoot() & "/" & owner & "/" & tmpURL;
					
				// if there is no extension then add .xml
				if(not find(".",tmpURL))
					tmpURL = tmpURL & ".xml";
			}
			
			cs_cfg.setURL(tmpURL);
		</cfscript>
	</cffunction>
	
</cfcomponent>