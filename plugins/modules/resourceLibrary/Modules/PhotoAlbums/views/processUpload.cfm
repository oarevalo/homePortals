<html>
	<head>
		<style type="text/css">
			body {
				font-family:arial;
				font-size:11px;
			}
		</style>
	</head>
	<body>
		<cfoutput>
			Uploading files:<br>
			<cfloop list="#arguments.fieldNames#" index="fld">
				<cfif left(fld, 5) eq "FILE_" and arguments[fld] neq "">
					<cfset stFile = upload(arguments.albumName, fld)>
					<li>#stFile.serverFile#</li>
				</cfif>
			</cfloop>
			<br />
			<b>Upload Complete.</b>
		</cfoutput>
	</body>
</html>
