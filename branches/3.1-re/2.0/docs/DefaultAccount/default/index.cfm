<cfscript>
	try {
		bHasError = false;
		
		// build path for components
		CFCRoot = Replace("/Home/","/",".","ALL");
		if(left(CFCRoot,1) eq ".") CFCRoot = right(CFCRoot, len(CFCRoot)-1); 
		if(right(CFCRoot,1) eq ".") CFCRoot = left(CFCRoot, len(CFCRoot)-1); 
		
		//redirect to account's homepage
		username = ListLast(GetDirectoryFromPath(GetCurrentTemplatePath()),"\/");
		oAccount = CreateObject("Component","#CFCRoot#.Components.accounts");
		oAccount.init(false, "/Home/");
		oAccount.gotoAccount(username);
		
	} catch(any e) {
		bHasError = true;
	}
</cfscript>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>HomePortals</title>
	<style type="text/css">
		body {
			font-family:Arial, Helvetica, sans-serif;
			font-size:12px;
			font-weight:bold;
			line-height:18px;
		}
	</style> 
</head>

<body>
	<div id="content">
		<cfif Not bHasError>
			<img src="/Home//Common/Images/loading_ring.gif" align="absmiddle" />&nbsp;&nbsp;
			Loading. Please wait...
		<cfelse>
			An unexpected error ocurred while loading the account. Please contact the system administrator.<br />
			<a href="/">Click Here</a> to continue.
		</cfif>
		<br /><br />
	</div>
</body>
</html>


