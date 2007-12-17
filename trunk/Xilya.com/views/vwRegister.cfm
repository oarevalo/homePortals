<cfparam name="request.requestState.accountName" default="">
<cfparam name="request.requestState.email" default="">
<cfparam name="request.requestState.firstName" default="">
<cfparam name="request.requestState.lastName" default="">

<cfscript>
	accountName = request.requestState.accountName;
	email = request.requestState.email;
	firstName = request.requestState.firstName;
	lastName = request.requestState.lastName;
</cfscript>

<table width="600" align="center">
	<tr><td>
	

<div style="margin-top:30px;">
	<img src="images/box_r1_c1.gif" style="float:left;">
	<div style="width:500px;float:left;background-color:#CCCC00;height:14px;font-size:1px;"></div>
	<img src="images/box_r1_c3.gif" style="float:left;">
	<br style="clear:both;font-size:1px;height:0px;" />

	<div style="width:528px;background-color:#CCCC00;">
		<form action="index.cfm" method="post" class="homeBoxForm">
			<input type="hidden" name="event" value="ehGeneral.doRegister">
			<div style="color:#fff;margin-bottom:10px;font-size:20px;">CREATE A XILYA ACCOUNT</div>
			<cfoutput>
			<table cellpadding="2">
				<tr valign="top">
					<td>
						Workarea:
						<div style="color:red;font-size:10px;font-weight:bold;">* Required</div>
					</td>
					<td>
						<input type="text" name="accountName" value="#accountName#" style="width:200px;" tabindex="1">
						<div style="font-size:11px;margin:3px;">
							Select a name for your workarea. You will use this name to login to
							your Xilya.com account. Names may contain any letters, numbers or the
							underscore "_" symbol, no spaces allowed.
						</div>
					</td>
				</tr>
				<tr valign="top">
					<td>
						Email:
						<div style="color:red;font-size:10px;font-weight:bold;">* Required</div>
					</td>
					<td>
						<input type="text" name="email" value="#email#" style="width:200px;" tabindex="2">
						<div style="font-size:11px;margin:3px;">
							We have a strictly no-spam policy. We will not share or sell personal information
							of our users with third parties.
						</div>
					</td>
				</tr>
				<tr><td colspan="2">&nbsp;</td></tr>
				<tr>
					<td>First Name:</td>
					<td><input type="text" name="firstName" value="#firstName#" style="width:200px;" tabindex="3"></td>
				</tr>
				<tr>
					<td>Last Name:</td>
					<td><input type="text" name="lastName" value="#lastName#" style="width:200px;" tabindex="4"></td>
				</tr>
				<tr><td colspan="2">&nbsp;</td></tr>
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
				<tr><td colspan="2">&nbsp;</td></tr>
				<tr>
					<td colspan="2" align="center" style="font-size:12px;font-weight:bold;">
						<input type="checkbox" name="agree" value="1" tabindex="7" style="border:0px;"> I agree to Terms and Conditions
						and Privacy Policy.
					</td>
				</tr>
				<tr><td colspan="2">&nbsp;</td></tr>
				<tr>
					<td colspan="2" align="right" style="padding-top:10px;">
						<div style="font-size:9px;font-family:verdana;text-align:right;padding-right:60px;float:left;">
							<a href="##" style="color:##fff;">Terms and Conditions</a>
						</div>
						<input type="submit" name="btnGo" value="Create Account" tabindex="8">					
						<input type="button" name="btnCancel" value="Cancel" onclick="document.location='index.cfm'" tabindex="9">					
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

</td></tr>
</table>