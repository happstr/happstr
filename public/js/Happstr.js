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

      // setup navigation etc
      $('.buttons-main .create-happy').click(function(ev) {
        ev.preventDefault();
        Navigate.navigateTo(0);
        reset();
        $('.buttons-main .find-happy').removeClass('active');
        $('.buttons-main .create-happy').addClass('active');
      });

      $('.buttons-main .find-happy').click(function(ev) {
        ev.preventDefault();
        Navigate.navigateTo(2);
        $('.buttons-main .create-happy').removeClass('active');
        $('.buttons-main .find-happy').addClass('active');
        reset();
      });

      $('.do-again-link').click(function(ev) {
        ev.preventDefault();
        Navigate.navigateTo(0);
        reset();
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
  _this.checkinID;
  _this.position;

  _this.reset = function() {
    _this.checkinID = null;
    _this.position = null;
  }

  function postHappy(lat, lon) {
    $.post('/api/checkins',
      function(data) {
        _this.checkinID = $.parseJSON(data)._id;
        Navigate.navigateTo(1);
      }
    );
  }

  function postBecause(because) {
    if(_this.checkinID) {
      $.ajax({
        url: '/api/checkins/' + _this.checkinID,
        type: "PUT",
        data: {
          comment: because
        },
        success: function(data) {
          $('.because-enter').hide();
          $('.because-success').show();
        }
      })
    } else {
      // look every second if posting the because is done already
      setTimeout(function() { postBecause(because) }, 1000);
    }
  }

  function noPosition() {
    // well, do something
  }

  function savePosition() {
    if(_this.checkinID && _this.position) {
      $.ajax({
        url: '/api/checkins/' + _this.checkinID,
        type: "PUT",
        data: {
          lat: _this.position.coords.latitude,
          lon: _this.position.coords.longitude
        },
        success: function(data) {
           // do something
        }
      })
    } else {
      // look every second if posting the happiness is done already
      setTimeout(savePosition, 1000);
    }
  }

  function getLocation() {
    if(navigator.geolocation) {
      function hasPosition(position) {
        _this.position = position;
        savePosition();
      }

      navigator.geolocation.getCurrentPosition(hasPosition, noPosition);
    } else {
      noPosition();
    }
  }

  _this.construct = function() {
      $('.send-happy').click(function() {
          getLocation();
          postHappy(1,2);
      });

      $('.send-because').click(function() {
          postBecause($('.happy-input').val());
      });
  }

 return obj;
}(HappyProcess || {}));

var reset = function() {
  HappyProcess.reset();

  $('.because-success').hide();
  $('.because-enter').show();
  $('.happy-input').val("");
}

