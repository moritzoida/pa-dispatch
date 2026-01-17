------------>Project Alpha<--------------
----->https://discord.gg/EKyPk4QbgD<-----

ESX = nil

local SuppressorComponents = {
    `COMPONENT_AT_PI_SUPP`,
    `COMPONENT_AT_PI_SUPP_02`,
    `COMPONENT_AT_AR_SUPP`,
    `COMPONENT_AT_AR_SUPP_02`
}

local function HasSuppressor(ped)
    local weapon = GetSelectedPedWeapon(ped)

    for _, comp in pairs(SuppressorComponents) do
        if HasPedGotWeaponComponent(ped, weapon, comp) then
            return true
        end
    end

    return false
end

local WeaponCategories = {
    PISTOL = {
        `WEAPON_PISTOL`,
        `WEAPON_COMBATPISTOL`,
        `WEAPON_PISTOL_MK2`,
        `WEAPON_SNSPISTOL`,
        `WEAPON_HEAVYPISTOL`,
        `WEAPON_VINTAGEPISTOL`
    },

    AUTO_PISTOL = {
        `WEAPON_APPISTOL`,
        `WEAPON_MACHINEPISTOL`
    },

    SHOTGUN = {
        `WEAPON_PUMPSHOTGUN`,
        `WEAPON_PUMPSHOTGUN_MK2`,
        `WEAPON_SAWNOFFSHOTGUN`,
        `WEAPON_ASSAULTSHOTGUN`,
        `WEAPON_BULLPUPSHOTGUN`
    },

    RIFLE = {
        `WEAPON_ASSAULTRIFLE`,
        `WEAPON_ASSAULTRIFLE_MK2`,
        `WEAPON_CARBINERIFLE`,
        `WEAPON_CARBINERIFLE_MK2`,
        `WEAPON_SPECIALCARBINE`,
        `WEAPON_BULLPUPRIFLE`,
        `WEAPON_MUSKET`
    }
}

local function GetWeaponCategory(ped)
    local weapon = GetSelectedPedWeapon(ped)

    for _, hash in pairs(WeaponCategories.PISTOL) do
        if weapon == hash then return 'Pistole' end
    end

    for _, hash in pairs(WeaponCategories.AUTO_PISTOL) do
        if weapon == hash then return 'Automatische Pistole' end
    end

    for _, hash in pairs(WeaponCategories.SHOTGUN) do
        if weapon == hash then return 'Shotgun' end
    end

    for _, hash in pairs(WeaponCategories.RIFLE) do
        if weapon == hash then return 'Langwaffe' end
    end

    return 'Unbekannt'
end

-- ESX holen
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- ?? Shooter Detection (KEIN Cooldown hier!)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local ped = PlayerPedId()

if IsPedArmed(ped, 4) and IsPedShooting(ped) then
    local coords = GetEntityCoords(ped)
    local weaponCategory = GetWeaponCategory(ped)
    local hasSuppressor = HasSuppressor(ped)

    TriggerServerEvent(
        'police_dispatch:gunshot',
        coords,
        weaponCategory,
        hasSuppressor
    )

    Citizen.Wait(500)
end
    end
end)

-- ?? Police bekommt Dispatch
RegisterNetEvent('police_dispatch:alert')
AddEventHandler('police_dispatch:alert', function(coords, weaponCategory)

    SendNUIMessage({ play = true })

    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    local zoneName = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))

    local locationText = streetName
    if zoneName and zoneName ~= '' then
        locationText = locationText .. ' (' .. zoneName .. ')'
    end

    ESX.ShowAdvancedNotification(
        'Dispatch',
        '~r~Schüsse gemeldet',
        'Ort: ~r~' .. locationText ..
        '\n~s~Waffe: ~r~' .. weaponCategory,
        'CHAR_CALL911',
        1
    )
    -- ?? Blip
    local blip = AddBlipForRadius(coords.x, coords.y, coords.z, 120.0)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 160)

    local startTime = GetGameTimer()
    local blipActive = true

    Citizen.CreateThread(function()
        while GetGameTimer() - startTime < 10000 and blipActive do
            Citizen.Wait(0)

            -- ?? GTA Hint oben links
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName(
                'Drücke ~g~E~s~ um einen Wegpunkt zu setzen\noder ~r~Backspace~s~, um den Dispatch abzulehnen.'
            )
            EndTextCommandDisplayHelp(0, false, true, -1)

            if IsControlJustPressed(0, 38) then -- E
                SetNewWaypoint(coords.x, coords.y)
                break
            end

            if IsControlJustPressed(0, 177) then -- Backspace
                if DoesBlipExist(blip) then
                    RemoveBlip(blip)
                end
                blipActive = false
                break
            end
        end

        -- Auto Cleanup
        Citizen.Wait(15000)
        if blipActive and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)
end)

print("A FiveM Dispatch Script")
print("Version: 1.0.0")
print("Autor: Project Alpha - moritzoida")