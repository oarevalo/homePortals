<cfset trialExpirationDate = getValue("trialExpirationDate")>

<!--- get html code for available messages --->		
<cfset tmpMsg = getPlugin("messageBox").renderit()>
			
<form name="frmLicense" method="post" action="index.cfm" id="frmLicense">
	<input type="hidden" name="event" value="ehGeneral.doSetLicense">
	
	<div class="titleBar">
		&nbsp;HomePortals Administrator License
	</div>
	<div class="innerContainer">
		<cfif tmpMsg neq "">
			<cfoutput>#tmpMsg#</cfoutput>
		</cfif>
		<p>
			Please enter your HomePortals License Key in the space below. 
		</p>
		<p>
			<input type="text" name="licenseKey" value="" style="width:270px;"><br>
			<cfif trialExpirationDate eq "">
				<input type="checkbox" name="isTrial" value="true"> Use 30-day Trial version<br>
			</cfif>
			<input type="submit" name="btnSet" value="Submit">
		</p>
		<cfif trialExpirationDate eq "">
			<p style="font-size:10px;">
				To start the Free 30-day trial of HomePortals, leave the license key
				blank and tick the checkbox.
			</p>
		</cfif>
		<p style="font-size:10px;">
			To obtain a valid license key, you may contact CFEmpire to purchase 
			by visiting <a href="http://www.cfempire.com/Homeportals">http://www.cfempire.com/Homeportals</a>
			or by sending an email to <a href="mailto:info@cfempire.com">info@cfempire.com</a>
		</p>
	</div>
</form>

<p align="center">
	<a href="http://www.cfempire.com" 
		alt="_blank"
		style="border:1px solid #999;background-color:white;padding:3px;padding-top:0px;"
		><img src="images/cfempire_logo.jpg" alg="CFEmpire Corp." border="0" align="absmiddle"></a>
</p>
