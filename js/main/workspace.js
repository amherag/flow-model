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

var projectArea = CodeMirror.fromTextArea(
    document.getElementById("projectArea"),
    {lineNumbers: true,
     lineWrapping: true,
     theme: "eclipse",
     smartIndent: true,
     styleActiveLine: true,
     matchBrackets: true,
     extraKeys: {"Tab": "indentAuto"}});

$(document).ready(function() {
    setInterval(function() {
	$.ajax({type: "post",
		url: "/update-review-area",
		data: {workspace: document.getElementById("workspace-id").value},
		success: function(data) {
		    reviewArea.setValue(data);
		    reviewArea.getDoc().setCursor(reviewArea.getDoc().lastLine(), reviewArea.getTokenAt({line: reviewArea.getDoc().lastLine(), char: 0}, true).end);
		},
		dataType: "html"});
    }, 5000);

});

function create_new_file() {
    $.ajax({type: "post",
	    url: "/create-new-file",
	    data: {
		filename: document.getElementById("new_file_name").value,
		gitproject: document.getElementById("workspace-gitproject").value,
		port: document.getElementById("workspace-port").value,
		ip: document.getElementById("workspace-ip").value},
	    success: function (data) {
		$("#project-files").html(data);
		inputArea.focus();
	    },
	    dataType: "html"});
}

function save_project_file() {
    $.ajax({type: "post",
	    url: "/save-project-file",
	    data: {
		gitproject: document.getElementById("workspace-gitproject").value,
		port: document.getElementById("workspace-port").value,
		ip: document.getElementById("workspace-ip").value,
		filename: $("#current-project-file").val(),
		filecontent: projectArea.getValue()},
	    success: function (data) {
		inputArea.focus();
	    },
	    dataType: "html"});
}

function get_project_file(file) {
    $.ajax({type: "post",
	    url: "/get-project-file",
	    data: {
		gitproject: document.getElementById("workspace-gitproject").value,
		port: document.getElementById("workspace-port").value,
		ip: document.getElementById("workspace-ip").value,
		file: file},
	    success: function (data) {
		projectArea.setValue(data);
		projectArea.getDoc().setCursor(0, 0);
		$("#current-project-file").val(file);
		inputArea.focus();
	    },
	    dataType: "html"});
}

//set cursor on last line
reviewArea.getDoc().setCursor(reviewArea.getDoc().lastLine(), reviewArea.getTokenAt({line: reviewArea.getDoc().lastLine(), char: 0}, true).end);
