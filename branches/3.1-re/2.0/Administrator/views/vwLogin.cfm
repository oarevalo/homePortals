
<!--- get html code for available messages --->		
<cfset tmpMsg = getPlugin("messageBox").renderit()>
			
<form name="frmLogin" method="post" action="index.cfm" id="frmLogin">
	<input type="hidden" name="event" value="ehGeneral.doLogin">
	
	<div class="titleBar">
		&nbsp;HomePortals Administrator Login
	</div>
	<div class="innerContainer">
		<cfif tmpMsg neq "">
			<cfoutput>#tmpMsg#</cfoutput>
		</cfif>
		<br>
		<p>
			Please enter your password:<br>
			<input type="password" name="password" value=""><br><br>
			<input type="submit" name="btnLogin" value="Login">
		</p>
		<br>
		<!--- 	
		<p style="font-size:10px;">
			If you have not setup your license key, please 
			<a href="?event=ehGeneral.dspLicense">Click Here</a>
		</p> 
		--->
	</div>
</form>

<p align="center">
	<a href="http://www.cfempire.com" 
		alt="_blank"
		style="border:1px solid #999;background-color:white;padding:3px;padding-top:0px;"
		><img src="images/cfempire_logo.jpg" alg="CFEmpire Corp." border="0" align="absmiddle"></a>
</p>
