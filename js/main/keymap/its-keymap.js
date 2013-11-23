(function() {
    CodeMirror.keyMap.inputArea = CodeMirror.keyMap.default;

    CodeMirror.keyMap.inputArea["Ctrl-Enter"] = function(cm)
    {
	$.ajax({type: "post",
		url: "/its",
		async: false,
		data: {
		    code: cm.getValue() },
		success: function (data) {
		    reviewArea.setValue((reviewArea.getValue() + "\n\n" + data).trim());
		    inputArea.setValue("");
		    reviewArea.getDoc().setCursor(reviewArea.getDoc().lastLine(), reviewArea.getTokenAt({line: reviewArea.getDoc().lastLine(), char: 0}, true).end);
		},
		dataType: "html"});
    };

})();
