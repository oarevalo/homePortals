<!--- search.cfm
This module searches the web.
--->

<!--- module parameters --->
<cfparam name="Attributes.moduleID">

<!--- client-side initialization --->
<cfset instanceName = Attributes.moduleID>
<cfsavecontent variable="tmpHead">
	<cfoutput>	
		<script type="text/javascript">
			#instanceName# = new searchClient();
			#instanceName#.instanceName = '#instanceName#';
			#instanceName#.contentID = '#instanceName#_content';
		</script>
	</cfoutput> 	
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">


<!--- displaty --->
<cfoutput>
	<form action="##" method="post" onSubmit="return false">
		<strong>Search The Web:</strong>
		<input type="text" name="query" value="" size="15">
		<input type="button" name="btn1" value="Search" onClick="#instanceName#.doSearch(this.form)">
		<input type="button" name="btn2" value="Clear" onClick="#instanceName#.clearSearch()">
		
		&nbsp;<input type="radio" name="engine" value="google" checked="checked" /> Google
	</form>
	
	<div id="#instanceName#_content_BodyRegion"></div>
</cfoutput>

