# Triggerzone

Triggerzone is not intended for end user use. It is a development tool and a development library, intended to supply a useful function to FiveM script developers.

It does not function without FiveM. This is intentional. It does nothing alone. This is also intentional.

# What it does

The short version is that triggerzone triggers an even then you leave or exit a "zone", and provides an editor interface for defining such zones.

## Defining zones

There is [a tutorial](tutorial/index.md) that walks you through creating your first zone. It is done by placing verticies on the ground by clicking, and is, hopefully, very intuitive.

## Loading zones

Zones are stored in .tzf files. Trigger Zone File. These are [messagepack](https://github.com/citizenfx/lua-cmsgpack/) encoded Lua tables.  
Usually, you will load these from the code of your own resource, more on that in [the exports section](#exported-functions), but you can manually load them using a command.  Of course, this *can* be done in your server.cfg, or similar, so it doesn't have to be a problem.

It is recommended to load your zones from your code.

## Using zones

Zones are stored with a setting called `events`. If this setting is `true`, entering or exiting that zone will trigger an event, and your resource can act on that event as it sees fit.

You can also manually check if a point is inside a zone. For example, you can specify your own command, and have it check if you're inside the special zone before letting you use it. You can have an NPC act differently when talked to inside or outside a zone. That sort of thing.

# A word on performance

Checking zones is a lot of math. A lot. If your zone has `events` activated, the distance to that zone has to be checked *all the time*, causing it to slow down a little. Performance is being worked on, but there is no real way to avoid this distance check.  For optimal performance, only enable `events` if you really need it.

There is also a `draw` setting, that will draw a visual representation of the zone even when it's not being edited.  This might be useful for testing, but complex zones are drawn using a huge number of native calls. This is bad, and should be avoided if you don't absolutely need it.  The graphics themselves are trivially light, but the CPU load of the native calls is substantial.

# Commands

There is just one command, `/triggerzone`, but it has several *verbs*.

| Verb   | Arguments     | Function                                                         |
|--------|---------------|------------------------------------------------------------------|
| cancel |               | Cancel the current edit, discarding all changes since last save. |
| check  | name resource | Checks if the named zone file is valid, but does not load it.    |
| edit   | name          | Puts the zone of the given name into edit mode.                  |
| help   |               | Gives you this lovely message!                                   |
| list   |               | Display a list of loaded trigger zones.                          |
| load   | name resource | Loads the named zone from disk, even if it's already loaded.     |
| new    | name          | Creates a new, blank zone for editing, with that initial name.   |
| save   |               | Saves the zone being edited.                                     |
| unload | name          | Unloads the specified zone from all clients.                     |

## cancel

`/triggerzone cancel`

Cancel editing, discarding and discard any changes made to the zone being edited.  This will remove the zone from your local client, and prompt the server to re-send it as it is saved on the server.

## check

`/triggerzone check whatever.tzf`

This will load the file `whatever.tzf` from the zones directory of the triggerzone resource. Useful for verifying that the zone file in question is valid. It will either tell you it's broken, or it will tell you what is stored in it.  If it gives you a list of things stored in the file, that means it checks out.

If a third argument is specified, that lets you specify what resource to load from when checking. If omitted, it will presume `triggerzone`'s own zones/ directory.

## edit

`/triggerzone edit whatever`

This presumes the zone named `whatever` is already loaded, and will start the editor interface to fiddle with that zone.

This works exactly like in [the tutorial](tutorial/index.md), except it will have points already in it.

## help

`/triggerzone help`

Shows you the table of verbs and what they do, much like the table above.

## list

`/triggerzone list`

Shows a list of the currently loaded zones, and some metadata about it.

| Column    | Meaning                                                    |
|-----------|------------------------------------------------------------|
| Name      | The filename, minus the .tzf extention                     |
| Label     | The label shown at the centroid when editing               |
| Verticies | The number of points that make out the outline of the zone |
| Events    | "Yes" or "No" if this zone emits events                    |
| Drawn     | "Yes" or "No" if this zone is drawn outside the editor     |
| Origin    | The name of the resource this resource was loaded from     |

## load

`/triggerzone load my_awesome_zone.tzf`

Load the specified .tzf file, and activate it as a zone.  If it is Drawn or emits Events, it will start doing so immediately, for all users.

If a third argument is specified, that lets you specify what resource to load from. If omitted, it will presume `triggerzone`'s own zones/ directory.

## new

`/triggerzone new aw_yiss`

This will create a brand new zone named `aw_yiss`, and open it for editing.  
See [the tutorial](tutorial/index.md) for details.

When naming zones, keep in mind that they can't have special symbols, or spaces, in their names, as the name ends up being the filename.  Also, keep in mind that you might conflict with other resoruces, so rather than using a generic name, use one specific to your resource.  For example, rather than `parking`, use `falcon_casino_parking`, or whatever matches your resource.

## save

`/triggerzone save`

Saves the zone currently being edited, using it's name as a filename. Will store it back in the resource it was loaded from, if possible.

This will *discard* the local copy of the zone, and the server will respond with the saved copy to reload it. This will be propagated to *all* clients.

## unload

`/triggerzone unload loathsome_square`

Unloads a zone by the name specified, if it is loaded. This takes immediate effect on all clients.

# Editor hotkeys

| Function             | Control action              | Default bind       |
|----------------------|-----------------------------|--------------------|
| Speed up camera      | 38 INPUT_PICKUP             | E                  |
| Slow down camera     | 44 INPUT_COVER              | Q                  |
| Boost camera speed   | 21 INPUT_SPRINT             | Left Shift         |
| Interact with vertex | 24 INPUT_ATTACK             | Left mouse button  |
| Delete vertex        | 25 INPUT_AIM                | Right mouse button |
| Move camera forward  | 32 INPUT_MOVE_UP_ONLY       | W                  |
| Move camera backward | 33 INPUT_MOVE_DOWN_ONLY     | S                  |
| Move camera left     | 34 INPUT_MOVE_LEFT_ONLY     | D                  |
| Move camera right    | 35 INPUT_MOVE_RIGHT_ONLY    | A                  |
| Modifier             | 36 INPUT_DUCK               | Left Ctrl          |
| Decrease value       | 16 INPUT_SELECT_NEXT_WEAPON | Scrollwheel down   |
| Increase value       | 17 INPUT_SELECT_PREV_WEAPON | Scrollwheel up     |
| Toggle UI focus      | 22 INPUT_JUMP               | Spacebar           |

## Interacting with verticies

Left-clicking while the cursor is yellow inserts a vertex at the given position.
Clicking and holding will insert the vertex, and then let you drag it into place.

Similarly, when the cursor is red, you can click and drag the closest vertex to a new position.

## Adjusting altitude and height

The "Decrese value" and "Increase value" controls do different things depending on if "Modifier" is pressed.

*Without* the modifier, it will increase and decrease the *Height* property of the zone.
*With* the modifier, it will increase and decrease the *Altitude* property of the zone.

# Editor UI

Large parts of the editor UI was designed and implemented by [MonBjo on GitHub](<https://github.com/MonBjo/triggerzones-ui>).
Thank you very much for the assist!

**To interact with the input fields and buttons, press the space bar.**

If you are brand new to the triggerzone, you might want to look at [the tutorial](tutorial/index.md) as well.

![Triggerzone UI](tutorial/Editor.png)

1. Zone controls
2. Points list
3. Area visualizer
4. Cursor-and-beam
5. Centroid
6. Glance data
7. Color controls
8. Minimap

## 1. Zone controls

This area holds a number of controls that define how your zone behaves.

### Label

This is the label drawn at the centroid, and is sent with the zone name in events. This is what you intend for the zone to be called, or referred to as, when interacting with a user.

### Altitude

The floor of your zone is this altitude above global zero.  This is set when you place the first point, but you can edit it freely.
This can also be adjusted with the hotkey Ctrl+Scrollwheel, assuming you have the default GTAV keybinds.

### Height

The distance, in meters, from the Altitude to the ceiling of the zone.
For reference, the default player ped is 2.0 units tall, but it's location is 1.0 units above where it is standing.  This means a zone that is flush with the floor will have to be just slightly taller than 1.0 for it to register players standing in it, but to not register them if they jump.

### Event

Does this zone trigger an event when entering or leaving it?

*Note:  This has performance implications.*

### Draw

Is this zone drawn, even when it is not being edited?

*Note:  This has serious performance implications.*

### Cancel

Discard all changes since the last save, and stop editing this zone.

### Save

Save changes made to this zone, and send them to the server. It is then distributed to all clients immediately!

## 2. Points list

This list shows the current points that make up your zone. Note that the points are not in any way preserved, and their number/index will hop around as you edit the zones. This is due to the polygon cleanup that happens behind the scenes.

If you click one of the points, you can then use the Action buttons below.
*View* will move the camera to put the point into view.
*Delete* will remove the point permanently.

You can hide the points list by clicking the little arrow.

## 3. Area visualizer

The area visualizer shows the walls, floor, and ceiling of your zone.
When your player ped is inside the zone, as shown in the screenshot, it will use the Active zone color. When you are outside, it will use the Inactive zones color.

Note that while the lines and walls are drawn in 3D space, the vertex labels are drawn on top, and will show through the world. If you move your camera too far from the zone, it will no longer draw the labels.

## 4. Cursor-and-beam

The spherical cursor shows you your intraction range. When it turns red, you will interact with the closest vertex. When it is yellow, you are in insert mode.

When it is interact mode, the glance data will update to show which vertex you will interact with.
When it is in insert mode, the glance data will update to show what index the new vertex will have.

The beam shows where the zone corner will be, and obeys Altitude and Height, even if the cursor is above or below the zone.

## 5. Centroid

This shows the current label for the zone, and where the geometric centroid of the zone is.
This does not have to be *inside* the zone, it's just a marker.
The centroid beam shows the height of the zone, just like the cursor beam.

Note that this will move around as you edit the zone.

## 6. Glance data

This little blob of text will show you some data about the state of the editor.

- Filename
- Number of verticies (misspelled in the screenshot, since fixed)
- The current camera speed (Use Q and E to adjust)
- Interaction hint

The interaction hint in the screenshot shows that a new vertex will be inserted at index 12.
When the cursor is close enough to an existing vertex, it will turn red, and the interaction hint will tell you what vertex you will interact with.

## 7. Color controls

These are the colors of active and inactive zones. A zone is active when your current player ped is *inside* it.

Note that the walls and lines have *separate* alpha values.  The vertex labels follow the lines alpha value.

## Minimap

The minimap will still show everything it would normally show, but it will now focus on where your cursor is.
The little ring shown is not to any sort of scale, but it will tell you exactly where the cursor is, not where the camera is.

Zoom is adjusted according to the distance between the camera and the cursor, meaning you get a very zoomed in view if you are editing up close.

# Exported functions

These are the functions you can use from your own resource, and what they do.

| Name              | Where  | Arguments                | Intended use                                                             |
|-------------------|--------|--------------------------|--------------------------------------------------------------------------|
| GetLoadedZones    | Server |                          | Get a list of loaded zones, and their associated resource of origin.     |
| GetZoneFilenames  | Server | resource                 | Get a list of .tzf files in the zones/ directory of the given resource.  |
| GetZoneLabel      | Shared | zoneName                 | Get the label for the zone of the given name.                            |
| GetZonesAtPoint   | Shared | point                    | Get a list of zones that overlap with the given vector3 point.           |
| IsPointInsideZone | Shared | point, zoneName          | Check if the given vector3 point is inside the zone with the given name. |
| Load              | Server | filename, resource       | Load zone data, and set the zone.                                        |
| LoadZoneFile      | Server | filename, resource       | Load zone data, but don't actually set the zone.                         |
| Set               | Server | name, zoneData, resource | Set a zone from raw data.                                                |
| Store             | Server | name, zoneData, resource | Store the zone data to a file who's name is derived from the given name. |

"Shared" means it's both on the client and the server.  Server obviously means it's only available from the server.

When an arguemnt is "resource", it can be omitted. It will assume you mean the resource you are calling the function from.

## GetLoadedZones

```lua
local zoneTable = exports.triggerzone:GetLoadedZones()
for zoneName, originResource in pairs(zoneTable) do
    print(zoneName, originResource)
end
```

Takes no arguments.
Returns a table of loaded zones, for example

```lua
{
    demonstration = "someResource",
    falcon_casino_floor_1 = "falcon-casino",
    tutorial = "triggerzone_test",
}
```

The key is the zone name, the value is the resource of origin.

## GetZoneFilenames

```lua
local filenames = exports.triggerzone:GetZoneFilenames()
for _, filename in ipairs(filenames) do
    exports.triggerzone:Load(filename)
end
```

Optionally takes a resource name as an argument. By default, it will use the resource it is called from.

Returns a table of filenames for any .tzf files in that resource, in no particular order, for example

```lua
{ "pdm_behind_counter.tzf", "pdm_office_1.tzf", "pdm_office_2.tzf", "pdm_mechanic_bay.tzf" }
```

Useful for autoloading zone files without having to maintain a list.

## GetZoneLabel

```lua
function DoThingInZone(player, zone)
    local coords = GetEntityCoords(GetPlayerPed(player))
    if exports.triggerzone:IsPointInsideZone(coords, zone) then
        DoTheThing(player, zone)
    else
        print( ("You must be in %s to do the thing!"):format(exports.triggerzone:GetZoneLabel(zone)) )
    end
end
```

Returns a string. If the zone is not loaded, it returns an *empty* string, and if there is no label set, it returns the zone name as given.

## GetZonesAtPoint

```lua
function WhereIsNPC(npc)
    local coords = GetEntityCoords(npc)
    local zones = exports.triggerzone:GetZonesAtPoint(coords)
    for zoneName, label  in pairs(zones) do
        print( ("NPC is in %s!"):format(label) )
        Frobnicate(npc, zoneName)
    end
end
```

Iterates through all loaded zones, and checks if the given point is in them.
Returns a table of zones, with their label, that the point is in.
For example,

```lua
{
    del_perro_pier = "The Pier",
    pier_hotdog_stand_3 = "Hotdog stand",
}
```

## IsPointInsideZone

```lua
function OpenBossMenu(player)
    local coords = GetEntityCoords(GetPlayerPed(player))
    if exports.triggerzone:IsPointInsideZone(coords, "laywer_boss_office") then
        TriggerClientEvent("laywerjob:showBossMenu", player)
    else
        TriggerClientEvent("laywerjob:showMessage", player, "You must be in your office to do that.")
    end
end
```

Returns a boolean. If the zone is not loaded, it will always return false, as no point can ever be inside an unloaded zone.

## Load

```lua
local filenames = exports.triggerzone:GetZoneFilenames()
for _, filename in ipairs(filenames) do
    exports.triggerzone:Load(filename)
end
```

Loads a zone file, and sends it to all clients for immediate use.

Returns true if the load was successful, false otherwise.
Will output success/failure to console as well.

## LoadZoneFile

```lua
function LoadSporkZone()
    local success, name, data = exports.triggerzone:LoadZoneFile('spork.tzf')
    if not success then
        print( ("Failed to load spork zone file, because %s"):format(name) )
        return
    end
    print( ("Oh no, we loaded %s, and did nothing with it!"):format(data.label or name) )
end
```

Loads the given zone file into memory, but does not send to clients or in any way make it available anywhere else.

Returns three values.
1. A boolean that tells you if the load was successful.
2. A string that holds the name of the zone (as derived from the filename), *or* the reason it failed to load.
3. A table containing the zone data, *or* just an empty table if the loading failed.

## Set

```lua
function NoFileNeededHAHAHAHA()
    local zoneData = {
        label = "Why would you do this?!"
        altitude = 36.4,
        height = 2.0,
        points = {
            vector2(0.0, 0.0)
            vector2(1.0, 0.0)
            vector2(1.0, 1.0)
            vector2(0.0, 1.0)
        }
    }
    exports.triggerzone:Set("some_zone", zoneData)
end
```

Sets a zone with the given zoneData, even if that data makes very little sense.  
Always returns true, even if you are being silly, and the whole thing catches fire.  

**Please, do not do this.  Use the editor instead.**  It is provided only for the warm, fuzzy feeling of completeness.

## Store

```lua
function SabotageZoneFilesDirectory()
    local zoneData = {
        label = "Why would you do this?!"
    }
    local saved, filename, size = exports.triggerzone:Store("some_zone", zoneData)
    if saved then
        if size > 9000 then
            print("OH WOW, where did all that data come from?!")
        end
    else
        print("OH NO! TIME TO PANIC!!!")
    end
end
```

Writes out a zone file with the given zone data.

Returns a boolean denoting if the save was successful, the name of the file it was saved as, and the length of the encoded messagepack string.

Generally speaking, you should never need to do this yourself.  **Please don't use this.  Use the editor instead.**

# Configuration file

There is a `config.lua`, and there should *probably* be some documentation related to it at some point.

For now, though, just don't mess with it. You really don't need to.

# Anticipated Questions

I'd call it a FAQ, but since there has been no release, there can't possibly be any *frequently* asked questions, right?

## Why the zones/ directory?

Having a uniform structure across all resources using this one is a good idea. Just trust me on this.

## Why Messagepack and not something like JSON?

Because encoding and decoding vector2 typed data to/from other formats is a pain, and messagepack is very well battle tested.

## Why .tzf?

Because it's a Trigger Zone File. I wanted an easily recognizable file extention, and, as far as I could tell, this one wasn't "taken".

## Has anyone really been far even as decided to use even go want to do look?

Not that I know of, but Agent Michael Ford is a pretty cool guy, and doesn't afraid of anything.
