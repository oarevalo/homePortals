<cfparam name="request.requestState.qryUser" default="">
<cfparam name="request.requestState.qryMember" default="">
<cfparam name="request.requestState.avatarHREF" default="">

<cfset qryUser = request.requestState.qryUser>
<cfset qryMember = request.requestState.qryMember>
<cfset avatarHREF = request.requestState.avatarHREF>

<table width="600" align="center">
	<tr><td>
		<br>
		<h1>Edit Your Account</h1>
		<p style="width:528px;">Use the following forms to make changes to your account information and to change your password.</p>
		
<div style="margin-top:30px;">
	<img src="images/box_r1_c1.gif" style="float:left;">
	<div style="width:500px;float:left;background-color:#CCCC00;height:14px;font-size:1px;"></div>
	<img src="images/box_r1_c3.gif" style="float:left;">
	<br style="clear:both;font-size:1px;height:0px;" />

	<div style="width:528px;background-color:#CCCC00;">
		<form action="index.cfm" method="post" class="homeBoxForm" enctype="multipart/form-data">
			<input type="hidden" name="event" value="ehProfile.doUpdate">
			<div style="color:#fff;margin-bottom:10px;font-size:20px;">EDIT PROFILE</div>
			<cfoutput>
			<table cellpadding="2">
				<tr valign="top">
					<td>
						Workarea:
					</td>
					<td>#qryUser.username#</td>
				</tr>
				<tr valign="top">
					<td>
						Email:
						<div style="color:red;font-size:10px;font-weight:bold;">* Required</div>
					</td>
					<td>
						<input type="text" name="email" value="#qryMember.email#" style="width:300px;" tabindex="2">
						<div style="font-size:11px;margin:3px;width:300px;">
							We have a strictly no-spam policy. We will not share or sell personal information
							of our users with third parties.
						</div>
					</td>
				</tr>
				<tr><td colspan="2">&nbsp;</td></tr>
				<tr>
					<td>First Name:</td>
					<td><input type="text" name="firstName" value="#qryMember.firstName#" style="width:300px;" tabindex="3"></td>
				</tr>
				<tr>
					<td nowrap>Middle Name:</td>
					<td><input type="text" name="middleName" value="#qryMember.middleName#" style="width:300px;" tabindex="4"></td>
				</tr>
				<tr>
					<td>Last Name:</td>
					<td><input type="text" name="lastName" value="#qryMember.lastName#" style="width:300px;" tabindex="5"></td>
				</tr>
				<tr valign="top">
					<td>Picture:</td>
					<td>
						<img src="#avatarHREF#" align="absmiddle" style="border:1px solid black;margin:5px;width:30px;height:30px;"><br>
						<input type="file" name="avatar" value="" style="width:300px;" tabindex="6">
						<div style="font-size:11px;margin:3px;width:300px;">
							Upload any image in JPG format. Images will be cropped to fit within a 30 by 30 pixels area.
						</div>
					</td>
				</tr>

				<tr>
					<td colspan="2" align="right" style="padding-top:10px;">
						<input type="submit" name="btnGo" value="Apply Changes" tabindex="7">					
					</td>
				</tr>
			</table>
			</cfoutput>
		</form>
	</div>

	<img src="images/box_r3_c1.gif" style="float:left;">
	<div style="width:500px;float:left;background-color:#CCCC00;height:14px;font-size:1px;"></div>
	<img src="images/box_r3_c3.gif" style="float:left;">
	<br style="clear:both;" />

</div>


<div style="margin-top:30px;">
	<img src="images/box_r1_c1.gif" style="float:left;">
	<div style="width:500px;float:left;background-color:#CCCC00;height:14px;font-size:1px;"></div>
	<img src="images/box_r1_c3.gif" style="float:left;">
	<br style="clear:both;font-size:1px;height:0px;" />

	<div style="width:528px;background-color:#CCCC00;">
		<form action="index.cfm" method="post" class="homeBoxForm">
			<input type="hidden" name="event" value="ehProfile.doChangePassword">
			<div style="color:#fff;margin-bottom:10px;font-size:20px;">CHANGE PASSWORD</div>
			<cfoutput>
			<table cellpadding="2">
				<tr valign="top">
					<td>Password:
						<div style="color:red;font-size:10px;font-weight:bold;">* Required</div>
					</td>
					<td>
						<input type="password" name="password" value="" style="width:200px;" tabindex="5">
						<div style="font-size:11px;margin:3px;">
							For security reasons, passwords are required to be at least 6 characters
							long.
						</div>
					</td>
				</tr>
				<tr>
					<td nowrap>Retype Password:
						<div style="color:red;font-size:10px;font-weight:bold;">* Required</div>
					</td>
					<td><input type="password" name="password2" value="" style="width:200px;" tabindex="6"></td>
				</tr>
				<tr>
					<td colspan="2" align="right" style="padding-top:10px;">
						<input type="submit" name="btnGo" value="Change Password" tabindex="8">					
					</td>
				</tr>
			</table>
			</cfoutput>
		</form>
	</div>

	<img src="images/box_r3_c1.gif" style="float:left;">
	<div style="width:500px;float:left;background-color:#CCCC00;height:14px;font-size:1px;"></div>
	<img src="images/box_r3_c3.gif" style="float:left;">
	<br style="clear:both;" />

</div>
		<p>&nbsp;</p>
	</td></tr>
</table>
