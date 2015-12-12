//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require tether
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree .


// FUNCTION FOR SMOOTH SCROLLING
$(function() {
  // CHECK IF LINK
  $('a[href*=#]:not([href=#])').click(function() {
    if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
      var target = $(this.hash);
      target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
      if (target.length) {
        $('html,body').animate({
          scrollTop: target.offset().top
        }, 1000);
        console.log("Success");
        return false;
      }
    }
  });
});

$('document').ready ->
  $('#myTab a').click (e) ->
  e.preventDefault()
  $(this).tab 'show'
  return


