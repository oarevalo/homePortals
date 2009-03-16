<cfparam name="action" default="">
<cfparam name="accountsRoot" default="">


<cfoutput>
<html>
	<head>
		<title>HomePortals - Fix Page Owner Tool</title>
	</head>
	<body>
		<h1>Fix Page Owner</h1>
		
		<p>
			This tool sets the correct page owner for all homePortals pages in the given accounts root. 
			The page owner is the account directory containing the page.
		</p>
		
		<form name="frm" method="post" action="#cgi.SCRIPT_NAME#"> 
			
			Accounts Root: 
			<input type="text" name="accountsRoot" value="#accountsRoot#">
			<input type="submit" name="action" value="Go">
			
		</form>
		<hr>
		
		<cfif action eq "Go">
		
			<cfdirectory action="list" directory="#expandPath(accountsRoot)#" name="qryDir">
			
			
			<cfloop query="qryDir">
			
				<cfif qryDir.type eq "Dir">
					<cfset accountName = qryDir.name>
					<cfset pagesDir = accountsRoot & "/" & accountName & "/layouts/">

					<b>#accountName#:</b>
		
					<cfif directoryExists(expandPath(pagesDir))>
			
						<cfdirectory action="list" directory="#expandPath(pagesDir)#" name="qryPages">
						
						#qryPages.recordCount# pages found.<br>
						
						<cfloop query="qryPages">
							#qryPages.name#....
							<cftry>
								<cfset xmlDoc = xmlParse(expandPath(pagesDir & qryPages.name))>
								<cfset xmlDoc.xmlRoot.xmlAttributes["owner"] = accountName>
								<cffile action="write" file="#expandPath(pagesDir & qryPages.name)#" output="#toString(xmlDoc)#">
								Done.<br>
								<cfcatch type="any">
									#cfcatch.message#<br>
								</cfcatch>
							</cftry>
						</cfloop>
						
					<cfelse>
					
						No layout pages found.<br>
					
					</cfif>
					<br>
				</cfif>
				
			</cfloop>
			
		</cfif>
		
	</body>
</html>
</cfoutput>
