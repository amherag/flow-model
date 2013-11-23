(function() {
    CodeMirror.keyMap.inputArea = CodeMirror.keyMap.default;

    CodeMirror.keyMap.inputArea["Ctrl-Enter"] = function(cm)
    {
	$.ajax({type: "post",
		url: "/code",
		async: false,
		data: {workspace: document.getElementById("workspace-id").value,
		       code: cm.getValue(),
		       port: document.getElementById("workspace-port").value,
		       ip: document.getElementById("workspace-ip").value},
		success: function (data) {
		    reviewArea.setValue((reviewArea.getValue() + "\n\n" + data).trim());
		    inputArea.setValue("");
		    reviewArea.getDoc().setCursor(reviewArea.getDoc().lastLine(), reviewArea.getTokenAt({line: reviewArea.getDoc().lastLine(), char: 0}, true).end);
		},
		dataType: "html"});
    };

})();
