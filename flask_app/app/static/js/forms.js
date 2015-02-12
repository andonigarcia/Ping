$.validate();

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
            $('#regCompZip .error').remove()
        },
        error: function(result, success){
            $('#regCompState').val("")
            $('#regCompCity').val("")
        }
    });
}

$("#regCompZip").focusout(function(){
    zipcode = $("#regCompZip").val();
    getZip(zipcode);
});
