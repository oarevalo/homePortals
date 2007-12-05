<!--- gateway.cfm

This file is a gateway for calls to server-side components. 

---->

<cfparam name="_server" default=""> 
<cfparam name="method" default="">

<!--- this is to avoid caching --->
<meta http-equiv="Expires" content="0">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<cfheader name="Expires" value="0">
<cfheader name="Pragma" value="no-cache">
<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
	
<cftry>
	<cfscript>
		stRequest = structNew();
		stRequest = form;
		structAppend(stRequest, url);
		
		// transform server path into dot notation 
		reqServer = stRequest._server;
		if(find("/",reqServer) gt 0 and findNoCase(".cfc",reqServer) gt 0) {
			reqServer = replace(reqServer,"/",".","ALL");
			reqServer = listDeleteAt(reqServer, listLen(reqServer,"."), ".");
			if(left(reqServer,1) eq ".") {
				reqServer = right(reqServer,len(reqServer)-1);
			}
		}
		
	</cfscript>
	
	<!--- create and execute call --->
	<cfsavecontent variable="tmp">
		<cfinvoke component="#reqServer#" 
				  returnvariable="obj" 
				  method="#stRequest.method#" 
				  argumentcollection="#stRequest#" />
	</cfsavecontent>
	
	<!---- output results ---->
	<cfset WriteOutput(tmp)>

	<!--- error handling --->
	<cfcatch type="any">
		<cfinclude template="error.cfm">
	</cfcatch>
</cftry>