Copyright 2007 - Oscar Arevalo (http://www.oscararevalo.com)

This file is part of HomePortals.

----------------------------------------------------------------------

Instructions:

1. Add the following to the <plugins> section of your application's homePortals-config.xml.cfm

<plugin name="accounts" path="homePortals.plugins.accounts.plugin" />


2. [OPTIONAL] If you are using HomePortals in standalone mode, replace your index.cfm with:

<cfinclude template="/homePortals/plugins/accounts/page.cfm">

*** The format to invoke pages within an account is to use "::" as a separator between the account
name and the page name, as in:

page = some_account::some_page

This will load the page named "some_page" within the account named "some_account"
