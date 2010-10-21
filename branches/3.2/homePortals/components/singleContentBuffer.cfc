<cfcomponent hint="This is a wrapper around a contentBuffer object that restricts access (read/write) to only one specific element in the buffer">

	<cfset variables.instance = structNew()>
	<cfset variables.instance.id = "">
	<cfset variables.instance.contentBuffer = 0>

	<cffunction name="init" access="public" returnType="singleContentBuffer">
		<cfargument name="id" type="string" required="true">
		<cfargument name="contentBuffer" type="contentBuffer" required="true">
		<cfset variables.instance.id = arguments.id>
		<cfset variables.instance.contentBuffer = arguments.contentBuffer>
		<cfreturn this>
	</cffunction>

	<cffunction name="append" access="public" returntype="void" hint="appends content">
		<cfargument name="content" type="string" required="true" hint="the content to store">
		<cfargument name="class" type="string" required="false" default="" hint="an identifier for the type or class of content">
		<cfset variables.instance.contentBuffer.append(variables.instance.id, arguments.class, arguments.content)>
	</cffunction>	
	
	<cffunction name="set" access="public" returntype="void" hint="stores a content entry">
		<cfargument name="content" type="string" required="true" hint="the content to store">
		<cfargument name="class" type="string" required="false" default="" hint="an identifier for the type or class of content">
		<cfset variables.instance.contentBuffer.set(variables.instance.id, arguments.class, arguments.content)>
	</cffunction>

	<cffunction name="get" access="public" returntype="string" hint="retrieves a content entry">
		<cfreturn variables.instance.contentBuffer.get(variables.instance.id)>
	</cffunction>	

	<cffunction name="containsClass" access="public" returntype="boolean" hint="Checks whether a content of a given class has been added to the buffer">
		<cfargument name="class" type="string" required="true">
		<cfreturn variables.instance.contentBuffer.containsClass(arguments.class)>
	</cffunction>

</cfcomponent>