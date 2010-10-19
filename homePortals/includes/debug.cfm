<cfsetting showdebugoutput="true">

<!------- Page parameters ----------->
<cfparam name="action" default="">
<cfparam name="cacheName" default="">
<cfparam name="resetApp" default="false"> 	<!--- Force a reload and parse of the HomePortals application --->

<cfparam name="pageHREF" default="">			<!--- Path to a homeportals account --->
<!----------------------------------->

<!------- Application Root ----------->
<!--- This variable must point to the root directory of the application --->
<!--- if not specified on the calling template, then it defaults to the current directory. --->
<cfparam name="request.appRoot" default="#GetDirectoryFromPath(cgi.script_Name)#"> 	
<!----------------------------------->

<cfif structKeyExists(request,"oPageRenderer")><hr /></cfif>

<cfsilent>
<cfscript>
	// this check is in case the debug template is displayed after the page.cfm template
	if(not structKeyExists(request,"oPageRenderer")) {

		// Initialize application if requested or needed
		if((isBoolean(resetApp) and resetApp) or Not StructKeyExists(application, "homePortals")) {
			application.homePortals = CreateObject("component","homePortals.components.homePortals").init(request.appRoot);
			resetApp = true;
		}

		// load and parse page
		request.oPageRenderer = application.homePortals.loadPage(pageHREF);

		// execute rendering of page html to obtain the timers
		html = request.oPageRenderer.renderPage();
	}

	hp = application.homePortals;
	
	stHPTimers = hp.getTimers();
	stPRTimers = request.oPageRenderer.getTimers();
	
	// get amount of free memory
	jrt = CreateObject("java", "java.lang.Runtime");
	freeMem = ( (jrt.getRuntime().freeMemory() / jrt.getRuntime().totalMemory() ) * 100 );
	if(freeMem gt 50)
		freeMemLabelColor = "green";
	else if(freemem gt 15)
		freeMemLabelColor = "orange";
	else
		freeMemLabelColor = "red";
		
	// get reference to cache registry
	oCacheRegistry = createObject("component","homePortals.components.cacheRegistry").init();
	tmpMsg = "";
</cfscript>
</cfsilent>

<!--- Process Actions --->
<cfswitch expression="#action#">
	<cfcase value="clear">
		<cfset oCacheRegistry.flush(cacheName)>
		<cfset tmpMsg = "Cache [#cacheName#] cleared.">
    </cfcase>
    
    <cfcase value="cleanup">
		<cfset oCache = oCacheRegistry.getCache(cacheName)>
		<cfset oCache.cleanup()>    
		<cfset tmpMsg = "Cache [#cacheName#] cleaned.">
    </cfcase>
    
	<cfcase value="list">
		<cfset oCache = oCacheRegistry.getCache(cacheName)>
        <cfdump var="#oCache.list()#" label="#cacheName#">
    </cfcase>
</cfswitch>

<!--- get list of caches --->
<cfset lstCaches = oCacheRegistry.getCacheNames()>

<cfoutput>
	<!-- /* HomePortals Debug Panel */ -->
	<style type="text/css">
		##hp_debugPanel {
			font-size:11px;
			font-family:arial;
		}
		##hp_debugPanel table {
			width:500px;
			border-collapse:collapse;
			border:1px solid silver;
			font-size:11px;
		}
		##hp_debugPanel th {
			font-weight:bold;
			text-align:left;
			background-color:##ebebeb;
		}
		##hp_debugPanel td, ##hp_debugPanel th {
			padding:2px;
		}
		##hp_debugPanel .msg {
			font-size:13px;
			border:1px solid silver;
			padding:8px;
			background-color:##ffffe1;
			margin-bottom:20px;
		}
	</style>

	<div id="hp_debugPanel">
		<h2>HomePortals - Debug Panel</h2>

		<cfif tmpMsg neq "">
			<div class="msg">#tmpMsg#</div>
		</cfif>

		<table border="1">
			<tr>
				<th colspan="2">
					<div style="float:right;">
						<a href="#cgi.SCRIPT_NAME#?resetApp=1&page=#pageHREF#">Reset App</a> |
						<a href="#cgi.SCRIPT_NAME#?page=#pageHREF#">Reload Page</a>
					</div>
					Application:
				</th>
			</tr>
			<tr>
				<td width="130"><b>HP Engine Version:</b></td>
				<td>#hp.getVersion()#</td>
			</tr>
			<tr>
				<td width="130"><b>App Root:</b></td>
				<td>#request.appRoot#</td>
			</tr>
			<tr>
				<td width="130"><b>Content Root:</b></td>
				<td>#hp.getConfig().getContentRoot()#</td>
			</tr>
			<tr>
				<td width="130"><b>Resource Libraries:</b></td>
				<td>
					<cfset rm = hp.getResourceLibraryManager()>
					<cfset aResLibs = rm.getResourceLibraries()>
					<cfloop from="1" to="#arrayLen(aResLibs)#" index="i">
						#aResLibs[i].getPath()#<br />
					</cfloop>
				</td>
			</tr>
			<tr>
				<td width="130"><b>Plugins Loaded:</b></td>
				<td>
					<cfset pm = hp.getPluginManager()>
					<cfset aPlugins = pm.getPlugins()>
					<cfloop from="1" to="#arrayLen(aPlugins)#" index="i">
						#aPlugins[i]#<br />
					</cfloop>
					<cfif arrayLen(aPlugins) eq 0>
						<em>None</em>
					</cfif>
				</td>
			</tr>
			<tr>
				<td width="130"><b>Free JVM Memory:</b></td>
				<td><span style="color:#freeMemLabelColor#;font-weight:bold;">#decimalFormat(freeMem)#%</span></td>
			</tr>
		</table>
		<br><br>

		<table border="1">
			<tr><th colspan="2">Current Page:</th></tr>
			<tr>
				<td width="130"><b>Title:</b></td>
				<td>#request.oPageRenderer.getPage().getTitle()#</td>
			</tr>
			<tr>
				<td><b>Path:</b></td>
				<td>#request.oPageRenderer.getPageHREF()#</td>
			</tr>
			<tr>
				<td><b>Custom Properties:</b></td>
				<td>
					<cfset stProps = request.oPageRenderer.getPage().getProperties()>
					<cfloop collection="#stProps#" item="key">
						<strong>&bull; #key#:</strong> 
						<cfif isSimpleValue(stProps[key].value)>
							#stProps[key].value#<br />
						<cfelse>
							<cfdump var="#stProps[key].value#">
						</cfif>
					</cfloop>
					<cfif structIsEmpty(stProps)>
						<em>None</em>
					</cfif>
				</td>
			</tr>
		</table>
		<br><br>
			
		<cfset row = 1>
		<cfset pageTotalTime = 0>
		<table border="1">
			<tr><th colspan="3">Timers:</th></tr>
			<tr>
				<th width="10">&nbsp;</th>
				<th>Task</th>
				<th width="100">Time (ms)</th>
			</tr>
			<cfif resetApp>
				<tr>
					<td width="10" align="right"><b>#row#.</b></td>
					<td><em><b>Engine Initialization</b></em></td>
					<td align="right" width="50"><b>#stHPTimers.init#</b></td>
				</tr>
				<cfset row = row + 1>
				<cfset pageTotalTime = pageTotalTime + stHPTimers.init>
			</cfif>
			<tr>
				<td width="10" align="right"><b>#row#.</b></td>
				<td><b><em>Page Loading</em></b></td>
				<td align="right"><b>#stHPTimers.loadPage#</b></td>
			</tr>
			<cfset row = row + 1>
			<cfset pageTotalTime = pageTotalTime + stHPTimers.loadPage>
<!--- 				
				<tr>
					<td width="10" align="right"><b>#row#.</b></td>
					<td>+----<em>Load Page Renderer</em></td>
					<td align="right">#stHPTimers.loadPageRenderer#</td>
				</tr>
				<cfset row = row + 1>
 --->			
			<tr>
				<td width="10" align="right"><b>#row#.</b></td>
				<td>+----<em>Process Modules</em></td>
				<td align="right">#stPRTimers.processModules#</td>
			</tr>
			<cfset row = row + 1>
			<tr>
				<td width="10" align="right"><b>#row#.</b></td>
				<td><b><em>Page Rendering</em></b></td>
				<td align="right"><b>#stPRTimers.renderPage#</b></td>
			</tr>
			<cfset row = row + 1>
			<cfset pageTotalTime = pageTotalTime + stPRTimers.renderPage>
			<tr>
				<td colspan="2" align="right"><b>TOTAL TIME:</b></td>
				<td align="right"><b>#pageTotalTime#</b></td>
			</tr>
		</table>
		<br><br>

		<table border="1">
			<tr><th colspan="3">Module Processing Timers:</th></tr>
			<tr>
				<th width="10">&nbsp;</th>
				<th>Module</th>
				<th width="100">Time (ms)</th>
			</tr>
			<cfset row = 1>
			<cfset tmpTime = 0>
			<cfloop collection="#stPRTimers#" item="key">
				<cfif listLen(key,"_") gt 1>
					<tr>
						<td width="10" align="right"><b>#row#.</b></td>
						<td>#listLast(key,"_")#</td>
						<td align="right">#stPRTimers[key]#</td>
					</tr>
					<cfset row = row + 1>
					<cfset tmpTime = tmpTime + stPRTimers[key]>
				</cfif>
			</cfloop>
			<tr>
				<td colspan="2" align="right"><b>TOTAL TIME:</b></td>
				<td align="right"><b>#tmpTime#</b></td>
			</tr>
		</table>			
			
		<br><br>
		<table border="1">
			<tr><th colspan="7">Cache Registry:</th></tr>
			<tr>
				<th width="10">No.</th>
				<th>Cache Name</th>
				<th>Current<br>Size</th>
				<th>Max<br>Size</th>
				<th>Hit/Miss</th>
				<th>Last Reap</th>
				<th>Actions</th>
			</tr>
			<cfset index = 1>
			<cfloop list="#lstCaches#" index="cacheName">
				<cfset oCache = oCacheRegistry.getCache(cacheName)>
				<cfset stStats = oCache.getStats()>
				<cfif stStats.maxSize gt 0>
					<cfset cacheWarning = (stStats.currentSize gt stStats.maxSize or
											(stStats.maxSize gte stStats.currentSize 
											and stStats.currentSize/stStats.maxSize gt 0.9))>
				<cfelse>
					<cfset cacheWarning = false>
				</cfif>
				<tr <cfif cacheWarning>style="background-color:pink;"</cfif>>
					<td>#index#.</td>
					<td>#cacheName#</td>
					<td align="right">#stStats.currentSize#</td>
					<td align="right">#stStats.maxSize#</td>
					<td align="right">#stStats.hitCount# / #stStats.missCount#</td>
					<td align="center">
						<cfif stStats.lastReap neq "" and stStats.lastReap neq "12/30/1899">
							#lsDateFormat(stStats.lastReap)#<br>#lsTimeFormat(stStats.lastReap)#
						<cfelse>
							-
						</cfif>
					</td>
					<td align="center">
						[<a href="#cgi.SCRIPT_NAME#?action=list&cacheName=#cacheName#" title="List all elements in the cache">list</a>]
						<cfif left(cacheName,2) neq "hp" or cacheName eq "hpPageCache">
							[<a href="#cgi.SCRIPT_NAME#?action=clear&cacheName=#cacheName#" title="Removes all elements from the cache">clear</a>]
						</cfif>
						[<a href="#cgi.SCRIPT_NAME#?action=cleanup&cacheName=#cacheName#" title="Removes stale elements from the cache">reap</a>]
					</td>
				</tr>
				<cfset index=index+1>
			</cfloop>
		</table>
	</div>
</cfoutput>
