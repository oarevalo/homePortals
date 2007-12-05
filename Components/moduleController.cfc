<cfcomponent displayname="moduleController"
			 hint="This component controls access to a module. All interaction with modules must be done through this controller">

	<cfscript>
		variables.isFirstInClass = false;
		variables.moduleID = 0;
		variables.oModule = 0;
		variables.oModuleConfigBean = 0;
		variables.oContentStoreConfigBean = 0;
		variables.message = "";
		variables.aEventsToRaise = ArrayNew(1);
		variables.stErrorInfo = structNew();
		variables.script = "";
		variables.execMode = "local";
	</cfscript>
	
	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->		
	<cffunction name="init" access="public" 
				hint="This is the constructor. It is responsible for instantiating the module and configuring it properly.">
		<cfargument name="moduleID" required="true">
		<cfargument name="moduleClassLocation" required="false" default="">
		<cfargument name="modulePageSettings" required="false" default="0">
		<cfargument name="pageHREF" required="false" default="">
		<cfargument name="isFirstInClass" required="false" type="boolean" default="false">
		<cfargument name="execMode" required="false" type="string" default="local" hint="Could be 'local' or 'remote', depending on under which context is being executed.">
	
		<cfscript>
			var contentStoreID = "";
			var moduleName = "";
			var myConfigBeanStore = createObject("component", "configBeanStore");
			var tmpModuleRoot = "";
		
			// initialize instance variables
			variables.moduleID = arguments.moduleID;
			variables.isFirstInClass = arguments.isFirstInClass;
			variables.execMode  = arguments.execMode;

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
			if(myConfigBeanStore.exists(variables.moduleID)) {
				variables.oModuleConfigBean = myConfigBeanStore.load(variables.moduleID, variables.oModuleConfigBean);
			} else {
				variables.oModuleConfigBean.setPageSettings(arguments.modulePageSettings);
				variables.oModuleConfigBean.setPageHREF(arguments.pageHREF);
				variables.oModuleConfigBean.setModuleClassLocation(arguments.moduleClassLocation);
				variables.oModuleConfigBean.setModuleRoot(tmpModuleRoot);
				myConfigBeanStore.save(variables.moduleID, variables.oModuleConfigBean);
			}
		
			// get the contentStoreConfigBean from the configBeanStore
			if(myConfigBeanStore.exists(contentStoreID)) {
				variables.oContentStoreConfigBean = myConfigBeanStore.load(contentStoreID, variables.oContentStoreConfigBean);
			} else {
				myConfigBeanStore.save(contentStoreID, variables.oContentStoreConfigBean);
			}
			
			
			// get the module class name
			moduleName = variables.oModuleConfigBean.getModuleClassLocation();
			if(moduleName eq "") throw("Module name is empty.");
			
			// get module properties
			stModuleProperties = getModuleProperties(moduleName);
			for(key in stModuleProperties) {
				// store all module properties on the module config bean
				variables.oModuleConfigBean.setProperty(key, stModuleProperties[key]);
			}
		
			// instantiate and initialize the module
			variables.oModule = createObject("component", moduleName);
			variables.oModule.controller = this;
			variables.oModule.init();
			
			// save any changes to the configBeans since the module init code may have made some changes
			myConfigBeanStore.save(variables.moduleID, variables.oModuleConfigBean);
			myConfigBeanStore.save(contentStoreID, variables.oContentStoreConfigBean);
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
		<cfset stRet.username = "">
		<cfset stRet.isOwner = false>
		<cfset stRet.owner = "">
		
		<cfif IsDefined("Session.homeConfig")>
			<cfif IsDefined("Session.User.qry")>
				<cfset stRet.username = session.user.qry.username>
				<cfset stRet.isOwner = (session.user.qry.username eq ListGetAt(session.homeConfig.href, 2, "/"))>
			</cfif>
			<cfset stRet.owner = ListGetAt(session.homeConfig.href, 2, "/")>
		</cfif>
		
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
			var cfg = getModuleConfigBean();
			var href = cfg.getPageHREF();
			var id = getModuleID();
			var xmlDoc = 0;
			var xmlModuleNode = 0;
			var stSettings = cfg.getPageSettings();
			var tmpField = "";
			var myConfigBeanStore = createObject("component", "configBeanStore");
			
			// read and parse layout page
			xmlDoc = xmlParse(expandPath(href));

			// loop through all page modules
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.modules.xmlChildren);i=i+1) {
				// when the current module is found, update module attributes
				if(xmlDoc.xmlRoot.modules.xmlChildren[i].xmlAttributes.id eq id) {
					xmlModuleNode = xmlDoc.xmlRoot.modules.xmlChildren[i];
					// update all attributes sent
					for(tmpField in stSettings) {
						//throw(tmpField);
						if(tmpField neq "icons")
							xmlModuleNode.xmlAttributes[tmpField] = stSettings[tmpField];
					}	
				}	
			}

			// save changes in configBean store
			myConfigBeanStore.save(id, cfg);

			// save layout page
			writeFile(expandPath(href), toString(xmlDoc));
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
	<cffunction name="render" access="public" returntype="string"
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
			<cfset tmpHTML = render(htmlHeadView,"",false)>
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
			<cfset tmpHTML = render(errorView,"",false)>
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
		<cfthrow message="#arguments.message#">
	</cffunction>

	<!---------------------------------------->
	<!--- dump                             --->
	<!---------------------------------------->
	<cffunction name="dump" access="private">
		<cfargument name="data" type="any" required="yes">
		<cfdump var="#arguments.data#">
	</cffunction>	

	<!-------------------------------------->
	<!--- writeFile                      --->
	<!-------------------------------------->
	<cffunction name="writeFile" access="private" hint="saves a file to the filesystem">
		<cfargument name="file" type="string">
		<cfargument name="content" type="string" default="">
		<cffile action="write" 
				file="#arguments.file#" 
				output="#toString(arguments.content)#">
	</cffunction>

	<cffunction name="getModuleProperties" access="private" 
				returntype="struct"
				hint="Returns read-only properties for the current module">
		<cfargument name="moduleClassName" required="true" type="string">
		<cfargument name="forceRefresh" required="false" type="boolean" default="false">
		<cfscript>
			var tmpPropsFile = "";
			var xmlPropsDoc = 0;
			var stProperties = structNew();
			var tmpNode = 0;
			var i = 0;
			var j = 0;
			var stModuleProperties = structNew();
			
			// if application-level structure for module properties does not exists, then initialize it.
			if(Not structKeyExists(application,"moduleProperties") or arguments.forceRefresh) {
				tmpPropsFile = ExpandPath("Config/module-properties.xml");
				// only read and parse if the file exists
				if(fileExists(tmpPropsFile)) {
					// read file and convert to xml object
					xmlPropsDoc = xmlParse(tmpPropsFile);
					
					// parse xml and conver to structure
					for(i=1;i lte arrayLen(xmlPropsDoc.xmlRoot.xmlChildren);i=i+1) {
						tmpNode = xmlPropsDoc.xmlRoot.xmlChildren[i];
						if(tmpNode.xmlName eq "module") {
							stProperties[tmpNode.xmlAttributes.name] = structNew();
							for(j=1;j lte arrayLen(tmpNode.xmlChildren);j=j+1) {
								if(tmpNode.xmlChildren[j].xmlName eq "property") {
									stProperties[tmpNode.xmlAttributes.name][tmpNode.xmlChildren[j].xmlAttributes.name] = tmpNode.xmlChildren[j].xmlAttributes.value;
								}		
							}
						}
					}
					
					// copy properties structure to application scope for persistence
					application.moduleProperties = duplicate(stProperties);
				}
			}

			// check again if the moduleProperties is in the application scope
			if(structKeyExists(application,"moduleProperties")
				and structKeyExists(application.moduleProperties, arguments.moduleClassName)) {
				stModuleProperties = application.moduleProperties[arguments.moduleClassName];
			}
		</cfscript>
		<cfreturn stModuleProperties>
	</cffunction>		
		
</cfcomponent>
			 
			 