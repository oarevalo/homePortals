Copyright 2007 - Oscar Arevalo (http://www.oscararevalo.com)

This file is part of HomePortals.

----------------------------------------------------------------------

Instructions:

1. Add the following to the <plugins> section of your application's homePortals-config.xml.cfm

<plugin name="modules" path="homePortals.plugins.modules.plugin" />


2. create a file named gateway.cfm at the root level of your application 
with the following contents:

<cfinclude template="/homePortals/plugins/modules/gateway.cfm">

