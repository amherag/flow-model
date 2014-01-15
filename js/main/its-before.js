//var endslide = jQuery.Event( "" );
var times = [];
var initialTime = new Date().getTime();
var endingTime = null;

// add an object with keycode and timestamp
$(document).keyup(function(evt) {
    times.push({"timestamp": new Date().getTime(),
                "keycode":evt.which})
});

function report(slideTime) {
    var reportString = "{\"timeintervals\": {";
    for(var i = 0; i < times.length - 1; ++i) {
        reportString += (i+1) + ": {\"milliseconds\": " + (times[i+1].timestamp - times[i].timestamp) + "," + " \"keycode\": " + times[i].keycode + "}, ";
    }
    //lastchar
    if (times[0] == undefined) {
	lastchar = null;
    } else {lastchar = times[times.length - 1].keycode}
    //thinkingTime
    if (times[0] == undefined) {
	thinkingTime = slideTime;
    } else {thinkingTime = times[0].timestamp - initialTime}

    reportString += "} \"keypresses\": " + times.length + ", \"lastchar\": " + lastchar + ", \"slidetime\": " + slideTime + ", \"thinkingtime\": " + thinkingTime + ", \"user\": \"" + $("#user").val() + "\", " + "\"activestep\": " + $("#activestep").val() + "}";
    return reportString;
}

$(function() {

    $('#jmpress').jmpress({
	hash: {
	    use: false
	},
	keyboard: {
	    use: false
	}
    });

    $("#activestep").val("1");

    $(".next").click(function(event){
	    endingTime = new Date().getTime();
	    $.ajax({type: "post",
		    url: "/result",
		    data: {
			result: report(endingTime - initialTime)}
		   });
	alert("¡Bien hecho! （⌒▽⌒）\n Ahora responde unas preguntas, por favor.");
	$("#tohide").css('display', 'none');
	$("#flowquestion").css('display', 'block');
	$('#jmpress').jmpress('next');
	return false;
    });

    $(".prev").click(function(event){
	$('#jmpress').jmpress('prev');
	return false;
    });

    $("#survey").click(function(event){
	if ($("#activestep").val() == "10") {window.location = "logout";} else {
	resultJSON = JSON.stringify({user: $("#user").val(), activestep: parseInt($("#activestep").val()) - 1, difficulty: $("#difficulty").val(), mentalstate: $("#mentalstate").val()});
	$.ajax({type: "post",
		url: "/result",
		data: {
		    result: resultJSON
		}
	});
	times = [];
	initialTime = new Date().getTime();
	//$("#jmpress").jmpress('next');
	$("#flowquestion").css('display', 'none');
	$("#tohide").css('display', 'block');
	inputArea.focus();
	return false;
    }});

    $('.step')
	.on('enterStep', function(event) {
	    inputArea.focus();
	})
	.on('leaveStep', function(event) {
	    inputArea.setValue("");
	    reviewArea.setValue("");
	});


    $( "#slider-range-max" ).slider({
	range: "min",
	min: 0,
	max: 100,
	value: 50,
	slide: function( event, ui ) {
	    $( "#flow" ).val( ui.value );
	}
    });
    $( "#flow" ).val( $( "#slider-range-max" ).slider( "value" ) );

});
