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

local function isValidResource(resource)
    if not resource or resource == "" then
        return false
    end
    local state = GetResourceState(resource)
    if state == "missing" or state == "unknown" then
        return false
    end
    return true
end

TRIGGERZONES = {}

function Set(name, zoneData, resource)
    resource = resource or zoneData.origin
    if not isValidResource(resource) then
        resource = GetInvokingResource()
    end
    resource = resource or GetCurrentResourceName()
    local points, triangles = Triangulate(zoneData.points or {})
    TRIGGERZONES[name] = {
        origin = resource,
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
    TriggerLatentClientEvent('triggerzone:add', -1, Config?.SendRate or 5120, name, TRIGGERZONES[name])
    return true
end
exports("Set", Set)

function Load(filename, resource)
    resource = resource or GetInvokingResource()
    resource = resource or GetCurrentResourceName()
    filename = ZonesDirFile(filename)
    local name = KeyFromFilename(UniformZoneFilename(filename))
    local data = LoadResourceFile(resource, filename)
    if not data then
        print(('Failed to load any data from %s/%s:  Does the file even exist?'):format(resource, filename))
        return
    end
    local success, zone = pcall(msgpack.unpack,data)
    if not success then
        print(('Failed to load %s/%s: %s'):format(resource, filename, zone))
        return
    end
    zone.origin = resource
    print(('Successfully loaded %s/%s'):format(resource, filename))
    Set(name, zone)
end
exports("Load", Load)

function Store(name, zone, resource)
    resource = resource or zone.origin
    if not isValidResource(resource) then
        resource = GetInvokingResource()
    end
    resource = resource or GetCurrentResourceName()
    name = KeyFromFilename(UniformZoneFilename(name))
    print('Events: ', zone.events)
    local data = msgpack.pack({
        label = zone.label or name,
        origin = resource,
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
    if SaveResourceFile(resource, filename, data, size) then
        print(('Successfully stored %s/%s (%d bytes) '):format(resource, filename, size))
    else
        print(('Failed to store %s/%s -> Does the zones directory exist?'):format(resource, filename))
    end
end
exports("Store", Store)

function GetLoadedZones()
    local list = {}
    for name, data in pairs(TRIGGERZONES) do
        list[name] = data.origin
    end
    return list
end
exports("GetLoadedZones", GetLoadedZones)
