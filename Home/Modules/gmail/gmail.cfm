<!--- Init variables and Params --->
<cftry>
	<cfparam name="attributes.Module" default="#StructNew()#">
	<cfparam name="Attributes.Module.XMLAttributes.username" default="">
	<cfparam name="Attributes.Module.XMLAttributes.password" default="">
	<cfparam name="Attributes.Module.XMLAttributes.numItems" default="5">
	
	<cfset args = Attributes.Module.XMLAttributes>
	<cfset instanceName = Attributes.moduleID>

	<!--- initialize server-side component --->
	<cfinvoke component="home.modules.gmail.gmail" method="init">
		<cfinvokeargument name="instanceName" value="#instanceName#">
		<cfinvokeargument name="username" value="#args.username#">
		<cfinvokeargument name="password" value="#args.password#">
		<cfinvokeargument name="numItems" value="#args.numItems#">
	</cfinvoke>
	
	<!--- client-side initialization --->
	<cfsavecontent variable="tmpHead">
		<script type="text/javascript">
			<cfoutput>	
				#instanceName# = new gmailClient();
				#instanceName#.instanceName = '#instanceName#';
				#instanceName#.contentID = '#instanceName#_content';
				#instanceName#.username = '#args.username#';
			</cfoutput> 	
		</script>
	</cfsavecontent>
	<cfhtmlhead text="#tmpHead#">	
	
	<cfoutput>
		<cfset urlGMail = "https://mail.google.com/mail?account_id=" & URLEncodedFormat(args.username)>
		
		<div style="font-size:1.2em;font-weight:bold;">
			<a href="#urlGMail#" target="_blank">
			<img src="/home/modules/gmail/gmail.gif" border="0" align="left" 
				alt="Click here to go to your inbox"
				title="Click here to go to your inbox"></a>
			&nbsp; New Messages For #args.username#</div>
		<hr />

		<div id="#instanceName#_content_BodyRegion"></div>

		<p>
			<a href="#urlGMail#" target="_blank"><strong>Go To Inbox</strong></a> | 
			<a href="##" onClick="#instanceName#.getMail()"><strong>Refresh</strong></a>
		</p>
	</cfoutput>
	
	<cfcatch type="any">
		An error ocurred while retrieving your email.<br>
		<cfoutput>
			#cfcatch.Message#<br>
			#cfcatch.Detail#
		</cfoutput>
	</cfcatch>
</cftry>


	