<!--- Module: Image  

This module displays an image with the given attributes.

------>

<cfparam name="attributes.Module" default="#StructNew()#">
<cfparam name="Attributes.Module.XMLAttributes.src" default="">
<cfparam name="Attributes.Module.XMLAttributes.href" default="">
<cfparam name="Attributes.Module.XMLAttributes.width" default="">
<cfparam name="Attributes.Module.XMLAttributes.height" default="">
<cfparam name="Attributes.Module.XMLAttributes.alt" default="">

<cfscript>
	args = structNew();
	args.src = Attributes.Module.XMLAttributes.src;
	args.href = Attributes.Module.XMLAttributes.href;
	args.width = Attributes.Module.XMLAttributes.width;
	args.height = Attributes.Module.XMLAttributes.height;
	args.alt = Attributes.Module.XMLAttributes.alt;
	args.title = Attributes.Module.XMLAttributes.alt;
</cfscript>

<cfoutput>
	<cfif args.src eq "">
		<p>Use the <b>src</b> attribute to enter the image source.</p>
		<cfexit>
	</cfif>

	<cfset lstAttribs = "">
	<cfloop collection="#args#" item="attr">
		<cfif args[attr] neq "">
			<cfset lstAttribs = lstAttribs & "#attr#=""#args[attr]#"" ">
		</cfif> 
	</cfloop>
	
	<cfif args.href eq "">
		<img #lstAttribs# />
	<cfelse>
		<a href="#args.href#"><img border="0" #lstAttribs# /></a>		
	</cfif>
</cfoutput>
