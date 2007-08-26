<cfset setControlPanelTitle("Add Friends","status_online")>

<div class="cp_sectionBox" 
	 style="padding:0px;width:475px;margin:10px;">
	<div style="margin:4px;">
		Enter the username of the account you wish to add as a friend. If the person you wish to add as a friend,
		does not yet has a Xilya.com account, enter their email address to invite him to form part of the Xilya.com
		community.
	</div>
</div>

<fieldset style="margin:10px;border:1px solid #ccc;background-color:#ebebeb;margin-top:30px;">
	<legend><strong>Add friend by account name:</strong></legend>
	<form name="frm" action="#" method="post" style="margin:0px;padding:0px;">
		Account name: <input type="text" name="accountName" value="" style="width:200px;">
		<input type="button" name="btnAdd" value="Add" onclick="controlPanel.addFriend(this.form.accountName.value)">
	</form>
</fieldset>

<fieldset style="margin:10px;border:1px solid #ccc;background-color:#ebebeb;margin-top:30px;">
	<legend><strong>Invite Friend:</strong></legend>
	<form name="frm" action="#" method="post" style="margin:0px;padding:0px;">
		Email address: 
		<input type="text" name="email" value="" style="width:200px;">
		<input type="button" name="btnInvite" value="Invite" onclick="controlPanel.inviteFriend(this.form.email.value)">
	</form>
</fieldset>
