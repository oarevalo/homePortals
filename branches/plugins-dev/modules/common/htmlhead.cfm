<cfscript>
	oHP = getHomePortals();
	appRoot = oHP.getConfig().getAppRoot();
	onLoadEvent = "";
	currentPage = getPage();
	currentPageHREF = getPageHREF();


	// create gateway if needed
	gateway = oHP.getPluginManager().getPlugin("modules").getPluginSetting("modulesGateway");
	if(not fileExists(expandPath("#appRoot#/#gateway#"))) {
		fileCopy(expandPath("/homePortals/plugins/modules/default-modules-gateway.cfm"),expandPath("#appRoot#/#gateway#"));
	}

	// get event listener elements	
	aEventListeners = arrayNew(1);
	if(currentPage.hasCustomElement("eventListeners")) {
		aEventListeners = currentPage.getCustomElement("eventListeners").getChildren();
	}
	
	// set initial javascript event
	initialEvent = oHP.getConfig().getPageProperty("plugins.modules.initialEvent");
	if(ListLen(initialEvent,".") eq 2)
		onLoadEvent = "h_raiseEvent('#ListFirst(initialEvent,".")#', '#ListLast(initialEvent,".")#')";
		
</cfscript>

<!--- Process event listeners --->
<cfoutput>
	<script type="text/javascript">
		/*********** Set app root **********/
		h_appRoot = "#jsStringFormat(appRoot)#";
		h_pageHREF = "#jsStringFormat(currentPageHREF)#";
		
		/*********** Raise events by modules *************/
		function h_raiseEvent(objectName, eventName, args) {
			<cfloop array="#aEventListeners#" index="element">
				<cfif element.getName() eq "event">
					<cfset objectName = element.getProperty("objectName")>
					<cfset eventName = element.getProperty("eventName")>
					<cfset eventHandler = element.getProperty("eventHandler")>
					if(objectName=="#jsStringFormat(objectName)#" && eventName=="#jsStringFormat(eventName)#") {
						try {#eventHandler#(args);} catch(e) {alert(e);}
					}
				</cfif>
			</cfloop>
		}
		
		<cfif onLoadEvent neq "">
			jQuery(function() {
				#onLoadEvent#
			});
		</cfif>
	</script>
</cfoutput>


		