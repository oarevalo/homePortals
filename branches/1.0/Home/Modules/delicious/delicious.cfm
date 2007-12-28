<!--- delicious.cfm
This module allows you to interact with del.icio.us
--->

<!--- module parameters --->
<cfparam name="Attributes.moduleID">
<cfparam name="Attributes.module.xmlAttributes.user" default="">
<cfparam name="Attributes.module.xmlAttributes.tags" default="">

<!--- client-side initialization --->
<cfset instanceName = Replace(Attributes.moduleID,".","_","ALL")>
<cfsavecontent variable="tmpHead">
	<cfoutput>	
		<script type="text/javascript">
			#instanceName# = new deliciousClient();
			#instanceName#.instanceName = '#instanceName#';
			#instanceName#.contentID = '#instanceName#_content';
			#instanceName#.user = '#Attributes.module.xmlAttributes.user#';
			#instanceName#.tags = '#Attributes.module.xmlAttributes.tags#';
		</script>
		<style type="text/css">
			###instanceName# {
				font-size:11px;
				font-family:Arial, Helvetica, sans-serif;
			}
			###instanceName#_header {
				padding:5px;
				margin:0px;
				background-color:##E8E8E8;
				border:1px solid ##999999;
			}
			###instanceName#_header input {
				font-size:10px;
				border:1px solid silver;
				font-family:Arial, Helvetica, sans-serif;
			}
		</style>
	</cfoutput> 	
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">


<cfoutput>
	<form id="#instanceName#_header" name="frm" method="post" action="##" onSubmit="return false;">
		<a href="http://del.icio.us"><img src="/home/modules/delicious/delicious.small.gif" alt="del.icio.us" longdesc="http://del.icio.us" align="absmiddle" border="0" /></a>
		<b>del.icio.us</b>&nbsp;&nbsp;
		USER: <input type="text" name="user" value="#Attributes.module.xmlAttributes.user#" size="15" />&nbsp;&nbsp;&nbsp;
		TAGS: <input type="text" name="tags" value="#Attributes.module.xmlAttributes.tags#" size="15" />&nbsp;&nbsp;&nbsp;
		<input type="button" name="btnGo" value="SEARCH" onClick="#instanceName#.doSearch(this.form.user.value, this.form.tags.value)">
	</form>
	<div id="#instanceName#_content_BodyRegion">
	</div>
</cfoutput>
