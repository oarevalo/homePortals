Copyright 2007 - Oscar Arevalo (http://www.oscararevalo.com)

This file is part of HomePortals.

HomePortals is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

HomePortals is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with HomePortals.  If not, see <http://www.gnu.org/licenses/>.

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
