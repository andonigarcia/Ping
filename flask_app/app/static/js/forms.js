$.validate();

function getZip(zipcode){
    url = "http://zip.getziptastic.com/v2/US/" + zipcode;
    $.ajax({
        url: url,
        cache: false,
        dataType: "JSON",
        type: "GET",
        success: function(result, success){
            $('#regCompState').val(result.state_short).attr("disabled", true);
            $('#regCompCity').val(result.city).attr("disabled", true);
            $('#regCompZip .error').remove()
        },
        error: function(result, success){
            $('#regCompZip').append("<p class='error'>ERROR INVALID ZIP</p>")
        }
    });
}

$("#regCompZip").focusout(function(){
    zipcode = $("#regCompZip").val();
    getZip(zipcode);
});
