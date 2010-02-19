<cfset appRoot = getHomePortals().getConfig().getAppRoot()>
<cfoutput>
	<div id="cms-adminBar">
		<a id="cms-mainTitle" href="#appRoot#">#application.applicationName#</a>
	</div>

	<div class="cms-panel">
		<cfif structKeyExists(url,"_statusMessage") and url._statusMessage neq "">
			<div style="color:red;font-weight:bold;margin-bottom:10px;">
				#url._statusMessage#
			</div>
		</cfif>		
		<p>It seems that you do not have yet created a user to access the CMS functionality.
			Please complete the following form to create a new user.
		</p>
		<form name="frm" action="##" method="post">
			<input type="hidden" name="method" value="createUser">
			<strong>Username:</strong> <input type="text" name="username" value="" class="cms-formField"><br />
			<strong>Password:</strong> <input type="password" name="password" value="" class="cms-formField"><br />
			<strong>Confirm password:</strong> <input type="password" name="password2" value="" class="cms-formField"><br /><br />
			<input type="button" value="Create User" onclick="controlPanel.createUser(this.form)">
		</form>
	</div>
</cfoutput>