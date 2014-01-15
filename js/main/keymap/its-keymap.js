(function() {
    CodeMirror.keyMap.inputArea = CodeMirror.keyMap.default;

    CodeMirror.keyMap.inputArea["Ctrl-Enter"] = function(cm)
    {
	var codeString = cm.getValue();
	$.ajax({type: "post",
		url: "/its",
		data: {
		    code: codeString,
		    step: $("#activestep").val()
		},
		success: function (data) {
		    result = (data).trim();
		    splitted = result.split("\n");
		    resultJSON = JSON.stringify({user: $("#user").val(), activestep: $("#activestep").val(), codesent: codeString, coderesult: splitted[2], score: splitted[0]});
		    $.ajax({type: "post",
			    url: "/result",
			    data: {
				result: resultJSON
			    }
			   });
		    reviewArea.setValue(result);
		    //reviewArea.getDoc().setCursor(reviewArea.getDoc().lastLine(), reviewArea.getTokenAt({line: reviewArea.getDoc().firstLine(), char: 0}, true).end);
		    //reviewArea.getDoc().setCursor({pos: {line: 0, ch: 0}});
		    if (splitted[0] == "¡Bien hecho!") {
			endingTime = new Date().getTime();
			$.ajax({type: "post",
				url: "/result",
				data: {
				    result: report(endingTime - initialTime)}
			       });
			alert("¡Bien hecho! （⌒▽⌒）\n Ahora responde unas preguntas, por favor.");
			$("#jmpress").jmpress('next');
			$("#tohide").css('display', 'none');
			$("#flowquestion").css('display', 'block');
		    }
		},
		dataType: "html"});
    };

})();
