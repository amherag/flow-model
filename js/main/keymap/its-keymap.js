(function() {
    CodeMirror.keyMap.inputArea = CodeMirror.keyMap.default;

    //alert($(".active").toSource());

    CodeMirror.keyMap.inputArea["Ctrl-Enter"] = function(cm)
    {
	$.ajax({type: "post",
		url: "/its",
		data: {
		    code: cm.getValue(),
		    step: $("#jmpress").jmpress('active').selector
		},
		success: function (data) {
		    reviewArea.setValue((data).trim());
		    inputArea.setValue("");
		    reviewArea.getDoc().setCursor(reviewArea.getDoc().lastLine(), reviewArea.getTokenAt({line: reviewArea.getDoc().lastLine(), char: 0}, true).end);
		},
		dataType: "html"});
    };

})();
