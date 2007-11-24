<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<cfsetting showdebugoutput="true">

<!------- Page parameters ----------->
<cfparam name="account" default=""> 			<!--- HomePortals account --->
<cfparam name="page" default=""> 				<!--- page to load within account --->
<cfparam name="refreshApp" default="false"> 	<!--- Force a reload and parse of the HomePortals application --->
<!----------------------------------->

<!------- Application Root ----------->
<!--- This variable must point to the root directory of the application --->
<!--- if not specified on the calling template, then it defaults to the current directory. --->
<cfparam name="request.appRoot" default="#GetDirectoryFromPath(cgi.script_Name)#"> 	
<!----------------------------------->

<cfsilent>
<cfscript>
	// Initialize application if requested or needed
	if((isBoolean(refreshApp) and refreshApp) or Not StructKeyExists(application, "homePortals")) {
		application.homePortals = CreateObject("component","Home.Components.homePortals").init(request.appRoot);
		refreshApp = true;
	}
	hp = application.homePortals;

	// load and parse page
	request.oPageRenderer = hp.loadPage(account, page);

	// render page html
	html = request.oPageRenderer.renderPage();
	
	stHPTimers = application.homePortals.getTimers();
	stCTimers = application.homePortals.getCatalog().getTimers();
	stPRTimers = request.oPageRenderer.getTimers();
</cfscript>
</cfsilent>

<cfoutput>
	<html>
		<head>
			<title>HP3 - Debug Panel</title>
			<style type="text/css">
				body {
					font-size:11px;
					font-family:arial;
				}
				table {
					width:500px;
					border-collapse:collapse;
					border:1px solid silver;
				}
				th {
					font-weight:bold;
					text-align:left;
					background-color:##ebebeb;
				}
				td, th {
					padding:2px;
				}
			</style>
		</head>
		<body>
			<h2>HP3 - Debug Panel</h2>

			<table border="1">
				<tr><th colspan="2">Application:</th></tr>
				<tr>
					<td width="130"><b>App Root:</b></td>
					<td>#request.appRoot#</td>
				</tr>
				<tr>
					<td width="130"><b>Acounts Root:</b></td>
					<td>#hp.getAccountsService().getConfig().getAccountsRoot()#</td>
				</tr>
				<tr>
					<td width="130"><b>Resources Root:</b></td>
					<td>#hp.getConfig().getResourceLibraryPath()#</td>
				</tr>
				<tr>
					<td width="130"><b>HP Engine Version:</b></td>
					<td>#hp.getVersion()#</td>
				</tr>
			</table>
			<br><br>

			<table border="1">
				<tr><th colspan="2">Current Page:</th></tr>
				<tr>
					<td width="130"><b>Title:</b></td>
					<td>#request.oPageRenderer.getPageTitle()#</td>
				</tr>
				<tr>
					<td><b>HREF:</b></td>
					<td>#request.oPageRenderer.getPageHREF()#</td>
				</tr>
				<tr>
					<td><b>Owner:</b></td>
					<td>#request.oPageRenderer.getOwner()#</td>
				</tr>
				<tr>
					<td><b>Access:</b></td>
					<td>#request.oPageRenderer.getAccess()#</td>
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
				<cfif refreshApp>
					<tr>
						<td width="10" align="right"><b>#row#.</b></td>
						<td><em><b>Engine Initialization</b></em></td>
						<td align="right" width="50"><b>#stHPTimers.init#</b></td>
					</tr>
					<cfset row = row + 1>
					<tr>
						<td width="10" align="right"><b>#row#.</b></td>
						<td>+----<em>Catalog Initialization</em></td>
						<td align="right">#stCTimers.init#</td>
					</tr>
					<cfset row = row + 1>
					<tr>
						<td width="10" align="right"><b>#row#.</b></td>
						<td>+--------<em>Rebuild Catalog</em></td>
						<td align="right">#stCTimers.rebuildcatalog#</td>
					</tr>
					<cfset row = row + 1>
					<cfset pageTotalTime = pageTotalTime + stHPTimers.init>
				</cfif>
				<tr>
					<td width="10" align="right"><b>#row#.</b></td>
					<td><b><em>Page Loading</em></b></td>
					<td align="right"><b>#stHPTimers.loadpage#</b></td>
				</tr>
				<cfset row = row + 1>
				<cfset pageTotalTime = pageTotalTime + stHPTimers.loadpage>
				<tr>
					<td width="10" align="right"><b>#row#.</b></td>
					<td>+----<em>Load Page Renderer</em></td>
					<td align="right">#stHPTimers.loadPageRenderer#</td>
				</tr>
				<cfset row = row + 1>
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
				<cfloop collection="#stPRTimers#" item="key">
					<cfif listLen(key,"_") gt 1>
						<tr>
							<td width="10" align="right"><b>#row#.</b></td>
							<td>#listLast(key,"_")#</td>
							<td align="right">#stPRTimers[key]#</td>
						</tr>
						<cfset row = row + 1>
					</cfif>
				</cfloop>
			</table>			

		</body>
	</html>
</cfoutput>

<cffunction name="abort">
	<cfabort>
</cffunction>
<cffunction name="dump">
	<cfargument name="data" type="any">
	<cfdump var="#arguments.data#">
</cffunction>
