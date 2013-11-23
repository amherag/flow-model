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
});


