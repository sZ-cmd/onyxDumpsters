ESX = nil

local dumpsterItems = {
    [1] = {chance = 2, id = 'bottle', name = 'Glass Bottle', quantity = math.random(1,3), limit = 10},
    [2] = {chance = 2, id = 'wallet', name = 'Wallet', quantity = 1, limit = 4},
    [3] = {chance = 2, id = 'oldshoe', name = 'Old Shoe', quantity = 1, limit = 10},
    [4] = {chance = 2, id = 'mouldybread', name = 'Mouldy Bread', quantity = 1, limit = 10},
    [5] = {chance = 3, id = 'plastic', name = 'Plastic', quantity = math.random(1,8), limit = 0},
    [6] = {chance = 10, id = 'WEAPON_BAT', name = 'Baseball Bat', quantity = 1, limit = 2},
    [7] = {chance = 4, id = 'electronics', name = 'Electronics', quantity = math.random(1,2), limit = 0},
    [8] = {chance = 5, id = 'screen', name = 'screen', quantity = 1, limit = 0},
    [9] = {chance = 4, id = 'lowgrademaleseed', name = 'Male Seed', quantity = 1, limit = 0},
    [10] = {chance = 2, id = 'deadbatteries', name = 'Dead Batteries', quantity = 1, limit = 10},
    [11] = {chance = 4, id = 'phone', name = 'Phone', quantity = 1, limit = 0},
    [12] = {chance = 3, id = 'rubber', name = 'Rubber', quantity = math.random(1,3), limit = 0},
    [13] = {chance = 2, id = 'brokenfishingrod', name = 'Broken Fishing Rod', quantity = 1, limit = 10},
    [14] = {chance = 7, id = 'car_wheel', name = 'Car Wheel', quantity = 1, limit = 4},
    [15] = {chance = 1, id = 'ring', name = 'Old Ring', quantity = 1, limit = 10},
    [16] = {chance = 10, id = 'repUSB', name = 'Mysterious USB Stick', quantity = 1, limit = 15},
    [17] = {chance = 3, id = 'weed4g', name = 'Mouldy Bud', quantity = 1, limit = 10},			  
   }

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('wallet', function(source) --Hammer high time to unlock but 100% call cops
    local source = tonumber(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local cash = math.random(500, 2000)
    local chance = math.random(1,2)

    if chance == 2 then
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find $' .. cash .. ' inside the wallet'})
        xPlayer.addMoney(cash)
        local cardChance = math.random(1, 40)
        if cardChance == 20 then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You found a Green Keycard inside the wallet'})
            xPlayer.addInventoryItem('id_card_f', 1)
        end
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'The wallet was empty'})
    end

    xPlayer.removeInventoryItem('wallet', 1)
end)

RegisterServerEvent('onyx:startDumpsterTimer')
AddEventHandler('onyx:startDumpsterTimer', function(dumpster)
    startTimer(source, dumpster)
end)

RegisterServerEvent('onyx:giveDumpsterReward')
AddEventHandler('onyx:giveDumpsterReward', function()
    local source = tonumber(source)
    local item = {}
    local xPlayer = ESX.GetPlayerFromId(source)
    local gotID = {}
    local rolls = math.random(1, 2)
    local foundItem = false
    --print( ESX.DumpTable(xPlayer) )

    for i = 1, rolls do
        item = dumpsterItems[math.random(1, #dumpsterItems)]
        if math.random(1, 10) >= item.chance then
            if item.isWeapon and not gotID[item.id] then
                if item.limit > 0 then
                    local count = xPlayer.getInventoryItem(item.id).count
                    if count >= item.limit then
                        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find a ' .. item.name .. ' but cannot carry any more of this item'})
                    else
                        gotID[item.id] = true
                        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find a ' .. item.name})
                        foundItem = true
                        xPlayer.addWeapon(item.id, 50)
                    end
                else
                    gotID[item.id] = true
                    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find a ' .. item.name})
                    foundItem = true
                    xPlayer.addWeapon(item.id, 50)
                end
            elseif not gotID[item.id] then
                if item.limit > 0 then
                    local playerItem = xPlayer.getInventoryItem(item.id)
                    --print( ESX.DumpTable( playerItem ) )
                    if playerItem ~= nil then
                        local count = playerItem.count
                        if count >= item.limit then
                            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find ' .. item.quantity .. 'x ' .. item.name .. ' but cannot carry any more of this item'})
                        else
                            gotID[item.id] = true
                            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find ' .. item.quantity .. 'x ' .. item.name})
                            xPlayer.addInventoryItem(item.id, item.quantity)
                            foundItem = true
                        end
                    end

                else
                    gotID[item.id] = true
                    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find ' .. item.quantity .. 'x ' .. item.name})
                    xPlayer.addInventoryItem(item.id, item.quantity)
                    foundItem = true
                end
            end
        end
        if i == rolls and not gotID[item.id] and not foundItem then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find nothing'})
        end
    end
end)

function startTimer(id, object)
    local timer = 10 * 60000

    while timer > 0 do
        Wait(1000)
        timer = timer - 1000
        if timer == 0 then
            TriggerClientEvent('onyx:removeDumpster', id, object)
        end
    end
end
