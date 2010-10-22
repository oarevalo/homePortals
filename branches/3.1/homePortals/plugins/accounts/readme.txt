Copyright 2007 - Oscar Arevalo (http://www.oscararevalo.com)

This file is part of HomePortals.

----------------------------------------------------------------------

Instructions:

1. Add the following to the <plugins> section of your application's homePortals-config.xml.cfm

<plugin name="accounts" path="homePortals.plugins.accounts.plugin" />


2. All page paths requested that fall within the accounts root will be treated as account pages,
being the first level above the account root considered the account name and anything after that
will be the account page. 

Examples:

** Considering /accounts to be the accounts root:

a) page = /accounts/some_account/some_page
	This will load the page named "some_page" within the account named "some_account"

b) page = /accounts
	This will load the default account and default page
   
c) page = /accounts/some_account
	This will load the default page on the account "some_account"
	
	