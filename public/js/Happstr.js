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
	
	_this = obj; //store local scope
	
	_this.idx = 0; //store frame index
	

	
	
	function sizeContent() {
        //alert('sizecontent');
	    pageWidth = $('body, html').width();
        $('#content-wrapper').css({width:pageWidth});
        $('ul.pages li.frames').css({width:pageWidth});
	}
	
	function setStructure(target) {
	    if(target !==0) {
	        $('#content-wrapper').animate({height: 900});
        } else {
            $('#content-wrapper').animate({height: 413});
        }
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
	 
	    $('ul.pages').animate({left: calcAnimation}, 200, function(){
	          idx = targetIdx;
    	      _this.idx = targetIdx;
    	      setStructure(_this.idx)
	    });
	      
	}
	
	//insert global js here

	return obj;
}(Navigate || {}));

/**************************************************************************
* BEGIN HAPPY PROCESS CLASS
*/
var HappyProcess = (function (obj) {
	
	_this = obj;
	
	function postHappy(lat, lon) {
	    $.post('/api/checkins', { 
	        lat: lat,
	        lon: lon
	    },
	    function(data) {
            Navigate.navigateTo(1);
        });
	}
	
	function postBecause() {
	    /*$.post('/api/checkins', { 
	        lat: lat,
	        lon: lon
	    },
	    function(data) {
            $('.because-enter').hide();
            $('.because-enter').show();
            
        });*/
        $('.because-enter').hide();
        $('.because-success').show();
	}
	
	_this.construct = function() {
	    $('.send-happy').click(function() {
	        postHappy(1,2);
	    });
	    
	    $('.send-because').click(function() {
	        postBecause();
	    });
	}
	
	


	return obj;
}(HappyProcess || {}));

