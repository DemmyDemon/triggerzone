let zoneNameElem = document.getElementById("zoneName");
let altitudeElem = document.getElementById("altitude");
let heightElem = document.getElementById("height");

let eventButtonElem = document.getElementById("eventButton");
let drawButtonElem = document.getElementById("drawButton");
let cancelButtonElem = document.getElementById("cancel");
let saveButtonElem = document.getElementById("save");


zoneNameElem.addEventListener("keyup", (event) => {
    glueChangeName(getZoneNameValue())
});

altitudeElem.addEventListener("change", (event) => {
    glueChangeAltitude(getAltitudeValue())
});

heightElem.addEventListener("change", (event) => {
    glueChangeHeight(getHeightValue())
});

drawButtonElem.addEventListener("change", (event) => {
    toggleBackroundColor(drawButtonElem, "green", "blue");
    event.target.blur();
    glueChangeDraw(getDrawingValue())
});

eventButtonElem.addEventListener("change", (event) => {
    toggleBackroundColor(eventButtonElem, "green", "blue");
    event.target.blur();
    glueChangeEvent(getEventValue())
});

cancelButtonElem.addEventListener("click", (event) => {
    event.target.blur();
    glueButtonCancel();
});

saveButtonElem.addEventListener("click", (event) => {
    event.target.blur();
    glueButtonSave();
});

function getZoneNameValue() {
    return zoneNameElem.value;
}
function getAltitudeValue() {
    return +altitudeElem.value;
}
function getHeightValue() {
    return +heightElem.value;
}
function getEventValue() {
    return eventButtonElem.firstElementChild.checked;
}
function getDrawingValue() {
    return drawButtonElem.firstElementChild.checked;
}

function setZoneNameValue(newZoneName) {
    zoneNameElem.value = newZoneName;
}
function setAltitudeValue(newAltitude) {
    altitudeElem.value = newAltitude;
}
function setHeightValue(newHeight) {
    heightElem.value = newHeight;
}
function setEventValue(newEvent) {
    eventButtonElem.firstElementChild.checked = newEvent;
    toggleBackroundColor(eventButtonElem, "green", "blue");
}
function setDrawingValue(newDrawing) {
    drawButtonElem.firstElementChild.checked = newDrawing;
    toggleBackroundColor(drawButtonElem, "green", "blue");
}

function toggleBackroundColor(elem, checkedColor, uncheckedColor) {
    if(elem.firstElementChild.checked) {
        elem.style.backgroundColor = `var(--${checkedColor})`;
        return true;
    } else if (!elem.firstElementChild.checked) {
        elem.style.backgroundColor = `var(--${uncheckedColor})`;
        return false;
    } else {
        console.log("what the heck is going on with [toggleBackgroundColor] function trying to do its thing in the " + elem.id + "element?");
    }
}