# 🎁 Aiben Starter Pack System

An advanced starter pack system for ESX Legacy FiveM servers that provides new players with customizable welcome rewards including cash, items, weapons, and vehicles.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![FiveM](https://img.shields.io/badge/FiveM-compatible-green)
![ESX Legacy](https://img.shields.io/badge/ESX-Legacy-darkgreen)
![License](https://img.shields.io/badge/license-MIT-brightgreen)

---

## 📸 Preview

### Screenshot
![Starter Pack System](https://r2.fivemanage.com/fDUKi7rgEhC1caoH2Yksm/Screenshot2026.png)

### Demo Video
[Starter Pack System Demo](https://r2.fivemanage.com/fDUKi7rgEhC1caoH2Yksm/6783d6e0-f468-424b-93db-aa459a615bfd-render.mp4)

---

## ✨ Features

- **Multiple Starter Pack Options** - Players can choose between different starter pack types (Civilian, Criminal, etc.)
- **Customizable Rewards** - Configure cash, items, weapons, and vehicles per pack
- **One-Claim System** - Prevents abuse by allowing each player to claim only once
- **NPC Interaction** - Easy-to-use NPC for players to interact with
- **Discord Logging** - Automatic Discord webhook notifications when packs are claimed
- **ox_target Support** - Optional integration with ox_target for better UX
- **Blip System** - Mini-map marker for easy NPC location
- **MySQL Support** - Uses oxmysql for efficient database operations
- **Player Tracking** - Database tracking of claimed packs per identifier

---

## 📋 Requirements

### Dependencies
This script requires the following resources to be installed on your FiveM server:

- [es_extended](https://github.com/esx-org/es_extended) - ESX Legacy Framework
- [ox_lib](https://github.com/overextended/ox_lib) - Utility library for FiveM
- [ox_target](https://github.com/overextended/ox_target) - Advanced targeting system
- [oxmysql](https://github.com/overextended/oxmysql) - MySQL driver

### Server Version
- **FiveM Build:** cerulean or higher
- **Game:** GTA5
- **Framework:** ESX Legacy

---

## 🚀 Installation

### Step 1: Download & Extract
1. Download or clone this repository
2. Extract the folder to your server's `resources` directory
3. Rename the folder to `[scripts]` if needed (or use any naming convention)

### Step 2: Database Setup
Run the following SQL query on your server database:

```sql
CREATE TABLE IF NOT EXISTS `starterpacks` (
    `identifier` varchar(60) NOT NULL,
    `claimed` tinyint(1) NOT NULL DEFAULT 1,
    `claimed_at` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Step 3: Configuration
1. Open `config.lua`
2. Configure your settings (NPC location, starter packs, etc.)
3. Add your Discord webhook URL (optional)

### Step 4: Server.cfg
Add the following to your `server.cfg`:

```cfg
ensure es_extended
ensure ox_lib
ensure ox_target
ensure oxmysql
ensure [scripts]
```

---

## ⚙️ Configuration

### Basic Configuration

```lua
Config = {}

-- Use ox_target for interactions (true) or DrawText3D + E key (false)
Config.UseTarget = false

-- Discord webhook for logging claims (set empty string to disable)
Config.DiscordWebhook = "YOUR_WEBHOOK_URL_HERE"
```

### Blip Configuration

```lua
Config.Blip = {
    Enabled = true,
    Sprite = 587,
    Color = 3,
    Scale = 0.8,
    Name = "Starter Pack"
}
```

### NPC Configuration

```lua
Config.NPC = {
    Model = "a_m_y_business_03",
    Coords = vector4(-1039.1547, -2732.2444, 20.1692, 237.3990) -- Airport location
}
```

### Starter Pack Configuration

Each starter pack can include:

```lua
Config.Packs = {
    ['basic'] = {
        label = 'Civilian Starter Pack',
        description = 'A simple start for an honest worker.',
        icon = 'briefcase',
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
                model = 'blista',
                spawnPoint = vector4(-1032.6547, -2728.7517, 19.6406, 56.3793)
            }
        }
    }
}
```

---

## 📁 File Structure

```
StarterPack/
├── README.md                 # This file
├── fxmanifest.lua           # FiveM manifest
├── config.lua               # Configuration file
├── starterpacks.sql         # Database schema
├── client/
│   └── main.lua             # Client-side code
├── server/
│   └── main.lua             # Server-side code
└── public/
    └── lib.js               # Utility library
```

---

## 🎮 Usage

### For Players
1. Locate the Starter Pack NPC at the airport on your map (blip appears)
2. Approach the NPC
3. If using `ox_target`: Click the interaction option
4. If using DrawText3D: Press 'E' when prompted
5. Select your desired starter pack from the menu
6. Receive your rewards instantly

### For Administrators

#### Add a New Starter Pack
Edit `config.lua` and add a new pack under `Config.Packs`:

```lua
['engineer'] = {
    label = 'Engineer Starter Pack',
    description = 'For mechanics and engineers.',
    icon = 'wrench',
    rewards = {
        money = { enabled = true, cash = 3000, bank = 7000 },
        items = { enabled = true, list = {{name = 'toolbox', count = 1}} },
        weapons = { enabled = false, list = {} },
        vehicle = { enabled = true, model = 'dilettante', spawnPoint = vector4(...) }
    }
}
```

#### Reset Player Claims
Run this SQL query to allow a player to claim again:

```sql
DELETE FROM starterpacks WHERE identifier = 'PLAYER_IDENTIFIER';
```

#### View All Claims
```sql
SELECT * FROM starterpacks;
```

---

## 🔌 API Reference

### Client-Side Callbacks

#### `starterpack:checkClaimStatus`
Checks if the current player has already claimed a starter pack.

**Returns:** `boolean` - `true` if already claimed, `false` otherwise

```lua
local hasClaimed = lib.callback.await('starterpack:checkClaimStatus')
```

#### `starterpack:claimPack`
Attempts to claim a specific starter pack for the player.

**Parameters:**
- `packId` (string): The ID of the pack to claim

**Returns:** `boolean`, `string` - Success status and message

```lua
local success, message = lib.callback.await('starterpack:claimPack', false, 'basic')
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| NPC not appearing | Check NPC coordinates in config.lua; ensure model exists |
| Can't interact with NPC | Verify `ox_target` is running if `UseTarget = true` |
| Discord webhook not working | Check webhook URL format and permissions |
| Database errors | Ensure starterpacks table is created; check oxmysql is running |
| Players can claim multiple times | Check `starterpacks` table for duplicate entries |

---

## 🔐 Security Features

- **One-Claim Protection**: Players can only claim once per identifier
- **Server-Side Validation**: All claims processed on server-side
- **Database Tracking**: Complete audit trail of who claimed what and when
- **Discord Logging**: Optional webhook logging for admin oversight

---

## 📊 Database Schema

### `starterpacks` Table

| Column | Type | Description |
|--------|------|-------------|
| `identifier` | varchar(60) | Player's unique identifier (Primary Key) |
| `claimed` | tinyint(1) | Claim status (1 = claimed) |
| `claimed_at` | timestamp | When the pack was claimed |

---

## 🎨 Customization Examples

### Example 1: Adding a Job-Specific Pack
```lua
['mechanic'] = {
    label = 'Mechanic Starter Pack',
    description = 'Tools and cash for mechanics.',
    icon = 'hammer',
    rewards = {
        money = { enabled = true, cash = 2000, bank = 3000 },
        items = { enabled = true, list = {{name = 'advancedtoolbox', count = 1}} },
        weapons = { enabled = false, list = {} },
        vehicle = { enabled = true, model = 'rumpo', spawnPoint = vector4(...) }
    }
}
```

### Example 2: Disabling Discord Logging
```lua
Config.DiscordWebhook = "" -- Empty string disables logging
```

### Example 3: Using DrawText3D Instead of ox_target
```lua
Config.UseTarget = false
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

### How to Contribute
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Author

**Aiben** - Created and maintained with ❤️

---

## 🙋 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check the [Troubleshooting](#-troubleshooting) section
- Consult the [Configuration](#-configuration) guide

---

## 📚 Resources & Links

- [ESX Framework Documentation](https://esx-org.github.io/)
- [FiveM Documentation](https://docs.fivem.net/)
- [ox_lib GitHub](https://github.com/overextended/ox_lib)
- [ox_target GitHub](https://github.com/overextended/ox_target)
- [oxmysql GitHub](https://github.com/overextended/oxmysql)

---

## 🎯 Roadmap

- [ ] GUI improvements with more customization options
- [ ] Skill points system based on starter pack
- [ ] Time-limited special packs
- [ ] Player statistics dashboard
- [ ] Integration with job systems
- [ ] Multilingual support

---

## ⭐ Show Your Support

If you find this script useful, please consider giving it a star! It helps others discover this resource.

---

**Enjoy your Starter Pack System! 🎉**
