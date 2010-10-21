<cfcomponent hint="This is an abstract component that should be extended by all content renderer components. It provides the basic method implementations that are expected from all renderer objects">
	
	<cfset variables._instance = structNew()>
	<cfset variables._instance.pageRenderer = 0>
	<cfset variables._instance.contentTag = 0>
	
	<cffunction name="init" access="public" returntype="contentTagRenderer" hint="Constructor. This object is initialized with a reference to the calling pageRenderer instance and an envelope for the current page module (content tag) to be processed.">
		<cfargument name="pageRenderer" type="pageRenderer" required="true">
		<cfargument name="contentTag" type="contentTag" required="true">
		<cfset setPageRenderer(arguments.pageRenderer)>
		<cfset setContentTag(arguments.contentTag)>
		<cfreturn this>
	</cffunction>
		
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="singleContentBuffer" required="true" hint="A content buffer for the generated document's 'body' content">	
		<cfargument name="bodyContentBuffer" type="singleContentBuffer" required="true" hint="A content buffer for the generated document's 'head' content">	
		<cfthrow message="Method not implemented!">
	</cffunction>

	<cffunction name="getPageRenderer" access="public" returntype="pageRenderer">
		<cfreturn variables._instance.pageRenderer>
	</cffunction>
	
	<cffunction name="setPageRenderer" access="public" returntype="void">
		<cfargument name="data" type="pageRenderer" required="true">
		<cfset variables._instance.pageRenderer = arguments.data>
	</cffunction>	

	<cffunction name="getContentTag" access="public" returntype="contentTag">
		<cfreturn variables._instance.contentTag>
	</cffunction>

	<cffunction name="setContentTag" access="public" returntype="void">
		<cfargument name="data" type="contentTag" required="true">
		<cfset variables._instance.contentTag = arguments.data>
	</cffunction>	

	<cffunction name="getHomePortals" access="public" returntype="homePortals">
		<cfreturn getPageRenderer().getHomePortals()>
	</cffunction>
	
</cfcomponent>