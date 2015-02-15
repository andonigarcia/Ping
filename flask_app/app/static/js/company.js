$(".headingTabs ul li").each(function(){
    $(this).click(function(){
       if(!$(this).hasClass('active')){
           currid = $('.active').children('a').attr('href').substr(1);
           nextid = $(this).children('a').attr('href').substr(1);
           $('.active').removeClass('active');
           $(this).addClass('active');
           $("div#"+currid).hide();
           $("div#"+nextid).show();
       }
    });
    $(this).children('a').click(function(){
        anchorsLi = $(this).parent();
        if(!anchorsLi.hasClass('active')){
           currid = $('.active').children('a').attr('href').substr(1);
           nextid = anchorsLi.children('a').attr('href').substr(1);
           $('.active').removeClass('active');
           anchorsLi.addClass('active');
           $("div#"+currid).hide();
           $("div#"+nextid).show();
       }
       return false;
    });
});
$('#editInfo').click(function(){
   $(".companyEditInfo").show();
   $(".overlayClose").click(function(){
       $(".companyEditInfo").hide();
   });
   $(".companyEdit input.formButton").click(function(){
       $(".companyEditInfo").hide();
   });
});
$('#editLogo').click(function(){
   $(".companyEditLogo").show();
   $(".overlayClose").click(function(){
       $(".companyEditLogo").hide();
   });
   $(".companyEditLogo input[type='submit']").click(function(){
       $(".companyEditLogo").hide();
   });
});