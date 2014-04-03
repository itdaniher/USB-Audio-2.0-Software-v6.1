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

function toggleContentsElement(elem, type) {
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
      if(document.getElementById('contentsFrame').contentDocument.getElementById(elem).style.display == 'none') document.getElementById('contentsFrame').contentDocument.getElementById(elem).style.display = 'block';
      else document.getElementById('contentsFrame').contentDocument.getElementById(elem).style.display = 'none';
      break;
    case 'name':
      var x = document.getElementById('contentsFrame').contentDocument.getElementsByName(elem);
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

function hideContentsElements(elem, type) {
  //Loop through all tags using a for loop
  switch(type) {
    case 'class':
      for (i=0; i<allHTMLTags.length; i++) {
        //alert(allHTMLTags[i].className);
        if(allHTMLTags[i].className == elem) allHTMLTags[i].style.display = 'none';
      }
      break;
    case 'id':
      document.getElementById('contentsFrame').contentDocument.getElementById(elem).style.display = 'none';
      break;
    case 'name':
      var x = document.getElementById('contentsFrame').contentDocument.getElementsByName(elem);
      for (i=0; i<x.length; i++) x[i].style.display = 'none';
      break;
    default:
      elem.style.display = 'none';
  }
  return false;
}
function activateIndexLinks() {
  allHTMLTags = document.getElementById('contentsFrame').contentDocument.getElementsByTagName("*");
  //place toggle actions on index links
  var indexlinks = document.getElementById('index').getElementsByTagName("a");
  for (i=0; i<indexlinks.length; i++) {
    indexlinks[i].setAttribute('onclick', "hideContentsElements('section', 'class'); return toggleContentsElement(this.href.slice(this.href.lastIndexOf('#')+1), 'id');");
  }
}

function addTaskContinueLink() {
  //Loop through all tags using a for loop
  for (i=0; i<allHTMLTags.length; i++) {
    
    if(allHTMLTags[i].className == 'contents' || allHTMLTags[i].className == 'contents_first') {
      if(xNextSibling(allHTMLTags[i].parentNode) == null) allHTMLTags[i].innerHTML += '<span class="task_start"><a href="#" onclick="hideElements(this.parentNode.parentNode.parentNode.parentNode, null); toggleElement(xFirstChild(this.parentNode.parentNode.parentNode), null); xNextSibling(xFirstChild(xNextSibling(this.parentNode.parentNode.parentNode.parentNode))).setAttribute(\'className\', \'active\'); return toggleElement(xNextSibling(this.parentNode.parentNode.parentNode.parentNode), null);">Go to \''+ xFirstChild(xNextSibling(allHTMLTags[i].parentNode.parentNode)).innerHTML +'\'</a></span>';
      else allHTMLTags[i].innerHTML += '<span class="task_continue"><a href="#" onclick="hideElements(this.parentNode.parentNode, null); toggleElement(xFirstChild(this.parentNode.parentNode.parentNode), null); inactivetaskhead(); xNextSibling(xFirstChild(xNextSibling(this.parentNode.parentNode.parentNode))).setAttribute(\'className\', \'active\'); return toggleElement(xLastChild(xNextSibling(this.parentNode.parentNode.parentNode)), null);">Click to Continue</a></span>';
    } else if(allHTMLTags[i].className == 'intro') {
      if(xNextSibling(allHTMLTags[i]) == null) allHTMLTags[i].innerHTML += '<span class="task_start"><a href="#" onclick="hideElements(this.parentNode.parentNode.parentNode, null); toggleElement(xFirstChild(this.parentNode.parentNode.parentNode), null); xNextSibling(xFirstChild(xNextSibling(this.parentNode.parentNode.parentNode))).setAttribute(\'className\', \'active\'); return toggleElement(xNextSibling(this.parentNode.parentNode.parentNode), null);">Go to \''+ xFirstChild(xNextSibling(allHTMLTags[i].parentNode)).innerHTML +'\'</a></span>';
      //else allHTMLTags[i].innerHTML += '<span class="task_continue"><a href="#" onclick="hideElements(this.parentNode, null); return toggleElement(xLastChild(xNextSibling(this.parentNode.parentNode)), null);">Click to Continue</a></span>';
    }
  
  }
  return false;
}

function activateTaskToggleLink() {
  //place toggle actions on task heading links
  for (i=0; i<allHTMLTags.length; i++) {
    if(allHTMLTags[i].className == 'task') {
      xNextSibling(xFirstChild(allHTMLTags[i])).setAttribute('onclick', "inactivetaskhead(); hideElements('contents', 'class'); xNextSibling(xNextSibling(xFirstChild(xNextSibling(xNextSibling(xFirstChild(this.parentNode.parentNode)))))).style.display = \'none\'; toggleElement(xNextSibling(this), null); this.focus(); this.setAttribute('className', 'active'); return false;");
    }
  }
}
function inactivetaskhead() {
  for (i=0; i<allHTMLTags.length; i++) {
    if(allHTMLTags[i].className == 'task') xNextSibling(xFirstChild(allHTMLTags[i])).setAttribute('className', '');
  }
 
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
  var ver = getInternetExplorerVersion();
  if(ver != -1 && ver<8) insertTips();
  
  //hideAll sections and task contentd
  toggleElement('section', 'class');
  toggleElement('contents', 'class');
  toggleElement('complete', 'class');
  
  draggableTextArea();
  
  setSelectAll();
  
  //unhide intro section
  toggleElement('intro', 'id');

  addTaskContinueLink();
  activateTaskToggleLink();
  
  //swap svg images
  swapSVGImages();
  
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

/* Expand/Collapse TOC */

var openLists = [], oIcount = 0;
function compactMenu(oID,oAutoCol,oPlMn,oMinimalLink) {
	if( !document.getElementsByTagName || !document.childNodes || !document.createElement ) { return; }
	var baseElement = document.getElementById( oID ); if( !baseElement ) { return; }
	compactChildren( baseElement, 0, oID, oAutoCol, oPlMn, baseElement.tagName.toUpperCase(), oMinimalLink && oPlMn );
}
function compactChildren( oOb, oLev, oBsID, oCol, oPM, oT, oML ) {
	if( !oLev ) { oBsID = escape(oBsID); if( oCol ) { openLists[oBsID] = []; } }
	for( var x = 0, y = oOb.childNodes; x < y.length; x++ ) { if( y[x].tagName ) {
		//for each immediate LI child
		var theNextUL = y[x].getElementsByTagName( oT )[0];
		if( theNextUL ) {
			//collapse the first UL/OL child
			theNextUL.style.display = 'none';
			//create a link for expanding/collapsing
			var newLink = document.createElement('A');
			newLink.setAttribute( 'href', '#' );
      newLink.className = 'close';
			newLink.onclick = new Function( 'clickSmack(this,' + oLev + ',\'' + oBsID + '\',' + oCol + ',\'' + escape(oT) + '\');return false;' );
			//wrap everything upto the child U/OL in the link
			if( oML ) { var theHTML = ''; } else {
				var theT = y[x].innerHTML.toUpperCase().indexOf('<'+oT);
				var theA = y[x].innerHTML.toUpperCase().indexOf('<A');
				var theHTML = y[x].innerHTML.substr(0, ( theA + 1 && theA < theT ) ? theA : theT );
				while( !y[x].childNodes[0].tagName || ( y[x].childNodes[0].tagName.toUpperCase() != oT && y[x].childNodes[0].tagName.toUpperCase() != 'A' ) ) {
					y[x].removeChild( y[x].childNodes[0] ); }
			}
			y[x].insertBefore(newLink,y[x].childNodes[0]);
			y[x].childNodes[0].innerHTML = oPM + theHTML.replace(/^\s*|\s*$/g,'');
			theNextUL.MWJuniqueID = oIcount++;
			compactChildren( theNextUL, oLev + 1, oBsID, oCol, oPM, oT, oML );
} } } }
function clickSmack( oThisOb, oLevel, oBsID, oCol, oT ) {
	if( oThisOb.blur ) { oThisOb.blur(); }
	oThisOb = oThisOb.parentNode.getElementsByTagName( unescape(oT) )[0];
	if( oCol ) {
		for( var x = openLists[oBsID].length - 1; x >= oLevel; x-=1 ) { 
      if( openLists[oBsID][x] ) {
  			openLists[oBsID][x].style.display = 'none';
        xFirstChild(oThisOb.parentNode).className = 'close';
        if( oLevel != x ) {
          openLists[oBsID][x] = null; 
        }
      }
    }
		if( oThisOb == openLists[oBsID][oLevel] ) {
      openLists[oBsID][oLevel] = null;
    } else {
      oThisOb.style.display = 'block';
      openLists[oBsID][oLevel] = oThisOb;
      xFirstChild(oThisOb.parentNode).className = 'open';
    }
	} else { 
    if( oThisOb.style.display == 'block' ) {
      oThisOb.style.display = 'none';
      xFirstChild(oThisOb).className = 'close';
    } else {
      oThisOb.style.display = 'block'; 
      xFirstChild(oThisOb).className = 'open';
    }
  }
}
function stateToFromStr(oID,oFStr) {
	if( !document.getElementsByTagName || !document.childNodes || !document.createElement ) { return ''; }
	var baseElement = document.getElementById( oID ); if( !baseElement ) { return ''; }
	if( !oFStr && typeof(oFStr) != 'undefined' ) { return ''; } if( oFStr ) { oFStr = oFStr.split(':'); }
	for( var oStr = '', l = baseElement.getElementsByTagName(baseElement.tagName), x = 0; l[x]; x++ ) {
		if( oFStr && MWJisInTheArray( l[x].MWJuniqueID, oFStr ) && l[x].style.display == 'none' ) { l[x].parentNode.getElementsByTagName('a')[0].onclick(); }
		else if( l[x].style.display != 'none' ) { oStr += (oStr?':':'') + l[x].MWJuniqueID; }
	}
	return oStr;
}
function MWJisInTheArray(oNeed,oHay) { for( var i = 0; i < oHay.length; i++ ) { if( oNeed == oHay[i] ) { return true; } } return false; }
function selfLink(oRootElement,oClass,oExpand,oLink) {
	var tmpLink;
	if(!document.getElementsByTagName||!document.childNodes) { return; }
	oRootElement = document.getElementById(oRootElement);
	if( oLink ) {
		tmpLink = document.createElement('a');
		tmpLink.setAttribute('href',oLink);
	}
	for( var x = 0, y = oRootElement.getElementsByTagName('a'); y[x]; x++ ) {
		if( y[x].getAttribute('href') && !y[x].href.match(/#$/) && getRealAddress(y[x]) == getRealAddress(oLink?tmpLink:location) ) {
			y[x].className = (y[x].className?(y[x].className+' '):'') + oClass;
			if( oExpand ) {
				oExpand = false;
				for( var oEl = y[x].parentNode, ulStr = ''; oEl != oRootElement && oEl != document.body; oEl = oEl.parentNode ) {
					if( oEl.tagName && oEl.tagName == oRootElement.tagName ) { ulStr = oEl.MWJuniqueID + (ulStr?(':'+ulStr):''); } }
				stateToFromStr(oRootElement.id,ulStr);
} } } }
function getRealAddress(oOb) { return oOb.protocol + ( ( oOb.protocol.indexOf( ':' ) + 1 ) ? '' : ':' ) + oOb.hostname + ( ( typeof(oOb.pathname) == typeof(' ') && oOb.pathname.indexOf('/') != 0 ) ? '/' : '' ) + oOb.pathname + oOb.search; }
function expandCollapseAll(oElID,oState) {
	if(!document.getElementsByTagName||!document.childNodes) { return; }
	var oEl = document.getElementById(oElID);
	var oT = oEl.tagName;
	var oULs = oEl.getElementsByTagName(oT);
	for( var i = 0, oLnk; i < oULs.length; i++ ) {
		if( typeof(oULs[i].MWJuniqueID) != 'undefined' ) {
			oLnk = oULs[i].parentNode.getElementsByTagName( 'a' )[0];
			if( oLnk && ( ( oState && oULs[i].style.display == 'none' ) || ( !oState && oULs[i].style.display != 'none' ) ) ) {
				oLnk.onclick();
} } } }



/* select all */
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


	  
	  
	  
	  
	  
	  
/* FORM */

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

	  