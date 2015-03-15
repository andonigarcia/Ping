$(document).ready(function(){
    $("#menuIcon").click(function(){
        if($(document).width() <= 550){
            $(".nav").slideToggle();
        }
    });
});