<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>HomePortals Administrator</title>
		<link href="style.css" rel="stylesheet" type="text/css">
	</head>

<body>

<table width="100%"  border="0" cellpadding="0" cellspacing="0" id="header">
  <tr valign="top">
	<td style="padding:4px;font-size:18px;">
		HomePortals Administrator
	</td>
  </tr>
</table>
	
<cfif appState.errMessage neq "">
	<p style="font-weight:bold;color:#990000;margin:20px;" align="center"><cfoutput>#appState.errMessage#</cfoutput></p>
	<cfset session.appState.errMessage = "">
</cfif>	
					
<table align="center">
<tr>
<td>
<form name="frmLogin" method="post" action="home.cfm" id="frmLogin">
	<p>
		Password: <input name="password" type="password" id="password">
	</p>
	<p>
		<input type="submit" name="Submit" value="Login">
		<input type="hidden" name="view" value="login">
		<input name="event" type="hidden" id="event" value="login">
	</p>
</form>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>
	If you have not setup your license key, plase <a href="../license.cfm">Click Here</a>
</p>
</td>
</tr>
</table>