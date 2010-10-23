<cfparam name="arguments.resourceType">
<cfparam name="arguments.resourceID" default="">
<cfparam name="arguments.prefix" default="res">

<cfscript>
	hp = variables.homePortals;
	oCatalog = hp.getCatalog();
	resLib = getDefaultResourceLibrary();
	
	if(arguments.resourceID eq "_NOVALUE_") arguments.resourceID = "";
	
	if(arguments.resourceID neq "")
		oResourceBean = oCatalog.getResource(arguments.resourceType, arguments.resourceID, true);
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
	isPlainText = false;
	isRichText = false;
	isImage = false;
	isEditable = (lstPropsConfig neq "" or resourceTypeConfig.getFileTypes() neq "");
	
	knownPlainTextExtensions = listToArray("txt,xml");
	knownRichTextExtensions = listToArray("htm,html,xhtml");
	for(i=1;i lte arrayLen(extensions);i++) {
		for(j=1;j lte arrayLen(knownPlainTextExtensions);j++) {
			if(extensions[i] eq knownPlainTextExtensions[j]) isPlainText = true;
		}
		for(j=1;j lte arrayLen(knownRichTextExtensions);j++) {
			if(extensions[i] eq knownRichTextExtensions[j]) isRichText = true;
		}
	}
	isText = (isPlainText or isRichText);

	isImage = (tmpFullPath neq "" and fileExists(tmpFullPath) and isImageFile(tmpFullPath));

	// read file
	if(isText and oResourceBean.targetFileExists()) {
		fileContent = oResourceBean.readFile();
		fileName = getFileFromPath( tmpFullHREF );
	}
</cfscript>
	
	<cfoutput>
		<div class="cms-panelTitle">
			<cfif arguments.resourceID neq "">
				<cfif isEditable>
					<div style="float:right;">
						<a href='javascript:void(0);' onclick="navCmdDeleteResource('#jsStringFormat(arguments.resourceType)#','#jsStringFormat(arguments.resourceID)#')"
							style="color:red;text-decoration:none;font-size:11px;"><img 
							src='#variables.cmsRoot#/images/omit-page-orange.gif' 
							border='0' align='absmiddle' alt='Click to delete resource' 
							title='click to delete resource'> Delete Resource</a>
					</div>
				</cfif>
				<cfif oResourceBean.getID() neq oResourceBean.getPackage() and oResourceBean.getPackage() neq "">
					#oResourceBean.getPackage()# /
				</cfif>
				#oResourceBean.getID()#
			<cfelse>
				New #arguments.resourceType#
			</cfif>
		</div>

		<cfif arguments.resourceID neq "">
			<cfset tmpDesc = oResourceBean.getDescription()>
			<cfif tmpDesc eq "">
				<cfset tmpDesc = resourceTypeConfig.getDescription()>
			</cfif>
		<cfelse>
			<cfset tmpDesc = resourceTypeConfig.getDescription()>
		</cfif>
		<cfif tmpDesc neq "">
			<div style="margin-top:10px;margin-bottom:10px;">
				<img src="#cmsRoot#/images/information.png" align="absmiddle">
				#tmpDesc#
			</div>
		</cfif>

		
		<cfif not isEditable>
			<cfif arguments.resourceID eq "">
				This resource type has no editable properties and cannot be created manually.
			<cfelse>
				<em>This resource has no editable properties.</em><br />
			</cfif>
			<script>jQuery("##cms-resourceEditPanel").show()</script>
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
							<cfif isRichText>
							    <script type="text/javascript">
							        jQuery(function() {
							            jQuery("###arguments.prefix#_btnEnableHtmlArea").click(function() { 
											  jQuery("###arguments.prefix#__filebody").htmlarea({
													toolbar: [
													        ["html"], ["bold", "italic", "underline", "strikethrough","forecolor"],
													        ["increasefontsize", "decreasefontsize"],
													        ["orderedlist", "unorderedlist"],
													        ["indent", "outdent"],
													        ["justifyleft", "justifycenter", "justifyright"],
													        ["link", "unlink", "image", "horizontalrule"],
													        ["p", "h1", "h2", "h3", "h4"]
													    ]
								                });
								              jQuery(this).hide();
										 });
										 
										 setTimeout("jQuery('###arguments.prefix#_btnEnableHtmlArea').click()",100);
						            });
								</script>
								<input type="hidden" name="#arguments.prefix#__filecontenttype" value="text/html">
								<a href="javascript:void(0);" id="#arguments.prefix#_btnEnableHtmlArea" style="font-weight:bold;color:green;">&raquo; Click to enable rich text editor</a>
							<cfelse>
								<input type="hidden" name="#arguments.prefix#__filecontenttype" value="text/plain">
							</cfif>
							<textarea name="#arguments.prefix#__filebody" rows="15" cols="50" id="#arguments.prefix#__filebody" class="cms-formField" style="width:100%;background-color:##fff;">#fileContent#</textarea><br />
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
									<cfset qryResources = oCatalog.getIndex(resourceType)>
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
														><cfif qryResources.package neq qryResources.id
															>[#qryResources.package#] </cfif>#qryResources.id#</option>
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

	