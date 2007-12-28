<!--- Init variables and Params --->
<cfparam name="Attributes.Module" default="#StructNew()#">

<cfset currentHome = session.homeConfig.href>
<cfset siteOwner = ListGetAt(session.homeConfig.href, 2, "/")>
<cfset dir = "/accounts/" & siteOwner & "/layouts">

<cfdirectory directory="#expandpath(dir)#" action="list" name="qryDir" filter="*.xml">
<cfquery name="qryDir" dbtype="query">
	SELECT * 
		FROM qryDir 
		WHERE Name <> '.' AND Name <> '..'
		ORDER BY Type,Name 
</cfquery>

<cfoutput>
	<select name="selHome" 
			onChange="if(this.value!='') document.location='Home.cfm?CurrentHome='+this.value">
		<option value="">--- Select New Page ---</option>
		<cfloop query="qryDir">
			<cfset tmpLabel = Left(qryDir.Name, Len(qryDir.Name)-4)>
			<option value="/accounts/#siteOwner#/layouts/#Name#" 
					<cfif qryDir.Name eq currentHome>selected</cfif>
					>#tmpLabel#</option>
		</cfloop>
	</select>
</cfoutput>

