<cfcomponent>
	<cfset this.menuXML = "menu.xml">

	<cffunction name="get" returntype="query" hint="returns a query with all menu options">
		<cfset var qry = QueryNew("optionGroup,label,view")>
		<cfset var xmlDoc = readMenuXML()>
		
		<cfloop from="1" to="#arrayLen(xmlDoc.xmlRoot.xmlChildren)#" index="i">
			<cfset thisNode = xmlDoc.xmlRoot.xmlChildren[i]>
			<cfset thisOptionGroup = thisNode.xmlAttributes.label>
			<cfloop from="1" to="#arrayLen(thisNode.xmlChildren)#" index="j">
				<cfset QueryAddRow(qry)>
				<cfset QuerySetCell(qry,"optionGroup",thisOptionGroup)>
				<cfset QuerySetCell(qry,"label",thisNode.xmlChildren[j].xmlAttributes.label)>
				<cfset QuerySetCell(qry,"view",thisNode.xmlChildren[j].xmlAttributes.view)>
			</cfloop>
		</cfloop>
			
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="createOptionGroup" hint="Creates a new option group">
		<cfargument name="ID" type="string" required="true">
		<cfargument name="label" type="string" required="true">
		<cfscript>
			var xmlDoc = readMenuXML();
			var tmpIndex = 0;

			// check if this option group already exists
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				if(xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.label eq arguments.label) {
					tmpIndex = i;	
					break;
				}
			}
			
			// only create group if it doesn't exist
			if(tmpIndex eq 0) {
				// append node
				ArrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc,"optionGroup") );
				tmpIndex = ArrayLen(xmlDoc.xmlRoot.xmlChildren);
				
				tmpOptionGroupNode = xmlDoc.xmlRoot.xmlChildren[tmpIndex];
				tmpOptionGroupNode.xmlAttributes["label"] = arguments.label;	
				tmpOptionGroupNode.xmlAttributes["ID"] = arguments.ID;	
			}
			
			// save changes
			saveMenuXML(xmlDoc);		
		</cfscript>
	</cffunction>

	<cffunction name="createOption" hint="Creates a new option within a group">
		<cfargument name="optionGroup" type="string" required="true">
		<cfargument name="label" type="string" required="true">
		<cfargument name="view" type="string" required="true">
		<cfscript>
			var xmlDoc = readMenuXML();
			var tmpIndex = 0;

			// find requested option group
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				if(xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.label eq arguments.optionGroup) {
					tmpIndex = i;	
					break;
				}
			}
			
			if(tmpIndex gt 0) {
				tmpOptionGroupNode = xmlDoc.xmlRoot.xmlChildren[tmpIndex];
				ArrayAppend(tmpOptionGroupNode.xmlChildren, xmlElemNew(xmlDoc,"option") );
				tmpIndex = ArrayLen(tmpOptionGroupNode.xmlChildren);
				tmpOptionGroupNode.xmlChildren[tmpIndex].xmlAttributes["label"] = arguments.label;
				tmpOptionGroupNode.xmlChildren[tmpIndex].xmlAttributes["view"] = arguments.view;
			}

			// save changes
			saveMenuXML(xmlDoc);		
		</cfscript>
	</cffunction>

	<cffunction name="removeOptionGroup" hint="Removes the option group with the given ID">
		<cfargument name="ID" type="string" required="true">
		<cfscript>
			var xmlDoc = readMenuXML();

			// check if this option group already exists
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				if(xmlDoc.xmlRoot.xmlChildren[i].xmlAttributes.ID eq arguments.ID) {
					ArrayDeleteAt(xmlDoc.xmlRoot.xmlChildren,i);
					break;
				}
			}
			
			// save changes
			saveMenuXML(xmlDoc);		
		</cfscript>		
	</cffunction>


	<!----------------------------->
	<!--- Private Methods      ---->
	<!----------------------------->
	<cffunction name="readMenuXML" returntype="any" access="private" hint="Returns the xml document for the menu file">
		<cfset var xmlDoc = "">
		<cffile action="read" file="#expandPath(this.menuXML)#" variable="txtDoc">
		<cfset xmlDoc = xmlParse(txtDoc)>
		<cfreturn xmlDoc>
	</cffunction>

	<cffunction name="saveMenuXML" access="private" hint="Saves the xml document for the menu file">
		<cfargument name="xmlDoc" type="any" required="true">
		<cfif isxmlDoc(arguments.xmlDoc)>
			<cffile action="write" output="#toString(arguments.xmlDoc)#" file="#expandPath(this.menuXML)#">
		<cfelse>
			<cfthrow message="The parameter passed to this function is not a valid xml document">
		</cfif>
	</cffunction>
	
</cfcomponent>