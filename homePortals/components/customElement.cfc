<cfcomponent hint="Represents a user defined (or custom) element that can be attached to a PageBean object">
	<cfscript>
		variables.instance = structNew();
		variables.instance.name = "";
		variables.instance.value = "";
		variables.instance.props = structNew();
		variables.instance.children = ArrayNew(1);
	</cfscript>

	<cffunction name="init" access="public" returntype="customElement" hint="Initializes the element">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="false" default="">
		<cfargument name="properties" type="struct" required="false" default="#structNew()#">
		<cfargument name="children" type="array" required="false" default="#arrayNew(1)#">
		<cfset var item = 0>
		<cfset variables.instance.name = arguments.name>
		<cfset variables.instance.value = arguments.value>
		<cfloop collection="#arguments.properties#" item="item">
			<cfset setProperty(item, arguments.properties[item])>
		</cfloop>
		<cfloop array="#arguments.children#" index="item">
			<cfset addChild(item)>
		</cfloop>
		<cfreturn this>
	</cffunction>

	<cffunction name="getName" access="public" returnType="string">
		<cfreturn variables.instance.name>
	</cffunction>

	<cffunction name="setValue" access="public" returnType="customElement">
		<cfargument name="value" type="string" required="false" default="">
		<cfset variables.instance.value = arguments.value>
		<cfreturn this>
	</cffunction>

	<cffunction name="getValue" access="public" returnType="string">
		<cfreturn variables.instance.value>
	</cffunction>

	<cffunction name="setProperty" access="public" returnType="customElement" hint="sets the value of a property">
		<cfargument name="propertyName" type="string" required="true">
		<cfargument name="propertyValue" type="string" required="true">
		<cfset variables.instance.props[arguments.propertyName] = structNew()>
		<cfset variables.instance.props[arguments.propertyName].name = arguments.propertyName>
		<cfset variables.instance.props[arguments.propertyName].value = arguments.propertyValue>
		<cfreturn this>
	</cffunction>

	<cffunction name="hasProperty" access="public" returnType="boolean" hint="Returns true if a property with the given name exists">
		<cfargument name="propertyName" type="string" required="true">
		<cfreturn structKeyExists(variables.instance.props, arguments.propertyName)>
	</cffunction>

	<cffunction name="getProperty" access="public" returnType="string" hint="Returns the value for the given property">
		<cfargument name="propertyName" type="string" required="true">
		<cfargument name="defaultValue" type="string" required="false" default="">
		<cfif hasProperty(arguments.propertyName)>
			<cfreturn variables.instance.props[arguments.propertyName].value>
		<cfelse>
			<cfreturn arguments.defaultValue>
		</cfif>
	</cffunction>

	<cffunction name="getProperties" access="public" returnType="struct" hint="Returns a map all the properties">
		<cfreturn variables.instance.props>
	</cffunction>

	<cffunction name="removeProperty" access="public" returnType="customElement" hint="Deletes a property">
		<cfargument name="propertyName" type="string" required="true">
		<cfset structDelete(variables.instance.props, arguments.propertyName, false)>
		<cfreturn this>
	</cffunction>

	<cffunction name="addChild" access="public" returnType="customElement" hint="adds a child element">
		<cfargument name="child" type="customElement" required="true">
		<cfset arrayAppend(variables.instance.children, arguments.child)>
		<cfreturn this>
	</cffunction>

	<cffunction name="setChild" access="public" returnType="customElement" hint="sets the value of a child element">
		<cfargument name="index" type="numeric" required="true">
		<cfargument name="child" type="customElement" required="true">
		<cfset variables.instance.children[arguments.index] = arguments.child>
		<cfreturn this>
	</cffunction>

	<cffunction name="getChildren" access="public" returnType="array" hint="Returns an array with all the child elements">
		<cfreturn variables.instance.children>
	</cffunction>
	
	<cffunction name="removeChild" access="public" returnType="customElement" hint="Deletes a child element">
		<cfargument name="index" type="numeric" required="true">
		<cfset arrayDeleteAt(variables.instance.chlidren, arguments.index)>
		<cfreturn this>
	</cffunction>
	
</cfcomponent>