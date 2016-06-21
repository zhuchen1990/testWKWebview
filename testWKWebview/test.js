var buttons = document.getElementsByClassName('se-inner');
for (var i = 0; i < buttons.length; i++) {
    var button = buttons[i];
    button.onclick = gaEventClick;
}

function gaEventClick() {
    var eventInfo = {className:'PrintClass',functionName:'printMethod:',para:'poi'};
    webkit.messageHandlers.MyInterface.postMessage(eventInfo);
}