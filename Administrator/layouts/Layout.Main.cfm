<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

		
<!--- get html code for available messages --->		
<cfset tmpMsg = getPlugin("messageBox").renderit()>
			
			
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>HomePortals Administrator</title>
		<link rel="stylesheet" href="style.css" type="text/css" />
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
		<script src="main.js" type="text/javascript"></script>
	</head>
	<body>
		<div class="header">
			<div class="innerContainer">
				<cfinclude template="../includes/header.cfm">
			</div>
		</div>
		<div class="headNav">
			<cfinclude template="../includes/headnav.cfm">
		</div>
		<div class="body">
			<table style="width:100%;margin:0px;" cellpadding="0" cellspacing="0">
				<tr valign="top">
					<td class="mainTbl_leftColumn">
						<cfinclude template="../includes/mainMenu.cfm">
					</td>
					<td class="mainTbl_rightColumn">
						<cfoutput>
							<cfif tmpMsg neq "">
								#tmpMsg#<br>
							</cfif>
							<div class="innerContainer">
								<cftry>
									#renderView()#		
											
									<cfcatch type="any">
										<p>#cfcatch.message#</p>
									</cfcatch>
								</cftry>
							</div>
						</cfoutput>
					</td>
				</tr>
			</table>
		</div>
		<p align="center" class="credits">
			<a href="http://www.coldboxframework.com"
				target="_blank"
				><img src="images/poweredByColdbox.gif" alt="Powered By Coldbox" border="0" align="absmiddle"></a>
			<a href="http://www.cfempire.com" 
				target="_blank"
				style="border:1px solid #999;background-color:white;padding:3px;padding-top:1px;"
				><img src="images/cfempire_logo.jpg" alg="CFEmpire Corp." border="0" align="absmiddle"></a>
		</p>
		<p></p>
	</body>
</html>
