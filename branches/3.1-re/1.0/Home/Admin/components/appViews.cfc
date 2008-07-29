<cfcomponent hint="This component stores info on all views used by this application.
				Views are stored on an external XML file.">
	<cfset this.viewsXML = "views.xml">
	<cfset this.xmlViews = "">


	<!------------------------------------------------->
	<!--- init                                     ---->
	<!------------------------------------------------->		
	<cffunction name="init" access="public" returntype="appViews" 
				hint="Initializes the component by reading the xml file and storing its 
						contents within the component">
		<cfargument name="href" type="string" required="no" default="#this.viewsXML#">

		<cffile action="read" file="#ExpandPath(arguments.href)#" variable="txtViews">
		<cfset this.xmlViews = xmlParse(txtViews)>

		<cfloop from="1" to="#ArrayLen(this.xmlViews.xmlRoot.xmlChildren)#" index="i">
			<cfset thisNode = this.xmlViews.xmlRoot.xmlChildren[i]>
			<cfparam name="thisNode.xmlAttributes.id">
			<cfparam name="thisNode.xmlAttributes.href" default="">
			<cfparam name="thisNode.xmlAttributes.label" default="">
			<cfparam name="thisNode.xmlAttributes.useMainView" default="true">
			<cfparam name="thisNode.xmlAttributes.requiresProject" default="false">
		</cfloop>

		<cfreturn this>
	</cffunction>


	<!------------------------------------------------->
	<!--- getView                                  ---->
	<!------------------------------------------------->
	<cffunction name="getView" access="public" returntype="struct"
				hint="Returns information on a specific view, using the view ID">
		<cfargument name="View" type="string" required="yes">
		<cfset stRet = StructNew()>
		<cfset aViews = xmlSearch(this.xmlViews,"//view[@id='#arguments.view#']")>
		<cfif arrayLen(aViews) gt 0>
			<cfset stRet = aViews[1].xmlAttributes> 
			<cfset stRet.href = stRet.id & ".cfm">
			<cfset stRet.viewFound = true>
		<cfelse>
			<cfset stRet.viewFound = false>
		</cfif>
		<cfreturn stRet>
	</cffunction>


	<!------------------------------------------------->
	<!--- getViews                                 ---->
	<!------------------------------------------------->
	<cffunction name="getViews" access="public" returntype="array"
				hint="Returns an array with all views">
		<cfreturn this.xmlViews.xmlRoot.xmlChildren>
	</cffunction>

	<!------------------------------------------------->
	<!--- importViewGroup                          ---->
	<!------------------------------------------------->
	<cffunction name="importViewGroup" access="public" hint="Imports a view group">
		<cfargument name="viewGroupName" type="string" required="true" hint="The name of the view group">
		<cfargument name="aViews" type="array" required="true" hint="An array of view IDs to append to the views file">
		<cfargument name="directory" type="string" required="true" hint="The source directory from where to import views. All files within this directory will be copied.">

		<!--- create subdirectory for views --->
		<cfset viewsDir = "views/#viewGroupName#">
		<cfif Not DirectoryExists(expandPath(viewsDir))>
			<cfdirectory action="create" directory="#expandPath(viewsDir)#">
		</cfif>
		
		<!--- copy views from source directory --->
		<cfdirectory action="list" directory="#directory#" name="qrySrcDir">
		<cfoutput query="qrySrcDir">
			<cfif type eq "file">
				<cfset src = directory & getFileSeparator() & name>
				<cfset tgt = expandPath(viewsDir)>
				<cffile action="copy" source="#src#" destination="#tgt#">
			</cfif>
		</cfoutput>
		
		<!--- append to views file --->	
		<cffile action="read" file="#ExpandPath(this.viewsXML)#" variable="txtDoc">
		<cfset xmlDoc = xmlParse(txtDoc)>
		<cfloop from="1" to="#arrayLen(arguments.aViews)#" index="i">
			<cfset ArrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc,"view") )>
			<cfset tmpIndex = ArrayLen(xmlDoc.xmlRoot.xmlChildren)>
			<cfset xmlDoc.xmlRoot.xmlChildren[tmpIndex].xmlAttributes["id"] = arguments.aViews[i]>
		</cfloop>
		<cffile action="write" output="#toString(xmlDoc)#" file="#expandPath(this.viewsXML)#">
	</cffunction>


	<!------------------------------------------------->
	<!--- removeViewGroup                          ---->
	<!------------------------------------------------->
	<cffunction name="removeViewGroup" hint="Removes a view group">
		<cfargument name="viewGroupName" type="string" required="true" hint="The name of the view group">
		
		<!--- delete directory and files --->
		<cfset viewsDir = "views/#viewGroupName#">
		<cfif DirectoryExists(expandPath(viewsDir))>
			<cfdirectory action="delete" directory="#expandPath(viewsDir)#" recurse="true">
		</cfif>
		
		<!--- remove entries from views file --->
		<cffile action="read" file="#ExpandPath(this.viewsXML)#" variable="txtDoc">
		<cfset xmlDoc = xmlParse(txtDoc)>
		<cfscript>
			// search and delete for views within this group
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				thisViewID = xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.ID;
				if(FindNoCase(arguments.viewGroupName & "/", thisViewID)) {
					ArrayDeleteAt(xmlDoc.xmlRoot.xmlChildren,i);
					i = i-1;
				}
			}
		</cfscript>		
		<cffile action="write" output="#toString(xmlDoc)#" file="#expandPath(this.viewsXML)#">
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