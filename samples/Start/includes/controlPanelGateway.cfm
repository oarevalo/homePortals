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
	<cfsilent>
		<cfscript>
			hp = application.homePortals;
	
			stRequest = structNew();
			stRequest = form;
			structAppend(stRequest, url);
			
			if(not structKeyExists(stRequest, "_pageHREF")) stRequest["_pageHREF"] = "";
			if(not structKeyExists(stRequest, "method")) stRequest.method = "";
			
			oControlPanel = createObject("component","controlPanel").init(hp, stRequest["_pageHREF"]);
		</cfscript>
	</cfsilent>
	
	<!--- create and execute call --->
	<cfif stRequest.method neq "">
		<cfsavecontent variable="tmp">
			<cfinvoke component="#oControlPanel#" 
					  returnvariable="obj" 
					  method="#stRequest.method#" 
					  argumentcollection="#stRequest#" />
		</cfsavecontent>
	<cfelse>
		<cfset tmp = "">
	</cfif>
	
	<!---- output results ---->
	<cfset WriteOutput(tmp)>

	<!--- error handling --->
	<cfcatch type="any">
		<cfinclude template="error.cfm">
	</cfcatch>
</cftry>
