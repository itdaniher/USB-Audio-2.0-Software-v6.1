/*
 To Script
 1. Hide All Sections
 2. Insert 'continue' and 'back' links at the end of each section
 3. open/close sections and tasks
 4. modify urls (eg. if opened by xde, help urls need to point to xde manual, else point to equivalent online version)
 5. add functionality to task action links
 
 */

//Create Array of All HTML Tags
var allHTMLTags = document.getElementsByTagName("*");

var cmdOptionsToggle = 0;
var readMoreToggle = 0;
var originalHTML = '';

var openH3 = new Array();
var openH2 = new Array();

function pageSearch(str) {
  var n = 0;
  if (str == "") return false;
  if (!window.find(str)) while(window.find(str, false, true)) n++; 
  else n++;
  if (n == 0) alert("Not found.");
  return false;
}

function toggleElement(elem, type) {
  //Loop through all tags using a for loop
  switch(type) {
    case 'class':
      for (i=0; i<allHTMLTags.length; i++) {
        if(allHTMLTags[i].className == elem) {
          if(allHTMLTags[i].style.display == 'none') allHTMLTags[i].style.display = 'block';
          else allHTMLTags[i].style.display = 'none';
        }
      }
      break;
    case 'id':
      if(document.getElementById(elem).style.display == 'none') document.getElementById(elem).style.display = 'block';
      else document.getElementById(elem).style.display = 'none';
      break;
    case 'name':
      var x = document.getElementsByName(elem);
      for (i=0; i<x.length; i++) {
        if(x[i].style.display == 'none') x[i].style.display = 'block';
        else x[i].style.display = 'none';
      }
      break;
    default:
      if(elem.style.display == 'none') elem.style.display = 'block';
      else elem.style.display = 'none';
  }
  return false;
}

function hideElements(elem, type) {
  //Loop through all tags using a for loop
  switch(type) {
    case 'class':
      for (i=0; i<allHTMLTags.length; i++) {
        if(allHTMLTags[i].className == elem) allHTMLTags[i].style.display = 'none';
      }
      break;
    case 'id':
      document.getElementById(elem).style.display = 'none';
      break;
    case 'name':
      var x = document.getElementsByName(elem);
      for (i=0; i<x.length; i++) x[i].style.display = 'none';
      break;
    default:
      elem.style.display = 'none';
  }
  return false;
}

// cross-browser version of nextSibling and firstChild
function xNextSibling(n, t) {
  var s = n ? n.nextSibling : null;
  while (s) {
    if (s.nodeType == 1 && (!t || s.nodeName.toLowerCase() == t.toLowerCase())){break;}
    s = s.nextSibling;
  }
  return s;
}
function xFirstChild(n,t) {
  var s = n ? n.firstChild : null;
  while (s) {
    if (s.nodeType == 1 && (!t || s.nodeName.toLowerCase() == t.toLowerCase())){break;}
    s = s.nextSibling;
  }
  return s;
}
function xLastChild(n,t) {
  var s = n ? n.lastChild : null;
  while (s) {
    if (s.nodeType == 1 && (!t || s.nodeName.toLowerCase() == t.toLowerCase())){break;}
    s = s.previousSibling;
  }
  return s;
}

function prepareContents() {
  //var ver = getInternetExplorerVersion();
  //if(ver != -1 && ver<8) insertTips();
  
  //add switch to flat list link
  //$('#switchcontent').replaceWith('<span id="switchcontent"><a href="javascript:restoreHTML();">Go to flat view</a></span>');
  
  insertIndex();
  addTaskContinueLink();
  activateTaskToggleLink();
  hideAllTopics();
  striph3();
  
  $('.content').prepend('<h2>Introduction</h2>');
  //draggableTextArea();
  //setSelectAll();
  
  //swap svg images
  //swapSVGImages();
}

function getInternetExplorerVersion() {
  var rv = -1; // Return value assumes failure.
  if (navigator.appName == 'Microsoft Internet Explorer') {
    var ua = navigator.userAgent;
    var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
    if (re.exec(ua) != null)
      rv = parseFloat( RegExp.$1 );
  }
  return rv;
}

function insertTips() {
  for (i=0; i<allHTMLTags.length; i++) {
	switch(allHTMLTags[i].className) {
      case 'toolsoutput': 
        allHTMLTags[i].innerHTML = '<span class="toolsoutput-before">tools output:<br /> </span>'+allHTMLTags[i].innerHTML;
        break;
	  case 'note': 
        allHTMLTags[i].innerHTML = '<span class="note-before">note </span>'+allHTMLTags[i].innerHTML;
        break;
	  case 'info': 
        allHTMLTags[i].innerHTML = '<span class="info-before">tip </span>'+allHTMLTags[i].innerHTML;
        break;
      case 'danger':
        allHTMLTags[i].innerHTML = '<span class="danger-before">caution </span>'+allHTMLTags[i].innerHTML;
        break;
      case 'newinxc':
        allHTMLTags[i].innerHTML = '<span class="newinxc-before">New in XC </span>'+allHTMLTags[i].innerHTML;
        break;
      case 'warning':
        allHTMLTags[i].innerHTML = '<span class="warning-before">warning </span>'+allHTMLTags[i].innerHTML;
        break;
      case 'topofpage':
        allHTMLTags[i].innerHTML = '<span class="topofpage-before"><img src="images/topofpage.gif" alt="" />: </span>'+allHTMLTags[i].innerHTML;
        break;
      case 'codeoptions':
        allHTMLTags[i].innerHTML = '<span class="codeoptions-before">CODE: </span>'+allHTMLTags[i].innerHTML;
        break;
      default:
    }
  }
  return false;
}

function insertIndex() {
 //loop through all <h2> elements and fetch #id and contents
  var indexid = [];
  var indexname = [];
  for (i=0; i<allHTMLTags.length; i++) {
    if(allHTMLTags[i].tagName == 'H1') {
      allHTMLTags[i].setAttribute('id', 'page-h1');
    }
    if(allHTMLTags[i].tagName == 'H2') {
      indexid.push(allHTMLTags[i].id);
      indexname.push(allHTMLTags[i].innerHTML);
    }
  }
  
  //<li><a href="#" id="index-intro" onclick="hideAllTopics(); return toggleTopic(\'.content\');" title="Introduction">Introduction</a></li>
  var indexhtml = '<div id="index"><ul>';
  for (i=0; i<indexid.length; i++) {
    indexhtml += '<li><a href="#" id="index-'+indexid[i]+'" onclick="return toggleTopic(\'#' + indexid[i] + '\');" title="'+indexname[i]+'">'+indexname[i]+'</a></li>';
  }
  indexhtml += '</ul></div>';
  $(indexhtml).insertAfter('h1');
}

function toggleTopic(id) {
  if(id != '.content') {
    //hide all previous sections
    $(id).prevUntil('.content').hide();
    $(id).nextUntil('#footer').hide();
    
    //show this section heading
    $(id).show();
    //show all contents below this section up until the next section heading
    $(id).nextUntil('h2').show();
    
    //hide tasks in this section
    var start1 = false;
    var start2 = false;
    var start3 = false;
    var start4 = false;
    for (i=0; i<allHTMLTags.length; i++) {
      if('#'+allHTMLTags[i].id == id) start1 = true;
      if(start1) {
        if(openH2[allHTMLTags[i].id] == 'current_topic' && openH3.length!=0) start4 = true;
        if(start4 && allHTMLTags[i].className == 'task_continue') {
          allHTMLTags[i].style.display = 'none';
          start4 = false;
        } else if(allHTMLTags[i].tagName == 'H3') {
          start2 = true;
          if(start3) start3 = false;
          if(openH3[allHTMLTags[i].id] == 'current_task' || openH3[allHTMLTags[i].id] == 'open_task') start3 = true;
        } else if(start2 && allHTMLTags[i].parentNode.parentNode.className == 'content') {
          if(!start3 && xNextSibling(allHTMLTags[i]).tagName != 'H2') allHTMLTags[i].style.display = 'none';
          if(allHTMLTags[i].tagName == 'H2') break;
        }
      }
    }
    
    //show topic continue link
    //$(id+' span').eq(-1).show();
  } else {
    $(id).children().first().nextUntil('h2').show();
  }
}
function toggleTask(tid) {
  //currently opened task
  openH3[$(tid).attr('id')] = 'current_task';
  
  //hide all contents before this task up until the next task or topic heading
  var prevh2count = 0;
  var prevh3count = 0;
  prevh2count = $(tid).prevUntil('h2').size();
  prevh3count = $(tid).prevUntil('h3').size();
  //if this is the first task heading, hide all previous until topic heading, else hide all previous until task heading
  if(prevh2count <= prevh3count) $(tid).prev('.task_continue').hide();
  else {
    $(tid).prevUntil('h3').hide();
    $(tid).prev().prev().prev().removeClass('bold');
  }
  
  //show all contents after this task up until the next task or topic heading
  var h2count = 0;
  var h3count = 0;
  h2count = $(tid).nextUntil('.task_start').size();
  h3count = $(tid).nextUntil('h3').size();  
  //if this is the last heading, show all until next section heading, else show all until next task heading
  if(h2count <= h3count) {
    $(tid).nextUntil('.task_start').show();
    $(tid).nextUntil('.task_start').removeClass('even');
    $(tid).nextUntil('.task_start').removeClass('odd');
    $(tid).addClass('bold');
  } else {
    $(tid).nextUntil('h3').show();
    $(tid).nextUntil('h3').removeClass('even');
    $(tid).nextUntil('h3').removeClass('odd');
    $(tid).addClass('bold');
  }
  //once shown, don't allow toggle on heading click, until you've clicked continue
  $(tid).removeAttr('onclick');
  //fetch h3 before this continue and reinstate toggleTaskHeading
  var start = false;
  for (i=(allHTMLTags.length-1); i>=0; i--) {
    if(start && allHTMLTags[i].tagName == 'H3') {
      allHTMLTags[i].setAttribute('onclick', "return toggleTaskHeading(\'#\'+$(this).attr(\'id\'));");
      openH3[allHTMLTags[i].id] = 'completed_task';
      break;
    }
    if(allHTMLTags[i].getAttribute('id') == $(tid).attr('id')) start = true;
  }
  //rehide explicitly hidden elements
  $(".hidden").hide();
}

function toggleTaskHeading(hid) {
  
  //show all contents after this task up until the next task or topic heading
  var h2count = 0;
  var h3count = 0;
  h2count = $(hid).nextUntil('.task_start').size();
  h3count = $(hid).nextUntil('h3').size();  
  //if this is the last heading, show all until next section heading
  if(h2count <= h3count) {
    if($.trim($(hid).next().attr('style')) == 'display: none;') {
      $(hid).nextUntil('.task_start').addClass($(hid).attr('class'));
      $(hid).addClass('bold');
      $(hid).nextUntil('.task_start').show();
      openH3[$(hid).attr('id')] = 'open_task';
    } else {
      $(hid).nextUntil('h3').removeClass($(hid).attr('class'));
      $(hid).removeClass('bold');
      $(hid).nextUntil('h3').hide();
      openH3[$(hid).attr('id')] = 'close_task';
    }
  } else {
    //else show all until next task heading
    if($.trim($(hid).next().attr('style')) == 'display: none;') {
      $(hid).nextUntil('h3').addClass($(hid).attr('class'));
      $(hid).addClass('bold');
      openH3[$(hid).attr('id')] = 'open_task';
      $(hid).nextUntil('h3').show();
    } else {
      $(hid).nextUntil('h3').removeClass($(hid).attr('class'));
      $(hid).removeClass('bold');
      openH3[$(hid).attr('id')] = 'close_task';
      $(hid).nextUntil('h3').hide();
    }
  }

  if(openH3[$(hid).attr('id')]!='current_task') {
    //hide task_continue link
    var start = false;
    for (i=0; i<allHTMLTags.length; i++) {
      if(allHTMLTags[i].id == $(hid).attr('id')) start = true;
      if(start) {
        if($(allHTMLTags[i]).hasClass('task_continue')) allHTMLTags[i].setAttribute("style", 'display:none;');
        if($(allHTMLTags[i]).hasClass('task_start') || $(allHTMLTags[i]).hasClass('task_continue')) break;
      }
    }
  }
  
  $(".hidden").hide();
}

function expandid(id) {
  $('#'+id).removeAttr('style');
  $('#'+id).toggleClass('hidden');
}

function showmore(thiselem, id) {
  $('#'+id).removeAttr('style');
  $('#'+id).toggleClass('hidden');
  $(thiselem).toggleClass('hidden');
}

function striph3() {
  var counter = 0
  for (i=0; i<allHTMLTags.length; i++) {
    if(allHTMLTags[i].tagName == 'H3') {
      if(counter%2) {
        allHTMLTags[i].setAttribute('class', 'even');
      } else {
        allHTMLTags[i].setAttribute('class', 'odd');
      }
      counter++;
    }
  }
}

//hide all topic contents
function hideAllTopics() {
  $("h2").hide();
  $("h2").nextUntil("h2").hide();
}

function restoreHTML() {
  $('body').empty();
  $('body').prepend(originalHTML);
  return false;
}

function nextTopic(nid) {
  openH2[nid] = 'current_topic';
  
  //insert tick next to topic index item
  var start = false;
  var start2 = false;
  var start3 = false;
  var finished = 'index-'+nid;
  for (i=(allHTMLTags.length-1); i>=0; i--) {
    if(start && allHTMLTags[i].getAttribute('id')!=null) {
      var tickelem = allHTMLTags[i].getAttribute('id');
      $('#'+tickelem).removeClass('current');
      
      if(allHTMLTags[i].getAttribute('id') != 'index') {
        $('#'+tickelem).addClass('complete');
      }
      break;
    }
    if(allHTMLTags[i].getAttribute('id') == finished) {
      $('#'+finished).addClass('current');
      start = true;
    }
    if(start2 && allHTMLTags[i].getAttribute('id')!=null) {
      if(!start3 && allHTMLTags[i].tagName == 'H3') {
        openH3[allHTMLTags[i].getAttribute('id')] = 'closed_task';
        start3 = true;
      }
      if(allHTMLTags[i].tagName == 'H2') {
        openH2[allHTMLTags[i].getAttribute('id')] = 'completed_topic';
      }
    }
    if(allHTMLTags[i].getAttribute('id') == nid) {
      start2 = true
    }
  }
  
  // alert(print_array(openH2));
  // alert(print_array(openH3));
  
  return toggleTopic('#'+nid);
}

function print_array(ar) {
  var strtext = '';
  for(var key in ar) {
    strtext += key+' = '+ar[key]+'\n';
  }
  return strtext;
}

function addTaskContinueLink() {
  //before every <h2> insert 'go to {h2 title}' link
  $('h2').prev().append('<div class="task_start"><a href="#" onclick="return nextTopic($(this).parent().parent().next().attr(\'id\'))">Go to next topic</a></div>');
  //before every <h3> insert 'Click to Continue' link
  $('<div class="task_continue"><a href="#" onclick="return toggleTask(\'#\'+$(this).parent().next().attr(\'id\'));">Click to Continue</a></div>').insertBefore($('h3'));
  //first h3 after h2...
  return false;
}
function activateTaskToggleLink() {
  //place toggle actions on task heading links
  $("h3").each(function(i) { this.setAttribute('onclick', "return toggleTaskHeading(\'#\'+$(this).attr(\'id\'));"); });
}

function inactivetaskhead() {
  for (i=0; i<allHTMLTags.length; i++) {
    if(allHTMLTags[i].className == 'task') xNextSibling(xFirstChild(allHTMLTags[i])).setAttribute('class', '');
  }
}

function draggableTextArea() {
  for (i=0; i<allHTMLTags.length; i++) {
    if(allHTMLTags[i].className == 'linecode') {
      //add draggable widget to this element
    }
  }
}

function setSelectAll() {
  for (i=0; i<allHTMLTags.length; i++) {
    if(allHTMLTags[i].className == 'codeoptions') {
      allHTMLTags[i].style.display = 'block !important';
      xFirstChild(allHTMLTags[i]).setAttribute('onclick', "return selectElementText(xNextSibling(this.parentNode));");
    }
  }
}
function selectElementText(el, win) {
  win = win || window;
  var doc = win.document, sel, range;
  if (win.getSelection && doc.createRange) {
    sel = win.getSelection();
    range = doc.createRange();
    range.selectNodeContents(el);
    sel.removeAllRanges();
    sel.addRange(range);
  } else if (doc.body.createTextRange) {
    range = doc.body.createTextRange();
    range.moveToElementText(el);
    range.select();
  }
}

function swapSVGImages() {
  if(supportsSvg()) {
    for (i=0; i<allHTMLTags.length; i++) {
      if(allHTMLTags[i].className == 'svg') {
        allHTMLTags[i].setAttribute('onclick', 'return expandSVG(this);');
        xFirstChild(allHTMLTags[i]).src = xFirstChild(allHTMLTags[i]).src.replace('.png', '.svg');
      }
    }
  }
}
function supportsSvg() {
  return document.implementation.hasFeature("http://www.w3.org/TR/SVG11/feature#BasicStructure", "1.1");
}
function expandSVG(elem) {
  if(xFirstChild(elem).getAttribute('width') == '100%') {
    xFirstChild(elem).setAttribute('width', 'auto');
    elem.setAttribute('title', 'click to zoom in');
  } else {
    xFirstChild(elem).setAttribute('width', '100%');
    elem.setAttribute('title', 'click to zoom out');
  }
}

/* form 
function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      oldonload();
      func();
    }
  }
}
*/
function prepareInputsForHints() {
  var inputs = document.getElementsByTagName("input");
  for (var i=0; i<inputs.length; i++){
    inputs[i].onfocus = function () {
      this.parentNode.getElementsByTagName("span")[0].style.display = "inline";
    }
    inputs[i].onblur = function () {
      this.parentNode.getElementsByTagName("span")[0].style.display = "none";
    }
  }
  var selects = document.getElementsByTagName("select");
  for (var k=0; k<selects.length; k++){
    selects[k].onfocus = function () {
      this.parentNode.getElementsByTagName("span")[0].style.display = "inline";
    }
    selects[k].onblur = function () {
      this.parentNode.getElementsByTagName("span")[0].style.display = "none";
    }
  }
}


/* implemented by doug - someone to review/fix 
   seems that setting allHTML[i].style.backgroundImage = "url(.......minus.gif)"; only works on absolute urls
*/
function toggleCmdOptions() {
  for (i=0; i<allHTMLTags.length; i++) {
	if (allHTMLTags[i].className == 'cmd-only') {
	  if (cmdOptionsToggle == 0)  
	    allHTMLTags[i].style.display = 'block';
      else
		allHTMLTags[i].style.display = 'none';
	}
	else if (allHTMLTags[i].className == 'cmd-toggle') {
	  if (cmdOptionsToggle == 0) {
	    allHTMLTags[i].innerHTML = 'Hide non-XDE options';
	  }
	  else {
	    allHTMLTags[i].innerHTML = 'Show Non-XDE Options';
      }
	}
  }
  cmdOptionsToggle = !cmdOptionsToggle;

	/*
	if (allHTMLTags[i].className == 'cmd-only') {
	  if (allHTMLTags[i].style.display == 'none') 
	    allHTMLTags[i].style.display = 'block';
      else 
		allHTMLTags[i].style.display = 'none';
	}
	else if (allHTMLTags[i].className == 'cmd-toggle') {
	  alert(allHTMLTags[i].style.backgroundImage);
	  allHTMLTags[i].style.backgroundImage = "url(../common/images/minus.gif)";
	}
  }*/
  return true;
}

function ToggleReadMore() {
  for (i=0; i<allHTMLTags.length; i++) {
	if (allHTMLTags[i].className == 'readmore-toggle') {
	  if (readMoreToggle == 0)  
	    allHTMLTags[i].style.display = 'block';
      else
		allHTMLTags[i].style.display = 'none';
	}
	else if (allHTMLTags[i].className == 'readmore') {
	  if (readMoreToggle == 0) {
	    allHTMLTags[i].style.display = 'none';
	  }
	  else {
	    allHTMLTags[i].style.display = 'block';
      }
	}
  }
  readMoreToggle = !readMoreToggle;
  return true;
}

function modifyHtmlContents() {
  var flag;
  
  //find #index and unhide
  toggleElement('index', 'id');
  
  //change <h2 class="topic"> to <h2 class="h2topic">, <h2 class="h2topic-first"> for the first <h2>
  $('.topic').first().addClass("h2topic-first");
  $('.h2topic-first').removeClass('topic');
  $('.topic').addClass("h2topic");
  $('.h2topic').removeClass('topic');
  
  //insert <div class="topic" id="intro"><h2 id="introduction">Introduction</h2><div class="intro"> after first <div class="content">
  $('.content').first().prepend('[lessthan]div class="topic" id="intro"[greaterthan][lessthan]h2 id="introduction"[greaterthan]Introduction[lessthan]/h2[greaterthan][lessthan]div class="intro"[greaterthan]');
  flag = reloadDOM();
  
  //insert </div></div><div class="topic"> before first <h2>
  $('[lessthan]/div[greaterthan][lessthan]/div[greaterthan][lessthan]div class="topic"[greaterthan]').insertBefore($('.h2topic-first'));
  
  //insert </div></div></div><div class="topic"> before every other <h2>
  $('[lessthan]/div[greaterthan]</div[greaterthan][lessthan]/div[greaterthan]<div class="topic"[greaterthan]').insertBefore($('.h2topic'));
  
  //insert <div class="intro"> after every <h2>
  $('[lessthan]div class="intro"[greaterthan]').insertAfter($('h2'));
  
  //insert </div><div class="task"><div class='complete'></div> before the first <h3> after every <h2>
  $('[lessthan]/div[greaterthan][lessthan]div class="task"[greaterthan][lessthan]div class="complete"[greaterthan][lessthan]/div[greaterthan]').insertBefore($('h3'));
  flag = reloadDOM();
  //insert </div></div><div class="task"><div class='complete'></div> before every other <h3>
  $('[lessthan]div[greaterthan]').insertBefore($('h2').find($('.task').first()));
  $('[lessthan]/div[greaterthan]').insertBefore($('h2').find($('.task')));
  
  //insert <div class='contents'> after every <h3>
  $('h3').prepend('[lessthan]div class="contents"[greaterthan]');
  
  //insert </div> before <div id="footer">
  $('[lessthan]/div[greaterthan]').insertBefore($('#footer'));
  flag = reloadDOM();
}

function reloadDOM() {
  var body = document.body.innerHTML;
  body = body.replace(/\[lessthan\]/g, '<')
  body = body.replace(/\[greaterthan\]/g, '>')
  $('.indented-content').empty();
  $('.indented-content').prepend(body);
  return true;
}

//$(document).ready(function() {
  //add switch to flat list link
  //$('<span id="switchcontent"><a href="#" onclick="return prepareContents();">Go to tutorial view</a></span>').insertBefore($('h1'));
  //originalHTML = $('body').html();
//});