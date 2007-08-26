<cfcomponent name="members" extends="xmlDataStore">

	<cfset variables.xmlDocURL = "/xilya/config/members.xml">
	<cfset variables.xmlDoc = 0>

	<cffunction name="init" returntype="members" access="public">
		<cfargument name="xmlDocURL" type="string" required="false" default="">
		
		<cfif arguments.xmlDocURL neq "">
			<cfset variables.xmlDocURL = arguments.xmlDocURL>
		</cfif>
		
		<cfset super.init(variables.xmlDocURL, "firstName,middleName,lastName,email,password,type,accountID", "memberID")>
	
		<cfreturn this>
	</cffunction>

	<cffunction name="getByAccountID" access="public" returntype="query">
		<cfargument name="accountID" type="string" required="true">

		<cfset var qry = getAll()>
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qry
				WHERE AccountID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.accountID#">
		</cfquery>

		<cfreturn qry>
	</cffunction>


</cfcomponent>