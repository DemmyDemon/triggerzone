# Triggerzone

Triggerzone is not intended for end user use. It is a development tool and a development library, intended to supply a useful function to FiveM script developers.

It does not function without FiveM. This is intentional. It does nothing alone. This is also intentional.

# What it does

The short version is that triggerzone triggers an even then you leave or exit a "zone", and provides an editor interface for defining such zones.

## Defining zones

There is [a tutorial](tutorial/index.md) that walks you through creating your first zone. It is done by placing verticies on the ground by clicking, and is, hopefully, very intuitive.

## Loading zones

Zones are stored in .tzf files. Trigger Zone File. These are [messagepack](https://github.com/citizenfx/lua-cmsgpack/) encoded Lua tables.  
Usually, you will load these from the code of your own resource, more on that in the exports section, but you can manually load them using a command.  Of course, this *can* be done in your server.cfg, or similar, so it doesn't have to be a problem.

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

# Editor UI

Large parts of the editor UI was designed and implemented by [MonBjo on GitHub](<https://github.com/MonBjo/triggerzones-ui>).
Thank you very much for the assist!

If you are brand new to the triggerzone, you might want to look at [the tutorial](tutorial/index.md) as well.

TODO: Editor screenshot goes here.

TODO: Legend of above screenshot goes here.

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

TODO: GetLoadedZones example code.

## GetZoneFilenames

TODO: GetZoneFilenames example code.

## GetZoneLabel

TODO: GetZoneLabel example code.

## GetZonesAtPoint

TODO: GetZonesAtPoint example code.

## IsPointInsideZone

TODO: IsPointInsideZone example code.

## Load

TODO: Load example code.

## LoadZoneFile

TODO: LoadZoneFile example code.

## Set

TODO: Set example code.

## Store

TODO: Store example code.

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
