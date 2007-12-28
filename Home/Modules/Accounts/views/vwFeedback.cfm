<!--- 
vwFeedback

Allows users to send feedback and comments back to CFEmpire

** This file should be included from addContent.cfc

History:
1/9/06 - oarevalo - created
---->

<div class="cp_sectionTitle" style="padding:0px;width:340px;">
	<div style="margin:2px;">We Want To Hear From You</div>
</div>

<div class="cp_sectionBox" style="margin-top:0px;height:300px;width:340px;padding:0px;">
	<form name="frm" action="#" method="post" style="margin:10px;">
		<p>Use the following space to send us your comments, questions, observations. 
		We want to hear what do you think of our site, where can we improve it,
		what modules would you like to see, etc.</p>
		
		<p>If you have questions please include an email where we can answer you.</p>
	
		<p>
			<textarea name="comments" rows="5" cols="50"></textarea>
		</p>
		
		<p><input type="button" value="Send" onclick="controlPanel.sendFeedback(this.form)"></p>
	</form>
</div>