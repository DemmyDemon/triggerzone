function GetZonesAtPoint(point)
    local zones = {}
    for name, zone in ipairs(TRIGGERZONES) do
        if IsInside(point, zone) then
            zones[name] = zone.label or name
        end
    end
    return zones
end
exports("GetZonesAtPoint", GetZonesAtPoint)

function IsPointInsideZone(point, zoneName)
    if not TRIGGERZONES[zoneName] then return false end
    return IsInside(point, TRIGGERZONES[zoneName])
end
exports("IsPointInsideZone", IsPointInsideZone)

function GetZoneLabel(zoneName)
    if not TRIGGERZONES[zoneName] then return "" end
    return TRIGGERZONES[zoneName].label or zoneName
end
exports("GetZoneLabel", GetZoneLabel)
