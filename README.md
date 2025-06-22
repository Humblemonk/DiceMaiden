# Dice Maiden

<p align="center">
<a href="https://top.gg/bot/377701707943116800">
    <img src="https://top.gg/api/widget/377701707943116800.svg" alt="Dice Maiden" />
</a>
<br><strong>Dice Bot for Discord</strong>
<br>A simple to use dice rolling bot perfect for any TTRPG sessions!
</p>


> **⚠️ Important Development Notice**
> 
> Active development for this Ruby version of Dice Maiden has entered **maintenance mode**. Future development and new features will focus on the **Rust version** found at [https://github.com/Humblemonk/dicemaiden-rs](https://github.com/Humblemonk/dicemaiden-rs).
> 
> This transition is due to scaling issues with the Ruby Discord library. The Ruby version will continue to receive critical bug fixes and security updates, but new features will be developed for the Rust implementation. These include the existing feature requests in this repo.


## Table of Contents

- [Quick Start](#quick-start)
- [Important Updates](#important-updates)
- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Advanced Rolling Options](#advanced-rolling-options)
- [Game System Support](#game-system-support)
- [Alias Commands](#alias-commands)
- [Self-Hosting](#self-hosting)
- [Support & Contributing](#support--contributing)

## Quick Start

**[Add Dice Maiden to your server →](https://discord.com/api/oauth2/authorize?client_id=572301609305112596&permissions=274878000128&scope=bot%20applications.commands)**

Once added, try these commands:
- `/roll 2d6` - Roll two six-sided dice
- `/roll 1d20+5` - Roll a d20 and add 5
- `/roll help` - See more options

## Important Updates

### Slash Command Migration (August 2022)

Due to Discord's new permission rules, Dice Maiden has migrated to slash commands:

- ❌ **Old**: `!roll 2d6` (no longer works)
- ✅ **New**: `/roll 2d6` or `/r 2d6`

**Required Setup:**
1. **Disable legacy chat input**: Go to User Settings > Accessibility > Turn OFF "Use the legacy chat input"
2. **Check permissions**: Users need the "USE APPLICATION COMMANDS" role
3. **Update bot permissions**: Re-add the bot if needed

> **Note**: When first added, the bot may appear offline while Discord caches your server. This is normal!

## Installation

### Quick Install (Recommended)

[**Click here to add Dice Maiden to your server**](https://discord.com/api/oauth2/authorize?client_id=572301609305112596&permissions=274878000128&scope=bot%20applications.commands)

The bot will have permissions to read, send, and manage messages.

### Self-Hosting

See the [Self-Hosting](#self-hosting) section below for detailed instructions.

## Basic Usage

### Simple Rolls

| Command | Description | Example |
|---------|-------------|---------|
| `/roll XdY` | Roll X dice with Y sides | `/roll 2d6` |
| `/roll XdY + Z` | Add static modifier | `/roll 3d6 + 5` |
| `/roll XdY - Z` | Subtract modifier | `/roll 1d20 - 2` |
| `/roll XdY * Z` | Multiply result | `/roll 2d4 * 3` |
| `/roll XdY / Z` | Divide result | `/roll 4d6 / 2` |

### Multiple Rolls

| Command | Description | Example |
|---------|-------------|---------|
| `/roll N XdY` | Roll N sets of XdY | `/roll 6 4d6` (roll 6 sets of 4d6) |
| `/roll A; B; C` | Multiple different rolls | `/roll 1d20; 2d6; 1d4` |

*Note: Maximum of 4 different rolls per command, sets can be 2-20.*

### Roll Modifiers

| Command | Description | Example |
|---------|-------------|---------|
| `/roll XdY s` | Simplified output | `/roll 4d6 s` |
| `/roll XdY nr` | No results shown | `/roll 4d6 nr` |
| `/roll XdY p` | Private roll | `/roll 4d6 p` |
| `/roll XdY ! comment` | Add comment | `/roll 4d6 ! Damage roll` |
| `/roll XdY ul` | Unsorted results | `/roll 4d6 ! unsort` |

### Utility Commands

| Command | Description |
|---------|-------------|
| `/roll help` | Basic usage instructions |
| `/roll help alias` | Alias command help |
| `/roll help system` | Game system help |
| `/roll donate` | Support the bot |
| `/roll purge N` | Delete last N messages (2-100)* |

*Requires "manage messages" or "administrator" role

## Advanced Rolling Options

### Exploding Dice

**Single Explosion:**
- `/roll 3d6 e6` - Explode on 6s (roll again once if you roll a 6)
- `/roll 3d6 e` - Explode on max value (same as `e6` for d6)

**Infinite Explosion:**
- `/roll 3d6 ie6` - Keep exploding on 6s (capped at 100 rolls)
- `/roll 3d6 ie` - Explode on max value indefinitely

### Keep/Drop Dice

**Keep Highest:**
- `/roll 4d6 k3` - Roll 4d6, keep the highest 3

**Keep Lowest:**
- `/roll 4d6 kl3` - Roll 4d6, keep the lowest 3

**Drop Lowest:**
- `/roll 4d6 d1` - Roll 4d6, drop the lowest 1

*Note: Drop happens before keep (roll → drop → keep)*

### Rerolls

**Single Reroll:**
- `/roll 4d6 r2` - Reroll any dice ≤ 2 (once)

**Infinite Reroll:**
- `/roll 4d6 ir2` - Keep rerolling dice ≤ 2 (capped at 100 per die)

### Success/Failure Systems

**Target Numbers:**
- `/roll 6d10 t7` - Count successes (7+ = success)
- `/roll 5d10 t8 f1` - Successes (8+) minus failures (1)

**Botches:**
- `/roll 4d6 b1` - Count botches (dice showing 1 or less)

### Complex Example

```
/roll 10d6 e6 k8 +4
```
*Roll 10d6, explode on 6s, keep highest 8, add 4*

## Game System Support

### Warhammer 40k: Wrath and Glory

| Command | Description |
|---------|-------------|
| `/roll wng 4d6` | Roll with wrath dice |
| `/roll wng dn2 4d6` | Difficulty test (DN 2) |
| `/roll wng 4d6 !soak` | No wrath dice |
| `/roll wng 4d6 !exempt` | No wrath dice |
| `/roll wng 4d6 !dmg` | No wrath dice |

### Dark Heresy 2nd Edition

- `/roll dh 4d10` - Includes righteous fury notifications

### Godbound

- `/roll gb 1d12+4` - Single die vs damage chart
- `/roll gb 8d8` - Multiple dice vs damage chart

### Hero System 5th Edition

| Command | Description |
|---------|-------------|
| `/roll 2hsn` | Normal damage (2d6) |
| `/roll 5hsk1 +1d3` | Killing damage with stun modifier |
| `/roll 3hsh` | Healing (11 + 3 - 3d6) |

## Alias Commands

Aliases are shorthand commands for common game systems:

### Popular Systems

| Alias | Equivalent | System |
|-------|------------|--------|
| `4cod` | `4d10 t8 ie10` | Chronicles of Darkness |
| `4wod8` | `4d10 f1 ie10 t8` | World of Darkness |
| `3df` | `3d3 t3 f1` | Fate (Fudge dice) |
| `3wh4+` | `3d6 t4` | Warhammer 40k/AoS |
| `age` | `2d6 + 1d6` | AGE System |
| `sr6` | `6d6 t5` | Shadowrun |
| `dndstats` | `6 4d6 k3` | D&D stat generation |

### D&D 5e Quick Rolls

| Alias | Description |
|-------|-------------|
| `attack +5` | `1d20 + 5` (Attack roll) |
| `skill -2` | `1d20 - 2` (Skill check) |
| `save +3` | `1d20 + 3` (Saving throw) |

### Advantage/Disadvantage

| Alias | Equivalent | Description |
|-------|------------|-------------|
| `+d20` | `2d20 d1` | Advantage |
| `-d20` | `2d20 kl1` | Disadvantage |
| `+d%` | `((2d10kl1-1)*10)+1d10` | Advantage percentile |
| `-d%` | `((2d10k1-1)*10)+1d10` | Disadvantage percentile |

### Specialty Dice

| Alias | Description |
|-------|-------------|
| `dd34` | `(1d3*10)+1d4` (Double digit d66 style) |
| `2d%` | `2d100` (Multiple percentile) |

### Complete Alias List

<details>
<summary>Click to expand full alias list</summary>

**World of Darkness Variants:**
- `cod8`, `cod9`, `codr` - 8-again, 9-again, rote quality

**Exalted:**
- `ex5` → `5d10 t7 t10`
- `ex5t8` → `5d10 t8 t10` (modified target)

**Other Systems:**
- `snm5` → `5d6 ie6 t4` (Sunsails: New Millennium)
- `d6s4` → `4d6 + 1d6 ie` (D6 System)
- `sp4` → `4d10 t8 ie10` (Storypath)
- `6yz` → `6d6 t6` (Year Zero)

</details>

### Earthdawn System

Special step-dice system with commands `ed1` through `ed50`:

<details>
<summary>Earthdawn Step Table (ed1-ed50)</summary>

| Step | Roll | Step | Roll | Step | Roll |
|------|------|------|------|------|------|
| ed1 | 1d4ie-2 | ed18 | 1d12ie+1d10ie+1d8ie | ed35 | 1d20ie+1d12ie+2d10ie+1d8ie |
| ed2 | 1d4ie-1 | ed19 | 1d20ie+2d6ie | ed36 | 2d20ie+1d10ie+1d8ie+1d4ie |
| ed3 | 1d4ie | ed20 | 1d20ie+1d8ie+1d6ie | ed37 | 2d20ie+1d10ie+1d8ie+1d6ie |
| ed4 | 1d6ie | ed21 | 1d20ie+1d10ie+1d6ie | ed38 | 2d20ie+1d10ie+2d8ie |
| ed5 | 1d8ie | ed22 | 1d20ie+1d10ie+1d8ie | ed39 | 2d20ie+2d10ie+1d8ie |
| ... | ... | ... | ... | ... | ... |

*Complete table available in source code*

**Earthdawn 4th Edition:** Use `ed4eX` format (ed4e1 through ed4e50)

</details>

## Self-Hosting

### Requirements

- Ruby 2.4 or higher
- Bundler gem manager
- Discord bot token

### Manual Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Humblemonk/DiceMaiden.git
   cd DiceMaiden
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Create environment file:**
   Create `.env` in the root directory:
   ```
   TOKEN: your_bot_token_here
   SHARD: 1
   ```

4. **Run the bot:**
   ```bash
   bundle exec ruby dice_maiden.rb 0 lite
   ```

### Docker Installation

1. **Clone to /opt directory:**
   ```bash
   sudo git clone https://github.com/Humblemonk/DiceMaiden.git /opt/DiceMaiden
   ```

2. **Create environment file:**
   ```bash
   sudo vim /opt/DiceMaiden/.env
   ```
   Add:
   ```
   TOKEN: your_bot_token_here
   SHARD: 1
   ```

3. **Build and run:**
   ```bash
   cd /opt/DiceMaiden
   sudo docker-compose up -d
   ```

### Docker Management

**View logs:**
```bash
sudo docker logs -f dicemaiden
```

**Access container:**
```bash
sudo docker exec -it dicemaiden bash
```

**Start/Stop/Restart:**
```bash
sudo docker start dicemaiden
sudo docker stop dicemaiden
sudo docker restart dicemaiden
```

**Update bot:**
```bash
cd /opt/dicemaiden
git pull origin master
sudo docker-compose up -d --build
```

## Support & Contributing

### Getting Help

- **Bug reports & feature requests:** [Create an issue on GitHub](https://github.com/Humblemonk/DiceMaiden/issues)
- **Discord support server:** [Join here](https://discord.gg/AYNcxc9NeU)
- **Documentation:** Check this README and the help commands

### Support the Project

If you find Dice Maiden useful, consider supporting development:

**[Support on Patreon](https://patreon.com/dicemaiden)**

### Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

*Dice Maiden - Making TTRPG sessions more fun, one roll at a time!*
