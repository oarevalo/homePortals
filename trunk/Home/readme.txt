/**************************************************************/	
/* HomePortals  (v3.1.x beta)										  */
/* http://www.homeportals.net
/**************************************************************/	

/*
	Copyright 2007-2008 - Oscar Arevalo (http://www.oscararevalo.com)

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

*/ 

-----------------------------------------------------------------------
Contents:
-----------------------------------------------------------------------
1. About HomePortals
2. Release Notes
3. System Requirements
4. Installing HomePortals
5. Database Support
6. Creating HomePortals Applications
7. Default URL Parameters
8. Acknowledgements / Thanks / Credits
9. Bugs / suggestions


-----------------------------------------------------------------------
1. About HomePortals
-----------------------------------------------------------------------
HomePortals is a platform that allows developers to build rich and modular
web applications by combining existing reusable resources into a single page.

HomePortals provides a runtime engine that processes documents called 
HomePortals Pages that provide information as to what resources to include on
a page and how to organize them.

Additionally, it provides a simple yet powerful framework on which to develop
"modules" which are the basic functionality units that can be embedded within
a page. Modules can range from the very basic (simple static html content) to 
full fledged AJAX powered mini applications.

HomePortals provides an extensive set of tools and features that allow 
developers to create multiple types of applications like start pages, personal
portals, social networking sites, intranet portals and more.

For more information check http://www.homeportals.net



-----------------------------------------------------------------------
2. Release Notes
-----------------------------------------------------------------------
This third release of HomePortals signals a big shift in the evolution of this project,
not only because of the move from closed source to open source, but because of the
entire refocusing of the project from being a simple configurable portal to being
a platform that can be used to create and execute multiple different applications.

A lot of the code has been rewritten and redesigned, there are many additions compared
from earlier versions, a lot have been done to improve performance but there is a lot of 
room to grow still.

Some of the main features of this release:
* separated HomePortals engine from the application, this allows applications to 
	be located anywhere on the server (even at the root level!)
* added new types of resources: feeds, contents, html, pageTemplates
* added resource directories to manage resources and organize them into packages
* added a "friends" subsystem that allows accounts to be linked to each other
* added access control features for resources
* added smart caching of pages 
* added configurable HTML rendering templates. Now you can modify the HTML structure
	of any rendered content.
and more ...



-----------------------------------------------------------------------
3. System Requirements
-----------------------------------------------------------------------
HomePortals have been developed primarily using ColdFusion MX 7, 
but it also works in: ColdFusion 8 and Railo 2. 
* HomePortals have not yet been tested for BlueDragon. 

Database support is optional, and have been tested for MySQL 4 (and up),
and Microsoft SQL Server (2000 and up). However any relation database that
supports SQL should work with no problem.




-----------------------------------------------------------------------
4. Installing HomePortals
-----------------------------------------------------------------------
Installing HomePortals is as easy as unzipping the installation package at the webserver root. 
All HomePortals files are contained within a single directory called /Home that must sit at the
root level of your site. 
To verify the installation, use your browser to go to the /Home directory and you will see the
current version of your HomePortals installation.




-----------------------------------------------------------------------
5. Database Support
-----------------------------------------------------------------------
By default HomePortals does not require a database to function, however it does provide the option
to use a database to store account information. The HomePortals distribution includes SQL scripts
for MySQL and Microsoft SQL Server, however you can create a table with the same structure in any
database supported by ColdFusion and it should work with no problems.




-----------------------------------------------------------------------
6. Creating HomePortals Applications
-----------------------------------------------------------------------
To create a homeportals application, all you need is a subdirectory named "config" right under the
root of the application directory (can be the webserver root itself). The /config directory should
contain at least the following files:

- homePortals-config.xml
- accounts-config.xml.cfm
- module-properties.xml

These files provide the configuration for the new application. You only need to define the overriding 
properties on these files, this means that any property not defined will have whatever value is defined
on the main config files in /Home/config.

In homePortals-config.xml the most important settings to define are:
appRoot: This is the path to the application directory relative to the webserver root. Always start with "/" 
		(i.e. if the application is on the root directory, then use /)
accountsRoot: This is the path to the directory where all account files will be stored.
resourceLibraryPath: This is the path to the directory where all resources for the application will be stored.
		(resources are modules, skins, feeds, contents, etc)

You can have multiple HomePortals applications on the same server. The only restriction is that they all have
their own appRoot. All other directories can be anything. For example, you may have multiple applications with
the same accounts root but different resource library root; or many applications with different accounts, but that
share the same resources.

Besides the config files, each homeportals application must have the following files at the application root level:

Application.cfc / Application.cfm : To define the ColdFusion application
gateway.cfm : This file is used to provide communication between module clients and servers (think Ajax)
			This file only needs to have the following content:
				<cfinclude template="/Home/Common/Templates/gateway.cfm">
index.cfm : This file is the one responsible for calling the HomePortals engine and rendering a page.
			On its simplest form this file only needs to have the following content:
				<cfinclude template="/Home/Common/Templates/page.cfm">
			This assumes that HomePortals pages will be called by passing the "Account" and "Page" URL 
			parameters into this page.

However, if you do not wish to use URL parameters to identify pages and wish to use a more search engine friendly,
or even use a fancy SES URL, you can also create your own .cfm pages with any name you desire and then manually set 
the Account and Page variables yourself using any method you want BEFORE the <cfinclude /> tag.

NOTE: when using files other than the index.cfm at the application root level to call HomePortals pages, it is very 
important that you define a variable named "request.appRoot" BEFORE calling the <cfinclude /> tag. This will tell the
engine where to locate the config files for the current application. An ideal place to set this variable is on the 
Application.cfc or Application.cfm





-----------------------------------------------------------------------
7. Default URL Parameters
-----------------------------------------------------------------------
By default, the HomePortals engine responds to the following URL parameters: Account, Page and RefreshApp

Account and Page are used to control which HomePortals page to display. You may use only the Account parameter or 
both parameters. When specifying both parameters HomePortals will load the page with the name given by the 
"page" belonging to the account identified with the "Account" parameter. 

The actual page that will be loaded would be:
<accounts_root>/<account_url_param>/layouts/<page_url_param>.xml

If no page is given, then the default page for the given account will be loaded.
When no account and no page are given, then HomePortals will display the default page for the account set as the default
account on the <defaultAccount> setting in /config/homePortals-config.xml

<< Application Reset >>
HomePortals uses the application scope to store multiple settings and to perform caching, however if you need to reset
the application and force the HomePortals engine to reload the configuration, you may use the "refreshApp=1" URL parameter.
Please bear in mind that application startup may take a bit of time to complete depending on the amount of resources
on the resource library of the application. 

NOTE: Since the HomePortals engine does not kick in until the <cfinclude /> tag is used, any of these parameters can be
overloaded with any value by the calling template. This is especially useful for production scenarios in which you may 
want to think about blocking the "refreshApp" parameter to avoid malicious use of the application reset feature.





-----------------------------------------------------------------------
8. Acknowledgements / Thanks / Credits
-----------------------------------------------------------------------
A lot of people have contributed ideas, inspiration and/or good vibrations during all the time I have been developing
this project, in particular I'd like to thank Luis Majano (the master of all things CF), 
John Nail (always taking HomePortals to its limits -- and beyond), 
my wife Isa, Tom DeManincor and Anabel Fernandez (you were there when it all began!!)




-----------------------------------------------------------------------
9. Bugs, suggestions, criticisms, well-wishes, good vibrations, etc
---------------------------------------------------------------------------
Please send them to info@homeportals.net or share them on the forum at http://www.homeportals.net/




