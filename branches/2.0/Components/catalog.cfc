<cfcomponent name="catalog" hint="This object provides access to the HomePortals catalog.">

	<cfscript>
		variables.href = "";
		variables.xmlDoc = 0;
		variables.homeRoot = "";
		variables.resInfoFile = "info.xml";
	</cfscript>
	
	<!---------------------------------------->
	<!--- init					           --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="catalog">
		<cfargument name="homeRoot" type="string" required="true" default="/Home/">
		<cfargument name="rebuild" type="boolean" required="false" default="false" hint="Flag to force a rebuild of the catalog. This scans the modules directory to register all modules.">

		<cfscript>
			var tmpXML = "";

			variables.href = arguments.homeRoot & "/Config/catalog.xml";
			variables.homeRoot = arguments.homeRoot;
		
			// check if catalog file exists, if not create it
			if(Not FileExists(expandPath(variables.href))) {
				variables.xmlDoc = xmlNew();
				variables.xmlDoc.xmlRoot = xmlElemNew(variables.xmlDoc,"catalog");
				arguments.rebuild = true;
				save();
			} else {
				variables.xmlDoc = xmlParse(expandPath(variables.href));
			}
			
			// rebuild the catalog if requested
			if(arguments.rebuild) rebuildCatalog();
		</cfscript>
		
		<cfreturn this>
	</cffunction>

	<!---------------------------------------->
	<!--- getModules			           --->
	<!---------------------------------------->	
	<cffunction name="getModules" access="public" returntype="array" output="False"
				hint="Returns all modules in this catalog">
		<cfscript>
			var aModuleNodes = ArrayNew(1);
			var aModules = ArrayNew(1);
			var i=0;
			var stTemp = 0;

			aModuleNodes = xmlSearch(variables.xmlDoc, "//module");
			for(i=1;i lte arrayLen(aModuleNodes);i=i+1) {
				stTemp = duplicate(aModuleNodes[i].xmlAttributes);
				ArrayAppend(aModules, stTemp);
			}
		</cfscript>
		<cfreturn aModules>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getSkins				           --->
	<!---------------------------------------->	
	<cffunction name="getSkins" access="public" returntype="array" output="False"
				hint="Returns all skins in this catalog">
		<cfscript>
			var aSkinNodes = ArrayNew(1);
			var aSkins = ArrayNew(1);
			var i=0;
			var stTemp = 0;

			aSkinNodes = xmlSearch(variables.xmlDoc, "//skin");
			for(i=1;i lte arrayLen(aSkinNodes);i=i+1) {
				stTemp = duplicate(aSkinNodes[i].xmlAttributes);
				ArrayAppend(aSkins, stTemp);
			}
		</cfscript>
		<cfreturn aSkins>
	</cffunction>

	<!---------------------------------------->
	<!--- getPages				           --->
	<!---------------------------------------->	
	<cffunction name="getPages" access="public" returntype="array" output="False"
				hint="Returns all published pages in the catalog">
		<cfscript>
			var aNodes = ArrayNew(1);
			var aReturn = ArrayNew(1);
			var i=0;
			var stTemp = 0;

			aNodes = xmlSearch(variables.xmlDoc, "//page");
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				stTemp = duplicate(aNodes[i].xmlAttributes);
				stTemp.description = aNodes[i].xmlText;
				ArrayAppend(aReturn, stTemp);
			}
		</cfscript>
		<cfreturn aReturn>
	</cffunction>

	<!---------------------------------------->
	<!--- getPageTemplates		           --->
	<!---------------------------------------->	
	<cffunction name="getPageTemplates" access="public" returntype="array" output="False"
				hint="Returns all page templates in the catalog">
		<cfscript>
			var aNodes = ArrayNew(1);
			var aReturn = ArrayNew(1);
			var i=0;
			var stTemp = 0;

			aNodes = xmlSearch(variables.xmlDoc, "//pageTemplate");
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				stTemp = duplicate(aNodes[i].xmlAttributes);
				stTemp.description = aNodes[i].xmlText;
				ArrayAppend(aReturn, stTemp);
			}
		</cfscript>
		<cfreturn aReturn>
	</cffunction>
	
	
	<!---------------------------------------->
	<!--- save							   --->
	<!---------------------------------------->	
	<cffunction name="save" access="public" hint="Saves the catalog xml" returntype="void" output="False"> 
		<!--- check that is a valid xml file --->
		<cfif Not IsXML(variables.xmlDoc)>
			<cfset throw("The given site doc is not a valid XML document.")>
		</cfif>		
		<!--- store page --->
		<cffile action="write" file="#expandpath(variables.href)#" output="#toString(variables.xmlDoc)#">
	</cffunction>

	<!---------------------------------------->
	<!--- getModuleByName				   --->
	<!---------------------------------------->	
	<cffunction name="getModuleByName" access="public" returntype="any" hint="Returns the tree node for a given resource on this catalog">
		<cfargument name="moduleName" type="string" required="true" hint="Name of the module">
	
		<cfscript>
			var xmlNode = 0;
			var xpath = "";
			var aModule = 0;
			
			// get resource
			xpath = "//module[@name='#arguments.moduleName#']";
			aModule = xmlSearch(variables.xmlDoc, xpath);
			
			if(ArrayLen(aModule) gt 0) {
				xmlNode = aModule[1];
			}
		</cfscript>
		<cfreturn xmlNode>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- getResourceNode				   --->
	<!---------------------------------------->	
	<cffunction name="getResourceNode" access="public" returntype="any" hint="Returns the tree node for a given resource on this catalog">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource. module, skin or page">
		<cfargument name="resourceID" type="string" required="true" hint="ID of the resource">
	
		<cfscript>
			var xmlNode = 0;
			var xpath = "";
			var aResources = 0;
			
			// get resource
			xpath = "//" & lcase(arguments.resourceType) & "[@id='#arguments.resourceID#']";
			aResources = xmlSearch(variables.xmlDoc, xpath);
			
			if(ArrayLen(aResources) gt 0) {
				xmlNode = aResources[1];
			}
		</cfscript>
		<cfreturn xmlNode>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- deleteResourceNode			   --->
	<!---------------------------------------->	
	<cffunction name="deleteResourceNode" access="public" returntype="any" hint="Deletes the given resource node on this catalog">
		<cfargument name="resourceType" type="string" required="true" hint="Type of resource. module, skin or page">
		<cfargument name="resourceID" type="string" required="true" hint="ID of the resource">
	
		<cfscript>
			var xmlNode = 0;
			var xpath = "";
			
			// get resource
			xpath = "//" & lcase(arguments.resourceType) & "[@id='#arguments.resourceID#']";
			aResources = xmlSearch(variables.xmlDoc, xpath);
			
			for(i=1;i lte arrayLen(variables.xmlDoc.xmlRoot[arguments.resourceType].xmlChildren);i=i+1) {
				xmlNode = variables.xmlDoc.xmlRoot[arguments.resourceType].xmlChildren[i];
				if(xmlNode.xmlAttributes.id eq arguments.resourceID) {
					ArrayDeleteAt(variables.xmlDoc.xmlRoot[arguments.resourceType].xmlChildren, i);
					break;
				}
			}
			
			save();
		</cfscript>
	</cffunction>		

	<!---------------------------------------->
	<!--- rebuildCatalog				   --->
	<!---------------------------------------->	
	<cffunction name="rebuildCatalog" access="public" returntype="void" hint="Rebuilds the catalog">
		<cfscript>
			var qry = QueryNew("");
			var i = 1;
			var tmpHREF = "";
			var newNode = 0;

			// clear modules from catalog
			structDelete(variables.xmlDoc.xmlRoot, "modules");
			structDelete(variables.xmlDoc.xmlRoot, "skins");
			structDelete(variables.xmlDoc.xmlRoot, "pageTemplates");
			structDelete(variables.xmlDoc.xmlRoot, "pages");
			
			// get list of resource packages
			qry = getResourcePackagesList();

			// add resources to the catalog
			for(i=1;i lte qry.recordCount;i=i+1) {
				
				switch(qry.resType[i]) {
					case "Module":
						// register module if module info file exists
						tmpHREF = variables.homeRoot & "/" & qry.resType[i] & "s/" & qry.name[i] & "/" & variables.resInfoFile;
						if(fileExists(expandPath(tmpHREF))) 
							importResourcePackage(tmpHREF);
						break;

					case "Skin":	
						// register skin if the CSS file with the same name as the skin exists
						tmpHREF = variables.homeRoot & "/" & qry.resType[i] & "s/" & qry.name[i] & "/" & qry.name[i] & ".css";
						if(fileExists(expandPath(tmpHREF))) {

							// create node for resource type if doesnt exist
							if(Not StructKeyExists(variables.xmlDoc.xmlRoot, "skins")) {
								ArrayAppend(variables.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(variables.xmlDoc, "skins"));	
							}
							
							newNode = xmlElemNew(variables.xmlDoc, "skin");
							newNode.xmlAttributes["id"] = qry.name[i];
							newNode.xmlAttributes["href"] = tmpHREF;
							
							ArrayAppend(variables.xmlDoc.xmlRoot.skins.xmlChildren, newNode);							
						}
							
						break;

					case "PageTemplate":	
						// register page template if the xml file with the same name as the page template exists
						tmpHREF = variables.homeRoot & "/" & qry.resType[i] & "s/" & qry.name[i] & "/" & qry.name[i] & ".xml";
						if(fileExists(expandPath(tmpHREF))) {

							// create node for resource type if doesnt exist
							if(Not StructKeyExists(variables.xmlDoc.xmlRoot, "pageTemplates")) {
								ArrayAppend(variables.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(variables.xmlDoc, "pageTemplates"));	
							}
							
							newNode = xmlElemNew(variables.xmlDoc, "pageTemplate");
							newNode.xmlAttributes["id"] = qry.name[i];
							newNode.xmlAttributes["href"] = tmpHREF;
							
							ArrayAppend(variables.xmlDoc.xmlRoot.pageTemplates.xmlChildren, newNode);							
						}
							
						break;

					case "Page":	
						// register page if the xml file with the same name as the page exists
						tmpHREF = variables.homeRoot & "/" & qry.resType[i] & "s/" & qry.name[i] & "/" & qry.name[i] & ".xml";
						if(fileExists(expandPath(tmpHREF))) {

							// create node for resource type if doesnt exist
							if(Not StructKeyExists(variables.xmlDoc.xmlRoot, "pages")) {
								ArrayAppend(variables.xmlDoc.xmlRoot.xmlChildren, xmlElemNew(variables.xmlDoc, "pages"));	
							}
							
							newNode = xmlElemNew(variables.xmlDoc, "page");
							newNode.xmlAttributes["id"] = qry.name[i];
							newNode.xmlAttributes["href"] = tmpHREF;
							
							ArrayAppend(variables.xmlDoc.xmlRoot.pages.xmlChildren, newNode);							
						}
							
						break;

				}
			}		
			save();
		</cfscript>
	</cffunction>

	<!--- * * * *     P R I V A T E     M E T H O D S   * * * * 	   --->


	<!---------------------------------------->
	<!--- getResourcePackagesList		   --->
	<!---------------------------------------->	
	<cffunction name="getResourcePackagesList" returntype="query" access="private"
				hint="returns a query with the names of all resource packages">

		<cfset var qry = QueryNew("ResType,Name")>
		<cfset var lstResources = "Module,Skin,PageTemplate,Page">
		<cfset var qryTemp = QueryNew("")>
		<cfset var tmpDir = "">
		
		<cfloop list="#lstResources#" index="res">
			<cfset tmpDir = ExpandPath("#variables.homeRoot#/#res#s")>
			<cfdirectory action="list" directory="#tmpDir#" name="qryTemp">
			<cfif qry.recordCount gt 0>
				<cfquery name="qry" dbtype="query">
					SELECT '#res#' AS ResType, name
						FROM qryTemp
						WHERE type = 'Dir'
					UNION
					SELECT ResType, name
						FROM qry
						ORDER BY name
				</cfquery>
			<cfelse>
				<cfquery name="qry" dbtype="query">
					SELECT '#res#' AS ResType, name
						FROM qryTemp
						WHERE type = 'Dir'
						ORDER BY name
				</cfquery>
			</cfif>
		</cfloop>
		<cfreturn qry>
	</cffunction>

	<!---------------------------------------->
	<!--- importResourcePackage			   --->
	<!---------------------------------------->	
	<cffunction name="importResourcePackage" access="private">
		<cfargument name="href" type="string" required="true" hint="Path of the resource descriptor file">

		<cfscript>
			// read catalog
			xmlCatalogDoc = variables.xmlDoc;
						
			// read resource descriptor
			xmlDescriptorDoc = xmlParse(expandPath(arguments.href));
		
			// append all resources in descriptor file to the catalog
			for(j=1;j lte arrayLen(xmlDescriptorDoc.xmlRoot.xmlChildren);j=j+1) {
				
				aResources = xmlDescriptorDoc.xmlRoot.xmlChildren[j].xmlChildren;
				resourceTypeGroup = xmlDescriptorDoc.xmlRoot.xmlChildren[j].xmlName;  // plural
				resourceType = left(resourceTypeGroup, len(resourceTypeGroup)-1); // singular

				// create node for resource type if doesnt exist
				if(Not StructKeyExists(xmlCatalogDoc.xmlRoot, resourceTypeGroup)) {
					ArrayAppend(xmlCatalogDoc.xmlRoot.xmlChildren, xmlElemNew(xmlCatalogDoc, resourceTypeGroup));	
				}
				
				for(i=1;i lte ArrayLen(aResources);i=i+1) {
					// check if this resource exists already in this catalog
					aCheckRes = xmlSearch(xmlCatalogDoc,"//#resourceType#[@id='#aResources[i].xmlAttributes.id#']");
					if(arrayLen(aCheckRes) eq 0) {
						// copy resource node from descriptor to catalog
						newNode = xmlElemNew(xmlCatalogDoc, resourceType);
						oldNode = aResources[i];
						copyNode(xmlCatalogDoc, newNode, oldNode);
						ArrayAppend(xmlCatalogDoc.xmlRoot[resourceTypeGroup].xmlChildren, newNode);
					}
				}
			}
		</cfscript>
	</cffunction>

	<!--- ************************************ --->
	<!--- * copyNode  					   * --->
	<!--- ************************************ --->
	<cffunction name="copyNode" access="private" output="false" returntype="void" hint="Copies a node from one document into a second document">
		<cfargument name="xmlDoc" required="true">
		<cfargument name="newNode" required="true">
		<cfargument name="oldNode" required="true">

		<cfset var key = "" />
		<cfset var index = "" />
		<cfset var i = "" />

		<!----
			CopyNode function based on code found at 
			http://www.spike.org.uk/blog/index.cfm?do=blog.cat&catid=8245E3A4-D565-E33F-39BC6E864D6B5DAA
			spike-fu:code poetry.
		----->

		<cfscript>
			if(len(trim(oldNode.xmlComment)))
				newNode.xmlComment = trim(oldNode.xmlComment);
			
			if(len(trim(oldNode.xmlCData)))
				newNode.xmlCData = trim(oldNode.xmlCData);
				
			newNode.xmlAttributes = oldNode.xmlAttributes;
			newNode.xmlText = trim(oldNode.xmlText);
			
			for(i=1;i lte arrayLen(oldNode.xmlChildren);i=i+1) {
				newNode.xmlChildren[i] = xmlElemNew(xmlDoc,oldNode.xmlChildren[i].xmlName);
				copyNode(xmlDoc,newNode.xmlChildren[i],oldNode.xmlChildren[i]);
			}
		</cfscript>
	</cffunction>

</cfcomponent>