$(function() {

    $('#jmpress').jmpress();

    $(".next").click(function(event){
	$('#jmpress').jmpress('next');
	return false;
    });

    $(".prev").click(function(event){
	$('#jmpress').jmpress('prev');
	return false;
    });

    $(".eval").click(function(event){
	CodeMirror.keyMap.inputArea["Ctrl-Enter"]();
	return false;
    });

    $('.step')
	.on('enterStep', function(event) {

	})
	.on('leaveStep', function(event) {

	    inputArea.setValue("");
	    reviewArea.setValue("");
	});

    //$("#jmpress").jmpress('setActive', function(step, eventData) {alert(step.toSource())} );
    //alert($("#jmpress").jmpress('activeClass'));
    //alert($("#jmpress").jmpress('active').selector);

});


