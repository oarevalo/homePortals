<!--- controlPanelGateway.cfm

This file is a gateway for calls to the Xilya control panel

---->

<cfparam name="method" default="">
<cfparam name="_pageHREF" default="">

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
		
		oControlPanel = createObject("component","controlPanel").init(stRequest["_pageHREF"]);
	</cfscript>
	
	<!--- create and execute call --->
	<cfsavecontent variable="tmp">
		<cfinvoke component="#oControlPanel#" 
				  returnvariable="obj" 
				  method="#stRequest.method#" 
				  argumentcollection="#stRequest#" />
	</cfsavecontent>
	
	<!---- output results ---->
	<cfset WriteOutput(tmp)>

	<!--- error handling --->
	<cfcatch type="lock">
		<cfinclude template="error.cfm">
	</cfcatch>
</cftry>