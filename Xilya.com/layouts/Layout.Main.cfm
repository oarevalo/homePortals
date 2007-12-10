<cfscript>
	tmpMsg = getPlugin("messageBox").renderit();
	
	oUserRegistry = createObject("component","Home.Components.userRegistry").init();
	stUserInfo = oUserRegistry.getUserInfo();
				
	if(stUserInfo.userID neq "") {
		bLoggedIn = true;
		qryUser = stUserInfo.userData;
	} else {
		bLoggedIn = false;
	}
</cfscript>
	
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Xilya.com - Your Space, Your Work</title>
	<link rel="stylesheet" type="text/css" href="style.css">
	<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
	</script>
	<script type="text/javascript">
		_uacct = "UA-86973-6";
		urchinTracker();
	</script>
</head>
<body>
	<div id="header">
		<div id="headerLogin">
			<cfif bLoggedIn>
				<cfoutput>
					<span style="font-size:12px;"><b>Logged in as:</b> #qryUser.username#</span>
					<a href="index.cfm?event=ehGeneral.doLogoff" style="text-decoration:underline;color:##fff;font-size:11px;">(Log Off)</a>
					<div style="margin-top:10px;font-size:12px;text-align:right;">
						<a href="/Accounts/#qryUser.username#" style="text-decoration:underline;color:##fff;font-size:11px;">My Workarea</a> &nbsp;|&nbsp;
						<a href="index.cfm?event=ehProfile.dspProfile" style="text-decoration:underline;color:##fff;font-size:11px;">My Account</a>
					</div>
				</cfoutput>
			<cfelse>
				<a href="index.cfm?event=ehGeneral.dspLogin" style="color:#fff;font-size:12px;">Login To Your Account</a>
			</cfif>
		</div>
	</div>
	<div id="navBar">
		<a href="index.cfm">Home</a> &nbsp;
		|&nbsp;<a href="index.cfm?event=ehGeneral.dspAbout">About</a> &nbsp;
		<!-- |&nbsp;<a href="/Home/Modules/Blog/?blog=/Accounts/wencho/myBlog.xml">Blog</a> -->
	</div>
	<cfoutput>
		<table width="100%">
			<tr valign="top">
				<td width="200" class="sideBar">
					<cfinclude template="../includes/sideBar.cfm">
				</td>
				<td>
					<cfif tmpMsg neq "">
						#tmpMsg#<br>
					</cfif>

					#renderView()#	
					
					<br /><br />
				</td>
			</tr>
			<tr>
				<td colspan="2" style="border-top:1px solid silver;border-bottom:1px solid silver;background-color:##ebebeb;font-size:10px;line-height:18px;" align="center">
					<a href="http://www.cfempire.com" style="color:##333;">CFEmpire.com</a> &nbsp;&nbsp;|&nbsp;&nbsp;
					<a href="mailto:info@cfempire.com" style="color:##333;">Contact Us</a>
				</td>
			</tr>
		</table>
	
	</cfoutput>	

	<!--- google analytics --->	
	<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
	</script>
	<script type="text/javascript">
	_uacct = "UA-1666655-10";
	urchinTracker();
	</script>	
</body>
</html>
