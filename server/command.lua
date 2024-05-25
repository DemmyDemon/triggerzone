local usage = {
    {"VERB",               "FUNCTION"},
    {"check [zone name]",  "Checks if the named zone file is valid, but does not load it."},
    {"edit [zone name]",   "Puts the zone of the given name into edit mode."},
    {"help",               "Gives you this lovely message!"},
    {"list",               "Display a list of active trigger zones."},
    {"load [zone name]",   "Loads the named zone from disk, even if it's already loaded.",},
    {"new [initial name]", "Creates a new, blank zone for editing, with that initial name."},
    {"save <new name>",    "Takes no arguments, saves the zone being edited, optionally under a new name."},
}

function SendMessage(source, ...)
    
    local args = {...}
    if source == 0 then
        if type(args[1]) == "table" then
            args = FormatTable(args[1], true)
        end
        for _, line in ipairs(args) do
            print(line)
        end
        return
    end

    TriggerClientEvent("triggerzone:message", source, ...)
end

local function checkZone(source, args)
    -- TODO: Read file and see that it loads properly, but *DO NOT* send to clients or add to TRIGGERZONE table.
end

local function discardEdit(source, args)
    TriggerClientEvent("triggerzone:discard", source)
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
    -- TODO: Send something useful here XD
end

local function loadZone(source, args)
    if #args ~= 1 then
        SendMessage(0, "When loading a zone, you must specify it's filename.")
        return
    end
    Load(args[1])
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

local commandVerbs = {
    check = checkZone,
    discard = discardEdit,
    edit = editZone,
    help = helpMessage,
    list = listZones,
    load = loadZone,
    new  = newZone,
    save = saveZone,
}

RegisterCommand("triggerzone", function(source, args, raw)
    if #args == 0 then
        SendMessage(source, table.unpack(usage))
        return
    end

    local verb = table.remove(args, 1):lower()

    if commandVerbs[verb] then
        commandVerbs[verb](source, args)
    else
        -- TODO:  Treat this differently?
        commandVerbs["help"](source, args)
    end
end, true)
