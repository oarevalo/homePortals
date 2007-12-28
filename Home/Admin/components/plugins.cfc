<cfcomponent>
	
	<cfset this.pluginXML = "plugins.xml">
	
	<cffunction name="getAll" returntype="query" hint="returns a query with installed plugins">
		<cfset var qry = QueryNew("id,src,version,description")>

		<cfset xmlDoc = readPluginsXML()>
		
		<cfloop from="1" to="#arrayLen(xmlDoc.xmlRoot.xmlChildren)#" index="i">
			<cfset thisNode = xmlDoc.xmlRoot.xmlChildren[i]>
			<cfset QueryAddRow(qry)>
			<cfset QuerySetCell(qry,"id",thisNode.xmlAttributes.id)>
			<cfset QuerySetCell(qry,"src",thisNode.xmlAttributes.src)>
			<cfset QuerySetCell(qry,"version",thisNode.xmlAttributes.version)>
			<cfset QuerySetCell(qry,"description",thisNode.xmlText)>
		</cfloop>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="install" hint="installs a plugin">
		<cfargument name="src" type="string" required="true">
		
		<!--- read plugin descriptor --->
		<cffile action="read" file="#expandPath(arguments.src)#" variable="txtDoc">
		<cfset xmlPlugin = xmlParse(txtDoc)>
	
		<!--- check that plugin has an id --->
		<cfif Not StructKeyExists(xmlPlugin.xmlRoot.xmlAttributes,"id")>
			<cfset throw("The given plugin descriptor file is corrupted. [ID not specified for plugin]")>
		</cfif>
		
		<!--- get the ID of the new plugin --->
		<cfset tmpNewModuleID = xmlPlugin.xmlRoot.xmlAttributes.id>

		<!--- get list of currently installed plugins --->
		<cfset xmlPlugins = readPluginsXML()>
		
		<!--- check that there is no previous version of this plugin installed --->
		<cfloop from="1" to="#arrayLen(xmlPlugins.xmlRoot.xmlChildren)#" index="i">
			<cfset thisNode = xmlPlugins.xmlRoot.xmlChildren[i]>
			<cfif thisNode.xmlAttributes.id eq xmlPlugin.xmlRoot.xmlAttributes.id>
				<cfthrow message="A previous version of this plugin is already installed. Please remove the current version before installing the new plugin.">
			</cfif>
		</cfloop>

		<!--- update plugins list --->
		<cfscript>
			tmpVersion = "";
			tmpDescription = "";
			if(StructKeyExists(xmlPlugin.xmlRoot.xmlAttributes,"version")) tmpVersion = xmlPlugin.xmlRoot.xmlAttributes.version;
			if(StructKeyExists(xmlPlugin.xmlRoot,"description")) tmpDescription = xmlPlugin.xmlRoot.description;
			
			// create node
			ArrayAppend(xmlPlugins.xmlRoot.xmlChildren, xmlElemNew(xmlPlugins,"plugin") );
			tmpIndex = ArrayLen(xmlPlugins.xmlRoot.xmlChildren);
			xmlPlugins.xmlRoot.xmlChildren[tmpIndex].xmlAttributes["id"] = tmpNewModuleID;
			xmlPlugins.xmlRoot.xmlChildren[tmpIndex].xmlAttributes["src"] = arguments.src;
			xmlPlugins.xmlRoot.xmlChildren[tmpIndex].xmlAttributes["version"] = tmpVersion;
			xmlPlugins.xmlRoot.xmlChildren[tmpIndex].xmlText = tmpDescription;
			
			// save plugins file
			savePluginsXML(xmlPlugins);
		</cfscript>		
		
		<!--- add options to main menu --->
		<cfif StructKeyExists(xmlPlugin.xmlRoot,"menu")>
			<cfscript>
				if(StructKeyExists(xmlPlugin.xmlRoot.menu.xmlAttributes,"optionGroupLabel"))
					tmpOptionGroupLabel = xmlPlugin.xmlRoot.menu.xmlAttributes.optionGroupLabel;
				else
					tmpOptionGroupLabel = tmpNewModuleID;
				
				// get instance of menu object
				oMenu = CreateObject("component","menu");
				
				// create optionGroup node
				oMenu.createOptionGroup(tmpNewModuleID,tmpOptionGroupLabel);

				// add options	
				for(i=1;i lte (arrayLen(xmlPlugin.xmlRoot.menu.xmlChildren));i=i+1) {

					// get reference to the new menu option
					tmpNewOptionNode = xmlPlugin.xmlRoot.menu.xmlChildren[i];

					// make sure that option is well defined
					if(Not StructKeyExists(tmpNewOptionNode.xmlAttributes, "view"))
						throw("The plugin descriptor file is corrupted. [view not specified for menu option]");
					if(Not StructKeyExists(tmpNewOptionNode.xmlAttributes, "label")) 
						tmpNewOptionNode.xmlAttributes.label = tmpNewOptionNode.xmlAttributes.view;
					
					// add option to menu
					oMenu.createOption(tmpOptionGroupLabel, 
										tmpNewOptionNode.xmlAttributes.label,
										tmpNewOptionNode.xmlAttributes.view);
				}
			</cfscript>
		</cfif>
		
		<!--- Add views --->
		<cfif StructKeyExists(xmlPlugin.xmlRoot,"views")>
			<cfscript>
				// get instance of appViews object
				oViews = CreateObject("component","appViews");
				
				// build array with views to import
				aViews = arrayNew(1);
				for(i=1;i lte (arrayLen(xmlPlugin.xmlRoot.views.xmlChildren));i=i+1) {
					if(Not StructKeyExists(xmlPlugin.xmlRoot.views.xmlChildren[i].xmlAttributes, "id"))
						throw("The plugin descriptor file is corrupted. [view missing ID attribute]");
					ArrayAppend(aViews, xmlPlugin.xmlRoot.views.xmlChildren[i].xmlAttributes.id);
				}
				
				// get source directory for views
				viewsSrc = getDirectoryFromPath(expandPath(arguments.src)) & getFileSeparator() & "views";
				
				// import view group	
				oViews.importViewGroup(tmpNewModuleID, aViews, viewsSrc);
			</cfscript>
		</cfif>
		
		<!--- add events --->
		<cfif StructKeyExists(xmlPlugin.xmlRoot,"events")>
			<cfscript>
				// get instance of appEvents object
				oEvents = CreateObject("component","appEvents");
				
				// build array with events to import
				aEvents = arrayNew(1);
				for(i=1;i lte (arrayLen(xmlPlugin.xmlRoot.events.xmlChildren));i=i+1) {
					if(Not StructKeyExists(xmlPlugin.xmlRoot.events.xmlChildren[i].xmlAttributes, "id"))
						throw("The plugin descriptor file is corrupted. [event missing ID attribute]");
					if(Not StructKeyExists(xmlPlugin.xmlRoot.events.xmlChildren[i].xmlAttributes, "component"))
						throw("The plugin descriptor file is corrupted. [event missing Component attribute]");
					if(Not StructKeyExists(xmlPlugin.xmlRoot.events.xmlChildren[i].xmlAttributes, "method"))
						xmlPlugin.xmlRoot.events.xmlChildren[i].xmlAttributes["method"] = 
							xmlPlugin.xmlRoot.events.xmlChildren[i].xmlAttributes.id;
								
					ArrayAppend(aEvents, duplicate(xmlPlugin.xmlRoot.events.xmlChildren[i].xmlAttributes));
				}
				
				// get source directory for event handlers
				eventsSrc = getDirectoryFromPath(expandPath(arguments.src)) & getFileSeparator() & "eventHandlers";
				
				// import events group	
				oEvents.importEventGroup(tmpNewModuleID, aEvents, eventsSrc);
			</cfscript>
		</cfif>
	</cffunction>

	<cffunction name="remove" hint="uninstalls a plugin">
		<cfargument name="pluginID" type="string" required="true">
		
		<cfscript>
			var tmpIndex = 0;
			var xmlPlugins = readPluginsXML();
		
			// verify that plugin exists
			for(i=1;i lte arrayLen(xmlPlugins.xmlRoot.xmlChildren);i=i+1) {
				thisNode = xmlPlugins.xmlRoot.xmlChildren[i];
				if(thisNode.xmlAttributes.id eq arguments.pluginID) {
					tmpIndex = i;
					break;
				}
			}
			if(tmpIndex eq 0)
				throw("This plugin has already been removed. Please login again to see the changes.");
			
			// remove from menu
			obj = CreateObject("component","menu");
			obj.removeOptionGroup(arguments.pluginID);

			// remove views
			obj = CreateObject("component","appViews");
			obj.removeViewGroup(arguments.pluginID);

			// remove events
			obj = CreateObject("component","appEvents");
			obj.removeEventGroup(arguments.pluginID);

			// remove plugin
			ArrayDeleteAt(xmlPlugins.xmlRoot.xmlChildren, tmpIndex);
			savePluginsXML(xmlPlugins);
		</cfscript>
	</cffunction>


	<!----------------------------->
	<!--- Private Methods      ---->
	<!----------------------------->
	<cffunction name="readPluginsXML" returntype="any" access="private" hint="Returns the xml document for the plugins file">
		<cfset var xmlDoc = "">
		<cffile action="read" file="#expandPath(this.pluginXML)#" variable="txtDoc">
		<cfset xmlDoc = xmlParse(txtDoc)>
		<cfreturn xmlDoc>
	</cffunction>

	<cffunction name="savePluginsXML" access="private" hint="Saves the xml document for the plugins file">
		<cfargument name="xmlDoc" type="any" required="true">
		<cfif isxmlDoc(arguments.xmlDoc)>
			<cffile action="write" output="#toString(arguments.xmlDoc)#" file="#expandPath(this.pluginXML)#">
		<cfelse>
			<cfthrow message="The parameter passed to this function is not a valid xml document">
		</cfif>
	</cffunction>

	<cffunction name="getFileSeparator" access="private" returntype="string">
		<cfscript>
		    var fileObj = "";
		    var retVal = "";
		    if (isDefined("application._fileSeparator"))
		        retVal = application._fileSeparator;
		    else
		    {   
		        fileObj = createObject("java", "java.io.File");
		        application._fileSeparator = fileObj.separator;
		        retVal = getFileSeparator();
		    }
		</cfscript>
		<cfreturn retVal>
	</cffunction>
</cfcomponent>