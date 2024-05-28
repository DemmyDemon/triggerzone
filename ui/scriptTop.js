let colorSectionElem = document.getElementById("colorSection");
let activeColorElems = document.getElementsByClassName("activeZoneColor");
let inactiveColorElems = document.getElementsByClassName("inactiveZoneColor");

for(let i = 0; i < activeColorElems.length; i++) {
    activeColorElems[i].nextElementSibling.innerHTML = activeColorElems[i].value;

    activeColorElems[i].addEventListener("mousedown", (event) => {
        activeColorElems[i].addEventListener("mousemove", (event) => {
            activeColorElems[i].nextElementSibling.innerHTML = activeColorElems[i].value;
            glueChangeActiveColor(getActiveRGBAAValue())
        });
    });
}

for(let i = 0; i < inactiveColorElems.length; i++) {
    inactiveColorElems[i].nextElementSibling.innerHTML = inactiveColorElems[i].value;
        
    inactiveColorElems[i].addEventListener("mousedown", (event) => {
        inactiveColorElems[i].addEventListener("mousemove", (event) => {
            inactiveColorElems[i].nextElementSibling.innerHTML = inactiveColorElems[i].value;
            glueChangeInactiveColor(getInactiveRGBAAValue())
        });
    });
}


function getActiveRGBAAValue() {
    let RGBAAvalues = {
        color: [],
        lines: 0,
        walls: 0
    }

    for(let i = 0; i < activeColorElems.length; i++){
        if (i < 3) {
            RGBAAvalues.color.push(activeColorElems[i].value);
        } else if (i == 3) {
            RGBAAvalues.lines = activeColorElems[i].value;
        } else if (i == 4) {
            RGBAAvalues.walls = activeColorElems[i].value;
        } else {
            console.log("Something odd is happening in the [getActiveRGBAAValue] function, the index is", i);
        }
    }

    return RGBAAvalues;
}
function getInactiveRGBAAValue() {
    let RGBAAvalues = {
        color: [],
        lines: 0,
        walls: 0
    }

    for(let i = 0; i < inactiveColorElems.length; i++){
        if (i < 3) {
            RGBAAvalues.color.push(inactiveColorElems[i].value);
        } else if (i == 3) {
            RGBAAvalues.lines = inactiveColorElems[i].value;
        } else if (i == 4) {
            RGBAAvalues.walls = inactiveColorElems[i].value;
        } else {
            console.log("Something odd is happening in the [getInactiveRGBAAValue] function, the index is", i);
        }
    }

    return RGBAAvalues;
}

function setActiveRGBAAValue(newRGBAA) {
    for(let i = 0; i < newRGBAA.color.length; i++) {
        activeColorElems[i].value = newRGBAA.color[i];
        activeColorElems[i].nextElementSibling.innerHTML = newRGBAA.color[i];
        // console.log(i);
    }
    activeColorElems[3].value = newRGBAA.lines;
    activeColorElems[3].nextElementSibling.innerHTML = newRGBAA.lines;

    activeColorElems[4].value = newRGBAA.walls;
    activeColorElems[4].nextElementSibling.innerHTML = newRGBAA.walls;
}
function setInactiveRGBAAValue(newRGBAA) {
    for(let i = 0; i < newRGBAA.color.length; i++) {
        inactiveColorElems[i].value = newRGBAA.color[i];
        inactiveColorElems[i].nextElementSibling.innerHTML = newRGBAA.color[i];
        // console.log(i);
    }
    inactiveColorElems[3].value = newRGBAA.lines;
    inactiveColorElems[3].nextElementSibling.innerHTML = newRGBAA.lines;

    inactiveColorElems[4].value = newRGBAA.walls;
    inactiveColorElems[4].nextElementSibling.innerHTML = newRGBAA.walls;
}