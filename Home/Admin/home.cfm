<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>HomePortals Administrator</title>
		<link href="style.css" rel="stylesheet" type="text/css">
		<script src="main.js" type="text/javascript"></script>
	</head>

<body>
	<cfoutput>
		<table width="100%"  border="0" cellpadding="0" cellspacing="0" id="header">
		  <tr valign="top">
			<td style="padding:4px;font-size:18px;">
				HomePortals Administrator
			</td>
			<td align="right" valign="middle" style="padding-right:20px;font-size:16px;font-weight:bold;">
				#LSDateFormat(now())#<br>
				<a href="home.cfm?resetApp=1" style="font-size:12px;"><b>Log Off</b></a>
			</td>
		  </tr>
		</table>
	
		<table>
			<tr valign="top">
				<td width="150" class="mainMenuList">
					<!--- menu --->
					<cfinclude template="includes/mainMenu.cfm">
				</td>
				<td>
					<!--- view --->
					<cfif appState.errMessage neq "">
						<p style="font-weight:bold;color:##990000;margin:20px;" align="center"><cfoutput>#appState.errMessage#</cfoutput></p>
						<cfset session.appState.errMessage = "">
					</cfif>			
					<cfif appState.infoMessage neq "">
						<p style="font-weight:bold;color:##006600;margin:20px;" align="center"><cfoutput>#appState.infoMessage#</cfoutput></p>
						<cfset session.appState.infoMessage = "">
					</cfif>			
					<cfinclude template="views/#currentView.href#">
				</td>
			</tr>
		</table>
	</cfoutput>
</body>
</html>
