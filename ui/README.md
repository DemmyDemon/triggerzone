# triggerzones-ui

A UI for the FiveM [Triggerzone resource](https://github.com/DemmyDemon/triggerzone) made by [DemmyDemon](https://github.com/DemmyDemon). 
> To be clear: This is **only the UI**. It won't work on it's own.

## **Specification**

 -  List of all points with xy-coordinates and index. 
    -  Button to remove a point after it has been selected. 
    -  Button to view a point after it has been selected
-  Input / Export data: 
    -  Color, Two groups made with sliders and realtime preview of the color in game.
        -  Active zone of 5 values: R, G, B, A(lines) and A(walls). 
        -  Inactive zone of 5 values: R, G, B, A(lines) and A(walls).
    -  Area name  
    -  Altitude 
    -  Height 
    -  Drawing mode
    -  Event mode
-  Save button 
-  Cancle button
-  Modal for errors/messages 

![image of resource](/screenshot.png)

## **How to use**

**Quick Navigation** - *ain't nobody got time for this*   
[Functions to get values](#getFunctions)     
[Functions to set values](#setFunctions)     
[Other functions](#otherFunctions)     

> **! Note !**  
> In some of the examples below, I have included the getting the elements to make it clearer in case you want to create and/or use different elements.   
> So if you are using the standard/included elements, you **do not** need to get them.

---
---

<a name="getFunctions"></a>
## Functions to get values

### `getActiveRGBAAValue(RGBAAinput)`

Input: 
- none

Output:
```js
{
    color: [0, 0, 0],
    lines: 0,
    walls: 0
}
```
RGBAA is *not* a typo, because this is practically two colors in one with different alpha values; one for the walls and one for the lines on the zones.

Example: 
```js
let activeColor = getActiveRGBAAValue();
```

---

### `getInactiveRGBAAValue(RGBAAinput)`

Input: 
- none

Output:
```js
{
    color: [0, 0, 0],
    lines: 0,
    walls: 0
}
```
RGBAA is *not* a typo, because this is practically two colors in one with different alpha values; one for the walls and one for the lines on the zones.

Example: 
```js
let inactiveColor = getInactiveRGBAAValue();
```

---

### `getZoneNameValue()`

Input:   
- none

Output:
- `string`, the zoneName value.

Get the value of the zoneName input. Might be an `<empty string>`.

Example:
```js
var zoneName = getZoneNameValue();
```

---

### `getAltitudeValue()`

Input:   
- none

Output:
- `number`, the altitude value with 2 decimals.

Get the value of the altitude input.

Example:
```js
var altitude = getAltitudeValue();
```

---

### `getHeightValue()`

Input:   
- none

Output:
- `number`, the height value with 2 decimals.

Get the value of the height input.

Example:
```js
var height = getHeightValue();
```

---

### `getEventValue()`

Input:   
- none

Output:
- `boolean`, the event value.

Get the value of the event input.

Example:
```js
var event = getEventValue();
```

---

### `getDrawingValue()`

Input:   
- none

Output:
- `boolean`, the drawing value.

Get the value of the drawing input.

Example:
```js
var drawing = getDrawingValue();
```

---
---

<a name="setFunctions"></a>
## Functions to set values

### `setActiveRGBAAValue(newRGBAA)`

Input: 
- `{ color: [0, 0, 0], lines: 0, walls: 0 }`, first an RGB value, then alphas.

Output:
- none

RGBAA is *not* a typo, because this is practically two colors in one with different alpha values; one for the walls and one for the lines on the zones.

Example: 
```js
let newColor = {
    color: [10, 20, 30],
    lines: 40,
    walls: 50
}

setActiveRGBAAValue(newColor);
```

---

#### `setInactiveRGBAAValue(newRGBAA)`

Input: 
- `{ color: [0, 0, 0], lines: 0, walls: 0 }`, first an RGB value, then alphas.


Output:
- none 

RGBAA is *not* a typo, because this is practically two colors in one with different alpha values; one for the walls and one for the lines on the zones.

Example: 
```js
let newColor = {
    color: [110, 120, 130],
    lines: 140,
    walls: 150
}

setInactiveRGBAAValue(newColor);
```

---

#### `setZoneNameValue(newZoneName)`

Input:   
- `string`, the zoneName value.

Output:
- none

Set the value of the zoneName input.

Example:
```js
let zoneName = "Coffe Cat Cafe";

setZoneNameValue(zoneName);
```

---

#### `setAltitudeValue(value)`

Input:   
- `number`, the altitude value with 2 decimals.

Output:
- none

Set the value of the altitude input.

Example:
```js
let altitude = 73.20;

setAltitudeValue(altitude);
```

---

#### `setHeightValue(newHeight)`

Input:   
- `number`, the height value with 2 decimals.

Output:
- none

Set the value of the height input.

Example:
```js
let height = 3.14;

setHeightValue(height);
```

---

#### `setEventValue(newEvent)`

Input:   
- `boolean`, the event value.

Output:
- none

set the value of the event input.

Example:
```js
let event = true;

setEventValue(event);
```

---

#### `setDrawingValue(newDrawing)`

Input:   
- `boolean`, the drawing value.

Output:
- none

False the value of the drawing input.

Example:
```js
let drawing = false;

setDrawingValue(drawing);
```

---
---

<a name="otherFunctions"></a>

## Other functions

### `populateTable(table, data)`

Input: 
- `table`, the table element to be populated.
- `data`, an array with arrays of data to fill the table.

Output:   
- none

This function clears the table and adds new data to it with automatic numbering based on index. In case you want to only clear the data, use `clearTable(table)`.

Example:
```js
let tableElem = document.getElementById("table");

// Example data
let tempTableData = [];
for(let i = 1; i <= 5; i++) {
    tempTableData.push(["xxxx", "yyyy"]);
}

populateTable(tableElem, tempTableData);

```

---

### `clearTable(table)`

Input: 
- `table`, the table element to be cleared.

Output:   
- none

This function simply clears the table, leaving the header-row intact. Simple as that.

Example:
```js
let tableElem = document.getElementById("table");

clearTable(tableElem);
```

---

### `getIndexOfActiveRow()`

Input:   
- none

Output
- `number`, index of the row.

Use this function to get the current selected row in the table. They are already used inside two event listeners in the file `scriptRightSide.js` to view or delete the point.

Example:
```js
let viewButtonElem = document.getElementById("viewButton");
let deleteButtonElem = document.getElementById("deleteButton");

viewButtonElem.addEventListener("click", (event) => {
    console.log("viewButton");
    let activeRowIndex = getIndexOfActiveRow();
});

deleteButtonElem.addEventListener("click", (event) => {
    console.log("deleteButton");
    let activeRowIndex = getIndexOfActiveRow();
});
```

---
### `showModalMessage(message, buttons)`

Input: 

- `message`, the message, works for plain text, tables and whatever just remember to add the HTML for it.
- `button`, an array of button/s data in an object:
    - `color`, color of the button, choose between "Green", "Red", "Blue"
    - `text`, the text that the button will display.
    - `function`, what will happend when the button is clicked.

Output:  
- none

This is the one and only modal and it is fairly customizable as you add the HTML you want and as many buttons as you need. Even if you want only one or zero buttons, you still have to include an empty array. Note! When choosing a color for the button, it *has* to be capitalized. To prevent the button/s to keeping focus after click add `event.target.blur();` to the function, as seen below.

Example:
```js
let alertElem = document.getElementById("alert");

let button = [{
    color: "Green",
    text: "Will do",
    action: (event) => {
        event.target.blur();
        hideElem(alertElem);
    }
}];

showModalMessage("<p>You need to select a row before proceeding with that action.</p>", button);
```

---

### `showUI(bool)`

Input:
- bool, true or false, yes or no, yay or nay.

Output:
- none

A function to show or hide the UI.

Example: 
```js
showUI(true);
```

---