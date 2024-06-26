local usage = {
    {"Verb",   "Arguments",     "Function"},
    {"cancel", "",              "Cancel the current edit, discarding all changes since last save."},
    {"check",  "name resource", "Checks if the named zone file is valid, but does not load it."},
    {"edit",   "name",          "Puts the zone of the given name into edit mode."},
    {"help",   "",              "Gives you this lovely message!"},
    {"list",   "",              "Display a list of loaded trigger zones."},
    {"load",   "name resource", "Loads the named zone from disk, even if it's already loaded.",},
    {"new",    "name",          "Creates a new, blank zone for editing, with that initial name."},
    {"save",   "",              "Saves the zone being edited."},
    {"unload", "name",          "Unloads the specified zone from all clients."},
}

function SendMessage(source, ...)

    local args = {...}
    if source == 0 then
        if type(args[1]) == "table" then
            args = FormatTable(args[1], true, false)
        end
        for _, line in ipairs(args) do
            print(line)
        end
        return
    end

    TriggerClientEvent("triggerzone:message", source, ...)
end

function CloseBlocker(source)
    if source == 0 then return end
    TriggerClientEvent("triggerzone:closeBlocker", source)
end

local function checkZone(source, args)
    if #args == 0 then
        SendMessage(source, "You must specify the file to check.")
        return
    end

    local resource = args[2] or GetCurrentResourceName()
    if not IsValidResource(resource) then
        SendMessage(source, "The resource you specified does not exist.")
        return
    end

    local success, name, zone = LoadZoneFile(args[1], resource)
    if not success then
        SendMessage(source, name)
        return
    end

    local zoneData = {{"Key", "Value"}}
    for key, value in pairs(zone) do
        if key == "points" then
            table.insert(zoneData, {key, ("%i verticies"):format(#value)})
        elseif key == "color" then
            table.insert(zoneData, {"Color (active)", ("RGB:(%i, %i, %i), Lines: %i, Walls: %i"):format(
                zone.color?.inside?[1] or -1,
                zone.color?.inside?[2] or -1,
                zone.color?.inside?[3] or -1,
                zone.color?.inside?[4] or -1,
                zone.color?.inside?[5] or -1
            )})
            table.insert(zoneData, {"Color (inactive)", ("RGB:(%i, %i, %i), Lines: %i, Walls: %i"):format(
                zone.color?.outside?[1] or -1,
                zone.color?.outside?[2] or -1,
                zone.color?.outside?[3] or -1,
                zone.color?.outside?[4] or -1,
                zone.color?.outside?[5] or -1
            )})
        else
            table.insert(zoneData, {key, ("%s"):format(value)})
        end
    end
    SendMessage(source, zoneData)
end

local function cancelEdit(source, args)
    TriggerClientEvent("triggerzone:cancel", source)
end

local function editZone(source, args)
    if source == 0 then
        SendMessage(0, "This is used to put the client into edit mode.", "Editing zones is not supported on the server.")
        return
    end
    if #args == 0 then
        SendMessage(source, "You must specify a zone to edit.")
        return
    end
    if not TRIGGERZONES[args[1]] then
        SendMessage(source, "Zone '" ..args[1].. "' does not seem to exist.", "To create a zone, use the verb 'new'." )
        return
    end
    TriggerClientEvent("triggerzone:edit", source, args[1])
end

local function helpMessage(source, args)
    SendMessage(source, usage)
end

local function listZones(source, args)
    local list = { {"Name", "Label", "Verticies", "Events", "Drawn", "Origin"} }
    local numZones = 0
    for name, zone in pairs(TRIGGERZONES) do
        numZones += 1
        table.insert(list, {name, zone.label, #zone.points, zone.events and "Yes" or "No", zone.draw and "Yes" or "No", zone.origin})
    end
    if numZones > 0 then
        SendMessage(source, list)
    else
        SendMessage(source, "No trigger zones are currently loaded")
    end
end

local function loadZone(source, args)
    if #args == 0 then
        SendMessage(0, "When loading a zone, you must specify it's filename.")
        return
    end

    local resource = args[2] or GetCurrentResourceName()
    if not IsValidResource(resource) then
        SendMessage(source, "The resource you specified does not exist.")
        return
    end

    Load(args[1], resource)
end

local function newZone(source, args)
    if source == 0 then
        SendMessage(0, "This is used to create a new zone for editing.", "Editing zones is not supported on the server.")
        return
    end
    if #args == 0 then
        SendMessage(source, "You must specify an intitial name.")
        return
    end
    local name = KeyFromFilename(UniformZoneFilename(args[1]))
    if TRIGGERZONES[name] then
        SendMessage(source, "Zone '" ..name.. "'exists already.", "To edit a zone, use the verb 'edit'." )
        return
    end
    TriggerClientEvent("triggerzone:new-zone", source, name)
end

local function saveZone(source, args)
    if source == 0 then
        SendMessage(0, "This is used to save zones you are editing.", "Editing zones is not supported on the server.")
        return
    end
    -- Basically just send an event to the client, requesting the current state of a given zone.
    -- The actual saving happens in the handler of the client response to this.
    -- The client will know the name of what is being edited, if it's being edited, and all that jam.
    TriggerClientEvent("triggerzone:save-zone", source)
end

local function unloadZone(source, args)
    if #args == 0 then
        SendMessage(source, "You must specify the zone to unload.")
        return
    end
    if TRIGGERZONES[args[1]] then
        TRIGGERZONES[args[1]] = nil
    else
        SendMessage(source, "The zone you tried to unload, " .. args[1] ..", did not exist on the server.", "Telling clients to unload it anyway, just in case.")
    end
    TriggerClientEvent("triggerzone:unload-zone", -1, args[1])
end

local commandVerbs = {
    cancel = cancelEdit,
    check = checkZone,
    edit = editZone,
    help = helpMessage,
    list = listZones,
    load = loadZone,
    new  = newZone,
    save = saveZone,
    unload = unloadZone,
}

function GetCommandVerbs()
    local verbs = {}
    for verb, _ in pairs(commandVerbs) do
        table.insert(verbs, verb)
    end
    table.sort(verbs)
    return verbs
end

RegisterCommand("triggerzone", function(source, args, raw)
    if #args == 0 then
        args = {"help"}
    end

    local verb = table.remove(args, 1):lower()

    if commandVerbs[verb] then
        commandVerbs[verb](source, args)
    else
        commandVerbs["help"](source, args)
    end
end, true)
