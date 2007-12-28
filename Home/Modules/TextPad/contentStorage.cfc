<cfcomponent displayname="ContentStorage">

	<cfset this.docURL = "">
	<cfset this.xmlDoc = "">
	<cfset this.owner = "">

	<!--- public methods --->
	<cffunction name="init" access="public">
		<cfargument name="owner" type="string" required="true">
		<cfargument name="storageURL" type="string" required="true">
		<cfargument name="createStorage" type="boolean" required="false" default="true">
		
		<cfset var bStorageExists = false>
		
		<cfset this.owner = arguments.owner>
		<cfset this.docURL = arguments.storageURL>
		
		<!--- if not storageURL is given, then use the default storage --->
		<cfif this.docURL eq "">
			<cfset this.docURL = "/accounts/" & this.owner & "/myContent.xml">
		</cfif>
					
		<!--- check if storageURL exists --->
		<cfset bStorageExists = FileExists(ExpandPath(this.docURL))>
			
		<!--- if doesnt exist and createStorage flag is on, then create it else throw error --->
		<cfif Not bStorageExists>
			<cfif arguments.createStorage>
				<cfset createStorageDoc()>
				<cfset saveStorageDoc()>
			<cfelse>
				<cfthrow message="The given storage URL does not exist. Please provide the URL of an existing storage location.">
			</cfif>
		</cfif>
		
		<!--- read and parse storage document --->
		<cfset readStorageDoc()>
	</cffunction>

	<cffunction name="saveEntry" access="public">
		<cfargument name="ID" type="string" required="true" hint="The entry ID of the entry to update. If inserting a new one, leave empty.">
		<cfargument name="NewID" type="string" required="true" hint="The entry ID to save. Use this field to update the ID of an existing entry or to indicate the ID of a new entry">
		<cfargument name="content" type="string" default="" hint="actual content to save">

		<cfset myContent = xmlSearch(this.xmlDoc,"//content[@id='#Arguments.ID#']")>
		
		<cfif arguments.NewID eq "">
			<cfthrow message="The title for the new entry cannot be empty.">	
		</cfif>
		
		<cfif ArrayLen(myContent) gt 0>
			<cfset myContent[1].xmlText = Arguments.content>
			<cfset myContent[1].xmlAttributes.id = Arguments.NewID>
		<cfelse>
			<cfset newIndex = ArrayLen(this.xmlDoc.xmlRoot.xmlChildren)+1>
			<cfset this.xmlDoc.xmlRoot.xmlChildren[newIndex] = xmlElemNew(this.xmlDoc,"content")>
			<cfset this.xmlDoc.xmlRoot.xmlChildren[newIndex].xmlText = arguments.content>
			<cfset this.xmlDoc.xmlRoot.xmlChildren[newIndex].xmlAttributes["id"] = arguments.NewID>
		</cfif>
		
		<cfset saveStorageDoc()>
	</cffunction>
	
	<cffunction name="deleteEntry" access="public">
		<cfargument name="ID" type="string" required="true" hint="The entry ID of the entry to delete">
		<cfscript>
			tmpNode = this.xmlDoc.xmlRoot;
			for(i=1;i lte ArrayLen(tmpNode.xmlChildren);i=i+1) {
				if(tmpNode.xmlChildren[i].xmlAttributes.id eq arguments.ID)
					ArrayClear(tmpNode.xmlChildren[i]);
			}	
			saveStorageDoc();			
		</cfscript>
	</cffunction>

	<cffunction name="getEntry" access="public" returntype="struct">
		<cfargument name="ID" type="string" required="true" hint="The entry ID of the entry to retrieve">
		
		<cfset var stTemp = StructNew()>
		<cfset stTemp.id = "">
		<cfset stTemp.content = "">
		<cfset stTemp.found = false>

		<cfset myContent = xmlSearch(this.xmlDoc,"//content[@id='#Arguments.ID#']")>
		
		<cfif ArrayLen(myContent) gt 0>
			<cfset stTemp.id = arguments.id>
			<cfset stTemp.content = myContent[1].xmlText>
			<cfset stTemp.found = true>
		</cfif>
		
		<cfreturn stTemp>		
	</cffunction>

	<cffunction name="getIndex" access="public" returntype="query">
		<cfset var qry = QueryNew("ID")>
		<cfset var aContents = xmlSearch(this.xmlDoc,"//content")>
		
		<cfloop from="1" to="#ArrayLen(aContents)#" index="i">
			<cfset QueryAddRow(qry)>
			<cfset QuerySetCell(qry,"ID",aContents[i].xmlAttributes.id)>
		</cfloop>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getOwner" access="public" returntype="string">
		<cfreturn this.owner>
	</cffunction>

	<cffunction name="getCreateDate" access="public" returntype="string">
		<cfreturn this.xmlDoc.xmlRoot.xmlAttributes.createdOn>
	</cffunction>

	<cffunction name="getStorageURL" access="public" returntype="string">
		<cfreturn this.docURL>
	</cffunction>

	<!--- private methods --->
	<cffunction name="createStorageDoc" access="private">
		<cfset this.xmlDoc = xmlNew()>
		<cfset this.xmlDoc.xmlRoot = xmlElemNew(this.xmlDoc, "editBoxes")>
		<cfset this.xmlDoc.xmlRoot.xmlAttributes["owner"] = this.owner>
		<cfset this.xmlDoc.xmlRoot.xmlAttributes["createdOn"] = GetHTTPTimeString(now())>
	</cffunction>

	<cffunction name="saveStorageDoc" access="private">
		<cffile action="write" file="#ExpandPath(this.docURL)#" output="#toString(this.xmlDoc)#">
	</cffunction>

	<cffunction name="readStorageDoc" access="private">
		<cfset var txtDoc = "">
		
		<cffile action="read" file="#ExpandPath(this.docURL)#" variable="txtDoc">

		<!--- check that the given file is a valid xml --->
		<cfif not IsXML(txtDoc)>
			<cfthrow message="The given storage document is not valid xml.">
		<cfelse>
			<cfset this.xmlDoc = xmlParse(txtDoc)>
		</cfif>

		<!--- if the storage file has already an owner, then set the current owner to the one on the storage --->
		<cfif StructKeyExists(this.xmlDoc.xmlRoot.xmlAttributes,"owner")>
			<cfset this.owner = this.xmlDoc.xmlRoot.xmlAttributes.owner>
		<cfelse>
			<!--- storage doesnt have an owner, so we will claim it --->
			<cfset this.xmlDoc.xmlRoot.xmlAttributes.owner = this.owner>
		</cfif> 

		<!--- set a default created on date --->
		<cfif Not StructKeyExists(this.xmlDoc.xmlRoot.xmlAttributes,"createdOn")>
			<cfset this.xmlDoc.xmlRoot.xmlAttributes.createdOn = GetHTTPTimeString(CreateDate(2000,1,1))>
		</cfif> 	
	</cffunction>

</cfcomponent>