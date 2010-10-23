<cfset moduleID = this.controller.getModuleID()>
<cfset stUser = this.controller.getUserInfo()>

<cfoutput>
	<style type="text/css">
		###moduleID# textarea {
			font-size:11px;
			border:1px solid silver;
			width:99%;
			height:200px;
			font-family:Arial, Helvetica, sans-serif;
		}		
		###moduleID#_viewer {
			cursor:text;
			font-family:Tahoma;
			font-size:11px;
			white-space: pre-wrap; /* css-3 */
			white-space: -moz-pre-wrap !important; /* Mozilla, since 1999 */
			white-space: -pre-wrap; /* Opera 4-6 */
			white-space: -o-pre-wrap; /* Opera 7 */
			word-wrap: break-word; /* Internet Explorer 5.5+ */
		}		
	</style>
	
	<cfif stUser.isOwner>
		<script type="text/javascript">
			#moduleID#.enableEditMode = function() {
				var modID = "#moduleID#";
				eViewer = $("#" + modID + "_viewer");
				eEditor = $("#" + modID + "_editor");
				
				eEditor.style.width = eViewer.clientWidth;
				eViewer.style.display = "none";
				eEditor.style.display = "block";
				
				#moduleID#_saveTimer = window.setInterval(modID + ".doFormAction('save',$('###moduleID#_frm'))",30000);
			};
	
			#moduleID#.disableEditMode = function() {
				var modID = "#moduleID#";
				eViewer = $("#" + modID + "_viewer");
				eEditor = $("#" + modID + "_editor");
				
				clearInterval(#moduleID#_saveTimer);
				
				/* save one last time  */
				this.doFormAction('save',$("#" + modID + '_frm'));
				
				/* refresh view */
				this.getView();						
			};
			
			#moduleID#.newNote = function() {
				var modID = "#moduleID#";
				var nName = prompt("Enter a name for the new note:");
				var frm = $("#" + modID + '_frm');
				var eEditor = $("#" + modID + "_editor");
				
				if(nName=='' || nName==null || nName==undefined) {
					return;
				};
				frm.noteID.value = nName;
				eEditor.value = "Type some notes here...";
				this.doFormAction('save',$("#" + modID + '_frm'));
				this.enableEditMode();
			};	
	
			#moduleID#.deleteNote = function() {
				var modID = "#moduleID#";
				var frm = $("#" + modID + '_frm');
				var eEditor = $("#" + modID + "_editor");
	
				if(confirm("Delete note?")) {
					this.doFormAction('delete',$("#" + modID + '_frm'))
				};
			};	
		</script>
	</cfif>
</cfoutput>


