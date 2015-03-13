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

// Image Upload Overlays
function renderImg(input){
  if(input.files && input.files[0]){
    var reader = new FileReader();
    reader.onload = function(e){
      $('.companyEditLogo #tmpUploadPrev').attr('src', e.target.result);
    }
    reader.readAsDataURL(input.files[0]);
  }
}

$(".companyEditLogo #userUpload").change(function(){
  renderImg(this);
});

// Ping Datetime Library Functions
$(".pingsRight .time").timepicker({
  "showDuration": true,
  "timeFormat": "g:ia",
  "forceRoundTime": true,
  "scrollDefault": "now",
  "step": 15
});
$(".pingsRight .date").datepicker({
  "format": "m-d-yyyy",
  "autoclose": true
});
$(".pingsRight").datepair();
$(".pingsRight .formButton").click(function(){
  function sanitizeTime(datestr, timestr){
    // Must be formatted M-D-Y
    datearr = datestr.split("-");
    // Must be formatted H:M%p
    timearr = timestr.split(":");
    isAm = timearr[1].substr(timestr[1].length - 3);
    timearr[1] = timearr[1].replace(/.{2}$/, "");
    if(isAm == "pm" || isAm == "PM")
      timearr[0] = parseInt(timearr[0]) + 12;
    var d = new Date();
    d.setMonth(datearr[0]);
    d.setDate(datearr[1]);
    d.setFullYear(datearr[2]);
    d.setHours(timearr[0]);
    d.setMinutes(timearr[1]);
    d.setSeconds(0);
    return d
  }

  $("#pingStart").val(sanitizeTime($("#pingStartDate").val(), $("#pingStartTime").val()).toISOString().replace(/.{8}$/, ""));
  $("#pingEnd").val(sanitizeTime($("#pingEndDate").val(), $("#pingEndTime").val()).toISOString().replace(/.{8}$/, ""));
  return true;
});
