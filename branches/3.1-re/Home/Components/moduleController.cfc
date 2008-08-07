<cfcomponent displayname="moduleController"
			 hint="This component controls access to a module. All interaction with modules must be done through this controller">

	<cfscript>
		variables.isFirstInClass = false;
		variables.pageHREF = "";
		variables.moduleID = 0;
		variables.oModule = 0;
		variables.oModuleConfigBean = 0;
		variables.oContentStoreConfigBean = 0;
		variables.message = "";
		variables.aEventsToRaise = ArrayNew(1);
		variables.stErrorInfo = structNew();
		variables.script = "";
		variables.execMode = "local";
		variables.oHomePortals = 0;
	</cfscript>
	
	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->		
	<cffunction name="init" access="public" 
				hint="This is the constructor. It is responsible for instantiating the module and configuring it properly.">
		<cfargument name="pageHREF" required="true">
		<cfargument name="moduleID" required="true">
		<cfargument name="moduleClassLocation" required="false" default="">
		<cfargument name="modulePageSettings" required="false" default="0">
		<cfargument name="isFirstInClass" required="false" type="boolean" default="false">
		<cfargument name="execMode" required="false" type="string" default="local" hint="Could be 'local' or 'remote', depending on under which context is being executed.">
		<cfargument name="homePortals" type="homePortals" required="true" hint="reference to homeportals environment">
	
		<cfscript>
			var contentStoreID = "";
			var moduleName = "";
			var myConfigBeanStore = createObject("component", "configBeanStore").init();
			var tmpModuleRoot = "";
			var oModuleProperties = 0;
		
			// validate the module info
			if(arguments.pageHREF eq "") throw("Page HREF cannot be blank","homePortals.moduleController.missingPageHREF");
			if(arguments.moduleID eq "") throw("Module ID cannot be blank","homePortals.moduleController.missingModuleID");
			if(arguments.moduleClassLocation eq "" and arguments.execMode eq "local") throw("Module class location cannot be blank","homePortals.moduleController.missingModuleClassLocation");
		
			// initialize instance variables
			variables.pageHREF = arguments.pageHREF;
			variables.moduleID = arguments.moduleID;
			variables.isFirstInClass = arguments.isFirstInClass;
			variables.execMode  = arguments.execMode;
			variables.oHomePortals = arguments.homePortals;

			// create configBeans
			variables.oModuleConfigBean = createObject("component", "moduleConfigBean");
			variables.oContentStoreConfigBean = createObject("component", "contentStoreConfigBean");
			
			// this will be used to identify the contentStoreConfigBean on the configBeanStore
			contentStoreID = variables.moduleID & "_CS";

			// derive the relative path to the module directory from the module cfc location
			if(arguments.moduleClassLocation neq "") {
				tmpModuleRoot = listDeleteAt(arguments.moduleClassLocation, listLen(arguments.moduleClassLocation,"."), ".");
				tmpModuleRoot = "/" & replace(tmpModuleRoot,".","/","all") & "/";
			}

			// get the moduleConfigBean from the configBeanStore
			if(myConfigBeanStore.exists(variables.pageHREF, variables.moduleID)) {
				variables.oModuleConfigBean = myConfigBeanStore.load(variables.pageHREF, variables.moduleID, variables.oModuleConfigBean);
			} else {
				variables.oModuleConfigBean.setPageSettings(arguments.modulePageSettings);
				variables.oModuleConfigBean.setPageHREF(arguments.modulePageSettings["_page"].href);
				variables.oModuleConfigBean.setModuleClassLocation(arguments.moduleClassLocation);
				variables.oModuleConfigBean.setModuleRoot(tmpModuleRoot);
				myConfigBeanStore.save(variables.pageHREF, variables.moduleID, variables.oModuleConfigBean);
			}


			// set the accounts root and the page owner on the content store
			variables.oContentStoreConfigBean.setAccountsRoot( getHomePortalsConfigBean().getAccountsRoot() );
			variables.oContentStoreConfigBean.setOwner( variables.oModuleConfigBean.getPageSetting("_page").owner );

		
			// check if the contentStoreConfigBean is already on the configBeanStore, otherwise add it
			if(myConfigBeanStore.exists(variables.pageHREF, contentStoreID)) {
				variables.oContentStoreConfigBean = myConfigBeanStore.load(variables.pageHREF, contentStoreID, variables.oContentStoreConfigBean);
			} else {
				myConfigBeanStore.save(variables.pageHREF, contentStoreID, variables.oContentStoreConfigBean);
			}

			
			// get module properties for this module (if any). Do this only on the first run of the module
			if(arguments.execMode eq "local") {
				oModuleProperties = getHomePortals().getModuleProperties();
				stModuleProperties = oModuleProperties.getProperties(arguments.modulePageSettings.name);
	
				// copy module properties to the module config bean
				for(key in stModuleProperties) {
					// store all module properties on the module config bean
					variables.oModuleConfigBean.setProperty(key, stModuleProperties[key]);
				}
			}

			// if this is a remote call, then get the module class location from the config bean
			if(arguments.execMode eq "remote") {
				arguments.moduleClassLocation = variables.oModuleConfigBean.getModuleClassLocation();
			}
			
			// instantiate and initialize the module
			variables.oModule = createObject("component", arguments.moduleClassLocation);
			variables.oModule.controller = this;
			variables.oModule.init();
			
			// save any changes to the configBeans since the module init code may have made some changes
			myConfigBeanStore.save(variables.pageHREF, variables.moduleID, variables.oModuleConfigBean);
			myConfigBeanStore.save(variables.pageHREF, contentStoreID, variables.oContentStoreConfigBean);
		</cfscript>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getContentStore                  --->
	<!---------------------------------------->		
	<cffunction name="getContentStore" access="public" returntype="contentStore" 
				hint="Returns the contentStore for the current module, already configured and ready to use.">
		<cfset var oContentStore = CreateObject("component","contentStore")>
		<cfset oContentStore.init(variables.oContentStoreConfigBean)>
		<cfreturn oContentStore>
	</cffunction>

	<!---------------------------------------->
	<!--- getContentStoreConfigBean        --->
	<!---------------------------------------->		
	<cffunction name="getContentStoreConfigBean" returntype="contentStoreConfigBean" access="public" 
				hint="Returns the contentStoreConfigBean">
		<cfreturn variables.oContentStoreConfigBean>
	</cffunction>
		
	<!---------------------------------------->
	<!--- getModuleConfigBean              --->
	<!---------------------------------------->		
	<cffunction name="getModuleConfigBean" returntype="moduleConfigBean" access="public"
				hint="Returns the moduleConfigBean">
		<cfreturn variables.oModuleConfigBean>
	</cffunction>

	<!---------------------------------------->
	<!--- getHomePortalsConfigBean         --->
	<!---------------------------------------->		
	<cffunction name="getHomePortalsConfigBean" returntype="homePortalsConfigBean" access="public"
				hint="Returns a bean with configuration settings for the HomePortals application">
		<cfreturn variables.oHomePortals.getConfig()>
	</cffunction>

	<!---------------------------------------->
	<!--- getHomePortals			       --->
	<!---------------------------------------->		
	<cffunction name="getHomePortals" returntype="homePortals" access="public"
				hint="Returns a reference to the current HomePortals application">
		<cfreturn variables.oHomePortals>
	</cffunction>
		
	<!---------------------------------------->
	<!--- getModuleID                      --->
	<!---------------------------------------->		
	<cffunction name="getModuleID" returntype="any" access="public"
				hint="Returns the module ID">
		<cfreturn variables.moduleID>
	</cffunction>

	<!---------------------------------------->
	<!--- getUserInfo                      --->
	<!---------------------------------------->		
	<cffunction name="getUserInfo" returntype="struct" access="public"
				hint="Returns a structure with information about the current user and the owner of the current page">
		<cfset var stRet = StructNew()>
		<cfset var oUserRegistry = 0>
		<cfset var stUserInfo = structNew()>
		
		<!--- get information on currently logged-in user (if any) from the registry --->
		<cfset oUserRegistry = createObject("component", "userRegistry").init()>
		<cfset stRet = oUserRegistry.getUserInfo()>

		<!--- add additional information about the page owner --->
		<cfset stRet.owner = variables.oModuleConfigBean.getPageSetting("_page").owner>
		<cfset stRet.isOwner = stRet.username neq "" and (stRet.owner eq stRet.username)>
		
		<cfreturn stRet>
	</cffunction>
		
	<!---------------------------------------->
	<!--- isFirstInClass                   --->
	<!---------------------------------------->		
	<cffunction name="isFirstInClass" returntype="boolean" access="public"
				hint="Returns a flag informing whether this module instance is the first occurrence of this module class on the current page.">
		<cfreturn variables.isFirstInClass>
	</cffunction>

	<!---------------------------------------->
	<!--- getExecMode                      --->
	<!---------------------------------------->		
	<cffunction name="getExecMode" returntype="string" access="public"
				hint="Returns either 'local' or 'remote' depending on under which context the module is being executed. A return value of 'local' means that the module is being executed during the initial page rendering phase, 'remote' indicates that the module is being executed as result of a call made from the client browser.">
		<cfreturn variables.execMode>
	</cffunction>

	<!---------------------------------------->
	<!--- getAPIObject                     --->
	<!---------------------------------------->		
	<cffunction name="getAPIObject" returntype="any" access="public"
				hint="Instantiates a HomePortals API object and returns the instance. This method is used so that the module can use any HomePortals API object without knowing the full path to the API location.">
		<cfargument name="APIObjectName" type="string" required="true">
		<cfscript>
			var o = 0;
			if(findoneof("./",arguments.APIObjectName)) throw("Invalid API object name");
			o = createObject("component", arguments.APIObjectName);
		</cfscript>
		<cfreturn o>
	</cffunction>

	<!---------------------------------------->
	<!--- setEventToRaise                  --->
	<!---------------------------------------->		
	<cffunction name="setEventToRaise" access="public" 
				hint="Adds a framework event to raise on the client">
		<cfargument name="event" type="string" required="true">	
		<cfargument name="args" type="string" default="" hint="arguments structure to pass to the event handler">	
		<cfset var stTemp = structNew()>
		<cfset stTemp.event = jsstringFormat(arguments.event)>
		<cfset stTemp.args = arguments.args>
		<cfset arrayAppend(variables.aEventsToRaise, stTemp)>
	</cffunction>

	<!---------------------------------------->
	<!--- flushEventsToRaise               --->
	<!---------------------------------------->		
	<cffunction name="flushEventsToRaise" access="public" 
				hint="Flushes the stack of events to raise">
		<cfset variables.aEventsToRaise = arrayNew(1)>
	</cffunction>



	<!---------------------------------------->
	<!--- setMessage		               --->
	<!---------------------------------------->		
	<cffunction name="setMessage" access="public"
				hint="Sets a message to display on the module client.">
		<cfargument name="message" type="string" required="yes">
		<cfset variables.message = arguments.message>
	</cffunction>

	<!---------------------------------------->
	<!--- getMessage                       --->
	<!---------------------------------------->		
	<cffunction name="getMessage" returntype="struct" access="public"
				hint="Returns the current message set to display">
		<cfreturn variables.message>
	</cffunction>
	
	<!---------------------------------------->
	<!--- flushMessage		               --->
	<!---------------------------------------->		
	<cffunction name="flushMessage" access="public"
				hint="Flushes the message set.">
		<cfset variables.message = "">
	</cffunction>



	<!---------------------------------------->
	<!--- setScript			               --->
	<!---------------------------------------->		
	<cffunction name="setScript" access="public"
				hint="Sets a javascript snippet to execute on the browser.">
		<cfargument name="script" type="string" required="yes">
		<cfset variables.script = arguments.script>
	</cffunction>

	<!---------------------------------------->
	<!--- getScript                        --->
	<!---------------------------------------->		
	<cffunction name="getScript" returntype="string" access="public"
				hint="Returns the javascript snippet set to execute">
		<cfreturn variables.script>
	</cffunction>
	
	<!---------------------------------------->
	<!--- flushScript		               --->
	<!---------------------------------------->		
	<cffunction name="flushScript" access="public"
				hint="Flushes the stored javascript snippet.">
		<cfset variables.script = "">
	</cffunction>





	<!---------------------------------------->
	<!--- setErrorInfo		               --->
	<!---------------------------------------->		
	<cffunction name="setErrorInfo" access="public"
				hint="Sets a structure that will hold exception information. You may use the cfcatch for this structure.">
		<cfargument name="errorInfo" type="any" required="yes">
		<cfset variables.stErrorInfo = arguments.errorInfo>
	</cffunction>

	<!---------------------------------------->
	<!--- getErrorInfo                     --->
	<!---------------------------------------->		
	<cffunction name="getErrorInfo" returntype="any" access="public"
				hint="Returns the saved error information">
		<cfreturn variables.stErrorInfo>
	</cffunction>
	
	<!---------------------------------------->
	<!--- flushErrorInfo	               --->
	<!---------------------------------------->		
	<cffunction name="flushErrorInfo" access="public"
				hint="Flushes the exception information.">
		<cfset variables.stErrorInfo = structNew()>
	</cffunction>


	<!---------------------------------------->
	<!--- savePageSettings                 --->
	<!---------------------------------------->		
	<cffunction name="savePageSettings" access="public" hint="saves page-level settings for this module">
		<cfscript>
			var oPageProvider = getHomePortals().getPageProvider();
			var cfg = getModuleConfigBean();
			var href = cfg.getPageHREF();
			var id = getModuleID();
			var oPage = 0;
			var oConfigBeanStore = 0;
			var tmpField = "";
			var stSettings = structNew();
			var stModule = structNew();

			// get container page			
			oPage = getPage();
				
			stModule = oPage.getModule( id );
			stSettings = cfg.getPageSettings();
			
			// update all attributes sent
			for(tmpField in stSettings) {
				if(isSimpleValue(stSettings[tmpField])) 
					stModule[tmpField] = stSettings[tmpField]; 	
			}			
			oPage.setModule(id, stModule);

			// save changes in configBean store
			oConfigBeanStore = createObject("component", "configBeanStore").init();
			oConfigBeanStore.save(variables.pageHREF, id, cfg);

			// save page
			oPageProvider.save(href, oPage);
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- execute		                   --->
	<!---------------------------------------->		
	<cffunction name="execute" access="public" 
				hint="Executes a method on the module.">
		<cfargument name="action" type="string" required="true">
		<cfset var myAction = arguments.action>
		<cfset structDelete(arguments, "action")>
		<cfinvoke component="#variables.oModule#" method="#myAction#" argumentcollection="#arguments#"></cfinvoke>
	</cffunction>

	<!---------------------------------------->
	<!--- render	                       --->
	<!---------------------------------------->		
	<cffunction name="renderView" access="public" returntype="string"
				hint="Rendes the selected view, or if no view is indicated, then returns the default view">
		<cfargument name="view" type="string" required="no" default="">
		<cfargument name="layout" type="string" required="no" default="">
		<cfargument name="useLayout" type="boolean" required="no" default="true">

		<cfscript>
			var tmpHTML = "";
			var viewHREF = "";
			var layoutHREF = "";	

			try {
				if(arguments.view eq "") 
					arguments.view = variables.oModuleConfigBean.getView("default");
					
				if(arguments.layout eq "")
					arguments.layout = variables.oModuleConfigBean.getDefaultLayout();
					
				if(arguments.view neq "") {
					if(arguments.layout eq "" or Not arguments.useLayout) {
						arguments.fileToInclude = "views/" & arguments.view & ".cfm";
						tmpHTML = variables.oModule.renderInclude(argumentCollection = arguments);
					} else {
						arguments.fileToInclude = "layouts/" & arguments.view & ".cfm";
						tmpHTML = variables.oModule.renderInclude(argumentCollection = arguments);
					}
				}
			} catch(any e) {
				setErrorInfo(e);
				tmpHTML = renderError();
			}
		</cfscript>

		<cfreturn tmpHTML>
	</cffunction>

	<!---------------------------------------->
	<!--- renderClientInit                 --->
	<!---------------------------------------->		
	<cffunction name="renderClientInit" access="public" returntype="string"
				hint="Returns the Javascript code for the initialization of the moduleClient javascript object.">
		<cfset var tmpHTML = "">
		<cfset var id = variables.moduleID>

		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<script type="text/javascript">
					var #id# = new moduleClient();
					#id#.init('#id#');					
				</script>
			</cfoutput>
		</cfsavecontent>		
		
		<cfreturn tmpHTML>
	</cffunction>

	<!---------------------------------------->
	<!--- renderHTMLHead	               --->
	<!---------------------------------------->		
	<cffunction name="renderHTMLHead" access="public" returntype="string"
				hint="Returns the contents of the view selected as the HTML Head for this module. If no HTMLHead view is defined, then returns an empty string.">
		<cfset var htmlHeadView = variables.oModuleConfigBean.getView("htmlHead")>
		<cfset var tmpHTML = "">
		<cfif htmlHeadview neq "">
			<cfset tmpHTML = renderView(htmlHeadView,"",false)>
		</cfif>
		<cfreturn tmpHTML>
	</cffunction>

	<!---------------------------------------->
	<!--- renderMessage		               --->
	<!---------------------------------------->		
	<cffunction name="renderMessage" access="public" returntype="string"
				hint="Returns the Javascript code to display a message on the module client.">
		<cfset var tmpHTML = "">
		
		<cfif variables.message neq "">
			<cfsavecontent variable="tmpHTML">
				<cfoutput>
					<script type="text/javascript">
						#variables.moduleID#.setMessage('#JSStringFormat(variables.message)#');					
					</script>
				</cfoutput>
			</cfsavecontent>	
			<cfset flushMessage()>
		</cfif>
		
		<cfreturn tmpHTML>
	</cffunction>

	<!---------------------------------------->
	<!--- renderRaiseEvents	               --->
	<!---------------------------------------->		
	<cffunction name="renderRaiseEvents" access="public" returntype="string"
				hint="Returns the Javascript code to raise framework events on the module client">
		<cfset var tmpHTML = "">

		<cfsavecontent variable="tmpHTML">
			<script type="text/javascript">
			<cfoutput>
				<cfloop from="1" to="#arrayLen(aEventsToRaise)#" index="i">
					<cfset thisEvent = aEventsToRaise[i]>
					<cfif thisEvent.args neq "">
						h_raiseEvent('#variables.moduleID#','#thisEvent.event#',{#thisEvent.args#});
					<cfelse>
						h_raiseEvent('#variables.moduleID#','#thisEvent.event#');
					</cfif>
				</cfloop>
			</cfoutput>
			</script>
		</cfsavecontent>	
		<cfset flushEventsToRaise()>
		<cfreturn tmpHTML>
	</cffunction>

	<!---------------------------------------->
	<!--- renderScript  	               --->
	<!---------------------------------------->		
	<cffunction name="renderScript" access="public" returntype="string"
				hint="Returns any Javascript code set to execute on the browser">
		<cfset var tmpHTML = "">

		<cfsavecontent variable="tmpHTML">
			<script type="text/javascript">
			<cfoutput>#getScript()#</cfoutput>
			</script>
		</cfsavecontent>	
		<cfset flushScript()>
		<cfreturn tmpHTML>
	</cffunction>

	<!---------------------------------------->
	<!--- renderError                      --->
	<!---------------------------------------->		
	<cffunction name="renderError" access="public" returntype="string"
				hint="Returns the content of the view defined for displaying errors. If not error view defined, then displays errors in a default format">
		<cfset var errorView = variables.oModuleConfigBean.getView("error")>
		<cfset var tmpHTML = "">
		<cfset var stError = getErrorInfo()>
		
		<cfif errorView neq "">
			<cfset tmpHTML = renderView(errorView,"",false)>
		<cfelse>
			<cfparam name="stError.message" default="">
			<cfparam name="stError.Detail" default="">
			<cfset tmpHTML = "<b>#variables.moduleID#: " 
							& stError.Message & "</b><br>"
							& stError.Detail>
		</cfif>
		<cfset flushErrorInfo()>
		<cfreturn tmpHTML>
	</cffunction>

	<!---------------------------------------->
	<!--- getPage	                       --->
	<!---------------------------------------->		
	<cffunction name="getPage" access="public" returntype="pageBean" hint="returns the pageBean that contains this module">
		<cfscript>
			var oPage = 0;
			var oPageRenderer = 0;
			var oPageProvider = getHomePortals().getPageProvider();
			var oCacheRegistry = createObject("component","cacheRegistry").init();			
			var oCache = oCacheRegistry.getCache("hpPageCache");
			var href = getModuleConfigBean().getPageHREF();

			try {
				oPageRenderer = oCache.retrieve(href);
				oPage = oPageRenderer.getPage();
			
			} catch(homePortals.cacheService.itemNotFound e) {
				oPage = oPageProvider.load(href);
			}
			
			return oPage;
		</cfscript>
	</cffunction>



	<!------------  P R I V A T E    M E T H O D S   -------------------------->

	<!---------------------------------------->
	<!--- renderInclude                    --->
	<!---------------------------------------->		
	<cffunction name="renderInclude" access="private" returntype="string">
		<cfargument name="fileToInclude" type="any" required="true">
		<cfset var tmpHTML1 = "">
		<cfset var moduleRoot = variables.oModuleConfigBean.getModuleRoot()>
		<cfsavecontent variable="tmpHTML1">
			<cfinclude template="#moduleRoot##arguments.fileToInclude#">	
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>

	<!---------------------------------------->
	<!--- throw                            --->
	<!---------------------------------------->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string" required="yes">
		<cfargument name="type" type="string" required="no" default="homePortals.moduleController.exception">
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>

	<!---------------------------------------->
	<!--- dump                             --->
	<!---------------------------------------->
	<cffunction name="dump" access="private">
		<cfargument name="data" type="any" required="yes">
		<cfdump var="#arguments.data#">
	</cffunction>	

	<!---------------------------------------->
	<!--- abort                             --->
	<!---------------------------------------->
	<cffunction name="abort" access="private">
		<cfabort>
	</cffunction>	

</cfcomponent>
			 
			 