local ESX = exports["es_extended"]:getSharedObject()
local ClaimCooldowns = {}

-- Utility to log to discord natively
local function SendDiscordWebhook(playerName, identifier, packName, rewards)
    if not Config.DiscordWebhook or Config.DiscordWebhook == "" or Config.DiscordWebhook == "YOUR_WEBHOOK_URL_HERE" then return end

    local rewardString = ""
    for _, reward in ipairs(rewards) do
        rewardString = rewardString .. "- " .. reward .. "\n"
    end

    local embed = {
        {
            ["color"] = 3447003, -- Blue
            ["title"] = "🎁 Starter Pack Claimed",
            ["description"] = string.format("**Player:** %s\n**Identifier:** %s\n**Pack:** %s\n\n**Rewards:**\n%s", playerName, identifier, packName, rewardString),
            ["footer"] = {
                ["text"] = "Aiben Starter Packs System",
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "Starter Logs", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

-- Callback to check if player already claimed
lib.callback.register('starterpack:checkClaimStatus', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return true end -- Fail-safe
    
    local identifier = xPlayer.identifier
    local result = MySQL.query.await('SELECT claimed FROM starterpacks WHERE identifier = ?', {identifier})
    
    -- If a record exists, they claimed it
    if result and result[1] then
        return true
    end
    return false
end)

-- Main logic for claiming the pack
lib.callback.register('starterpack:claimPack', function(source, packId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false, "Player not found." end
    
    local identifier = xPlayer.identifier

    -- Anti-spam / Cooldown to prevent double executions
    if ClaimCooldowns[identifier] and (os.time() - ClaimCooldowns[identifier]) < 5 then
        return false, "Please wait before trying again."
    end
    ClaimCooldowns[identifier] = os.time()

    -- Final security DB check
    local result = MySQL.query.await('SELECT claimed FROM starterpacks WHERE identifier = ?', {identifier})
    if result and result[1] then
        return false, "You have already claimed a starter pack."
    end

    local pack = Config.Packs[packId]
    if not pack then
        return false, "Invalid pack selected."
    end

    -- Insert into DB immediately to prevent race conditions
    local rowsChanged = MySQL.insert.await('INSERT INTO starterpacks (identifier, claimed) VALUES (?, ?)', {identifier, 1})
    if not rowsChanged then
        return false, "Database error. Please try again."
    end

    local rewardsGiven = {}

    -- Give Money Settings
    if pack.rewards.money.enabled then
        if pack.rewards.money.cash > 0 then
            xPlayer.addMoney(pack.rewards.money.cash)
            table.insert(rewardsGiven, "$" .. pack.rewards.money.cash .. " Cash")
        end
        if pack.rewards.money.bank > 0 then
            xPlayer.addAccountMoney('bank', pack.rewards.money.bank)
            table.insert(rewardsGiven, "$" .. pack.rewards.money.bank .. " Bank")
        end
    end

    -- Give Items Settings
    if pack.rewards.items.enabled then
        for _, item in ipairs(pack.rewards.items.list) do
            -- ESX AddItem handles most inventories automatically 
            xPlayer.addInventoryItem(item.name, item.count)
            table.insert(rewardsGiven, item.count .. "x " .. item.name)
        end
    end

    -- Give Weapons Settings
    if pack.rewards.weapons.enabled then
        for _, wep in ipairs(pack.rewards.weapons.list) do
            xPlayer.addWeapon(wep.name, wep.ammo)
            table.insert(rewardsGiven, wep.name .. " (" .. wep.ammo .. " Ammo)")
        end
    end

    -- Send Webhook
    SendDiscordWebhook(xPlayer.getName(), identifier, pack.label, rewardsGiven)

    return true, "Successfully claimed " .. pack.label .. "!"
end)

-- Dedicated event to save a vehicle (Client gives properties, Server saves to DB)
RegisterNetEvent('starterpack:saveVehicle', function(vehicleProps)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    -- Verify the player actually just claimed
    -- This adds a layer of security, making it harder to exploit
    local result = MySQL.query.await('SELECT claimed FROM starterpacks WHERE identifier = ?', {xPlayer.identifier})
    if not result or not result[1] then
        print(string.format("[starterpack] Warning: User %s tried to save vehicle without claiming a pack first.", xPlayer.identifier))
        return
    end

    -- Save to basic ESX 'owned_vehicles' table
    MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
        xPlayer.identifier,
        vehicleProps.plate,
        json.encode(vehicleProps)
    })
end)
