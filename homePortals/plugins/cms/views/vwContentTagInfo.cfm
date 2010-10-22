<cfparam name="arguments.tagName" default="">
<cfset objPath = variables.homePortals.getConfig().getContentRenderer(arguments.tagName)>
<cfset obj = createObject("component",objPath)>
<cfset tagInfo = getMetaData(obj)>
<cfoutput>
	<cfif structKeyExists(tagInfo,"hint") and tagInfo.hint neq "">
		<div class="cms-lightPanel" style="margin-bottom:5px;">
			<img src="#cmsRoot#/images/information.png" align="absmiddle">
			#tagInfo.hint#
		</div>
	</cfif>
</cfoutput>