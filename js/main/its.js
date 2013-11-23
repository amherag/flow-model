var inputArea = CodeMirror.fromTextArea(
    document.getElementById("inputArea"),
    {theme: "eclipse",
     autofocus: true,
     lineWrapping: true,
     smartIndent: true,
     styleActiveLine: true,
     matchBrackets: true,
     keyMap: "inputArea",
     extraKeys: {"Tab": "indentAuto"}});

var reviewArea = CodeMirror.fromTextArea(
    document.getElementById("reviewArea"),
    {lineNumbers: true,
     lineWrapping: true,
     readOnly: "nocursor",
     theme: "eclipse",
     smartIndent: true,
     matchBrackets: true,
     extraKeys: {"Tab": "indentAuto"}});

//set cursor on last line
reviewArea.getDoc().setCursor(reviewArea.getDoc().lastLine(), reviewArea.getTokenAt({line: reviewArea.getDoc().lastLine(), char: 0}, true).end);



