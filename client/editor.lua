EDITING = false
local EDITORCAM = 0
local TARGETBLIP = 0
local ZERO = vector3(0,0,0)
local SPEED = Config.Editor?.Speed?.Start or 10
local vertexFormat = "%0.2f"

local MOVING

AddTextEntry('TZEDITOR', 'Editing ~a~~n~~1~ Verices~n~Speed: ~1~%~n~~a~')

local function getCam()
    if not EDITORCAM or not DoesCamExist(EDITORCAM) then
        EDITORCAM = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end
    return EDITORCAM
end

function MakeUiPoints(vertices)
    local points = {}
    for i, vertex in ipairs(vertices) do
        table.insert(points, {i, string.format(vertexFormat, vertex.x), string.format(vertexFormat, vertex.y)})
    end
    return points
end

local function foramatRGBAA(color)
    color = color or {255, 0, 0, 0, 255, 255}
    return {
        color = {color[1] or 255, color[2] or 0, color[3] or 0},
        lines = color[4] or 255,
        walls = color[5] or 128,
    }
end

function EditorShutdown()
    if not EDITING then return end
    RenderScriptCams(false, false, 0, false, false)
    DestroyCam(EDITORCAM, false)
    ClearFocus()
    NetworkClearVoiceProximityOverride()
    RemoveBlip(TARGETBLIP)
    UnlockMinimapAngle()
    UnlockMinimapPosition()
    SendNUIMessage({type = "abort"})
    SetNuiFocus(false, false)
    EDITORCAM = 0
    EDITING = false
end

function EditorStart(zoneName)
    if EDITING then return end

    local coords = GetGameplayCamCoord()
    local rot = GetGameplayCamRot(2)
    local fov = GetGameplayCamFov()
    local cam = getCam()
    RenderScriptCams(true, true, 500, true, false)
    SetCamCoord(cam, coords.x, coords.y, coords.z)
    SetCamRot(cam, rot.x, rot.y, rot.z, 2)
    SetCamFov(cam, fov)
    EDITING = zoneName

    local zone = TRIGGERZONES[zoneName]
    SendNUIMessage({
        type = 'loaded',
        name = zone.label or zoneName,
        altitude = zone.altitude or 0.0,
        height = zone.height or 2.0,
        events = zone.events or false,
        draw = zone.draw or false,
        activeRGBAA = foramatRGBAA(zone.color?.inside),
        inactiveRGBAA = foramatRGBAA(zone.color?.outside),
        points = MakeUiPoints(zone.points)
    })

end

local function fiddleWithMinimap(location, rotation, ray)
    if not IsMinimapRendering() then
        return
    end

    DontTiltMinimapThisFrame()

    if ray.hit then
        local distance = #(location.xy - ray.coords.xy)
        if distance < 15 then
            distance = 15.0
        end
        SetRadarZoomToDistance(distance)
    else
        SetRadarZoomToDistance(location.z)
    end


    if not DoesBlipExist(TARGETBLIP) then
        TARGETBLIP = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(TARGETBLIP, 270)
        SetBlipHiddenOnLegend(TARGETBLIP, true)
        SetBlipScale(TARGETBLIP, 0.7)
    end
    LockMinimapAngle(math.floor(rotation.z + 360) % 360)
    if ray.hit then
        LockMinimapPosition(ray.coords.x, ray.coords.y)
        SetBlipCoords(TARGETBLIP, ray.coords.x, ray.coords.y, ray.coords.z)
    else
        LockMinimapPosition(location.x, location.y)
        SetBlipCoords(TARGETBLIP, location.x, location.y, location.z)
    end
end

local function disableConflictingControls()
    for i=0, 31 do
        DisableAllControlActions(i)
    end
    for _, control in ipairs(Config?.Editor?.EnableControls or {245, 249}) do
        EnableControlAction(0, control, true)
    end
end

local function getRelativeLocation(location, rotation, distance)
    location = location or vector3(0,0,0)
    rotation = rotation or vector3(0,0,0)
    distance = distance or 10.0

    local tZ = math.rad(rotation.z)
    local tX = math.rad(rotation.x)

    local absX = math.abs(math.cos(tX))

    local rx = location.x + (-math.sin(tZ) * absX) * distance
    local ry = location.y + (math.cos(tZ) * absX) * distance
    local rz = location.z + (math.sin(tX)) * distance

    return vector3(rx,ry,rz)
end

local function getMovementInput(location, rotation, frameTime)
    local multiplier = 1.0
    if IsDisabledControlPressed(0, Config?.Editor?.Keys?.Boost or 21) then
        multiplier = Config?.Editor?.BoostFactor or 10.0
    end

    if IsDisabledControlPressed(0, Config?.Editor?.Keys?.Right or 35) then
        local camRot = vector3(0,0,rotation.z)
        location = getRelativeLocation(location, camRot + vector3(0,0,-90), SPEED * frameTime * multiplier)
    elseif IsDisabledControlPressed(0, Config?.Editor?.Keys?.Left or 34) then
        local camRot = vector3(0,0,rotation.z)
        location = getRelativeLocation(location, camRot + vector3(0,0,90), SPEED * frameTime * multiplier)
    end

    if IsDisabledControlPressed(0, Config?.Editor?.Keys?.Forward or 32) then
        location = getRelativeLocation(location, rotation, SPEED * frameTime * multiplier)
    elseif IsDisabledControlPressed(0, Config?.Editor?.Keys?.Back or 33) then
        location = getRelativeLocation(location, rotation, -SPEED * frameTime * multiplier)
    end

    return location
end

local function adjustHeight(zone)
    if IsDisabledControlJustPressed(0, Config?.Editor?.Keys?.Increase or 17) then
        if IsDisabledControlPressed(0, Config?.Editor?.Keys?.Modifier or 36) then
            zone.altitude = zone.altitude + (Config?.Editor?.HeightAdjustInterval or 0.1)
        else
            zone.height = math.max(zone.height + (Config?.Editor?.HeightAdjustInterval or 0.1), (Config?.Editor?.MinHeight or 0.2))
        end
        if zone.centroid then
            zone.labelPoint = vec3(zone.centroid.x, zone.centroid.y, zone.altitude + (zone.height/2))
        end
    end
    if IsDisabledControlJustPressed(0, Config?.Editor?.Keys?.Decrease or 16) then
        if IsDisabledControlPressed(0, Config?.Editor?.Keys?.Modifier or 36) then
            zone.altitude = zone.altitude - (Config?.Editor?.HeightAdjustInterval or 0.2)
        else
            zone.height = zone.height - (Config?.Editor?.HeightAdjustInterval or 0.2)
        end
        if zone.centroid then
            zone.labelPoint = vec3(zone.centroid.x, zone.centroid.y, zone.altitude + (zone.height/2))
        end
    end
end

local function getMouseMovement()
    local x = GetDisabledControlNormal(0, 2)
    local y = 0
    local z = GetDisabledControlNormal(0, 1)
    return vector3(-x, y, -z) * (Config?.Editor?.Sensitivity or 5.0)
end

local function moveCamera()
    local frameTime = GetFrameTime()
    local cam = getCam()

    local rotation = GetCamRot(cam,2)
    rotation = rotation + getMouseMovement()
    if rotation.x > 85 then
        rotation = vector3(85, rotation.y, rotation.z)
    elseif rotation.x < -85 then
        rotation = vector3(-85, rotation.y, rotation.z)
    end
    ---@diagnostic disable-next-line: missing-parameter,param-type-mismatch vector3 expands to three numbers.
    SetCamRot(cam, rotation, 2)

    local location = GetCamCoord(cam)
    local newLocation = getMovementInput(location, rotation, frameTime)
    ---@diagnostic disable-next-line: missing-parameter,param-type-mismatch vector3 expands to three numbers.
    SetCamCoord(cam, newLocation)

    return newLocation, rotation
end

local function changeSpeed()
    if IsDisabledControlJustPressed(0, Config?.Editor?.Keys?.SpeedUp or 38) then
        SPEED = SPEED + (Config?.Editor?.Speed?.Interval or 5)
        SPEED = math.min(SPEED, Config?.Editor?.Speed?.Max or 100)
    elseif IsDisabledControlJustPressed(0, Config?.Editor?.Keys?.SlowDown or 44) then
        SPEED = SPEED - (Config?.Editor?.Speed?.Interval or 5)
        SPEED = math.max(SPEED, Config?.Editor?.Speed?.Min or 5)
    end
end

local function rayCastResultFormat(state, hit, hitCoords, normal, targetCoords)
    if state == 0 then
        hit = false
    end

    if #(hitCoords - ZERO) < 1e-4 then
        hit = false
    end

    local result = {
        hit = hit,
        coords = hitCoords,
        normal = normal,
        target = targetCoords,
    }

    return result
end

local function rayCast(location, rotation)
    local targetLocation = getRelativeLocation(location, rotation, 100)
    ---@diagnostic disable-next-line: missing-parameter,param-type-mismatch vector3 expands to three numbers.
    local ray = StartExpensiveSynchronousShapeTestLosProbe(location, targetLocation, 1, 0)
    local state, hit, hitCoords, normal, _ = GetShapeTestResult(ray)
    
    if state == 0 then
        return rayCastResultFormat(0, false, nil, nil, targetLocation)
    end

    while state == 1 do
        Citizen.Wait(0)
        state, hit, hitCoords, normal, _ = GetShapeTestResult(ray)
    end
    return rayCastResultFormat(state, hit, hitCoords, normal, targetLocation)
end

local function drawMarker(ray, delete)
    if not ray.hit then
        return
    end

    local scale = Config?.Editor?.InteractProximity or 0.2
    local green = 255
    if delete then green = 0 end

    ---@diagnostic disable: missing-parameter,param-type-mismatch vector3 expands to three numbers.
    DrawMarker(
        28, -- Type
        ray.coords, -- Location
        0.0, 0.0, 0.0, -- Direction
        0.0, 0.0, 0.0, -- Rotation
        scale, scale, scale,
        255, green, 0, 128, -- Color
        false, -- bobs
        false, -- face camera
        1, -- Cargo Cult (Rotation order?)
        false, -- rotates
        0, 0, -- texture
        false -- projects on entities
    )
    ---@diagnostic enable

end
local function drawTriangle(r, g, b, altitude, height, p1, p2, p3)
    -- p1->p2
    DrawLine(
        p1.x, p1.y, altitude,
        p2.x, p2.y, altitude,
        r, g, b, 255
    )
    DrawLine(
        p1.x, p1.y, altitude + height,
        p2.x, p2.y, altitude + height,
        r, g, b, 255
    )
    -- p1->p3
    DrawLine(
        p1.x, p1.y, altitude,
        p3.x, p3.y, altitude,
        r, g, b, 255
    )
    DrawLine(
        p1.x, p1.y, altitude + height,
        p3.x, p3.y, altitude + height,
        r, g, b, 255
    )
end

local function drawBeam(ray, delete)
    if not ray.hit then return 1 end
    local zone = TRIGGERZONES[EDITING]
    local r,g,b = 255, 255, 0
    if delete then g = 0 end

    if not zone then return 1 end
    if #zone.points == 0 then
        DrawLine(
            ray.coords.x, ray.coords.y, ray.coords.z,
            ray.coords.x, ray.coords.y, ray.coords.z + zone.height,
            r, g, b, 255
        )
        return 1
    end

    DrawLine(
        ray.coords.x, ray.coords.y, zone.altitude,
        ray.coords.x, ray.coords.y, zone.altitude + zone.height,
        r, g, b, 255
    )

    -- if delete then return 1 end

    if #zone.points == 1 then
        DrawLine(
            ray.coords.x, ray.coords.y, zone.altitude,
            zone.points[1].x, zone.points[1].y, zone.altitude,
            r, g, b, 255
        )
        DrawLine(
            ray.coords.x, ray.coords.y, zone.altitude + zone.height,
            zone.points[1].x, zone.points[1].y, zone.altitude + zone.height,
            r, g, b, 255
        )
        return 2
    elseif #zone.points == 2 then
        drawTriangle(r, g, b, zone.altitude, zone.height, ray.coords.xy, zone.points[1], zone.points[2])
        return 3
    else
        local _, _, closestSegment, closestIndices = Closest(zone.points, ray.coords.xy)
        drawTriangle(r, g, b, zone.altitude, zone.height, ray.coords.xy, closestSegment[1], closestSegment[2])
        return closestIndices[2]
    end



end

local function drawEditorText(vertices, message)
    if not EDITING or EDITING == "" then return end
    BeginTextCommandDisplayText('TZEDITOR')
    SetTextScale(0.25,0.25)
    SetTextOutline()
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(EDITING)
    AddTextComponentInteger(vertices)
    AddTextComponentInteger(SPEED)
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayText(0.5, 0.1)
end

function EditorFrame()
    if not EDITING or EDITING == "" then return end

    local zone = TRIGGERZONES[EDITING]

    disableConflictingControls()
    local location, rotation = moveCamera()
    changeSpeed()

    local ray = rayCast(location, rotation)
    local dist, point, idx = math.huge, vec2(0,0), 0

    if ray.hit then
        dist, _ , idx = ClosestVertex(zone.points, ray.coords.xy)
    end
    local interact = (dist < (Config?.Editor?.InteractProximity or 0.1))
    drawMarker(ray, interact)
    local insertIdx = drawBeam(ray, interact)
    if interact then
        drawEditorText(#zone.points,("Vertex %d"):format(idx))
    else
        drawEditorText(#zone.points,("Add new vertex %d"):format(insertIdx))
    end

    local refresh = false

    if ray.hit and IsDisabledControlJustPressed(0, Config?.Editor?.Keys?.Interact or 24) then
        if interact then
            MOVING = idx
        else
            table.insert(zone.points, insertIdx, ray.coords.xy)
            refresh = true
            if #zone.points == 1 then
                zone.altitude = ray.coords.z - 0.05
                SendNUIMessage({type="setAltitude", altitude=zone.altitude})
            end
        end
    end

    if MOVING and ray.hit then
        zone.points[MOVING] = ray.coords.xy
        refresh = true
    end

    if IsDisabledControlJustReleased(0, Config?.Editor?.Keys?.Interact or 24) then
        if MOVING then
            MOVING = nil
            refresh = true
        end
    end

    if IsDisabledControlJustPressed(0, Config?.Editor?.Keys?.Delete or 25) then
        if interact then
            refresh = true
            table.remove(zone.points, idx)
        end
    end

    if IsDisabledControlJustPressed(0, Config?.Editor?.Keys?.Focus or 22) then
        SetNuiFocus(true, true)
    end

    if refresh and not MOVING then
        Citizen.Wait(0) -- Yield the thread for a moment, to let the table manipulation settle.
        zone.points, zone.triangles = Triangulate(zone.points)
        zone.centroid = Centroid(zone.points)
        if zone.centroid then
            zone.labelPoint = vec3(zone.centroid.x, zone.centroid.y, zone.altitude + (zone.height/2))
        end
        SendNUIMessage({type="populateTable", points=MakeUiPoints(zone.points)})
    end

    adjustHeight(zone)

    fiddleWithMinimap(location, rotation, ray)

    ---@diagnostic disable: missing-parameter,param-type-mismatch vector3 expands to three numbers.
    SetFocusPosAndVel(location, ZERO)
    NetworkApplyVoiceProximityOverride(location)
    ---@diagnostic enable
end