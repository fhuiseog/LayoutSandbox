function callNativeApp () {
    try {
        webkit.messageHandlers.callbackHandler.postMessage("Send from JavaScript");
    } catch(err) {
        console.log('error');
    }
}

function postLayoutPositions() {
    
    try {
        
        var elements = document.getElementsByTagName("div");
        
        var locations = "";
        
        for (var i = 0; i < elements.length; i++) {
        
            var element = elements[i];
            
            var rect = element.getBoundingClientRect();
        
            var loc = i + "," + rect.left + "," + rect.top + "," + rect.width + "," + rect.height;
            
            if (locations != "")
                locations += "\n";
            
            locations += loc;
        }
        
        webkit.messageHandlers.callbackHandler.postMessage(locations);
        
    } catch(err) {
        console.log('error');
    }
    
}

function onResized () {
    try {
        webkit.messageHandlers.callbackHandler.postMessage("onResized");
    } catch(err) {
        console.log('error');
    }
}



function testMe() {
    document.querySelector('p').style.color = "red";
}

window.addEventListener("resize", postLayoutPositions)

