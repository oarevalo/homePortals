<cfcomponent hint="This component stores info on all events used by this application.
				Event declarations are stored on an external XML file.
				The role of the xml file is to map an event with the controller
				who will handle the given event.">
	<cfset this.eventsXML = "events.xml">
	<cfset this.xmlEvents = "">


	<!------------------------------------------------->
	<!--- init                                     ---->
	<!------------------------------------------------->	
	<cffunction name="init" access="public" returntype="appEvents" 
				hint="Initializes the component by reading the xml file and storing its 
						contents within the component">
		<cfargument name="href" type="string" required="no" default="#this.eventsXML#">

		<cffile action="read" file="#ExpandPath(arguments.href)#" variable="txtEvents">
		<cfset this.xmlEvents = xmlParse(txtEvents)>
		
		<cfloop from="1" to="#ArrayLen(this.xmlEvents.xmlRoot.xmlChildren)#" index="i">
			<cfset thisNode = this.xmlEvents.xmlRoot.xmlChildren[i]>
			<cfparam name="thisNode.xmlAttributes.id">
			<cfparam name="thisNode.xmlAttributes.component">
			<cfparam name="thisNode.xmlAttributes.method" default="#thisNode.xmlAttributes.id#">
			<cfparam name="thisNode.xmlAttributes.executionMode" default="normal">
		</cfloop>

		<cfreturn this>
	</cffunction>


	<!------------------------------------------------->
	<!--- getEvent                                 ---->
	<!------------------------------------------------->
	<cffunction name="getEvent" access="public" returntype="struct"
				hint="Returns information on a specific event, using the event ID">
		<cfargument name="Event" type="string" required="yes">
		
		<cfset var stRet = StructNew()>
		<cfset var aEvents = xmlSearch(this.xmlEvents,"//event[@id='#arguments.Event#']")>
		<cfif arrayLen(aEvents) gt 0>
			<cfset stRet = aEvents[1].xmlAttributes> 
			<cfset stRet.eventFound = true>
		<cfelse>
			<cfset stRet.eventFound = false>
		</cfif>
		<cfreturn stRet>
	</cffunction>
	
	
	<!------------------------------------------------->
	<!--- getEvents                                ---->
	<!------------------------------------------------->
	<cffunction name="getEvents" access="public" returntype="array"
				hint="Returns an array with all events. If an executionMode is given, 
						then returns all events for the given execution mode">
		<cfargument name="executionMode" type="string" default="" required="no">

		<cfset var aRet = ArrayNew(1)>
		
		<cfif arguments.executionMode eq "">
			<cfset aRet = this.xmlEvents.xmlRoot.xmlChildren>
		<cfelse>
			<cfset aRet = xmlSearch(this.xmlEvents,"//event[@executionMode='#arguments.executionMode#']")>
		</cfif>
		<cfreturn aRet>
	</cffunction>

	<!------------------------------------------------->
	<!--- importEventGroup                         ---->
	<!------------------------------------------------->
	<cffunction name="importEventGroup" access="public" hint="Imports an event handlers group">
		<cfargument name="eventGroupName" type="string" required="true" hint="The name of the event group">
		<cfargument name="aEvents" type="array" required="true" hint="An array of event structures to append to the events file">
		<cfargument name="directory" type="string" required="true" hint="The source directory from where to import event handlers. All files within this directory will be copied.">

		<!--- create subdirectory for event handlers --->
		<cfset eventsDir = "eventHandlers/#eventGroupName#">
		<cfif Not DirectoryExists(expandPath(eventsDir))>
			<cfdirectory action="create" directory="#expandPath(eventsDir)#">
		</cfif>
	
		
		<!--- copy required files for the new event handlers group --->
		<cfset src = ExpandPath("eventHandlers/eventHandler.cfc")>
		<cfset tgt = ExpandPath("eventHandlers/#eventGroupName#/eventHandler.cfc")>
		<cffile action="copy" source="#src#" destination="#tgt#">
		
		
		<!--- copy handlers from source directory --->
		<cfdirectory action="list" directory="#directory#" name="qrySrcDir">
		<cfoutput query="qrySrcDir">
			<cfif type eq "file">
				<cfset src = directory & getFileSeparator() & name>
				<cfset tgt = expandPath(eventsDir)>
				<cffile action="copy" source="#src#" destination="#tgt#">
			</cfif>
		</cfoutput>
		
		<!--- append to events file --->	
		<cffile action="read" file="#ExpandPath(this.eventsXML)#" variable="txtDoc">
		<cfset xmlDoc = xmlParse(txtDoc)>
		<cfloop from="1" to="#arrayLen(arguments.aEvents)#" index="i">
			<cfset ArrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc,"event") )>
			<cfset tmpIndex = ArrayLen(xmlDoc.xmlRoot.xmlChildren)>
			<cfset xmlDoc.xmlRoot.xmlChildren[tmpIndex].xmlAttributes["id"] = arguments.aEvents[i].id>
			<cfset xmlDoc.xmlRoot.xmlChildren[tmpIndex].xmlAttributes["component"] = arguments.aEvents[i].component>
			<cfset xmlDoc.xmlRoot.xmlChildren[tmpIndex].xmlAttributes["method"] = arguments.aEvents[i].method>
		</cfloop>
		<cffile action="write" output="#toString(xmlDoc)#" file="#expandPath(this.eventsXML)#">
	</cffunction>

	<!------------------------------------------------->
	<!--- removeEventGroup                         ---->
	<!------------------------------------------------->
	<cffunction name="removeEventGroup" hint="Removes an event group">
		<cfargument name="eventGroupName" type="string" required="true" hint="The name of the event group">
		
		<!--- delete directory and files --->
		<cfset eventsDir = "eventHandlers/#eventGroupName#">
		<cfif DirectoryExists(expandPath(eventsDir))>
			<cfdirectory action="delete" directory="#expandPath(eventsDir)#" recurse="true">
		</cfif>
		
		<!--- remove entries from views file --->
		<cffile action="read" file="#ExpandPath(this.eventsXML)#" variable="txtDoc">
		<cfset xmlDoc = xmlParse(txtDoc)>
		<cfscript>
			// search and delete for events within this group
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				thisEventID = xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.ID;
				if(FindNoCase(arguments.eventGroupName & ".", thisEventID)) {
					ArrayDeleteAt(xmlDoc.xmlRoot.xmlChildren,i);
					i = i-1;
				}
			}
		</cfscript>		
		<cffile action="write" output="#toString(xmlDoc)#" file="#expandPath(this.eventsXML)#">
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