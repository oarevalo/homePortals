<cfcomponent hint="this component is a temporary storage for generated content. All content is identified by an ID">

	<cfset variables.instance = structNew()>
	<cfset variables.instance.buffer = structNew()>
	<cfset variables.instance.lstContentClass = "">

	<cffunction name="init" access="public" returntype="contentBuffer">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="append" access="public" returntype="void" hint="appends content">
		<cfargument name="id" type="string" required="true" hint="unique identifier for the content entry">
		<cfargument name="class" type="string" required="false" default="" hint="an identifier for the type or class of content">
		<cfargument name="content" type="string" required="false" default="" hint="the content to store">
		<cfscript>
			// add content to buffer
			if(containsID(arguments.id))
				set(arguments.id, arguments.class, get(arguments.id) & arguments.content);
			else
				set(arguments.id, arguments.class, arguments.content);
		</cfscript>
	</cffunction>	
	
	<cffunction name="set" access="public" returntype="void" hint="stores a content entry">
		<cfargument name="id" type="string" required="true" hint="unique identifier for the content entry">
		<cfargument name="class" type="string" required="false" default="" hint="an identifier for the type or class of content">
		<cfargument name="content" type="string" required="false" default="" hint="the content to store">
		<cfscript>
			// sets the content
			variables.instance.buffer[arguments.id] = arguments.content;
			
			// add content class to list
			if(arguments.class neq "" and not containsClass(arguments.class))
				addContentClass(arguments.class);
		</cfscript>
	</cffunction>

	<cffunction name="get" access="public" returntype="string" hint="retrieves a content entry">
		<cfargument name="id" type="string" required="true" hint="unique identifier for the content entry">
		<cfset var tmpHTML = "">
		<cfif structKeyExists(variables.instance.buffer, arguments.id)>
			<cfset tmpHTML = variables.instance.buffer[arguments.id]>
			<cfset tmpHTML = REReplace(tmpHTML, "[[:space:]]{2,}"," ","ALL")>
			<cfreturn tmpHTML>
		<cfelse>
			<cfthrow message="Content ID [#arguments.id#] not found in content buffer" type="homePortals.contentBuffer.IDNotFound">
		</cfif>
	</cffunction>	

	<cffunction name="getIDList" access="public" returntype="string" hint="returns a list with all content IDs">
		<cfreturn structKeyList(variables.instance.buffer)>
	</cffunction>

	<cffunction name="containsID" access="public" returntype="boolean" hint="Checks whether a content of a given ID has been added to the buffer">
		<cfargument name="id" type="string" required="true">
		<cfreturn structKeyExists(variables.instance.buffer, arguments.id)>
	</cffunction>

	<cffunction name="containsClass" access="public" returntype="boolean" hint="Checks whether a content of a given class has been added to the buffer">
		<cfargument name="class" type="string" required="true">
		<cfreturn listFindNoCase(variables.instance.lstContentClass, arguments.class)>
	</cffunction>

	<cffunction name="addContentClass" access="private" returntype="void">
		<cfargument name="class" type="string" required="true">
		<cfset variables.instance.lstContentClass = listAppend(variables.instance.lstContentClass, arguments.class)>
	</cffunction>

</cfcomponent>