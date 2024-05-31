RegisterNUICallback('altitude', function(data, cb)
    if EDITING then
        TRIGGERZONES[EDITING].altitude = data.value
        cb({type = "ok"})
        return
    end
    cb({type = "message", message="Unexpected altitude setting"})
end)

RegisterNUICallback('height', function(data, cb)
    if EDITING then
        if data.value >= (Config?.Editor?.MinHeight or 0.2)  then
            TRIGGERZONES[EDITING].height = data.value
            cb({type = "ok"})
        else
            cb({type="message", message="Minimum height is " .. Config.Editor.MinHeight })
        end
        return
    end
    cb({type = "message", message="Unexpected height setting"})
end)

RegisterNUICallback('draw', function(data, cb)
    if EDITING then
        TRIGGERZONES[EDITING].draw = (data.value or false)
        cb({type = "ok"})
        return
    end
    cb({type = "message", message="Unexpected draw setting"})
end)

RegisterNUICallback('event', function(data, cb)
    if EDITING then
        TRIGGERZONES[EDITING].events = (data.value or false)
        cb({type = "ok"})
        return
    end
    cb({type = "message", message="Unexpected event setting"})
end)

RegisterNUICallback('name', function(data, cb)
    if EDITING then
        TRIGGERZONES[EDITING].label = data.value
        cb({type = "ok"})
        return
    end
    cb({type = "message", message="Unexpected name setting"})
end)

RegisterNUICallback('save', function(data, cb)
    if EDITING then
        TriggerLatentServerEvent('triggerzone:save-zone', 2048, EDITING, TRIGGERZONES[EDITING])
        cb({type = "blocker", message="Saving to server!"})
        return
    end
    cb({type = "message", message="Unexpected save request"})
end)

RegisterNUICallback('cancel', function(data, cb)
    if EDITING then
        TRIGGERZONES[EDITING] = nil
        TriggerServerEvent('triggerzone:resend', EDITING)
        cb({type = "ok"})
        EditorShutdown()
        return
    end
    cb({type = "message", message="Unexpected cancel request"})
end)

RegisterNUICallback('view', function(data, cb)
    if EDITING then
        EditorViewVertex(data.vertex)
        cb({type = "ok"})
        return
    end
    cb({type = "message", message="Unexpected view request"})
end)

RegisterNUICallback('delete', function(data, cb)
    if EDITING then
        local vertex = data.vertex
        if #TRIGGERZONES[EDITING].points >= vertex then
            local zone = TRIGGERZONES[EDITING]
            table.remove(zone.points, vertex)
            
            Citizen.Wait(0) -- Yield the thread for a tick, to let the removal settle, because Lua things.

            zone.points, zone.triangles = Triangulate(zone.points)
            zone.centroid = Centroid(zone.points)
            if zone.centroid then
                zone.labelPoint = vec3(zone.centroid.x, zone.centroid.y, zone.altitude + (zone.height/2))
            end
            cb({type="populateTable", points=MakeUiPoints(zone.points)})
        else
            cb({type = "message", message="Delete failed: No such vertex?!"})
        end
        return
    end
    cb({type = "message", message="Unexpected delete request"})
end)

RegisterNUICallback('activeColor', function(data, cb)
    if EDITING then
        TRIGGERZONES[EDITING].color.inside = {
            math.floor(data.value.color[1] or 255),
            math.floor(data.value.color[2] or 0),
            math.floor(data.value.color[3] or 0),
            math.floor(data.value.lines or 255),
            math.floor(data.value.walls or 128),
        }
        cb({type = "ok"})
        return
    end
    cb({type = "message", message="Unexpected activeColor request"})
end)

RegisterNUICallback('inactiveColor', function(data, cb)
    if EDITING then
        TRIGGERZONES[EDITING].color.outside = {
            math.floor(data.value.color[1] or 255),
            math.floor(data.value.color[2] or 0),
            math.floor(data.value.color[3] or 0),
            math.floor(data.value.lines or 255),
            math.floor(data.value.walls or 128),
        }
        cb({type = "ok"})
        return
    end
    cb({type = "message", message="Unexpected activeColor request"})
end)

RegisterNUICallback('unfocus', function(data, cb)
    SetNuiFocus(false, false)
    cb({type = "ok"})
end)
