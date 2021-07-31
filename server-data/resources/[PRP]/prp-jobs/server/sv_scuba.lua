RegisterServerEvent('prp-scuba:checkAndTakeDepo')
AddEventHandler('prp-scuba:checkAndTakeDepo', function()
local src = source
local user = exports["prp-core"]:getModule("Player"):GetUser(src)
    user:removeMoney(400)
end)

RegisterServerEvent('prp-scuba:returnDepo')
AddEventHandler('prp-scuba:returnDepo', function()
local src = source
local user = exports["prp-core"]:getModule("Player"):GetUser(src)
    user:addMoney(200)
end)

RegisterServerEvent('prp-scuba:findTreasure')
AddEventHandler('prp-scuba:findTreasure', function()
local source = source
    local roll = math.random(1,8)
    if roll == 1 then
        TriggerClientEvent('player:receiveItem', source, "ironbar", math.random(6,9))
    end
    if roll == 2 then
        TriggerClientEvent('player:receiveItem', source, 'ironbar', math.random(6,11))
    end
    if roll == 3 then
        TriggerClientEvent('player:receiveItem', source, 'ironbar', math.random(6,9))
    end
    if roll == 5 then
        TriggerClientEvent('player:receiveItem', source, "ironbar", math.random(6,11))
    end
    if roll == 6 then
        TriggerClientEvent('player:receiveItem', source, "ironbar", math.random(5,7))
    end
    if roll == 7 then
        TriggerClientEvent('player:receiveItem', source, "umetal", math.random(2,3))
    end
    if roll == 8 then
        TriggerClientEvent('player:receiveItem', source, "umetal", math.random(2,3))
    end
end)

RegisterServerEvent('prp-scuba:paySalvage')
AddEventHandler('prp-scuba:paySalvage', function(money)
    local src = source
    local user = exports["prp-core"]:getModule("Player"):GetUser(src)
    if money ~= nil then
        user:addMoney(tonumber(money))
    end
end)

RegisterServerEvent('prp-scuba:makeGold')
AddEventHandler('prp-scuba:makeGold', function()
 local source = source
 TriggerClientEvent('inventory:removeItem', source, 'umetal', 10)
 TriggerClientEvent("player:receiveItem", source, "goldbar", 1)
end)