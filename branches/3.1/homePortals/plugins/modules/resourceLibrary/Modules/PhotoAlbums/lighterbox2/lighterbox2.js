//By: Richard Lee - Transcendent Design - tdesignonline.com
var closeimagelink="/homePortals/plugins/modules/resourceLibrary/Modules/PhotoAlbums/lighterbox2/close.gif"
var nextimagelink="/homePortals/plugins/modules/resourceLibrary/Modules/PhotoAlbums/lighterbox2/next.gif"
var previmagelink="/homePortals/plugins/modules/resourceLibrary/Modules/PhotoAlbums/lighterbox2/prev.gif"
var IE6=(navigator.userAgent.indexOf("MSIE 6")>=0)
var safari=(navigator.userAgent.indexOf("Safari")>=0)
var IE=(navigator.userAgent.indexOf("MSIE")>=0)
var opera=(navigator.userAgent.indexOf("Opera")>=0)
var tb=document.getElementsByTagName('body')
var lbox=document.createElement("div")
var llocation
var scrollt
var ltoggle
lbox.setAttribute('id','lighterbox2')
tb[0].appendChild(lbox)
tb[0].insertBefore(lbox,tb[0].firstChild)
var lighterboxwrapper=document.createElement("div")
lighterboxwrapper.setAttribute('id','lighterboxwrapper2')
lbox.appendChild(lighterboxwrapper)
var lc=document.createElement("div")
lc.setAttribute('id','lighterboxclose2')
lc.style.width="100%"
lc.style.height="100%"
lc.style.zIndex="101"
lc.setAttribute('title','Click to Close')
lbox.appendChild(lc)
var labox=document.createElement("div")
labox.setAttribute('id','lighterboxcontent2')
lighterboxwrapper.appendChild(labox)
var portimage=document.createElement('img')
portimage.setAttribute('src','none')
portimage.setAttribute('id','portimage2')
labox.appendChild(portimage)
var lboxlink=document.createElement('div')
lboxlink.setAttribute('id','closebutton2')
labox.appendChild(lboxlink)
var ci=document.createElement('img')
ci.setAttribute('src',closeimagelink)
ci.setAttribute('id','lightercloseimage2')
ci.setAttribute('title','Close')
ci.setAttribute('alt','Close')
lboxlink.appendChild(ci)
var pi=document.createElement('img')
pi.setAttribute('src',previmagelink)
pi.setAttribute('id','previmage2')
pi.setAttribute('title','Previous Image')
pi.setAttribute('alt','Previous')
pi.setAttribute('width','22')
pi.setAttribute('height','17')
lboxlink.appendChild(pi)
var ni=document.createElement('img')
ni.setAttribute('src',nextimagelink)
ni.setAttribute('id','nextimgage2')
ni.setAttribute('title','Next Image')
ni.setAttribute('alt','Next')
ni.setAttribute('width','22')
ni.setAttribute('height','17')
lboxlink.appendChild(ni)
var description=document.createElement('div')
description.setAttribute('id','description2')
lboxlink.appendChild(description)
var txt = document.createTextNode("Lighter Box 2");
description.appendChild(txt)
portimage.style.cursor="pointer"
portimage.setAttribute('title','Click For Next Image')
ci.style.cursor="pointer"
pi.style.cursor="pointer"
ni.style.cursor="pointer"
var piclinks=document.getElementsByTagName('a')
var lighterbox=document.getElementById('lighterbox2')
var bigpic=lighterbox.getElementsByTagName('img')
var thepage=document.getElementById('page')
var z
var picarray = new Array();
function scrolltf()
{if(safari){scrollt=tb[0].scrollTop
return scrollt}
else{scrollt=document.documentElement.scrollTop
return scrollt}}
for(z=0;z<piclinks.length;z++){
if(piclinks[z].getAttribute('rel')=='lighterbox'){
picarray.push(piclinks[z])
piclinks[z].onclick=function(){
searchString=this
if(!IE){llocation=picarray.indexOf(this)}
else{for (var i = 0; i < picarray.length; i++) {
if (picarray[i] == searchString) {
llocation = i
break;}}}
ltoggle=1
return setpic(this)}}}
var closebutton=document.getElementById('lightercloseimage2')
closebutton.onclick=function(){
lbox.style.display="none"
lbox.setAttribute('class','hide')};
function setpic(thispic){
function fadeout(){
for(fo=11;fo>0;fo--){
setTimeout('document.getElementById("portimage2").style.opacity="'+fo/10+'"',fo*20)}}
lc.onclick=function(){lbox.style.display="none"
lbox.setAttribute('class','hide')}
function nif(){
scrolltf()
if(llocation==picarray.length-1){llocation=-1}
setpic(picarray[llocation+=1])}
ni.onclick=nif
portimage.onclick=nif
pi.onclick=function(){
scrolltf()
if(llocation==0){llocation=picarray.length}
setpic(picarray[llocation-=1])}
function checkKeycode(e) {
if(ltoggle==1){
var keycode
if (window.event) keycode = window.event.keyCode;
else if (e) keycode = e.which;
if (keycode == "37"){scrolltf()
if(llocation==0){llocation=picarray.length}
setpic(picarray[llocation-=1])}
else if (keycode == "27") {
lbox.style.display="none"
lbox.setAttribute('class','hide')
ltoggle=0
return false;}
else if ((keycode == "39") || (keycode == "32")){nif();
return false;}}}
document.onkeydown = checkKeycode
var source=thispic.getAttribute("href")
var placeholder=document.getElementById("placeholder2")
var description=document.getElementById("lighterbox2")
if(thispic.getAttribute('rel')=='lighterbox'){
function setdim(){
var imgdim=document.getElementById('portimage2')
imgdim.style.opacity="0"
var mytext=thispic.getAttribute("title")
document.getElementById('description2').firstChild.nodeValue=mytext;
var wr=document.getElementById('lighterboxwrapper2')
imgdim.onload=function(){
var bwidth3=document.documentElement.clientWidth
var bheight3=document.documentElement.clientHeight
var imgdimh=document.getElementById('portimage2').height
var imgdimw=document.getElementById('portimage2').width
wr.style.arginLeft=((bwidth3-imgdimw)/2)+"px"
wr.style.width=imgdimw+"px"
wr.style.height=imgdimh+"px"
for(fd=0;fd<11;fd++){
setTimeout('document.getElementById("portimage2").style.opacity="'+fd/10+'"',fd*30)}
setTimeout("lighterbox.setAttribute('class','show')",100)
setTimeout("lighterbox.style.display='block'",100)
scrolltf()
if(IE6){}
else if(safari){
lbox.style.height=tb[0].scrollHeight+100+"px"
wr.style.top=((bheight3-imgdimh-60)/2)+scrollt+"px"}
else{lbox.style.height=document.documentElement.scrollHeight+100+"px"}
lighterboxwrapper.style.top=((bheight3-imgdimh-60)/2)+scrollt+"px"}}
bigpic[0].setAttribute('src',source)
setdim()
if(IE){lbox.style.display="none"
lbox.style.display="block"
lighterboxwrapper.style.marginTop="10px"
if(!IE6){lighterbox.style.height=document.documentElement.scrollHeight+"px"}}
return false}}
function timedCount(){
var bwidth4=document.documentElement.clientWidth
var bheight4=document.documentElement.clientHeight
var imgdimh4=document.getElementById('portimage2').height
var imgdimw4=document.getElementById('portimage2').width
var wr4=document.getElementById('lighterboxwrapper2')
wr4.style.marginLeft=((bwidth4-imgdimw4)/2)+"px"
if(IE6){wr4.style.position="absolute"
lc.style.display="none"
wr4.style.border="solid 5px #ccc"
}else if(opera){
	scrolltf()
	wr4.style.top=((bheight4-imgdimh4)/2)+scrollt+"px"}
else{wr4.style.width=imgdimw4+"px"}
setTimeout("timedCount()",1)}
timedCount()