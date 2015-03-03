$.validate({
    borderColorOnError: "",
    addValidClassOnAll: true
});

$("form").each(function(){
    $(this).change(function(){
        setTimeout(function () {
            var formFields = $(this).add('.formInput[required]');
            if (formFields.filter('.error').length) {
                $(this).add('.formButton').attr('disabled', 'disabled');
            } else {
                // Causes a problem when uploading in Company Page
                isEmpty = false;
                formFields.filter('.formInput').each(function () {
                    if (!$(this).val()) {
                        isEmpty = true;
                    }
                });
                $(this).add('.formButton').removeAttr('disabled');
            }
        }, 250);
    });
});

helps = $("input[data-validation-help]");
helps.each(function(){
    $(this).focusin(function(){
        if ($(this).siblings('span.form-error').length) {
            $(this).siblings('span.form-error').before('<br />');
        }
    });
    $(this).focusout(function(){
        if ($(this).add('br').length > 1) {
            $(this).siblings('span.help').fadeOut("slow", function(){
                $(this).add('br').last().remove();
            });
        }
    });
});

function getZip(zipcode){
    url = "http://zip.getziptastic.com/v2/US/" + zipcode;
    $.ajax({
        url: url,
        cache: false,
        dataType: "JSON",
        type: "GET",
        success: function(result, success){
            $('#regCompState').val(result.state_short).attr("readonly", true);
            $('#regCompCity').val(result.city).attr("readonly", true);
            $('#regCompZip .error').remove();
        },
        error: function(result, success){
            $('#regCompState').val("");
            $('#regCompCity').val("");
        }
    });
}

$("#regCompZip").focusout(function(){
    zipcode = $("#regCompZip").val();
    getZip(zipcode);
});
