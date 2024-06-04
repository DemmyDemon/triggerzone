RegisterNetEvent('triggerzone:enter', function(name)
    local source = source
    if not TRIGGERZONES[name] then
        print(GetPlayerName(source) .. " claims to have entered triggerzone " .. name ..", but this triggerzone does not exist.")
        return
    end
    local pedLoc = GetEntityCoords(GetPlayerPed(source))
    if not IsInside(pedLoc, TRIGGERZONES[name]) then
        Citizen.Wait(100)
        pedLoc = GetEntityCoords(GetPlayerPed(source))
        if not IsInside(pedLoc, TRIGGERZONES[name]) then
            print(GetPlayerName(source) .. " claims to have entered triggerzone " .. name ..", but this could not be confirmed.")
        end
    end
end)

RegisterNetEvent('triggerzone:exit', function(name)
    local source = source
    if not TRIGGERZONES[name] then
        print(GetPlayerName(source) .. " claims to have left triggerzone " .. name ..", but this triggerzone does not exist.")
        return
    end
    local pedLoc = GetEntityCoords(GetPlayerPed(source))
    if IsInside(pedLoc, TRIGGERZONES[name]) then
        Citizen.Wait(100)
        pedLoc = GetEntityCoords(GetPlayerPed(source))
        if IsInside(pedLoc, TRIGGERZONES[name]) then
            print(GetPlayerName(source) .. " claims to have left triggerzone " .. name ..", but this could not be confirmed.")
        end
    end
end)

RegisterNetEvent('triggerzone:ready', function()
    local source = source
    TriggerClientEvent('triggerzone:commandUsage', source, GetCommandVerbs())
    TriggerLatentClientEvent('triggerzone:addBulk', source, Config?.SendRate or 5120, TRIGGERZONES)
end)

RegisterNetEvent('triggerzone:resend', function(name)
    local source = source
    if TRIGGERZONES[name] then
        TriggerLatentClientEvent('triggerzone:add', source, Config?.SendRate or 5120, name, TRIGGERZONES[name])
        return
    end
    CloseBlocker(source)
end)

RegisterNetEvent('triggerzone:save-zone', function(name, data)
    local source = source
    if not IsPlayerAceAllowed(source, "command.triggerzone") then
        SendMessage(source, 'Could not save:  Permission denied.')
        return
    end
    Set(name, data)
    Store(name, data)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        return -- No need to do any extra work, as they'll all get forgotten really soon ;)
    end
    for name, zone in pairs(TRIGGERZONES) do
        if zone.origin == resourceName then
            TRIGGERZONES[name] = nil
        end
    end
end)
