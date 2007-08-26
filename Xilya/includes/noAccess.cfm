<!--- noAccess.cfm

	This template is displayed when a user
	requests a page for which he doesnt have 
	access.
	
--->
<html>
	<head>
		<title>Not Authorized</title>
		<link rel="stylesheet" type="text/css" href="/xilya/includes/styles/skin.css"/>
	</head>
	<body>
		
		<div class="Section" style="width:300px;margin:0 auto;margin-top:300px;">
			<div class="SectionTitle">
				<div class="SectionTitleLabel" style="margin:3px;">Not Allowed</div>
			</div>
			<div style="margin:10px;font-size:12px;line-height:18px;">
				The page you requested is a private page and cannot be viewed.
				<br><br>
				Please <a href="javascript:history.go(-1)">Click Here</a> to go back, or <a href="/">Here</a>
				to return to the Xilya homepage.
			</div>
		</div>
		
	</body>
</html>