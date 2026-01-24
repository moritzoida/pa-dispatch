------------>SRAG<--------------
----->https://discord.gg/EKyPk4QbgD<-----

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

local GLOBAL_COOLDOWN = 6000       -- 6 Sekunden
local PLAYER_COOLDOWN = 30000     -- 30 Sekunden

local lastGlobalDispatch = 0
local lastPlayerDispatch = {}     -- source => time

RegisterNetEvent('police_dispatch:gunshot')
AddEventHandler('police_dispatch:gunshot', function(coords, weaponCategory, hasSuppressor)
    local src = source
    local now = GetGameTimer()
    local xShooter = ESX.GetPlayerFromId(src)

    -- ?? Police schie�t ? KEIN Dispatch
    if xShooter and xShooter.job and xShooter.job.name == 'police' then
        return
    end

    if now - lastGlobalDispatch < GLOBAL_COOLDOWN then return end
    if lastPlayerDispatch[src] and now - lastPlayerDispatch[src] < PLAYER_COOLDOWN then return end

    if hasSuppressor then
        local chance = math.random(1, 100)
        if chance > 50 then
            return
        end
    end

    lastGlobalDispatch = now
    lastPlayerDispatch[src] = now

    local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer and xPlayer.job and xPlayer.job.name == 'police' then
            TriggerClientEvent(
                'police_dispatch:alert',
                xPlayers[i],
                coords,
                weaponCategory
            )
        end
    end
end)
