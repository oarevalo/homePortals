<cfset cfg = this.controller.getModuleConfigBean()>
<cfset tmpModulePath = cfg.getModuleRoot()>
<cfset moduleID = this.controller.getModuleID()>

<cfsavecontent variable="tmpHTML">
	<cfoutput>
	<link rel="stylesheet" type="text/css" href="#tmpModulePath#/includes/epoch_styles.css" />
	<script type="text/javascript" src="#tmpModulePath#/includes/epoch_classes.js"></script>
	<script>
		#moduleID#.initCalendar = function() {
			#moduleID#_cal = new Epoch('epoch_basic','flat',document.getElementById('#moduleID#_calendar'),'#moduleID#');
		};	
	</script>
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#tmpHTML#">