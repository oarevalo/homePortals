<cfapplication name="HomePortalsAdmin" sessionmanagement="yes" clientmanagement="yes">

<cftry>

<!----------------- Application Settings ------------------------>
<cfset app_basePage = "home.cfm">
<cfset app_errorPage = "error.cfm">
<cfset app_xmlViews = "views.xml">
<cfset app_xmlEvents = "events.xml">
<cfset app_cfcAppController = "eventHandlers.eventHandler">
<cfset app_cfcViews = "components.appViews">
<cfset app_cfcEvents = "components.appEvents">
<cfset app_cfcState = "eventHandlers.appState">
<cfset app_initialView = "login">

<!----------------- Page Parameters ----------------------------->
<!--- Use the following parameters on each request to a page  --->
<!--- to control the behavior of the application			  --->
<!--------------------------------------------------------------->
<cfparam name="Event" default="">	<!--- use to determine the action to perform --->
<cfparam name="View" default="">	<!--- use to indicate which view to display --->
<cfparam name="debug" default="false"> <!--- use to display debug information at the end --->
<cfparam name="resetApp" default="false">  <!--- use to recreate the controller --->

<cfscript>
	try {
		/*---------------------- Create CFCs --------------------------------*/
		/*--- The application requires cfcs to handle Views, Events &  State */
		/*--- The Views cfc is used to determine all screens (or views)  ----*/
		/*--- of the application. Events are actions mapped to components ---*/
		/*--- Application state is maintained as an instance of appState  ---*/
		/*--- component.												  ---*/
		/*--- These objects are stored at session level to avoid having   ---*/
		/*--- to instantiate them on every request.                       ---*/
		/*--- Use page parameter ResetApp to restart the application.     ---*/
		/*-------------------------------------------------------------------*/
		if(Not IsDefined("session.appInitialized") or ResetApp) {
			Session.appViews = CreateObject("Component",app_cfcViews).init(app_xmlViews);
			Session.appEvents = CreateObject("Component",app_cfcEvents).init(app_xmlEvents);
			Session.appState = CreateObject("Component",app_cfcState).init();
			session.appInitialized = true;
		}
		appViews = Session.appViews;
		appEvents = Session.appEvents;
		appState = Session.appState;

		// Pass the requested view to the state
		// The View is passed so that controllers can change it if necessary.
		if(View neq "") {
			appState.lastView = appState.view; 
			appState.view = view;
		}

		// Pass the requested event to the state 
		// The Event is passed so that controller prologue can change it if necessary.
		appState.event = event;
		
		// Execute all the prologue events; these are events that are
		// always executed on every request. Use this to check for
		// conditions such as that the user is logged in.
		aPreEvents = appEvents.getEvents("pre");
		for(i=1;i lte ArrayLen(aPreEvents);i=i+1) {
			thisEvent = aPreEvents[i].xmlAttributes;
			obj = CreateObject("Component", thisEvent.component);
			appState = Evaluate("obj.#thisEvent.method#(form,url,appState)");
			obj = 0;
		}

		// Execute the requested event on the corresponding controller.
		// All events are implemented as methods on a controller CFC.
		// Event methods should take Form and URL scopes as parameters
		// as well as the current application state. The method should
		// return the updated application state.
		Event = appState.event;
		if(Event neq "") {
			thisEvent = appEvents.getEvent(Event);
			if(thisEvent.eventFound) {
				obj = CreateObject("Component", thisEvent.component);
				appState = Evaluate("obj.#thisEvent.method#(form,url,appState)");
			} else
				throw("Event '#event#' is not defined or is misspelled!");
		}

		// Update state on session scope
		session.appState = appState;

	} catch(any e) {
		// Catch unhandled exceptions
		appState.errMessage = e.Message & "<br>" & e.Detail;
	}
	
	
	// If a grave error ocurred and the application was not initialized, then
	// redirect user to login
	if(Not IsDefined("session.appInitialized")) {
		appState = StructNew();
		appState.view = app_initialView;
		appState.errMessage = "An unexpected error ocurred. Unable to initialize application.";
	}
</cfscript>



<!------------------------ Display ------------------------------>
<!--- This application uses a default template to display all --->
<!--- screens. This is used in order to allow the reuse of    --->
<!--- visual elements that remain constant across screens.    --->
<!--- The parameter "View" indicates the selected view.       --->
<!--- The actual file that will be included within the default--->  
<!--- template is obtained using the appView component. The   --->
<!--- included file is used to display the different "screens"--->
<!--- of the application.									  --->
<!--------------------------------------------------------------->
<cfset currentView = appViews.getView(appState.view)>

<cfif currentView.viewFound>
	<cfif currentView.useMainView>
		<cfinclude template="#app_basePage#">
	<cfelse>
		<cfinclude template="views/#currentView.href#">
	</cfif>
<cfelse>
	<cfoutput>
		<p>The requested view (#appState.view#) has not been defined in Views.xml</p>
		<cfif appState.errMessage neq "">
			<b>Error:</b> #appState.errMessage#
		</cfif>
	</cfoutput>
</cfif>


<!--- clear error message, because it has been displayed already --->
<cfset appState.errMessage = "">


<!------------------------ Debug ---------------------------------->
<!--- Use the variable "debug" to enable display of debugging   --->
<!--- information at the end of page							--->
<!----------------------------------------------------------------->
<cfif debug>
	<cfoutput>
		[<b>Event:</b>#event#] 
		[<b>View:</b>#appState.view#] 
		[<b>Last View:</b>#appState.LastView#] 
		<a href="#app_basePage#?resetApp=1">Reset Application Controller</a>
	</cfoutput>
</cfif>


<!--- top-level error handler --->
<cfcatch type="any">
	<cfoutput>
		<cfinclude template="#app_errorPage#">
	</cfoutput>
</cfcatch>
</cftry>


<!--- Auxiliary Functions --->
<cffunction name="dump" access="public">
	<cfargument name="var" type="any">
	<cfdump var="#arguments.var#">
</cffunction>

<cffunction name="warn" access="public">
	<cfargument name="message" type="string">
	<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="warning">
</cffunction>

<cffunction name="throw" access="public">
	<cfargument name="message" type="string">
	<cfargument name="detail" type="string" default=""> 
	<cfargument name="type" type="string" default="custom"> 
	<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
</cffunction>

<cfabort>