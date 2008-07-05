<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<!--- this is a reference to the homeportals application instance,
	it is done as a cfparam to allow the caller to override the reference
	when storing in on a different place --->
<cfparam name="HOMEPORTALS_INSTANCE" default="#application.homePortals#">

<cfparam name="action" default="">
<cfparam name="cacheName" default="">

<!--- get reference to cache registry --->
<cfset oCacheRegistry = createObject("component","Home.Components.cacheRegistry").init()>
<cfset tmpMsg = "">

<!--- Process Actions --->
<cfswitch expression="#action#">
	<cfcase value="clear">
		<cfset oCacheRegistry.flush(cacheName)>
		<cfset tmpMsg = "Cache [#cacheName#] deleted.">
    </cfcase>
    
    <cfcase value="cleanup">
		<cfset oCache = oCacheRegistry.getCache(cacheName)>
		<cfset oCache.cleanup()>    
		<cfset tmpMsg = "Cache [#cacheName#] cleared.">
    </cfcase>
    
	<cfcase value="list">
		<cfset oCache = oCacheRegistry.getCache(cacheName)>
        <cfdump var="#oCache.list()#" label="#cacheName#">
    </cfcase>
</cfswitch>


<!--- get list of caches --->
<cfset lstCaches = oCacheRegistry.getCacheNames()>
<cfset hp = HOMEPORTALS_INSTANCE>

<html>
	<head>
		<title>HomePortals - Cache Manager Tool</title>
		<style type="text/css">
			body {
				font-size:12px;
				font-family:arial;
			}
			table {
				width:500px;
				border-collapse:collapse;
				border:1px solid silver;
			}
			th {
				font-weight:bold;
				background-color:#ebebeb;
			}
			td, th {
				font-size:12px;
				border:1px solid silver;
				padding:2px;
			}
			.msg {
				font-size:13px;
				border:1px solid silver;
				padding:8px;
				background-color:#ffffe1;
				margin-bottom:20px;
			}
		</style>
	</head>
	<body>
		<h1>HomePortals Cache Manager</h1>
		
		<p>
			This tool allows to view and perform operations on all internal caches used by HomePortals.<br>
			<b>IMPORTANT:</b> To use this tool you must include a reference to this file (cacheManager.cfm) 
			into the application where the cache is being used.
		</p>
		
		<cfoutput>
			<cfif tmpMsg neq "">
				<div class="msg">#tmpMsg#</div>
			</cfif>
			
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
					<td>#hp.getConfig().getVersion()#</td>
				</tr>
			</table>
			<br><br>			
			
			<table>
				<tr>
					<th width="10">No.</th>
					<th>Cache Name</th>
					<th>Current Size</th>
					<th>Max Size</th>
					<th>Hit/Miss</th>
					<th>Last Reap</th>
					<th>Actions</th>
				</tr>
				<cfset index = 1>
				<cfloop list="#lstCaches#" index="cacheName">
					<cfset oCache = oCacheRegistry.getCache(cacheName)>
					<cfset stStats = oCache.getStats()>
					<tr>
						<td>#index#.</td>
						<td>#cacheName#</td>
						<td align="right">#stStats.currentSize#</td>
						<td align="right">#stStats.maxSize#</td>
						<td align="right">#stStats.hitCount#/#stStats.missCount#</td>
						<td align="center">
							<cfif stStats.lastReap neq "">
								#lsDateFormat(stStats.lastReap)#<br>#lsTimeFormat(stStats.lastReap)#
							</cfif>
						</td>
						<td align="center">
							[<a href="#cgi.SCRIPT_NAME#?action=list&cacheName=#cacheName#">list</a>]
							<cfif left(cacheName,2) neq "hp">
								[<a href="#cgi.SCRIPT_NAME#?action=clear&cacheName=#cacheName#">clear</a>]
							</cfif>
							[<a href="#cgi.SCRIPT_NAME#?action=cleanup&cacheName=#cacheName#">reap</a>]
						</td>
					</tr>
					<cfset index=index+1>
				</cfloop>
			</table>
		
			<p>
				<a href="#cgi.SCRIPT_NAME#">Refresh</a>
			</p>
		</cfoutput>
	</body>
</html>
		