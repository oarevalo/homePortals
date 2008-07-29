<!--- gateway.cfm

This file is a gateway for calls to server-side components. 

---->

<cfparam name="url._server" default=""> 
<cfparam name="url.method" default="">

<!--- this is to avoid caching --->
<meta http-equiv="Expires" content="0">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<cfheader name="Expires" value="0">
<cfheader name="Pragma" value="no-cache">
<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
	
<cftry>
	<!--- transform server path into dot notation --->
	<cfset reqServer = url._server>
	<cfif find("/",reqServer) gt 0 and findNoCase(".cfc",reqServer) gt 0>
		<cfset reqServer = replace(reqServer,"/",".","ALL")>
		<cfset reqServer = listDeleteAt(reqServer, listLen(reqServer,"."), ".")>
		
		<cfif left(reqServer,1) eq ".">
			<cfset reqServer = right(reqServer,len(reqServer)-1)>
		</cfif>
	</cfif>

	<!--- create and execute call --->
	<cfsavecontent variable="tmp">
		<cfinvoke component="#reqServer#" returnvariable="obj" method="#url.method#" argumentcollection="#url#" />
	</cfsavecontent>
	
	<!---- output results ---->
	<cfset WriteOutput(tmp)>

	<!--- error handling --->
	<cfcatch type="any">
		<cfinclude template="error.cfm">
	</cfcatch>
</cftry>