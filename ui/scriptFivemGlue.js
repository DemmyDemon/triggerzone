// FiveM Glue

function glueInvokeCallback(endpoint, payload){
    fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload)
    }).then(resp => resp.json()).then(resp => actOnData(resp));
}

function glueChangeAltitude(newValue){
    glueInvokeCallback('altitude', {value:newValue})
}
function glueChangeHeight(newValue){
    glueInvokeCallback('height', {value:newValue})
}
function glueChangeDraw(newValue){
    glueInvokeCallback('draw', {value:newValue})
}
function glueChangeEvent(newValue){
    glueInvokeCallback('event', {value:newValue})
}
function glueChangeName(newValue){
    glueInvokeCallback('name', {value:newValue})
}

function glueButtonCancel(){
    glueInvokeCallback('cancel', {})
}
function glueButtonSave(){
    glueInvokeCallback('save', {})
}
function glueButtonView(idx){
    glueInvokeCallback('view', {vertex:idx})
}
function glueButtonDelete(idx){
    glueInvokeCallback('delete', {vertex:idx})
}

function glueChangeActiveColor(newValue){
    glueInvokeCallback('activeColor', {value:newValue})
}
function glueChangeInactiveColor(newValue){
    glueInvokeCallback('inactiveColor', {value:newValue})
}

function actOnData(data){
    console.log(`Processing data type "${data.type}"`)
    switch (data.type){
        case "ok":
            hideElem(alertElem);
            break;
        case "message":
            showModalMessage(alertElem, alertMessageElem, data.message);
            break;
        case "setName":
            setZoneNameValue(data.name);
            break;
        case "setAltitude":
            setAltitudeValue(data.altitude);
            break;
        case "setHeight":
            setHeightValue(data.height);
            break;
        case "setEvent":
            setEventValue(data.events);
            break;
        case "setDraw":
            setDrawingValue(data.draw);
            break;
        case "populateTable":
            populateTable(tableElem, data.points);
            break;
        case "setActiveRGBAA":
            setActiveRGBAAValue(data.activeRGBAA);
            break;
        case "setInactiveRGBAA":
            setInactiveRGBAAValue(data.inactiveRGBAA);
            break;
        case "loaded":
            showUI(true);
            setZoneNameValue(data.name);
            setAltitudeValue(data.altitude);
            setHeightValue(data.height);
            setEventValue(data.events);
            setDrawingValue(data.draw);
            setActiveRGBAAValue(data.activeRGBAA);
            setInactiveRGBAAValue(data.inactiveRGBAA);
            populateTable(tableElem, data.points);
            if (data.message) {
                showModalMessage(alertElem, alertMessageElem, data.message);
            }
            break;
        case "abort":
            hideElem(alertElem);
            showUI(false);
            break;
        default:
            console.log(`Unknown data type "${data.type}"`, data)
    }
}

window.addEventListener('message', (event) => {
    actOnData(event.data);
});
