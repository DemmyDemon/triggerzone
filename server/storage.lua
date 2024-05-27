function ZonesDirFile(name)
    name = name:match("[^\\/\\]+$")
    return "zones/" .. name
end

function UniformZoneFilename(name)
    name = name:match("[^\\/\\]+$")
    name = name:match("^([^.]+)")
    name = name:gsub("[%W]", "_")
    return name:lower() .. ".tzf"
end

function KeyFromFilename(name)
    name = name:match("[^\\/\\]+$")
    name = name:match("^([^.]+)")
    return name
end

TRIGGERZONES = {}

function Set(name, zoneData)
    local points, triangles = Triangulate(zoneData.points or {})
    TRIGGERZONES[name] = {
        origin = GetCurrentResourceName(),
        label = zoneData.label,
        height = zoneData.height or 100.0,
        altitude = zoneData.altitude or 0.0,
        points = points,
        triangles = triangles,
        centroid = Centroid(points),
        draw = zoneData.draw or false,
        events = zoneData.events or false,
        version = zoneData.version or 1,
        color = zoneData.color,
    }
    TriggerLatentClientEvent('triggerzone:add', -1, 1024, name, TRIGGERZONES[name])
    return true
end
exports("Set", Set)

function Load(filename)
    filename = ZonesDirFile(filename)
    local name = KeyFromFilename(UniformZoneFilename(filename))
    local data = LoadResourceFile(GetCurrentResourceName(), filename)
    if not data then
        print(('Failed to load any data from %s:  Does the file even exist?'):format(filename))
        return
    end
    local success, zone = pcall(msgpack.unpack,data)
    if not success then
        print(('Failed to load %s: %s'):format(filename, zone))
        return
    end
    print(('Successfully loaded %s'):format(filename))
    Set(name, zone)
end
exports("Load", Load)

function Store(name, zone)
    name = KeyFromFilename(UniformZoneFilename(name))
    local data = msgpack.pack({
        label = zone.label or name,
        origin = zone.origin or GetCurrentResourceName(),
        height = zone.height or 100.0,
        altitude = zone.altitude or 0.0,
        draw = zone.draw or false,
        points = zone.points or {},
        events = zone.events or false,
        version = zone.version or 1,
        color = zone.color,
    })
    local size = string.len(data)
    local filename = ZonesDirFile(UniformZoneFilename(name))
    if SaveResourceFile(GetCurrentResourceName(), filename, data, size) then
        print(('Successfully stored %s (%d bytes) '):format(filename, size))
    else
        print(('Failed to store %s -> Does the directory exist?'):format(filename))
    end
end
exports("Store", Store)