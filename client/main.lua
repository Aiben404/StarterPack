local ESX = exports["es_extended"]:getSharedObject()
local pedSpawned = false
local npcPed = nil

-- Create map blip
CreateThread(function()
    if Config.Blip.Enabled then
        local blip = AddBlipForCoord(Config.NPC.Coords.x, Config.NPC.Coords.y, Config.NPC.Coords.z)
        SetBlipSprite(blip, Config.Blip.Sprite)
        SetBlipColour(blip, Config.Blip.Color)
        SetBlipScale(blip, Config.Blip.Scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.Name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Main logic for NPC spawning and interactions
CreateThread(function()
    while true do
        local sleep = 1500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local npcLoc = vector3(Config.NPC.Coords.x, Config.NPC.Coords.y, Config.NPC.Coords.z)
        local distance = #(playerCoords - npcLoc)

        -- Spawn NPC when nearby
        if distance < 50.0 then
            sleep = 500
            if not pedSpawned then
                lib.requestModel(Config.NPC.Model)
                npcPed = CreatePed(4, GetHashKey(Config.NPC.Model), Config.NPC.Coords.x, Config.NPC.Coords.y, Config.NPC.Coords.z - 1.0, Config.NPC.Coords.w, false, true)
                SetEntityHeading(npcPed, Config.NPC.Coords.w)
                FreezeEntityPosition(npcPed, true)
                SetEntityInvincible(npcPed, true)
                SetBlockingOfNonTemporaryEvents(npcPed, true)
                
                if Config.UseTarget then
                    exports.ox_target:addLocalEntity(npcPed, {
                        {
                            name = 'starter_pack_npc',
                            icon = 'fas fa-gift',
                            label = 'Claim Starter Pack',
                            onSelect = function()
                                OpenStarterPackMenu()
                            end
                        }
                    })
                end
                pedSpawned = true
                SetModelAsNoLongerNeeded(Config.NPC.Model)
            end
        elseif distance >= 50.0 and pedSpawned then
            -- Cleanup NPC when far
            if Config.UseTarget then
                exports.ox_target:removeLocalEntity(npcPed, 'starter_pack_npc')
            end
            DeletePed(npcPed)
            pedSpawned = false
        end

        -- Interaction logic if NOT using ox_target
        if not Config.UseTarget and pedSpawned and distance < 2.0 then
            sleep = 0
            lib.showTextUI('[E] - Claim Starter Pack', {
                position = "right-center",
                icon = 'gift'
            })
            if IsControlJustReleased(0, 38) then -- E key
                OpenStarterPackMenu()
            end
        elseif not Config.UseTarget and distance >= 2.0 then
            lib.hideTextUI()
        end

        Wait(sleep)
    end
end)

-- UI Menu handling
function OpenStarterPackMenu()
    -- Hide DrawText if visible
    lib.hideTextUI()

    -- Check if already claimed first before opening UI
    lib.callback('starterpack:checkClaimStatus', false, function(hasClaimed)
        if hasClaimed then
            lib.notify({
                title = 'Denied',
                description = 'You have already claimed your starter pack!',
                type = 'error',
                icon = 'ban'
            })
            return
        end

        -- Generate context menu options from config
        local options = {}
        for packId, packData in pairs(Config.Packs) do
            table.insert(options, {
                title = packData.label,
                description = packData.description,
                icon = packData.icon,
                arrow = true,
                onSelect = function()
                    ConfirmPack(packId, packData)
                end
            })
        end

        lib.registerContext({
            id = 'starter_pack_menu',
            title = 'Select Starter Pack',
            options = options
        })

        lib.showContext('starter_pack_menu')
    end)
end

function ConfirmPack(packId, packData)
    local alert = lib.alertDialog({
        header = 'Confirm Selection',
        content = ('Are you sure you want to claim the **%s**?\n\nYou can only claim ONE starter pack per character.'):format(packData.label),
        centered = true,
        cancel = true,
        labels = {
            cancel = 'Cancel',
            confirm = 'Claim Pack'
        }
    })

    if alert == 'confirm' then
        ClaimPack(packId)
    else
        lib.showContext('starter_pack_menu')
    end
end

function ClaimPack(packId)
    local pack = Config.Packs[packId]
    if not pack then return end

    -- Trigger server to give items, money, weapons securely
    lib.callback('starterpack:claimPack', false, function(success, message)
        if success then
            lib.notify({
                title = 'Success!',
                description = message,
                type = 'success',
                icon = 'check'
            })

            -- Handle vehicle locally if included and successful
            if pack.rewards.vehicle and pack.rewards.vehicle.enabled then
                SpawnVehicle(pack.rewards.vehicle.model, pack.rewards.vehicle.spawnPoint)
            end
        else
            lib.notify({
                title = 'Failed',
                description = message,
                type = 'error'
            })
        end
    end, packId)
end

function SpawnVehicle(model, coords)
    lib.requestModel(model)

    -- Spawn vehicle
    local vehicle = CreateVehicle(GetHashKey(model), coords.x, coords.y, coords.z, coords.w, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    
    local props = ESX.Game.GetVehicleProperties(vehicle)
    
    -- Save vehicle to DB
    TriggerServerEvent('starterpack:saveVehicle', props)
    
    -- Warp player into vehicle
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    
    -- Basic key giving, adjust to your exact key script logic if necessary.
    TriggerEvent('vehiclekeys:client:SetOwner', props.plate)

    lib.notify({
        title = 'Vehicle Delivered',
        description = 'You have received your vehicle with plate: ' .. props.plate,
        type = 'success',
        icon = 'car'
    })
    
    SetModelAsNoLongerNeeded(model)
end

-- Cleanup on restart
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if npcPed then
        DeletePed(npcPed)
    end
    lib.hideTextUI()
end)
