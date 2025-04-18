local ox_inventory = exports.ox_inventory

local employeeStats = {}
local clockedInEmployees = {}
local dutyPlayers = {}

RegisterNetEvent('upnatom:craftItem')
AddEventHandler('upnatom:craftItem', function(category, itemName, quantity)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    local itemConfig = Config.Menu[category]
    
    local selectedItem = nil
    for _, item in ipairs(itemConfig) do
        if item.name == itemName then
            selectedItem = item
            break
        end
    end

    if not selectedItem then
        TriggerClientEvent('upnatom:craftNotification', src, false, 'Ugyldig item')
        return
    end

    local isEmployed = player.PlayerData.job.name == Config.Job

    TriggerClientEvent('upnatom:startCrafting', src, category, itemName, quantity)
end)

RegisterNetEvent('upnatom:finishCrafting')
AddEventHandler('upnatom:finishCrafting', function(category, itemName, quantity)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    local itemConfig = Config.Menu[category]
    
    local selectedItem = nil
    for _, item in ipairs(itemConfig) do
        if item.name == itemName then
            selectedItem = item
            break
        end
    end

    local isEmployed = player.PlayerData.job.name == Config.Job

    if isEmployed then
        exports.ox_inventory:AddItem(src, itemName, quantity)
        TriggerClientEvent('upnatom:craftNotification', src, true, string.format('Du har laget %dx %s', quantity, selectedItem.label))

        if employeeStats[src] then
            employeeStats[src].itemsCrafted = (employeeStats[src].itemsCrafted or 0) + quantity
        end
    else
        TriggerClientEvent('upnatom:craftNotification', src, false, 'Kun ansatte kan lage mat')
    end
end)

RegisterNetEvent('upnatom:cancelCrafting')
AddEventHandler('upnatom:cancelCrafting', function()
    local src = source
    TriggerClientEvent('upnatom:craftNotification', src, false, 'Crafting avbrutt')
end)

RegisterNetEvent('upnatom:clockIn')
AddEventHandler('upnatom:clockIn', function()
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    
    if not Player then return end

    if Player.PlayerData.job.name ~= Config.Job then
        exports.qbx_core:SetJob(src, Config.Job, 0)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Up-n-Atom',
            description = 'Du har gått på vakt',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Up-n-Atom',
            description = 'Du er allerede på vakt',
            type = 'error'
        })
    end
end)

RegisterNetEvent('upnatom:clockOut')
AddEventHandler('upnatom:clockOut', function()
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    
    if not Player then return end

    if Player.PlayerData.job.name == Config.Job then
        exports.qbx_core:SetJob(src, 'unemployed', 0)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Up-n-Atom',
            description = 'Du har gått av vakt',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Up-n-Atom',
            description = 'Du er ikke på vakt',
            type = 'error'
        })
    end
end)

RegisterNetEvent('upnatom:getEmployeeStats')
AddEventHandler('upnatom:getEmployeeStats', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    
    if player.PlayerData.job.name == Config.Job and player.PlayerData.job.grade.level >= 4 then  -- Kun ledere
        local statsMenu = {}
        
        for _, stat in pairs(employeeStats) do
            table.insert(statsMenu, {
                title = stat.name,
                description = string.format('Items laget: %d | Timer jobbet: %d', 
                    stat.itemsCrafted or 0, 
                    stat.endTime and math.floor((stat.endTime - stat.startTime) / 3600) or 0),
                icon = 'user',
                onSelect = function()
                    lib.callback.await('upnatom:showDetailedEmployeeStats', src, stat)
                end
            })
        end
        
        TriggerClientEvent('ox_lib:contextMenu', src, statsMenu)
    end
end)

lib.callback.register('upnatom:showDetailedEmployeeStats', function(source, employeeStat)
    local detailedStats = {
        {
            title = 'Detaljert Statistikk',
            description = string.format('Navn: %s\nItems laget: %d\nTimer jobbet: %d\nStartet vakt: %s', 
                employeeStat.name, 
                employeeStat.itemsCrafted or 0, 
                employeeStat.endTime and math.floor((employeeStat.endTime - employeeStat.startTime) / 3600) or 0,
                os.date('%Y-%m-%d %H:%M', employeeStat.startTime)
            )
        }
    }
    
    return detailedStats
end)

RegisterNetEvent('upnatom:toggleDuty')
AddEventHandler('upnatom:toggleDuty', function()
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    
    if not Player then return end

    local currentJob = Player.PlayerData.job.name
    local isOnDuty = dutyPlayers[src] or false

    if currentJob == Config.Job then
        if not isOnDuty then
            dutyPlayers[src] = true
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Up-n-Atom',
                description = 'Du er nå på vakt',
                type = 'success'
            })
        else
            dutyPlayers[src] = false
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Up-n-Atom',
                description = 'Du er nå av vakt',
                type = 'error'
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Up-n-Atom',
            description = 'Du er ikke ansatt her',
            type = 'error'
        })
    end
end)
