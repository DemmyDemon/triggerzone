let sectionElems = document.querySelectorAll("body > section");

let alertElem = document.getElementById("alert");
let alertMessageWrapperElem = document.getElementById("alertMessageWrapper");
let alertButtonWrapperElem = document.getElementById("alertButtonWrapper");


showUI(false);

window.addEventListener("keyup", (event) => {
    var activeElement = document.activeElement;
    var inputs = ['input', 'textarea', 'button'];

    if(event.key == " ") {
            if (activeElement && inputs.indexOf(activeElement.tagName.toLowerCase()) == -1) {
            // events that should happen when pressing space and no input filed is active
            glueSpace();
        }
    }
});

function hideElem(elem) {
    elem.className = "hidden";
    console.log(`Element [${elem}] is now hidden.`);
}

function showElem(elem) {
    let classes = elem.classList;
    
    for(let className of classes) {
        if(className == "hidden") {
            elem.classList.remove("hidden");
            console.log(`Element [${elem.id}] is visible again`);
        } else {
            console.log(`Element [${elem.id}] is already visible`);
        }
    }
}

function showModalMessage(message, buttons) {
    console.log("showing modal");
    alertButtonWrapperElem.innerHTML = "";
    
    for(let i = 0; i < buttons.length; i++) {
        console.log("buttons", buttons);
        let newButton = document.createElement("button");
        newButton.classList.add("button", "button"+buttons[i].color);
        newButton.textContent = buttons[i].text;
        newButton.onclick = buttons[i].action;
        
        alertButtonWrapperElem.append(newButton);
    }
        
    alertMessageWrapperElem.innerHTML = message;
    showElem(alertElem);
}

function showUI(bool) {
    for(let i = 0; i < sectionElems.length; i++) {
        // console.log(sectionElems[i]);
        if(bool == true || sectionElems[i].id == "alert") {
            sectionElems[i].style.display = "flex";
        } else if(bool == false) {
            sectionElems[i].style.display = "none";
        } else {
            console.log("the boolean isn't a boolean in the [showUI] function. What.");
        }
    }
}