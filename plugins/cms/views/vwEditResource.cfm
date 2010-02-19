<cfparam name="arguments.resourceType">
<cfparam name="arguments.resourceID" default="">
<cfparam name="arguments.prefix" default="res">

<cfscript>
	hp = variables.homePortals;
	oCatalog = hp.getCatalog();
	resLib = getDefaultResourceLibrary();
	
	if(arguments.resourceID eq "_NOVALUE_") arguments.resourceID = "";
	
	if(arguments.resourceID neq "")
		oResourceBean = oCatalog.getResourceNode(arguments.resourceType, arguments.resourceID, true);
	else
		oResourceBean = resLib.getNewResource(arguments.resourceType);
	
	tmpFullPath = oResourceBean.getFullPath();
	tmpFullHREF = oResourceBean.getFullHref();
	
	tmp = hp.getResourceLibraryManager().getResourceTypesInfo();
	resourceTypeConfig = tmp[arguments.resourceType];

	propsConfig = resourceTypeConfig.getProperties();
	lstPropsConfig = structKeyList(propsConfig);
	lstPropsConfig = listSort(lstPropsConfig,"textnocase");	
	
	props = oResourceBean.getProperties();
	lstProps = structKeyList(props);
	lstProps = listSort(lstProps,"textnocase");		

	extensions = listToArray(resourceTypeConfig.getFileTypes());
	fileContent = "";
	fileName = "";
	isText = false;
	isImage = false;
	isEditable = (lstPropsConfig neq "" or resourceTypeConfig.getFileTypes() neq "");
	
	knownTextExtensions = listToArray("txt,htm,html,xhtml,xml");
	for(i=1;i lte arrayLen(extensions);i++) {
		for(j=1;j lte arrayLen(knownTextExtensions);j++) {
			if(extensions[i] eq knownTextExtensions[j]) isText = true;
		}
	}

	isImage = (tmpFullPath neq "" and fileExists(tmpFullPath) and isImageFile(tmpFullPath));

	// read file
	if(isText and oResourceBean.targetFileExists()) {
		fileContent = oResourceBean.readFile();
		fileName = getFileFromPath( tmpFullHREF );
	}
</cfscript>
	
	<cfoutput>
		<cfif not isEditable>
			<cfif arguments.resourceID eq "">
				This resource type has no editable properties and cannot be created manually.
				<script>jQuery("##cms-resourceEditPanel").show()</script>
			<cfelse>
				<script>jQuery("##cms-resourceEditPanel").hide()</script>
			</cfif>
			<cfexit method="exittemplate">
		<cfelse>
			<script>jQuery("##cms-resourceEditPanel").show()</script>
		</cfif>
		
		<table width="100%">
			<cfif arguments.resourceID eq "">
				<tr>
					<td nowrap="nowrap" style="width:80px;"><b>Name:</b></td>
					<td><input type="text" name="#arguments.prefix#__id" value="" class="cms-formField"></td>
				</tr>
				<input type="hidden" name="#arguments.prefix#__isnew" value="1">
			<cfelse>
				<input type="hidden" name="#arguments.prefix#__id" value="#arguments.resourceID#">
				<input type="hidden" name="#arguments.prefix#__isnew" value="0">
			</cfif>
			<cfif resourceTypeConfig.getFileTypes() neq "">
				<input type="hidden" name="#arguments.prefix#__filename" value="#fileName#">
				<tr>
					<td colspan="2">
						<cfif isText>
							<input type="hidden" name="#arguments.prefix#__filecontenttype" value="text/plain">
							<textarea name="#arguments.prefix#__filebody" rows="15" cols="50" class="cms-formField" style="width:100%;">#fileContent#</textarea><br />
						<cfelseif isImage>
							<cfimage action="resize"
									    width="100" height="" 
									    source="#tmpFullPath#"
									    name="resImage">
							<a href="#tmpFullHREF#"><cfimage action="writeToBrowser" source="#resImage#"></a>
						</cfif>
					</td>
				</tr>
				<tr>
					<td nowrap="nowrap" style="width:80px;"><b>Upload:</b></td>
					<td><input type="file" name="#arguments.prefix#__file" value="" class="cms-formField" style="width:auto;"></td>
				</tr>
			</cfif>
	
			<cfif lstPropsConfig neq "">
				<cfloop list="#lstPropsConfig#" index="key">
					<cfset tmpValue = "">
					<cfset tmpLabel = key>
					<cfset lstValues = "">
					<cfset tmpType = propsConfig[key].type>
					
					<cfif structKeyExists(props,key)>
						<cfset tmpValue = trim(props[key])>
					<cfelseif propsConfig[key].default neq "">
						<cfset tmpValue = propsConfig[key].default>
					</cfif>
					<cfif propsConfig[key].label neq "">
						<cfset tmpLabel = propsConfig[key].label>
					</cfif>
					<cfif listLen(propsConfig[key].type,":") eq 2 and listfirst(propsConfig[key].type,":") eq "resource">
						<cfset tmpType = listfirst(propsConfig[key].type,":")>
						<cfset resourceType = listlast(propsConfig[key].type,":")>
					</cfif>
		
					<tr>
						<td nowrap="nowrap" style="width:80px;"><b>#tmpLabel#:</b></td>
						<td>
							<cfswitch expression="#tmpType#">
								<cfcase value="list">
									<cfset lstValues = propsConfig[key].values>
									<select name="#arguments.prefix#_#key#" class="cms-formField" style="width:150px;">
										<cfif not propsConfig[key].required><option value="_NOVALUE_"></option></cfif>
										<cfloop list="#lstValues#" index="item">
											<option value="#item#" <cfif tmpValue eq item>selected</cfif>>#item#</option>
										</cfloop>
									</select>
									<cfif propsConfig[key].required><span style="color:red;">&nbsp; * required</span></cfif>
								</cfcase>
								
								<cfcase value="resource">
									<cfset qryResources = oCatalog.getResourcesByType(resourceType)>
									<cfquery name="qryResources" dbtype="query">
										SELECT *, upper(package) as upackage, upper(id) as uid
											FROM qryResources
											ORDER BY upackage, uid, id
									</cfquery>
									<select name="#arguments.prefix#_#key#" class="cms-formField">
										<cfif not propsConfig[key].required><option value="_NOVALUE_"></option></cfif>
										<cfloop query="qryResources">
											<option value="#qryResources.id#"
													<cfif tmpValue eq qryResources.id>selected</cfif>	
														>[#qryResources.package#] #qryResources.id#</option>
										</cfloop>
									</select>
									<cfif propsConfig[key].required><span style="color:red;">&nbsp; * required</span></cfif>
								</cfcase>
								
								<cfcase value="boolean">
									<cfif propsConfig[key].required>
										<cfset isTrueChecked = (isBoolean(tmpValue) and tmpValue)>
										<cfset isFalseChecked = (isBoolean(tmpValue) and not tmpValue) or (tmpValue eq "")>
									<cfelse>
										<cfset isTrueChecked = (isBoolean(tmpValue) and tmpValue)>
										<cfset isFalseChecked = (isBoolean(tmpValue) and not tmpValue)>
									</cfif>
									
									<input type="radio" name="#arguments.prefix#_#key#" 
											style="border:0px;width:15px;"
											value="true" 
											<cfif isTrueChecked>checked</cfif>> True 
									<input type="radio" name="#arguments.prefix#_#key#" 
											style="border:0px;width:15px;"
											value="false" 
											<cfif isFalseChecked>checked</cfif>> False 
									<cfif propsConfig[key].required><span style="color:red;">&nbsp; * required</span></cfif>
								</cfcase>
								
								<cfdefaultcase>
									<input type="text" 
											name="#arguments.prefix#_#key#" 
											value="#tmpValue#" 
											class="cms-formField">
									<cfif propsConfig[key].required><span style="color:red;">&nbsp; * required</span></cfif>
								</cfdefaultcase>
							</cfswitch>
							<input type="hidden" name="#arguments.prefix#_#key#_default" value="#propsConfig[key].default#">
						
						</td>
					</tr>
				</cfloop>
			</cfif>
		</table>

	</cfoutput>

	