local ox_inventory = exports.ox_inventory

function getNearbyPlayers()
    local players = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(playerCoords - targetCoords)

        if distance < 5.0 and playerId ~= PlayerId() then
            local playerName = GetPlayerName(playerId)
            table.insert(players, {
                label = string.format("%s (ID: %d)", playerName, GetPlayerServerId(playerId)),
                value = GetPlayerServerId(playerId)
            })
        end
    end

    return players
end

CreateThread(function()
    local blip = AddBlipForCoord(Config.Blip.coords)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.label)
    EndTextCommandSetBlipName(blip)

    for category, locations in pairs(Config.Locations) do
        for _, location in ipairs(locations) do
            if category == 'Handwash' then
                exports.ox_target:addBoxZone({
                    coords = location.coords,
                    size = vec3(1, 1, 2),
                    rotation = 45,
                    debug = false,
                    options = {
                        {
                            name = 'up_n_atom_handwash',
                            label = 'Vask Hender',
                            icon = 'fa-solid fa-hand-soap',
                            onSelect = function()
                                lib.progressBar({
                                    duration = 3000,
                                    label = 'Vasker hender...',
                                    useWhileDead = false,
                                    canCancel = true,
                                    disable = {
                                        car = true,
                                        move = true,
                                    },
                                    anim = {
                                        dict = 'mp_arresting',
                                        clip = 'a_uncuff'
                                    }
                                })
                            end
                        }
                    }
                })
            else
                exports.ox_target:addBoxZone({
                    coords = location.coords,
                    size = vec3(1, 1, 2),
                    rotation = 45,
                    debug = false,
                    options = {
                        {
                            name = 'up_n_atom_' .. string.lower(category),
                            event = 'upnatom:openMenu',
                            icon = 'fa-solid fa-' .. (category == 'Burgers' and 'burger' or category == 'Drinks' and 'glass-water' or 'fries'),
                            label = 'Åpne ' .. category .. ' Meny',
                            category = category,
                            canInteract = function()
                                return exports.qbx_core:HasGroup(Config.Job)
                            end
                        }
                    }
                })
            end
        end
    end
end)

RegisterNetEvent('upnatom:openMenu')
AddEventHandler('upnatom:openMenu', function(data)
    local category = data.category
    
    local menuOptions = {}
    for _, item in ipairs(Config.Menu[category]) do
        table.insert(menuOptions, {label = item.label, value = item.name})
    end

    local mainMenu = lib.inputDialog('Up-n-Atom ' .. category .. ' Meny', {
        {type = 'select', label = 'Velg ' .. category, options = menuOptions},
        {type = 'number', label = 'Antall', default = 1, min = 1, max = 10}
    })

    if not mainMenu then return end

    local selectedItem = mainMenu[1]
    local quantity = mainMenu[2]

    TriggerServerEvent('upnatom:craftItem', category, selectedItem, quantity)
end)

RegisterNetEvent('upnatom:startCrafting')
AddEventHandler('upnatom:startCrafting', function(category, itemName, quantity)
    local craftConfig = Config.CraftEmotes[category]
    
    RequestAnimDict(craftConfig.animDict)
    while not HasAnimDictLoaded(craftConfig.animDict) do
        Wait(10)
    end

    local animationStarted = false

    if lib.progressBar({
        duration = Config.CraftTime,
        label = craftConfig.progressText,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
        },
        anim = {
            dict = craftConfig.animDict,
            clip = craftConfig.animName
        },
        onStart = function()
            TaskPlayAnim(cache.ped, craftConfig.animDict, craftConfig.animName, 8.0, -8.0, -1, 1, 0, false, false, false)
            animationStarted = true
        end,
        onStop = function()
            if animationStarted then
                StopAnimTask(cache.ped, craftConfig.animDict, craftConfig.animName, 1)
            end
        end
    }) then
        TriggerServerEvent('upnatom:finishCrafting', category, itemName, quantity)
    else
        TriggerServerEvent('upnatom:cancelCrafting')
    end
end)

RegisterNetEvent('upnatom:craftNotification')
AddEventHandler('upnatom:craftNotification', function(success, message)
    if success then
        lib.notify({
            title = 'Up-n-Atom',
            description = message,
            type = 'success'
        })
    else
        lib.notify({
            title = 'Up-n-Atom',
            description = message,
            type = 'error'
        })
    end
end)