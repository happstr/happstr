/**************************************************************************
* BEGIN MAIN HAPPSTR JAVASCRIPT APP
*/

/**************************************************************************
* STORE GLOBAL METHODS AND STATES UNDER THE HAPPSTER NAMESPACE
*/
var Happstr = (function (obj) {
	
	_this = obj;
	
	//insert global js here

	return obj;
}(Happstr || {}));

/**************************************************************************
* BEGIN MAIN NAVIGATION CLASS
*/
var Navigate = (function (obj) {
	
	_this = obj;
	
	_this.idx = 0;
	
	
	function sizeContent() {
        //alert('sizecontent');
	    pageWidth = $('body, html').width();
        $('#content-wrapper').css({width:pageWidth});
        $('ul.pages li').css({width:pageWidth});
	}
	
	_this.construct = function() {
	    sizeContent();
	    $(window).resize(function() {
	        sizeContent();
	    });
	}
	
	_this.navigateTo = function(targetIdx) {
	    animWidth = $('body, html').width();
	    calcAnimation = - (animWidth * targetIdx);
	 
	    $('ul.pages').animate({left: calcAnimation}, 200);
	        idx = targetIdx;
	        _this.idx = targetIdx;
	}
	
	//insert global js here

	return obj;
}(Navigate || {}));

