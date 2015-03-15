// Tab Functionality
hash = location.hash;
if(hash == "" || $(hash).length == 0){
  $("div#" + $(".active").children('a').attr('href').substr(1)).show();
} else {
  $($(".active").children('a').attr("href")).hide();
  $(hash).show();
  $(".active").removeClass("active");
  $(".headingTabs ul li a[href=" + hash + "]").parent().addClass("active");
  window.scrollTo(0, 0);
}

$(".headingTabs ul li").each(function(){
    $(this).click(function(){
      $(this).children('a')[0].click();
    });
});

$(window).on('hashchange', function(){
  hash = location.hash;
  if(hash){
    window.scrollTo(0, 0);
  }
  if(hash != ""){
    if($(hash).length){
      currid = $(".active").children('a').attr("href");
      $(".active").removeClass("active");
      $(".headingTabs ul li a[href=" + hash + "]").parent().addClass("active");
      $(currid).hide();
      $(hash).show();
    }
  }
});

// Overlay Functionality
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
$("#pingMessage").val("");
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
