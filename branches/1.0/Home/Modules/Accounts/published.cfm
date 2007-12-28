<!--- Modules.cfm

This module displays a list of available modules on the default catalog
--->
<cfset defaultCatalog = "catalog.xml">

<cffile action="read" file="#expandpath(defaultCatalog)#" variable="txtDoc">
<cfset xmlCatalog = xmlParse(txtDoc)>
<cfset aPages = xmlSearch(xmlCatalog,"//page")>
<cfset qryPages = QueryNew("href,name,description,createdOn,accountName,title")>
<cfset isLoggedIn = (IsDefined("Session.homeConfig") and IsDefined("Session.User.qry"))>
<cfif isLoggedIn>
	<cfset username = session.user.qry.username> 
</cfif> 


<!--- get account config --->
<cfif Not IsDefined("application.HomePortalsAccountsConfig")>
	<cfset objAccounts.loadConfig()>
	<cflock scope="application" type="exclusive" timeout="10">
		<cfset application.HomePortalsAccountsConfig = duplicate(objAccounts.getConfig())>
	</cflock>
<cfelse>
	<cfset objAccounts.setConfig(application.HomePortalsAccountsConfig)>
</cfif>

<!--- get accounts root --->
<cfset accountsRoot = objAccounts.getConfig().accountsRoot>

		
<!--- put all published pages in a query --->
<cfloop from="1" to="#arrayLen(aPages)#" index="i">
	<cfset QueryAddRow(qryPages,1)>
	<cfset QuerySetCell(qryPages, "href", aPages[i].xmlAttributes.href)>
	<cfset QuerySetCell(qryPages, "name", aPages[i].xmlAttributes.name)>
	<cfset QuerySetCell(qryPages, "description", aPages[i].xmlText)>
	<cfif StructKeyExists(aPages[i].xmlAttributes, "createdOn")>
		<cfset QuerySetCell(qryPages, "createdOn", aPages[i].xmlAttributes.createdOn)>
	</cfif>
	<cfif StructKeyExists(aPages[i].xmlAttributes, "title")>
		<cfset QuerySetCell(qryPages, "title", aPages[i].xmlAttributes.title)>
	<cfelse>
		<cfset QuerySetCell(qryPages, "title", aPages[i].xmlAttributes.name)>
	</cfif>
	<cfset QuerySetCell(qryPages, "accountName", ListGetAt(aPages[i].xmlAttributes.href, 2, "/"))>
</cfloop>


<!--- sort pages to show first the most recent --->
<cfquery name="qryPages" dbtype="query" maxrows="100">
	SELECT *
		FROM qryPages
		ORDER BY createdOn DESC
</cfquery>


<!--- display pages --->
<div style="font-family:Arial, Helvetica, sans-serif;">

<b>Shared Pages</b>
<div style="font-size:10px;margin-bottom:10px;margin-top:5px;">
	These pages have been created and shared
	by other users. Add them to your
	account by using the 
	"Add To My Site" button.
</div>

<cfoutput query="qryPages">
	<div style="margin-bottom:5px;border-bottom:1px solid ##FFFFFF;">
		<a href="home.cfm?currentHome=#qryPages.href#"><strong>#ListFirst(qryPages.name,".")#</strong></a>
		<span style="font-size:9px;color:##999999;">
			by <a href="#accountsRoot#/#accountName#">#qryPages.accountName#</a>
			<cfif qryPages.createdOn neq "">
				<br>Published on #DateFormat(qryPages.createdOn,"mmm d")#
			</cfif>
			<cfif description neq "">
				<br>#description#
			</cfif>
			<br><a href="javascript:controlPanel.addPageToCurrentUser('#qryPages.href#','#defaultCatalog#')"><img src="#accountsRoot#/addPage.gif" border="0" alt="Add Page" style="margin-top:3px;margin-bottom:6px;"></a>
			
		</span>
	</div>
</cfoutput>
</div>