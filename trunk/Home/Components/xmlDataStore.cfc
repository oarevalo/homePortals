<cfcomponent name="members">

	<cfset variables.xmlDocURL = "">
	<cfset variables.xmlDoc = 0>
	<cfset variables.lstFields = "">
	<cfset variables.pkName = "">
	<cfset variables.xmlDocCopy = 0>

	<cffunction name="init" returntype="members" access="public">
		<cfargument name="xmlDocURL" type="string" required="true">
		<cfargument name="lstFields" type="string" required="true">
		<cfargument name="pkName" type="string" required="true">
		
		<cfset variables.xmlDocURL = arguments.xmlDocURL>
		<cfset variables.lstFields = arguments.lstFields>
		<cfset variables.pkName = arguments.pkName>
		
		<cfif fileExists(expandPath(variables.xmlDocURL))>
			<cfset variables.xmlDoc = xmlParse(expandPath(variables.xmlDocURL))>
		<cfelse>
			<cfset variables.xmlDoc = xmlNew()>
			<cfset variables.xmlDoc.xmlRoot = xmlElemNew(variables.xmlDoc,"data")>
		</cfif>
		
		<cfset variables.xmlDocCopy = duplicate(variables.xmlDoc)>

		<cfreturn this>
	</cffunction>

	<cffunction name="getAll" returntype="query" access="public">
		<cfscript>
			var qry = QueryNew(listAppend(variables.lstFields,variables.pkName));
			var aFields = listToArray(variables.lstFields);
			var i = 0;
			var j = 0;
			var xmlNode = 0;

			for(i=1;i lte arrayLen(variables.xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = variables.xmlDoc.xmlRoot.xmlChildren[i];
				queryAddRow(qry);
				querySetCell(qry, variables.pkName, xmlNode.xmlAttributes.id);

				for(j=1;j lte arrayLen(aFields);j=j+1) {

					if(structKeyExists(xmlNode, aFields[j])) {
						querySetCell(qry, aFields[j], xmlNode[aFields[j]].xmlText);
					}

				}			
			}
			
			return qry;
		</cfscript>
	</cffunction>
	
	
	<cffunction name="get" returntype="query" access="public">
		<cfargument name="ID" type="string" required="true">
		<cfset qry = getAll()>
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qry
				WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pkName#">
		</cfquery>
		<cfreturn qry>
	</cffunction>
	

	<cffunction name="delete" returntype="void" access="public">
		<cfargument name="ID" type="string" required="true">
		<cfscript>
			var i = 0;
			var xmlNode = 0;
			
			variables.xmlDocCopy = duplicate(variables.xmlDoc);

			for(i=1;i lte arrayLen(variables.xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = variables.xmlDoc.xmlRoot.xmlChildren[i];
				if(xmlNode.xmlAttributes.ID eq arguments.ID) {
					arrayDeleteAt(variables.xmlDoc.xmlRoot.xmlChildren, i);
					break;
				}
			}
		</cfscript>
	</cffunction>
	

	<cffunction name="save" returntype="string" access="public">
		<cfargument name="ID" type="string" required="true">
		
		<cfscript>
			var xmlNode = 0;
			var aFields = listToArray(variables.lstFields);

			variables.xmlDocCopy = duplicate(variables.xmlDoc);
			
			if(arguments.ID eq "") {
				arguments.ID = createUUID();
				xmlNode = xmlElemNew(variables.xmlDoc,"record");
				xmlNode.xmlAttributes["ID"] = arguments.ID;

				for(i=1;i lte arrayLen(aFields);i=i+1) {
					xmlFieldNode = xmlElemNew(variables.xmlDoc, aFields[i]);
					xmlFieldNode.xmlText = arguments[aFields[i]];
					arrayAppend(xmlNode.xmlChildren, xmlFieldNode);
				}

				arrayAppend(variables.xmlDoc.xmlRoot.xmlChildren, xmlNode);

			} else {
			
				for(i=1;i lte arrayLen(variables.xmlDoc.xmlRoot.xmlChildren);i=i+1) {
					xmlNode = variables.xmlDoc.xmlRoot.xmlChildren[i];
					if(xmlNode.xmlAttributes.ID eq arguments.ID) {
						for(i=1;i lte arrayLen(aFields);i=i+1) {
							xmlNode[aFields[i]].xmlText = arguments[aFields[i]];
						}
						break;
					}
				}
				if(xmlNode eq 0) throw("ID Not found");
			}
	
			return arguments.ID;
		</cfscript>
	</cffunction>


	<cffunction name="commit" access="public" returntype="void">
		<cffile action="write" file="#expandPath(variables.xmlDocURL)#" output="#toString(variables.xmlDoc)#">
	</cffunction>

	<cffunction name="rollback" access="public" returntype="void">
		<cfset variables.xmlDoc = duplicate(variables.xmlDocCopy)>
	</cffunction>

	<cffunction name="destroy" access="public" returntype="void">
		<cffile action="delete" file="#expandPath(variables.xmlDocURL)#">
	</cffunction>

	<cffunction name="throw" access="private" returntype="void">
		<cfargument name="message" type="string" required="true">
		<cfthrow message="#arguments.message#">
	</cffunction>

	<cffunction name="dump" access="private" returntype="void">
		<cfargument name="data" type="any" required="true">
		<cfdump var="#arguments.data#">
	</cffunction>

	<cffunction name="abort" access="private" returntype="void">
		<cfabort>
	</cffunction>

</cfcomponent>