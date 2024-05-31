AddTextEntry('TZVERTEXLABEL', "~1~")
AddTextEntry('TZZONELABEL', '~a~')

function VertexLabel(point, idx, distance, r,g,b,a)
    local visible, screenX, screenY = GetScreenCoordFromWorldCoord(point.x, point.y, point.z)
    if not visible then return end
    BeginTextCommandDisplayText('TZVERTEXLABEL')
    AddTextComponentInteger(idx)
    SetTextColour(r,g,b,a)
    SetTextScale(0.0, math.max(0.15, (1/(distance or 1)) * 4))
    SetTextOutline()
    EndTextCommandDisplayText(screenX, screenY)
end

function ZoneLabel(point, label, distance, r,g,b,a)
    local visible, screenX, screenY = GetScreenCoordFromWorldCoord(point.x, point.y, point.z)
    if not visible then return end

    BeginTextCommandDisplayText('TZZONELABEL')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(label)
    SetTextColour(r,g,b,a)
    SetTextScale(0.0, math.max(0.15, (1/(distance or 1)) * 4))
    SetTextOutline()
    EndTextCommandDisplayText(screenX, screenY)
end

function DrawZone(name, zone, color, edit)

    if #zone.points == 0 then
        return
    end

    if zone.radius and zone.labelPoint and not IsSphereVisible(zone.labelPoint.x, zone.labelPoint.y, zone.labelPoint.z, zone.radius) then
        return
    end

    local r = color[1] or 255
    local g = color[2] or 0
    local b = color[3] or 0
    local a = color[4] or 200
    local wa = color[5] or math.floor(a/2)
    
    local camCoord = GetFinalRenderedCamCoord()

    local drawDistance = zone.drawDistance or 50.0

    if #(zone.centroid - camCoord.xy) > drawDistance * 2 and not edit then return end

    local distance, closestPoint, closestSegment = Closest(zone.points, camCoord.xy)

    if distance and distance > drawDistance and not edit then
        return
    elseif distance then
        local fadeRange = math.max(1.0, drawDistance - 5)
        local lerpFactor = LerpFactor(fadeRange, distance, drawDistance)
        a = math.ceil(a * lerpFactor)
        wa = math.ceil(wa * lerpFactor)
    end

    if edit then
        -- a = 255
        DrawLine( -- Centroid indicator line
            zone.centroid.x, zone.centroid.y, zone.altitude,
            zone.centroid.x, zone.centroid.y, zone.altitude + zone.height,
            r, g, b, 255
        )
        if not zone.labelPoint and zone.centroid then
            zone.labelPoint = vec3(zone.centroid.x, zone.centroid.y, zone.altitude + (zone.height/2))
        end
        ZoneLabel(zone.labelPoint, zone.label or name, #(zone.labelPoint - camCoord), r, g, b, 255)
    end

    for i, point in ipairs(zone.points) do
        local bottom = vec3(point.x, point.y, zone.altitude)
        local top =  vec3(point.x, point.y, zone.altitude + zone.height)
        DrawLine(bottom.x, bottom.y, bottom.z, top.x, top.y, top.z, r, g, b, a)

        if edit then
            VertexLabel(top, i, #(camCoord - top), r,g,b,a)
        end

        if #zone.points == 1 then
            return
        end

        local nextPoint = zone.points[(i % #zone.points) + 1]
        local nextBottom = vec3(nextPoint.x, nextPoint.y, zone.altitude)
        local nextTop = vec3(nextPoint.x, nextPoint.y, zone.altitude + zone.height)
        DrawLine(top.x, top.y, top.z, nextTop.x, nextTop.y, nextTop.z, r, g, b, a)
        DrawLine(bottom.x, bottom.y, bottom.z, nextBottom.x, nextBottom.y, nextBottom.z, r, g, b, a)

        if wa > 0 then
            ---@diagnostic disable: missing-parameter,param-type-mismatch vector3 expands to three numbers.
            if PlaneSide(nextBottom, bottom, top, camCoord) > 0 then
                DrawPoly(nextBottom, bottom, top, r, g, b, wa)
                DrawPoly(top, nextTop, nextBottom, r, g, b, wa)
            else
                DrawPoly(top, bottom, nextBottom, r, g, b, wa)
                DrawPoly(nextBottom, nextTop, top, r, g, b, wa)
            end
            ---@diagnostic enable: missing-parameter,param-type-mismatch
        end
    end

    if wa <= 0 then return end

    if not zone.triangles then
        local points, triangles = Triangulate(zone.points)
        zone.triangles = triangles
        zone.points = points
    end

    DrawPlane(zone.triangles, zone.altitude + zone.height, camCoord.z > zone.altitude + zone.height, r,g,b,wa)
    DrawPlane(zone.triangles, zone.altitude, camCoord.z > zone.altitude, r,g,b,wa)

end

function DrawPlane(triangles, altitude, abovePlane, r, g, b, a)
    for i, triangle in ipairs(triangles) do
        -- print("Triangle:", json.encode(triangle))
        if abovePlane then
            DrawPoly(
                triangle[1].x, triangle[1].y, altitude,
                triangle[2].x, triangle[2].y, altitude,
                triangle[3].x, triangle[3].y, altitude,
                r,g,b,a
            )
        else
            DrawPoly(
                triangle[3][1], triangle[3][2], altitude,
                triangle[2][1], triangle[2][2], altitude,
                triangle[1][1], triangle[1][2], altitude,
                r,g,b,a
            )
        end
    end
end