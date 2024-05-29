let colorSectionElem = document.getElementById("colorSection");
let activeColorElems = document.getElementsByClassName("activeZoneColor");
let inactiveColorElems = document.getElementsByClassName("inactiveZoneColor");

document.addEventListener("DOMContentLoaded", (event) => {
    console.log("DOM fully loaded and parsed");

    for(let i = 0; i < activeColorElems.length; i++) {
        activeColorElems[i].nextElementSibling.innerHTML = activeColorElems[i].value;
        console.log("Setting inital value for activeColorElems: ", i, activeColorElems[i].value);

        activeColorElems[i].addEventListener("mousedown", (event) => {
            
            console.log("activeColorElems["+i+"], eventlistener on mousedown");
            activeColorElems[i].addEventListener("mousemove", (event) => {
                
                console.log("activeColorElems["+i+"], eventlistener on mousemove: ", i, activeColorElems[i].value);
                
                activeColorElems[i].nextElementSibling.innerHTML = activeColorElems[i].value;
                glueChangeActiveColor(getActiveRGBAAValue())
            });
        });
    }

    for(let i = 0; i < inactiveColorElems.length; i++) {
        inactiveColorElems[i].nextElementSibling.innerHTML = inactiveColorElems[i].value;
        console.log("Setting inital value for inactiveColorElems: ", i, inactiveColorElems[i].value);

        inactiveColorElems[i].addEventListener("mousedown", (event) => {
            
            console.log("inactiveColorElems["+i+"], eventlistener on mousedown");
            inactiveColorElems[i].addEventListener("mousemove", (event) => {
                
                console.log("inactiveColorElems["+i+"], eventlistener on mousemove: ", i, inactiveColorElems[i].value);

                inactiveColorElems[i].nextElementSibling.innerHTML = inactiveColorElems[i].value;
                glueChangeInactiveColor(getInactiveRGBAAValue())
            });
        });
    }

});

function getActiveRGBAAValue() {
    let RGBAAvalues = {
        color: [],
        lines: 0,
        walls: 0
    }

    for(let i = 0; i < activeColorElems.length; i++){
        console.log("getActiveRGBAAValue(), activeColorElems[i].value: ", i, activeColorElems[i].value);
        if (i < 3) {
            RGBAAvalues.color.push(activeColorElems[i].value);
        } else if (i == 3) {
            RGBAAvalues.lines = activeColorElems[i].value;
        } else if (i == 4) {
            RGBAAvalues.walls = activeColorElems[i].value;
        } else {
            console.log("Something odd is happening in the [getActiveRGBAAValue] function, the index is: ", i);
        }
    }
    console.log("getActiveRGBAAValue(), returns: ",  RGBAAvalues.color[0],RGBAAvalues.color[1],RGBAAvalues.color[2],RGBAAvalues.lines,RGBAAvalues.walls);
    return RGBAAvalues;
}
function getInactiveRGBAAValue() {
    let RGBAAvalues = {
        color: [],
        lines: 0,
        walls: 0
    }

    for(let i = 0; i < inactiveColorElems.length; i++){
        console.log("getInactiveRGBAAValue(), inactiveColorElems[i].value: ", i, inactiveColorElems[i].value);
        if (i < 3) {
            RGBAAvalues.color.push(inactiveColorElems[i].value);
        } else if (i == 3) {
            RGBAAvalues.lines = inactiveColorElems[i].value;
        } else if (i == 4) {
            RGBAAvalues.walls = inactiveColorElems[i].value;
        } else {
            console.log("Something odd is happening in the [getInactiveRGBAAValue] function, the index is: ", i);
        }
    }
    console.log("getInactiveRGBAAValue(), returns: ",  RGBAAvalues.color[0],RGBAAvalues.color[1],RGBAAvalues.color[2],RGBAAvalues.lines,RGBAAvalues.walls);
    return RGBAAvalues;
}

function setActiveRGBAAValue(newRGBAA) {
    console.log("setActiveRGBAAValue(), newRGBAA: ", newRGBAA.color[0],newRGBAA.color[1],newRGBAA.color[2],newRGBAA.lines,newRGBAA.walls);
    for(let i = 0; i < newRGBAA.color.length; i++) {
        activeColorElems[i].value = newRGBAA.color[i];
        activeColorElems[i].nextElementSibling.innerHTML = newRGBAA.color[i];
    }
    activeColorElems[3].value = newRGBAA.lines;
    activeColorElems[3].nextElementSibling.innerHTML = newRGBAA.lines;

    activeColorElems[4].value = newRGBAA.walls;
    activeColorElems[4].nextElementSibling.innerHTML = newRGBAA.walls;
}
function setInactiveRGBAAValue(newRGBAA) {
    console.log("setInactiveRGBAAValue(), newRGBAA: ", newRGBAA.color[0],newRGBAA.color[1],newRGBAA.color[2],newRGBAA.lines,newRGBAA.walls);
    for(let i = 0; i < newRGBAA.color.length; i++) {
        inactiveColorElems[i].value = newRGBAA.color[i];
        inactiveColorElems[i].nextElementSibling.innerHTML = newRGBAA.color[i];
    }
    inactiveColorElems[3].value = newRGBAA.lines;
    inactiveColorElems[3].nextElementSibling.innerHTML = newRGBAA.lines;

    inactiveColorElems[4].value = newRGBAA.walls;
    inactiveColorElems[4].nextElementSibling.innerHTML = newRGBAA.walls;
}