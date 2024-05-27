let sectionElems = document.querySelectorAll("body > section");
let alertElem = document.getElementById("alert");
let alertMessageElem = document.getElementById("alertMessage");
let alertButtonElem = document.getElementById("alertButton");


showUI(false);


alertButtonElem.addEventListener("click", (event) => {
    hideElem(alertElem);
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

function showModalMessage(modalElem, messageElem, message) {
    messageElem.innerHTML = `<p>${message}</p>`;
    showElem(modalElem);
}

function showUI(bool) {
    for(let i = 0; i < sectionElems.length; i++) {
        if(bool == false) {
            sectionElems[i].style.display = "none";
        } else if(bool == true) {
            sectionElems[i].style.display = "flex";
        } else {
            console.log("the boolean isn't a boolean in the [showUI] function. What.");
        }
    }
}