Config = {}

-- General Settings
Config.UseTarget = false -- Set to true to use ox_target, false to use DrawText3D + E key
Config.DiscordWebhook = "YOUR_WEBHOOK_URL_HERE" -- Replace with your webhook or keep empty to disable

-- Blip Configuration
Config.Blip = {
    Enabled = true,
    Sprite = 587,
    Color = 3,
    Scale = 0.8,
    Name = "Starter Pack"
}

-- NPC Configuration
Config.NPC = {
    Model = "a_m_y_business_03",
    Coords = vector4(-1039.1547, -2732.2444, 20.1692, 237.3990) -- x, y, z, heading
}

-- Built-in Bonus: Allow players to pick between multiple starter packs!
Config.Packs = {
    ['basic'] = {
        label = 'Civilian Starter Pack',
        description = 'A simple start for an honest worker. Contains cash, essentials and a reliable vehicle.',
        icon = 'briefcase', -- ox_lib fontawesome icon
        rewards = {
            money = {
                enabled = true,
                cash = 5000,
                bank = 10000
            },
            items = {
                enabled = true,
                list = {
                    {name = 'phone', count = 1},
                    {name = 'water', count = 5},
                    {name = 'bread', count = 5}
                }
            },
            weapons = {
                enabled = false,
                list = {
                    {name = 'WEAPON_BAT', ammo = 1}
                }
            },
            vehicle = {
                enabled = true,
                model = 'blista', -- Vehicle spawn name
                spawnPoint = vector4(-1032.6547, -2728.7517, 19.6406, 56.3793) -- Where to spawn
            }
        }
    },
    ['criminal'] = {
        label = 'Criminal Starter Pack',
        description = 'For those who want to live fast and dangerously. Contains dirty money, lockpicks and a getaway vehicle.',
        icon = 'mask',
        rewards = {
            money = {
                enabled = true,
                cash = 10000,
                bank = 0
            },
            items = {
                enabled = true,
                list = {
                    {name = 'phone', count = 1},
                    {name = 'lockpick', count = 3},
                    {name = 'water', count = 2}
                }
            },
            weapons = {
                enabled = true,
                list = {
                    {name = 'WEAPON_KNIFE', ammo = 1},
                    {name = 'WEAPON_PISTOL', ammo = 50}
                }
            },
            vehicle = {
                enabled = true,
                model = 'sanchez',
                spawnPoint = vector4(-1032.6547, -2728.7517, 19.6406, 56.3793)
            }
        }
    }
}
