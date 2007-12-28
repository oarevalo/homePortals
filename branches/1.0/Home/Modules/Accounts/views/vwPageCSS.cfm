<cfparam name="arguments.href" default="">
<cfset initContext()>
<cfset stUser = getUserInfo()>
<cfset localStyleHREF = this.accountsRoot & "/" & stUser.username & "/styles/#getFileFromPath(this.pageURL)#.css">
<cfset cssContent = "">

<cfif FileExists(expandPath(localStyleHREF))>
	<cffile action="read" file="#expandPath(localStyleHREF)#" variable="cssContent">
</cfif>

<cfoutput>
	<form name="frm" style="padding:0px;margin:0px;" method="post" action="##">
		<div class="cp_sectionTitle" style="width:340px;padding:0px;"><div style="margin:2px;">StyleSheet Editor</div></div>
		<div class="cp_sectionBox" style="margin-top:0px;height:310px;padding:0px;margin-bottom:0px;width:340px;">
			<textarea name="cssContent" 
					  style="width:339px;font-size:11px;height:300px;border:0px;">#cssContent#</textarea>
		</div>
		<div class="cp_sectionBox" style="margin-top:0px;height:20px;background-color:##ccc;border-top:0px;padding-bottom:0px;width:340px;padding:0px;">
			<input type="button" value="Apply Changes" onclick="controlPanel.savePageCSS(this.form)">
			&nbsp;&nbsp;&nbsp;
			<a href="http://www.w3.org/Style/CSS/" target="_blank">About CSS</a>
		</div>
	</form>
</cfoutput>
