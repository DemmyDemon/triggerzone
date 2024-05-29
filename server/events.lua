RegisterNetEvent('triggerzone:enter', function(name)
    local source = source
    if not TRIGGERZONES[name] then
        print(GetPlayerName(source) .. " claims to have entered triggerzone " .. name ..", but this triggerzone does not exist.")
        return
    end
    local pedLoc = GetEntityCoords(GetPlayerPed(source))
    if not IsInside(pedLoc, TRIGGERZONES[name]) then
        print(GetPlayerName(source) .. " claims to have entered triggerzone " .. name ..", but this could not be confirmed.")
        return
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
        print(GetPlayerName(source) .. " claims to have left triggerzone " .. name ..", but this could not be confirmed.")
        return
    end
end)

RegisterNetEvent('triggerzone:ready', function()
    local source = source
    TriggerClientEvent('triggerzone:commandUsage', source, GetCommandVerbs())
    TriggerLatentClientEvent('triggerzone:addBulk', source, 1024, TRIGGERZONES)
end)

RegisterNetEvent('triggerzone:resend', function(name)
    local source = source
    if TRIGGERZONES[name] then
        TriggerLatentClientEvent('triggerzone:add', source, 1024, name, TRIGGERZONES[name])
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
