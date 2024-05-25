TRIGGERZONES = {}

Citizen.CreateThread(function()

    TriggerServerEvent('triggerzone:ready')

    while true do
        Citizen.Wait(0)

        local pedLoc = GetEntityCoords(PlayerPedId())

        if EDITING then
            EditorFrame()
        end

        for name, zone in pairs(TRIGGERZONES) do
            if zone.draw or zone.events or EDITING == name then
                if IsInside(pedLoc, zone) then
                    if not zone.triggered then
                        zone.triggered = true
                        if zone.events then
                            TriggerEvent('triggerzone:enter', name)
                            TriggerServerEvent('triggerzone:enter', name)
                        end
                    end
                    if zone.draw or EDITING == name then
                        DrawZone(name, zone, zone.color.inside, EDITING == name)
                    end
                else
                    if zone.triggered then
                        zone.triggered = false
                        if zone.events then
                            TriggerEvent('triggerzone:exit', name)
                            TriggerServerEvent('triggerzone:exit', name)
                        end
                    end
                    if zone.draw or EDITING == name then
                        DrawZone(name, zone, zone.color.outside, EDITING == name)
                    end
                end
            end
        end
    end
end)
