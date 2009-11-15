<cfcomponent extends="homePortals.components.contentTagRenderer" 
			hint="This content tag renderer renders regular ColdBox events as reusable widgets on a page">
	<cfproperty name="event" default="" type="string" displayname="Event" hint="ColdBox Event to execute">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">
		<cfscript>
			var html = "";
			var reqState = structNew();
			var nodeAttr = getContentTag().getModuleBean().toStruct();

			// create a structure to hold current request state
			reqState = duplicate(form);
			StructAppend(reqState, url);
			StructAppend(reqState, nodeAttr);

			// process ColdBox request and generate output
			html = processColdBoxRequest(reqState);
			
			// append HTML to output buffer
			arguments.bodyContentBuffer.set( html );
		</cfscript>
	</cffunction>

	<cffunction name="processColdBoxRequest" access="private" returntype="string" hint="Process a Coldbox Request. Returns the generated output" output="true" >
		<cfargument name="reqState" type="struct" required="true">
		
		<cfset var cbController = 0>
		<cfset var Event = 0>
		<cfset var ExceptionService = 0>
		<cfset var ExceptionBean = 0>
		<cfset var renderedContent = "">
		<cfset var eventCacheEntry = 0>
		<cfset var interceptorData = structnew()>
		
		<cfset var appHash = hash(getBaseTemplatePath())>
		<cfset var lockTimeout = 30>
		
		<!--- Start Application Requests --->
		<cflock type="readonly" name="#appHash#" timeout="#lockTimeout#" throwontimeout="true">
			<cfset cbController = application.cbController>
		</cflock>
			
		<!--- set request time --->
		<cfset request.fwExecTime = getTickCount()>
		
		<!--- Create Request Context & Capture Request --->
		<cfset Event = cbController.getRequestService().requestCapture()>
		
		<!--- Override/append the request context --->
		<cfset Event.collectionAppend(arguments.reqState, true)>
		
		<!--- Execute preProcess Interception --->
		<cfset cbController.getInterceptorService().processState("preProcess")>
		
		
		<!--- IF Found in config, run onRequestStart Handler --->
		<cfif cbController.getSetting("RequestStartHandler") neq "">
			<cfset cbController.runEvent(cbController.getSetting("RequestStartHandler"),true)>
		</cfif>
		
		<!--- Before Any Execution, do we have cached content to deliver --->
		<cfif Event.isEventCacheable() and cbController.getColdboxOCM().lookup(Event.getEventCacheableEntry())>
			<cfset renderedContent = cbController.getColdboxOCM().get(Event.getEventCacheableEntry())>
		<cfelse>
		
			<!--- Run Default/Set Event not executing an event --->
			<cfif NOT event.isNoExecution()>
				<cfset cbController.runEvent(default=true)>
			</cfif>
		
			<!--- Check for Marshalling and data render --->
			<cfif isStruct(event.getRenderData()) and not structisEmpty(event.getRenderData())>
				<cfset renderedContent = cbController.getPlugin("Utilities").marshallData(argumentCollection=event.getRenderData())>
			<cfelse>
				<!--- Render View pair via set variable to eliminate whitespace--->
				<cfset renderedContent = cbController.getPlugin("Renderer").renderView()>
			</cfif>
			
			<!--- PreRender Data:--->
			<cfset interceptorData.renderedContent = renderedContent>
			<!--- Execute preRender Interception --->
			<cfset cbController.getInterceptorService().processState("preRender",interceptorData)>
			<!--- Replace back Content --->
			<cfset renderedContent = interceptorData.renderedContent>
			
			
			<!--- Check if caching the content --->
			<cfif event.isEventCacheable()>
				<cfset eventCacheEntry = Event.getEventCacheableEntry()>
				<!--- Cache the content of the event --->
				<cfset cbController.getColdboxOCM().set(eventCacheEntry.cacheKey,
														renderedContent,
														eventCacheEntry.timeout,
														eventCacheEntry.lastAccessTimeout)>
			</cfif>
			
			<!--- Render Content Type if using Render Data --->
			<cfif isStruct(event.getRenderData()) and not structisEmpty(event.getRenderData())>
				<!--- Render the Data Content Type --->
				<cfcontent type="#event.getRenderData().contentType#; charset=#event.getRenderData().encoding#" reset="true">
				<!--- Remove panels --->
				<cfsetting showdebugoutput="false">
			</cfif>
			
			
			<!--- Execute postRender Interception --->
			<cfset cbController.getInterceptorService().processState("postRender")>
			
			
			<!--- If Found in config, run onRequestEnd Handler --->
			<cfif cbController.getSetting("RequestEndHandler") neq "">
				<cfset cbController.runEvent(cbController.getSetting("RequestEndHandler"),true)>
			</cfif>
			
			<!--- Execute postProcess Interception --->
			<cfset cbController.getInterceptorService().processState("postProcess")>
			
		
		<!--- End else if not cached event --->
		</cfif>
		
		<cfreturn renderedContent>
	</cffunction>

</cfcomponent>