<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>HomePortals License Manager</title>
	<style type="text/css">
		body {
			font-family:Arial, Helvetica, sans-serif;
			font-size:14px;
			color:#666666;
		}
		input {
			font-size:14px;
			color:#666666;
		}
		h1 {
			font-size:18px;
			margin-bottom:15px;
		}
		.validLabel {
			color:#009900;
			font-weight:bold;
		}
		.invalidLabel {
			color:#990000;
			font-weight:bold;
		}
		.licenseInfo {
			margin-top:20px;
			padding:10px;
			background-color:#EBFDC1;
			font-size:11px;
		}
	</style>
</head>

<body>
	<cftry>
		<cfset errMessage = "">
		<cfset myLicense = "">
		<cfset bValid = false>
		
		<cftry>
			<!--- instantiate license manager object --->
			<cfset oLicense = CreateObject("component","Components.license")>
			
			<!--- if user is entering her license the store it --->
			<cfif IsDefined("form.btnSubmit") and IsDefined("form.licenseKey")>
				<cfset oLicense.saveLicenseKey(form.licenseKey)>
			</cfif>
			
			<!--- get license info --->
			<cfset myLicense = oLicense.getLicenseKey()>
			<cfset bValid = oLicense.validateLicenseKey(myLicense)>

			<cfcatch type="any">
				<cfset errMessage = cfcatch.Message>
			</cfcatch>
		</cftry>
		
		<cfoutput>
			<h1>
				HomePortals License Manager
			</h1>
		
			<cfif errMessage neq "">
				<div style="color:##990000;font-weight:bold;font-size:16px;">#errMessage#</div>
			</cfif>
		
			<form action="license.cfm" method="post">
				License Key: 
				<input type="text" name="licenseKey" value=""  size="30" <cfif bValid>disabled</cfif> />
				<input type="submit" value="Submit" name="btnSubmit" />
			</form>
			
			<cfif myLicense neq "">
				<div class="licenseInfo">
					<cfif bValid>
						<div class="validLabel">Your License is Valid!</div>
					<cfelse>
						<div class="invalidLabel">Your License is Not Valid</div><br />
						You may contact CFEmpire to purchase a valid license by visiting 
						<a href="http://www.cfempire.com/Homeportals">http://www.cfempire.com/Homeportals</a>
						or by sending an email to <a href="mailto:info@cfempire.com">info@cfempire.com</a>
					</cfif>
				</div>
				
				<p><a href="Admin/">Click Here</a> to visit the HomePortals Administrator.</p>
			</cfif>
		</cfoutput>

		<cfcatch type="any">
			<p>An unforeseen error ocurred.</p>
			<p><b>Diagnostics:</b><br />
			<cfoutput>
				<b>#cfcatch.Message#</b>
			</cfoutput>
		</cfcatch>
	</cftry>
</body>
</html>

