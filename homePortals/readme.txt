/**************************************************************/	
/* HomePortals  (v3.2.x beta)										  */
/* http://www.homeportals.net
/**************************************************************/	

/*
	homePortals
	http://www.homeportals.net

    This file is part of HomePortals.

	Copyright 2007-2010 Oscar Arevalo
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.	
*/ 

-----------------------------------------------------------------------
Contents:
-----------------------------------------------------------------------
1. About HomePortals
2. Release Notes
3. System Requirements
4. Installing HomePortals
5. Using HomePortals / Documentation
6. Acknowledgements / Thanks / Credits
7. Bugs / suggestions


-----------------------------------------------------------------------
1. About HomePortals
-----------------------------------------------------------------------
HomePortals is a CFML framework used to facilitate the layout and rendering 
of modular components on web-based applications. Since HomePortals only deals 
with the layout management of a web page, it can easily integrate with more 
general MVC frameworks. 

HomePortals provides a runtime engine that processes documents called 
HomePortals Pages that provide information as to what resources to include on
a page and how to organize them.

HomePortals modular architecture allows it to be extended and customized on
almost every aspect. Developers can register custom resource types, custom
renderers and even custom templates.

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
This version of HomePortals have been developed primarily using 
ColdFusion 8.01 and Railo 3.
Also, HomePortals requires that creation of CFC and Java objects is
enabled. 





-----------------------------------------------------------------------
4. Installing HomePortals
-----------------------------------------------------------------------
Installing HomePortals is as easy as unzipping the installation package at the webserver root. 
All HomePortals files are contained within a single directory called /homePortals that must sit at the
root level of your site. 
To verify the installation, use your browser to go to the /homePortals directory and you will see the
current version of your HomePortals installation.



-----------------------------------------------------------------------
5. Using HomePortals / Documentation
-----------------------------------------------------------------------
See http://wiki.homeportals.net for more information



-----------------------------------------------------------------------
6. Acknowledgements / Thanks / Credits
-----------------------------------------------------------------------
A lot of people have contributed ideas, inspiration and/or good vibrations during all the time I have been developing
this project, in particular I'd like to thank Luis Majano (the master of all things CF), 
John Nail (always taking HomePortals to its limits -- and beyond), 
my wife Isa, Tom DeManincor and Anabel Fernandez (you were there when it all began!!)




-----------------------------------------------------------------------
8. Bugs, suggestions, criticisms, well-wishes, good vibrations, etc
---------------------------------------------------------------------------
Please send them to info@homeportals.net or share them on the forum at http://www.homeportals.net/




