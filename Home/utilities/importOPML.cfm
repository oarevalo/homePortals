<cfparam name="action" default="">
<cfparam name="resourceLibraryRoot" default="">
<cfparam name="owner" default="">
<cfparam name="accessType" default="">
<cfparam name="packageName" default="">

<cfset lstAccessTypes = "general,owner,friend">

<cfoutput>
<html>
	<head>
		<title>HomePortals - Import OPML</title>
	</head>
	<body>
		<h1>Import OPML</h1>
		
		<p>
			This tool imports rss feeds from an OPML document and create them as resources.
		</p>
		
		<form name="frm" method="post" action="#cgi.SCRIPT_NAME#"> 
			
			Resource Library Root: 
			<input type="text" name="resourceLibraryRoot" value="#resourceLibraryRoot#"><br>
			Owner:
			<input type="text" name="owner" value="#owner#"><br>
			Access Type:
				<cfloop list="#lstAccessTypes#" index="item">
					<input type="radio" name="accessType" value="#item#"> #item#  &nbsp;&nbsp;&nbsp;&nbsp;
				</cfloop><br>
			Package Name:
			<input type="text" name="packageName" value="#packageName#"><br>

			<input type="submit" name="action" value="Go">
		</form>
		<hr>
	</body>
</html>
</cfoutput>
		