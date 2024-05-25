function PrepareZone(name, zone)
    zone.height = zone.height or (Config?.Editor?.DefaultHeight or 2.0)
    zone.altitude = zone.altitude or 0.0
    zone.points, zone.triangles = Triangulate(zone.points or {})
    zone.centroid = Centroid(zone.points)
    zone.color = zone.color or {
        outside = {255, 255, 0, 200, 100},
        inside = {0, 255, 0, 200, 100},
    }
    zone.labelPoint = vec3(zone.centroid.x, zone.centroid.y, zone.altitude + (zone.height/2))
    zone.triggered = false
    zone.label = zone.label or name
    zone.events = zone.events or false
    zone.version = zone.version or 1
    zone.draw = zone.draw or false
end

function MessageOK(...)
    --TODO: Message modal with OK button.
    for _, line in ipairs({...}) do
        print('OK:', line)
    end
end

function MessageCrap(...)
    --TODO: Error modal with "Crap" button.
    for _, line in ipairs({...}) do
        print('CRAP:', line)
    end
end

function MessageBlock(...)
    --TODO: Message modal with *no* buttons. Spinner?
    for _, line in ipairs({...}) do
        print('BLOCK:', line)
    end
end

RegisterNetEvent('triggerzone:message', function(...)
    MessageOK(...)
end)

RegisterNetEvent('triggerzone:add', function(name, zone)
    print('Got zone data for', name)
    TRIGGERZONES[name] = zone
    PrepareZone(name, zone)
end)

RegisterNetEvent('triggerzone:addBulk', function(zones)
    for name, zone in pairs(zones) do
        TRIGGERZONES[name] = zone
        PrepareZone(name, zone)
        print('Bulk adding', name)
    end
end)

RegisterNetEvent('triggerzone:save-zone', function()
    if not EDITING then
        MessageOK("Can't save:  Not currently editing anything.")
        return
    end
    if not TRIGGERZONES[EDITING] then
        MessageOK("WTF?! You seem to be editing a trigger zone that doesn't exist?!")
        EditorShutdown()
        return
    end
    TriggerLatentServerEvent('triggerzone:save-zone', 2048, EDITING, TRIGGERZONES[EDITING])
end)

RegisterNetEvent('triggerzone:discard', function()
    if not EDITING then
        MessageOK("Can't discard changes when not editing.")
        return
    end
    TRIGGERZONES[EDITING] = nil
    TriggerServerEvent('triggerzone:resend', EDITING)
    MessageBlock("Discarding changes...")
    EditorShutdown()
end)

RegisterNetEvent('triggerzone:edit', function(zoneName)
    if EDITING then
        MessageOK("You are already editing a zone. You must discard this edit before you can start another.")
        return
    end
    print("Preparing to edit", zoneName)
    if not TRIGGERZONES[zoneName] then
        MessageCrap("Could not edit zone because it does not exist locally.  This should never happen.")
        return
    end
    EditorStart(zoneName)
end)

RegisterNetEvent('triggerzone:new-zone', function(zoneName)
    if EDITING then
        MessageOK("You are already editing a zone. You must discard this edit before you can start another.")
        return
    end
    print("Starting new zone", zoneName)
    if TRIGGERZONES[zoneName] then
        MessageCrap("Could not create a new zone because it already exists locally.  This should never happen.")
        return
    end
    TRIGGERZONES[zoneName] = {
        draw = true,
    }
    PrepareZone(zoneName, TRIGGERZONES[zoneName])
    EditorStart(zoneName)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    EditorShutdown()
end)