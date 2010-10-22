<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
	
	// get content store
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();

	// get current user info
	stUser = this.controller.getUserInfo();
		
	// check if current user is owner
	bIsContentOwner = stUser.isOwner and (stUser.username eq myContentStore.getOwner());
	
	// get all content entries
	aNotes = xmlSearch(xmlDoc,"//note");
	noteContent = "Type some notes here...";
	
	// get the noteID defined on the page (if any)
	noteID = this.controller.getModuleConfigBean().getPageSetting("noteID");	
	
	// if no noteID is selected, then we use the 'current' note
	if(noteID eq "") noteID = "CURRENT";
	
	
	// get the selected note entry
	aThisNote = xmlSearch(xmlDoc,"//note[@id='#noteID#']");
	if(arrayLen(aThisNote) gt 0)
		noteContent = aThisNote[1].xmlText;
		
	if(trim(noteContent eq "")) noteContent = "Type some notes here...";
</cfscript>


<cfoutput>
	<cfif bIsContentOwner and ArrayLen(aNotes) gt 1>
		<div style="text-align:right;margin-bottom:5px;padding-bottom:5px;border-bottom:1px solid silver;">
			<select name="selNotes" 
					onclick="if(this.value!='' && this.value!=$('#moduleID#_frm').noteID.value) #moduleID#.doAction('setNoteID',{noteID:this.value})" 
					style="font-size:11px;border:1px solid silver;">
				<option value="">--- Saved Notes ---</option>
				<cfloop from="1" to="#ArrayLen(aNotes)#" index="i">
					<option value="#aNotes[i].xmlAttributes.id#" <cfif noteID eq aNotes[i].xmlAttributes.id>selected</cfif>>#aNotes[i].xmlAttributes.id#</option>
				</cfloop>
			</select>
		</div>
	</cfif>

	<cfif bIsContentOwner>
		<form name="frmNotes" method="post" action="##" style="margin:0px;padding:0px;" id="#moduleID#_frm">
			<input type="hidden" name="noteID" value="#noteID#">
			<textarea id="#moduleID#_editor" 
						name="noteBody" 
						rows="10" 
						onblur="#moduleID#.disableEditMode()"
						style="display:none;border:1px dashed red;">#noteContent#</textarea>
			<div id="#moduleID#_viewer" onclick="#moduleID#.enableEditMode()">#paragraphFormat(noteContent)#</div>
		
		</form>
	<cfelse>
		<div id="#moduleID#_viewer">#noteContent#</div>
	</cfif>

	<cfif bIsContentOwner>
		<div class="SectionToolbar">
			<a href="##" onclick="#moduleID#.newNote()"><img src="#imgRoot#/add-page-orange.gif" border="0" align="absmiddle"></a>
			<a href="##" onclick="#moduleID#.newNote();">New Note</a>&nbsp;&nbsp;
			
			<cfif noteID neq "CURRENT">
				<a href="##" onclick="#moduleID#.deleteNote()"><img src="#imgRoot#/omit-page-orange.gif" border="0" align="absmiddle"></a>
				<a href="##" onclick="#moduleID#.deleteNote();">Delete Note</a>&nbsp;&nbsp;
			</cfif>
		</div>
	</cfif>
</cfoutput>
