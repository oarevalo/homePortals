<cfcomponent>
	
	<cfset variables.instance = structNew()>
	<cfset variables.instance.pageRenderer = 0>
	<cfset variables.instance.contentTag = 0>
	
	<cffunction name="init" access="public" returntype="contentTagRenderer">
		<cfargument name="pageRenderer" type="pageRenderer" required="true">
		<cfargument name="contentTag" type="contentTag" required="true">
		<cfset setPageRenderer(arguments.pageRenderer)>
		<cfset setContentTag(arguments.contentTag)>
		<cfreturn this>
	</cffunction>
		
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="singleContentBuffer" required="true">	
		<cfthrow message="Method not implemented!">
	</cffunction>

	<cffunction name="getPageRenderer" access="public" returntype="pageRenderer">
		<cfreturn variables.instance.pageRenderer>
	</cffunction>
	
	<cffunction name="setPageRenderer" access="public" returntype="void">
		<cfargument name="data" type="pageRenderer" required="true">
		<cfset variables.instance.pageRenderer = arguments.data>
	</cffunction>	

	<cffunction name="getContentTag" access="public" returntype="contentTag">
		<cfreturn variables.instance.contentTag>
	</cffunction>

	<cffunction name="setContentTag" access="public" returntype="void">
		<cfargument name="data" type="contentTag" required="true">
		<cfset variables.instance.contentTag = arguments.data>
	</cffunction>	

</cfcomponent>