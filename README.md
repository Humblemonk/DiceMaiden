# Dice Maiden
<p align="center">
<a href="https://top.gg/bot/377701707943116800">
    <img src="https://top.gg/api/widget/377701707943116800.svg" alt="Dice Maiden" />
</a>
<br>Dice Bot for Discord
<br>Dice Maiden is a simple to use dice rolling bot perfect for any trpg sessions!
</p>

# Slash Command Update
On August 31st 2022, Discord is enforcing new permission rules for large bots. This includes Dice Maiden. These updates restricts access to certain APIs for privacy reasons. One is the message content from users which Dice Maiden has used for years. More info about these changes can be found [here](https://support-dev.discord.com/hc/en-us/articles/4404772028055-Message-Content-Privileged-Intent-FAQ)

In an attempt to not have to rewrite the majority of Dice Maidens codebase, I applied for privileged intents and was denied. The Discord devteam recommended moving the bot to slash commands so here we are. What this means for users:

* !roll and other prefixes have been retired. Sorry no custom prefixes
* rolls can be initiated now by doing /roll
* Some new (and maybe old) bugs might crop up with this shift to slash command. We are working on ironing these out
* Bot permissions may have broken for your server. Please update the permission for the bot or re add the bot to your server

# **USERS WILL NEED THE ROLE "USE APPLICATION COMMANDS" TO USE SLASH COMMANDS**

# Quick Install
Follow the link to add the bot to your discord server :

https://discord.com/api/oauth2/authorize?client_id=572301609305112596&permissions=274878000128&scope=bot%20applications.commands

This will authorize the bot for your server and you should see it in your default public channel. The bot will have permissions to read, send and manage messages.

**NOTE:** When you first add the bot to your server, it may show up as offline. This is normal! It can take some time for your server to be cached by the bot. 

# Manual Install
If you wish to host this yourself, Dice Maiden requires ruby version 2.4 or higher. Please check the Gemfile for the various gems required. To manage these gems, it is recommended to utilize [Bundler](https://bundler.io/).You will also need to create a bot which can be done at the [discord developer section](https://discordapp.com/developers/applications/me). 

An ENV file (.env) must be created for storing your bots secret token and current shard count. Single instance bots will have a shard count of 1. This file must exist in the bots root directory. Example ENV file:
```
TOKEN: foobar
SHARD: 1
```
A single instance of Dice Maiden does not require a sqlite database to operate. Passing the command 'lite' at runtime will tell the bot to ignore any database requirement. 

Example runtime command for a single bot instance: `bundle exec ruby dice_maiden.rb 0 lite`

## Single instance Docker install

Another way to run a single instance of Dice Maiden is via docker. Before utilizing the docker image included with Dice Maiden, please make sure both `docker` and `docker-compose` are installed. Follow the steps below:

1. Run `git clone https://github.com/Humblemonk/DiceMaiden.git` in your /opt directory. This may require sudo powers.
2. run `vim /opt/DiceMaiden/.env` and add the following to the env file:

```
TOKEN: token obtained from your discord developer application
SHARD: 1
```

The `docker-compose` file created by this repo expects to find the `.env` file in `/opt` directory. This can be changed by editing the `docker-compose` file.

3. Once the env file is created, make sure you are in the DiceMaiden directory by typing `cd /opt/dicemaiden`. Once in the DiceMaiden directory, run `docker-compose up -d` to build the docker container. 

**NOTE:** The initial run can take a bit as the container needs to download and install all the ruby gems and their dependencies. This isnt required again unless you rebuild the container.

If everything was successful, your Dice Maiden docker container should now be running! A couple helpful commands for docker newbies:

1. View dicemaiden container logs: `sudo docker logs -f dicemaiden`
2. Run commands inside dicemaiden container: `sudo docker exec -it dicemaiden bash`
3. Start/stop/restart dicemaiden container: `sudo docker start dicemaiden; sudo docker stop dicemaiden; sudo docker restart dicemaiden`

If you wish to rebuild the container so that your bot is running the latest changes, run the following commands:

1. Update the bot by running `git pull origin master` in the `/opt/dicemaiden` directory
2. Rebuild the docker container `sudo docker-compose up -d --build`

# Support
Found a bug? Have a feature request? Create an issue on github. Thanks!

You can also join the Discord Support server: https://discord.gg/AYNcxc9NeU

If you wish to support the bot and donate, you can do so via Patreon [here](https://patreon.com/dicemaiden) or paypal via donate bot [here](https://donatebot.io/checkout/534632036569448458?buyer=176097017926385664)!

# How to use
Below are examples of the dice roll syntax.

`/roll 2d6 + 3d10` : Roll two six-sided dice and three ten-sided dice.

`/roll 3d6 + 5` : Roll three six-sided dice and add five. Other supported static modifiers are add (+), subtract (-), multiply (*), and divide (/).

`/roll 3d6 e6` : Roll three six-sided dice and explode on sixes. Some game systems call this 'open ended' dice. If the number rolled is greater than or equal to the value given for this option, the die is rolled again and added to the total. If no number is given for this option, it is assumed to be the same as the number of sides on the die. Thus, '3d6 e' is the same as '3d6 e6'. The dice will only explode once with this command. Use "ie" for indefinite explosions.

`/roll 3d6 ie6` : Roll three six-sided dice and explode on sixes indefinitely within reason. We will cap explosions at 100 rolls to prevent abuse.

`/roll 3d10 d1` : Roll three ten-sided dice and drop one die. The lowest value will be dropped first.  **NOTE:** These dice are dropped before any dice are kept with the following `k` command. Order of operations is : roll dice, drop dice, keep dice

`/roll 3d10 k2` : Roll three ten-sided dice and keep two. The highest value rolled will be kept.

`/roll 4d6 r2` : Roll four six-sided dice and reroll any that are equal to or less than two once. Use ir for indefinite rerolls.

`/roll 4d6 ir2` : Roll four six-sided dice and reroll any that are equal to or less than two (and do the same to those dice). This is capped at 100 rerolls per die to prevent abuse.

`/roll 6d10 t7` : Roll six ten-sided dice and any that are seven or higher are counted as a success. The dice in the roll are not added together for a total. Any die that meets or exceeds the target number is added to a total of successes.

`/roll 5d10 t8 f1` : f# denotes a failure number that each dice must match or be beneath in order to count against successes. These work as a sort of negative success and are totaled together as described above. In the example roll, roll five ten-sided dice and each dice that is 8 or higher is a success and subtract each one. The total may be negative. If the option is given a 0 value, that is the same as not having the option at all thus a normal sum of all dice in the roll is performed instead.

`/roll 4d10 kl3` : Roll four ten-sided dice and keep the lowest three dice rolled.

`/roll purge 10`: Purge the last 10 messages from channel. The purge value can be between 2 to 100 messages and requires the user to have the "manage messages" or "administrator" role.

`/roll 4d6 ! Hello World!`: Roll four six-sided dice and add comment to the roll.

`/roll 6 4d6` : Roll 6 sets of four six-sided dice. A size of a set can be between 2 and 20.

`/roll s 4d6` : Simplify roll output by not showing the tally.

`/roll 4d6 ! unsort` or `!roll ul 4d6`: Roll four six-sided dice and unsort the tally.

`/roll help` : Displays basic usage instructions.

`/roll help alias` : Displays alias instructions.

`/roll help system` : Displays game system instructions.

`/roll donate` : Get donation information on how to help support the bot!

These commands can be combined. For example:

`/roll 10d6 e6 k8 +4` : Roll ten six-sided dice , explode on sixes and keep eight of the highest rolls and add four.

# Game Systems Specific Rolls
Warhammer 40k Wrath and Glory example syntaxes:

`/roll wng 4d6` : Roll four six-sided dice with a wrath dice.

`/roll wng dn2 4d6`: Roll four six-sided dice with a wrath dice and a difficulty test of 2. The bot will append the test pass/fail status to the roll result!

`/roll wng 4d6 !soak` or `!roll wng 4d6 !exempt` or `!roll wng 4d6 !dmg` : Roll four six-sided dice without a wrath dice.

Dark Heresy 2nd edition syntaxes:

`/roll dh 4d10` : Roll four ten-sided dice for dark heresy 2nd edition. If your roll contains a natural 10, you will be prompted with a righteous fury notification!

## Alias Rolls
Alias rolls are commands that are shorthand for a longer, more complex comand. They can also change what the dice faces appear as
in most cases. Below is the complete list of aliases , with example rolls, currently supported by Dice Maiden. Have a game system that you want turned into an alias? Create an issue on github to get it added to this list!

`4cod` -> `4d10 t8 ie10` Chronicles of Darkness. The first number is the number of dice to roll (use cod8, cod9 and codr for 8-again, 9-again and rote quality rolls).

`4wod8` -> `4d10 f1 ie10 t8` World of darkness 4th edition. The first number is the number of dice to roll and the second is the toughness of the check.

`3df` -> `3d3 t3 f1` Fudge dice from the fate RPG system. The number represents total dice rolled. This alias also outputs the dice faces as `+`/` `/`-`.

`3wh4+` -> `3d6 t4` Warhammer Age of Sigmar/40k style rolls. The first number is the amount of dice rolled and the second number is the target number.

`dd34` -> `(1d3 * 10) + 1d4` Double digit rolls. Uses the first number for the first digit and the second number for the second digit. This is sometimes used in warhammer as a "d66".

`age` -> `2d6 + 1d6` AGE system roll. The AGE system games use 3d6 for ability tests, with 1 of them typically being represented as a drama die, stunt die, dragon die etc. It is important that all three dice be rolled together but the drama die is able to be distinguished from the others. Example games include Fantasy Age, Dragon Age, Modern Age, Blue Rose, and The Expanse RPG.

`+dX` -> `2dX d1`  Advantage roll where X is the dice sides value. Roll two dice and keep the highest.

`-dX` -> `2dX kl1` Disadvantage roll where X the dice sides value. Roll two dice and keep the lowest.

`+d%` -> `((2d10kl1-1) *10) + 1d10` Advantage roll for a percentile dice in a roll-under system. Rolls two tens and keeps the lowest.

`-d%` -> `((2d10k1-1) *10) + 1d10` Disadvantage roll for a percentile dice in a roll-under system. Rolls two tens and keeps the highest.

`xd%` -> `d100` Simple shorthand for a d100 roll where x is the number of dice to roll.

`snm5` -> `5d6 ie6 t4` Sunsails: New Millennium 4th edition. The number represents total dice rolled. Indefinitely explodes on sixes, with a target of four.

`d6s4` -> `4d6 + 1d6 ie` The D6 System. The number must be 1 lower than the total size of the dice pool as the wild die is automatically added for you. If you have some pips to add put them on the end (i.e. `d6s4 +2` is the same as `4d6 + 1d6 ie + 2`).

`sr6` -> `6d6 t5` Shadowrun System. The number represents total dice rolled. Target to hit is 5 or higher.

`sp4` -> `4d10 t8 ie10` Storypath system. The number represents total dice rolled. A d10 system with a target set to 8 and infinite explosion on 10.

`6yz` -> `6d6 t6` Year Zero system. The number represents the total dice rolled. A d6 system with a target set to 6.

`dndstats` -> `6 4d6 k3` DnD stat roll (4d6 drop lowest). This is supported by DnD 2nd edition, 3.5e, 5e and pathfinder 1e.

## Earthdawn System:

`/roll edX` where X can be a value of 1 to 50. Earthdawn system has a plethora of ways to roll the dice and the table below breaks down the various options:

| Roll Command | Description|
| --- | --- |
| /roll ed1 | 1d4 ie - 2 |
| /roll ed2 | 1d4 ie - 1 |
| /roll ed3 | 1d4 ie | 
| /roll ed4 | 1d6 ie |
| /roll ed5 | 1d8 ie |
| /roll ed6 | 1d10 ie |
| /roll ed7 | 1d12 ie |
| /roll ed8 | 2d6 ie |
| /roll ed9 | 1d8 ie + 1d6 ie |
| /roll ed10 | 2d8 ie |
| /roll ed11 | 1d10 ie + 1d8 ie |
| /roll ed12 | 2d10 ie |
| /roll ed13 | 1d12 ie + 1d10 ie |
| /roll ed14 | 2d12 ie |
| /roll ed15 | 1d12 ie + 2d6 ie |
| /roll ed16 | 1d12 ie + 1d8 ie + 1d6 ie |
| /roll ed17 | 1d12 ie + 2d8 ie |
| /roll ed18 | 1d12 ie + 1d10 ie + 1d8 ie |
| /roll ed19 | 1d20 ie + 2d6 ie |
| /roll ed20 | 1d20 ie + 1d8 ie + 1d6 ie |
| /roll ed21 | 1d20 ie + 1d10 ie + 1d6 ie |
| /roll ed22 | 1d20 ie + 1d10 ie + 1d8 ie |
| /roll ed23 | 1d20 ie + 2d10 ie |
| /roll ed24 | 1d20 ie + 1d12 ie + 1d10 ie |
| /roll ed25 | 1d20 ie + 1d12 ie + 1d8 ie + 1d4 ie |
| /roll ed26 | 1d20 ie + 1d12 ie + 1d8 ie + 1d6 ie |
| /roll ed27 | 1d20 ie + 1d12 ie + 2d8 ie |
| /roll ed28 | 1d20 ie + 2d10 ie + 1d8 ie |
| /roll ed29 | 1d20 ie + 1d12 ie + 1d10 ie + 1d8 ie |
| /roll ed30 | 1d20 ie + 1d12 ie + 1d10 ie + 1d8 ie |
| /roll ed31 | 1d20 ie + 1d10 ie + 2d8 ie + 1d6 ie |
| /roll ed32 | 1d20 ie + 2d10 ie + 1d8 ie + 1d6 ie |
| /roll ed33 | 1d20 ie + 2d10 ie + 2d8 ie |
| /roll ed34 | 1d20 ie + 3d10 ie + 1d8 ie |
| /roll ed35 | 1d20 ie + 1d12 ie + 2d10 ie + 1d8 ie |
| /roll ed36 | 2d20 ie + 1d10 ie + 1d8 ie + 1d4 ie |
| /roll ed37 | 2d20 ie + 1d10 ie + 1d8 ie + 1d6 ie |
| /roll ed38 | 2d20 ie + 1d10 ie + 2d8 ie |
| /roll ed39 | 2d20 ie + 2d10 ie + 1d8 ie |
| /roll ed40 | 2d20 ie + 1d12 ie + 1d10 ie + 1d8 ie |
| /roll ed41 | 2d20 ie + 1d10 ie + 1d8 ie + 2d6 ie |
| /roll ed42 | 2d20 ie + 1d10 ie + 2d8 ie + 1d6 ie |
| /roll ed43 | 2d20 ie + 2d10 ie + 1d8 ie + 1d6 ie |
| /roll ed44 | 2d20 ie + 3d10 ie + 1d8 ie |
| /roll ed45 | 2d20 ie + 3d10 ie + 1d8 ie |
| /roll ed46 | 2d20 ie + 1d12 ie + 2d10 ie + 1d8 ie |
| /roll ed47 | 2d20 ie + 2d10 ie + 2d8 ie + 1d4 ie |
| /roll ed48 | 2d20 ie + 2d10 ie + 2d8 ie + 1d6 ie |
| /roll ed49 | 2d20 ie + 2d10 ie + 3d8 ie |
| /roll ed50 | 2d20 ie + 3d10 ie + 2d8 ie |

### Earthdawn 4th edition

`/roll ed4eX` where X can be a value of 1 to 50. Earthdawn 4th edition roll steps can be found in the earthdawn_logic.rb. 
