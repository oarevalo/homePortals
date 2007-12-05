<!--- DebugInfo
This page displays debugging information about the current page 

History:
	11/10/05 - Oscar Arevalo - Created
--->
<cfset tmp = 0>
<cfset timers = oHP.getTimers()>
<cfoutput>
	<style type="text/css">
		##hp_debugInfo {
			padding-left:20px;	
			font-family:Arial, Helvetica, sans-serif;
			font-size:11px;
		}
		.hp_tblDebugInfo {
			border-collapse:collapse;
			font-family:Arial, Helvetica, sans-serif;
			font-size:10px;
			border:1px solid black;
		}
		.hp_tblDebugInfo td, .hp_tblDebugInfo th {
			border:1px solid silver;
			padding:3px;
		}
		.hp_tblDebugInfo th {
			background-color:##FFCC66;
			color:##990000;
		}
	</style>
	
	<hr>	
	<div id="hp_debugInfo">
		<h3>HomePortals Debug Info:</h3>
		
		<p>
			<strong>Current Home:</strong> <a href="#Session.HomeConfig.href#" target="_blank">#Session.HomeConfig.href#</a><br />
			<strong>HomePortals Settings:</strong> <a href="Config/homePortals-config.xml" target="_blank">Config/homePortals-config.xml</a>
		</p>		
		
		<table class="hp_tblDebugInfo">
			<tr><th colspan="2">TIME TAKEN (ms):</th></tr>
			<cfloop collection="#timers#" item="item">
				<tr>
					<td>#item#:</td>
					<td>#timers[item]# ms.</td>
				</tr>
				<cfset tmp = tmp + timers[item]>
			</cfloop>
			<tr>
				<td><strong>TOTAL:</strong></td>
				<td><strong>#tmp# ms.</strong></td>
			</tr>
		</table>

		<br><br>

	</div>
</cfoutput>