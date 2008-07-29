<!--- Proxy.cfm 
This file is a proxy for server-side calls from the client when the target server is on 
a different domain. Security limitations of javascript does not allow XMLHttpRequest to
make requests to different domains. So what this proxy does, is receive the request
for the server side call and make it through an http request, returning the results
to the client --->

<cfparam name="url._server" default=""> 

<!--- this is to avoid caching --->
<meta http-equiv="Expires" content="0">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<cfheader name="Expires" value="0">
<cfheader name="Pragma" value="no-cache">
<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
	
<cftry>
	<!--- make an http to the target server --->
	<cfset tmpURL = "">
	<cfloop collection="#url#" item="arg">
		<cfif left(arg,1) neq "_" and arg neq "EXTEND">
			<cfset tmpURL = ListAppend(tmpURL, arg & "=" & url[arg],"&")> 
		</cfif>
	</cfloop>

	<cfhttp method="get" url="#url._server#?#tmpURL#" throwonerror="no">
	</cfhttp>
	
	<!---- output results ---->
	<cfset WriteOutput(cfhttp.FileContent)>

	<!--- error handling --->
	<cfcatch type="any">
		<cfinclude template="/home/common/templates/error.cfm">
	</cfcatch>
</cftry>