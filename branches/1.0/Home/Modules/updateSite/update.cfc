<cfcomponent name="update" displayname="update" hint="HomePortals Update webservice">

	<!--- call constructor --->
	<cfset init()>
	
	<cffunction name="getPackagesList" hint="Retrieves a list of packages available for download" access="remote" output="false" returntype="query">
		<cfscript>
			var qry = QueryNew("href,name,description,version,dateAdded");
			
			if(StructKeyExists(this.xmlDoc.xmlRoot,"packageList")) {
				aRes = this.xmlDoc.xmlRoot.packageList.xmlChildren;
				for(i=1;i lte ArrayLen(aRes);i=i+1) {
					QueryAddRow(qry);
					QuerySetCell(qry,"href",aRes[i].xmlAttributes.href);
					QuerySetCell(qry,"name",aRes[i].xmlAttributes.name);
					QuerySetCell(qry,"description",aRes[i].xmlText);
					QuerySetCell(qry,"dateAdded",aRes[i].xmlAttributes.dateAdded);
					QuerySetCell(qry,"version",aRes[i].xmlAttributes.version);
				}
			}
		</cfscript>
		<cfreturn qry />
	</cffunction>

	<cffunction name="downloadPackage" hint="downloads a package" access="remote" output="false" returntype="boolean">
		<cfargument name="PackageHREF" type="string" hint="HREF of the package" required="true" />

		<!--- check that the requested HREF exists on the repository catalog --->
		<cfset qryRes = this.getPackagesList()>
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qryRes
				WHERE href = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PackageHREF#">
		</cfquery>
		<cfif qry.recordCount eq 0>
			<cfthrow message="The requested package does not exist on the repository catalog.">
		</cfif>

		<!--- check that the requested file exists on the repository --->
		<cfset tmpPkgFile = ExpandPath("packages/#qry.href#")>
		<cfif Not FileExists(tmpPkgFile)>
			<cfthrow message="The requested package does not exist on the repository.">
		</cfif>
		
		<!--- send package --->
		<cfcontent type="application/zip" file="#tmpPkgFile#">
		
		<cfreturn true>
	</cffunction>

	<cffunction name="getInfo" hint="Returns information about this Update site" access="remote" output="true" returntype="struct">
		<cfset var stInfo = StructNew()>
		<cfset stInfo.name = this.xmlDoc.xmlRoot.info.name.xmlText>
		<cfset stInfo.description = this.xmlDoc.xmlRoot.info.description.xmlText>
		<cfreturn stInfo />
	</cffunction>

	<!--- /*************************** Private Methods **********************************/ --->

	<!--- ************************************ --->
	<!--- * init   				 	       * --->
	<!--- ************************************ --->
	<cffunction name="init" access="private" hint="Initializes the update webservice.">
		<cfscript>
			var tmpXML = "";
			var xmlWSConfigDoc = 0;

			// ***** Get update webservice config file ******
			tmpXML = readFile(ExpandPath("update-config.xml"));
			if(Not IsXML(tmpXML)) throw("The update config file is not a valid XML document.");
			xmlWSConfigDoc = xmlParse(tmpXML);
			
			// find the location of the UpdateSite config file
			if(StructKeyExists(xmlWSConfigDoc.xmlRoot,"homeRoot")) {
				tmpPkgFile = xmlWSConfigDoc.xmlRoot.homeRoot.xmlText & "Config/updateSite-config.xml";
				this.packagesFile = ExpandPath(tmpPkgFile);
			} else {
				throw("The update web-service config file is corrupted.");
			}
		
			// ***** Get UpdateSite config file ******
			tmpXML = readFile(this.packagesFile);
			if(Not IsXML(tmpXML)) throw("The packages file is not a valid XML document.");
			this.xmlDoc = xmlParse(tmpXML);
		</cfscript>
	</cffunction>

	<!--- ************************************ --->
	<!--- * readFile						 * --->
	<!--- ************************************ --->
	<cffunction name="readFile" returntype="string" access="private" hint="reads a file from the filesystem and returns its contents">
		<cfargument name="file" type="string">
		<cftry>
			<cffile action="read" file="#arguments.file#" variable="tmp"> 
			
			<cfcatch type="any">
				<cfif cfcatch.Type eq "Application" and FindNoCase("FileNotFound",cfcatch.Detail)>
					<cfset throw("The requested file [#arguments.file#] does not exist.")>
				<cfelse>
					<cfrethrow>
				</cfif>
			</cfcatch>
		</cftry>
		<cfreturn tmp>
	</cffunction>

	<!--- ************************************ --->
	<!--- * throw						 	 * --->
	<!--- ************************************ --->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>
	
</cfcomponent>