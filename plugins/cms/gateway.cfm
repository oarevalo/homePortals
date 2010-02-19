<!--- gateway.cfm

This file acts as a front controller for the CMS functionality

---->

<!--- this is a reference to the homeportals application instance,
	it is done as a cfparam to allow the caller to override the reference
	when storing in on a different place --->
<cfparam name="HOMEPORTALS_INSTANCE" default="">

<cfif isSimpleValue(HOMEPORTALS_INSTANCE) and HOMEPORTALS_INSTANCE eq "" and structKeyExists(application,"homePortals")>
	<cfset HOMEPORTALS_INSTANCE = application.homePortals>
</cfif>

<!--- this is to avoid caching --->
<meta http-equiv="Expires" content="0">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<cfheader name="Expires" value="0">
<cfheader name="Pragma" value="no-cache">
<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
	
<cftry>
	<cfparam name="method" default="">		<!--- the method to execute --->
	<cfparam name="_pageHREF" default="">	<!--- the current page --->
	<cfscript>
		stRequest = structNew();
		stRequest = form;
		structAppend(stRequest, url);
		
		if(not structKeyExists(stRequest, "_pageHREF")) stRequest._pageHREF = "";
		if(not structKeyExists(stRequest, "method")) stRequest.method = "";
		
		oControlPanel = createObject("component","cms").init(HOMEPORTALS_INSTANCE, stRequest._pageHREF);
	</cfscript>
	
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
		<cfinclude template="includes/error.cfm">
	</cfcatch>
</cftry>