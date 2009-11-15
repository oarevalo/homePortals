<cfcomponent extends="homePortals.components.contentTagRenderer" 
			hint="This content tag renderer renders regular ModelGlue events as reusable widgets on a page">
	<cfproperty name="event" default="" type="string" displayname="Event" hint="ModelGlue Event to execute">

	<cfset variables.MG_APP_KEY = "_modelglue">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">
		<cfscript>
			var html = "";
			var nodeAttr = getContentTag().getModuleBean().toStruct();

			// create a structure to hold current request state
			reqState = duplicate(form);
			StructAppend(reqState, url);
			StructAppend(reqState, nodeAttr);

			// process ModelGlue request and generate output
			html = processModelGlueRequest(nodeAttr);
			
			// append HTML to output buffer
			arguments.bodyContentBuffer.set( html );
		</cfscript>
	</cffunction>

	<cffunction name="processModelGlueRequest" access="private" returntype="string" hint="Process a ModelGlue Request. Returns the generated output">
		<cfargument name="reqState" type="struct" required="true">
		
		<cfset var event = getContentTag().getAttribute("event")>
		
		<cfset var modelGlueEngine = application[variables.MG_APP_KEY]>
		<cfset var eventContext = modelGlueEngine.executeEvent(event,arguments.reqState) />

		<cfset var renderedContent = eventContext.getLastRendereredView()>
			
		<cfreturn renderedContent>
	</cffunction>

</cfcomponent>