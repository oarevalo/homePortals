<!--- Welcome To HomePortals module --->

<cfset username = ListGetAt(session.homeConfig.href, 2, "/")>

<style type="text/css">
	.welcomeModule {
		font-size:12px;
		background-color:#FFFFCC;
		border:1px dashed silver;
		padding:10px;
		font-family:Arial, Helvetica, sans-serif;
	}
	.welcomeModule li {
		margin-bottom:6px;
	}
</style>

<div class="welcomeModule">
	<cfoutput>
		This is your personal HomePortals site, you can <u>add</u>, <u>remove</u>, and <u>customize</u> pages to your liking. 
		Pretty much everything in any page can be customized by you.<br /><br />
	
		<li>Page content is organized in modules that you can add, edit or remove.</li>
		<li>Use modules to add features like calendars, appointments, RSS Readers, blogs, and more to your pages.</li>
		<li>To add modules to your page you first need to login to your account. Once you are logged in click
			on the <img src="Modules/Welcome/Images/btnAddContent2.gif" align="absmiddle" alt="Add Content"> button
			and select the module you wish to add.</li>
		<li>To add a page to your site, click on the <img src="Modules/Welcome/Images/btnAddPage.gif" align="absmiddle" alt="Add Content"> button
			and type the name of the new page or select one of the pages published by other users.</li>
		<li>To make changes to a module, click on the <img src="/Home/Modules/Welcome/Images/icon_module.gif" align="absmiddle" alt="Module Settings" /> icon on the module's title bar.</li>
		<li>For more customization options, click on <b>Settings</b>.</li>
		<li>Use the following link to access your account directly: <a href="http://#cgi.HTTP_HOST#/Accounts/#username#"><b>http://#cgi.HTTP_HOST#/Accounts/#username#</b></a></li>
		<li>Find more information, announcements and help by visiting the 
	
		<a href="http://www.homeportals.net/Home/home.cfm?currentHome=/Accounts/HomePortals/layouts/blog.xml"><b>Blog</b></a>,
		<a href="http://www.homeportals.net/Home/home.cfm?currentHome=/Accounts/HomePortals/layouts/Documentation.xml"><b>User Guide</b></a> or the
		<a href="http://www.homeportals.net/Home/home.cfm?currentHome=/Accounts/HomePortals/layouts/Forum.xml"><b>Forums</b></a></li>
		
		<li><a href="javascript:controlPanel.editModule('Welcome1')"><b>Click Here</b></a> and select <b>Delete Module</b> to remove this note.</li>
	</cfoutput>
</div>