## 8.6.3 - 2024-01-26
### Added
- Refactored Gemfile 

## 8.6.2 - 2024-01-24
### Added
- Refactored sqlite usage
- Updated dockerfile to ruby 3.3.0
- Updated dockerfile to alpine linux 3.19

## 8.6.1 - 2024-01-24
### Added
- Minor changes to command text outputs

## 8.6.0 - 2023-09-22
### Added
- Resolved an issue where unsort comments would not work

## 8.5.2 - 2023-07-13
### Added
- Minor changes to donate and help text prompts

## 8.5.1 - 2023-07-03
### Added
- Resolved an issue related to display names in rolls

## 8.5.0 - 2023-05-08
### Added
- Added Earth Dawn 4th edition as well as additional steps for previous editions

## 8.4.0 - 2022-12-18
### Added
- Resolved an issue related to user names in direct messages to the bot

## 8.3.1 - 2022-09-01
### Added
- Removed ignoring heartbeat ack from discord API. No longer needed for stability

## 8.3.0 - 2022-08-29
### Added
- Changed formatting of dice response string. Format should now be Request -> Tally -> Result

## 8.2.2 - 2022-08-25
### Added
- Made roll message a requirement to improve the user experience

## 8.2.1 - 2022-08-23
### Added
- Added error reporting when dice roll message is empty

## 8.2.0 - 2022-08-23
### Added
- Resolved issue #148 related to single die dice rolls

## 8.1.0 - 2022-08-23
### Added
- Added first unit test file
- Added additional messaging for when purge commands are run

## 8.0.2 - 2022-08-23
### Added
- Refactored some code to further support slash commands

## 8.0.1 - 2022-08-21
### Added
- Resolved an issue with nickname checks for DMs. No longer going to check

## 8.0.0 - 2022-08-21
### Added
- Moved to slash commands per discord requirements. More info in readme!

## 7.2.0 - 2021-12-19
### Added
- Added alias support for general DnD stat rolls

## 7.1.1 - 2021-10-16
### Added
- Fixed an issue where the bot would read commands inside markdown blockquotes

## 7.1.0 - 2021-09-01
### Added
- Added support for threads

## 7.0.1 - 2021-04-25
### Added
- Resolved case sensitive issue from rubocop update

## 7.0.0 - 2021-04-25
### Added
- Added alias for Year Zero Engine
- Added rubocop rules and cleaned up the codebase

## 6.8.1 - 2021-03-13
### Added
- Resolved an issue where the bot would respond with "Invalid Form Body"

## 6.8.0 - 2021-01-17
### Added
- Added support for earthdawn system

## 6.7.0 - 2021-01-07
### Added
- Added initial support for storypath system
- Resolved an issue where the bot was responding to "!roll" even when a custom prefix was set.

## 6.6.1 - 2020-10-17
### Added
- Added alias for shorthand d100 rolls

## 6.6.0 - 2020-9-17
### Added
- Removed dice_maiden_lite.rb and consolidated its features into dice_maiden.rb
- Added 'lite' runtime support. If this is set, the bot will ignore database requirements

## 6.5.0 - 2020-9-05
### Added
- Added Shadowrun alias
- Added d6 System alias

## 6.4.0 - 2020-8-07
### Added
- Added Chronicles of Darkness alias
- Added Sunsails: New Millennium 4th edition alias

## 6.3.0 - 2020-7-28
### Added
- Added new text for rerolls. Results will now show total rerolls

## 6.2.1 - 2020-7-23
### Added
- Resolved an issue with keep lowest command. This now fully supports the drop command

## 6.2.0 - 2020-6-22
### Added
- Added support for indefinite explodes and rerolls. Check readme for more information!
- Updated world of darkness 4th edition alias. It now properly supports indefinite explosions.

## 6.1.0 - 2020-6-08
### Added
- Added new server wide option: Roll request display. You can set the bot to display the actual roll executed as part of the bots response.
- Resolved an issue with unsorting tally

## 6.0.1 - 2020-5-28
### Added
- The bot should now respond to private message rolls

## 6.0.0 - 2020-5-19
### Added
- Refactored the majority of bot logic to make it easier for multiple users to contribute to the code base

## 5.3.0 - 2020-5-13
## Added
- Fixed a bug where we were not properly checking the prefix

## 5.2.1 - 2020-5-12
## Added
- A laundry list of bug fixes for the recent prefix change support

## 5.0.0 - 2020-5-12
## Added
- Resolved an issue where roll sets would fail with single die rolls: !roll 5 d20
- Add prefix change support! Documentation updated with command syntax

## 4.3.0 - 2020-5-8
## Added
- Better error reporting for when roll is over discord character limit. The roll result will be resent in a simplified format

## 4.2.0 - 2020-5-4
## Added
- New unsort command syntax: !roll ul
- Refactored some command logic

## 4.1.0 - 2020-4-24
### Added
- Alias support for AGE system
- Typing indicator effect
- Listening status for roll command

## 4.0.6 - 2020-4-17
### Added
- Roll mechanic is now case-insensitive

## 4.0.5 - 2020-4-12
### Added
- Fixed bug with wrath and glory rolls
- Readded latency check feature

## 4.0.4 - 2020-4-12
### Added
- Better server count logging

## 4.0.3 - 2020-4-10
### Added
- Cleaned up ruby gems and discordbots API

## 4.0.2 - 2020-4-07
## Added
- Fixed an issue with d2 rolls

## 4.0.1 - 2020-4-05
### Added
- Moved shard count to env variable
- Removed check ping command
- Updated purge roll functionality

## 4.0.0 - 2020-4-05
### Added
- Add full math engine. Support for more advanced rolls!
- Removed check latency feature

## 3.4.0 - 2020-3-28
### Added
- Added support for game system Wrath and Glory

## 3.3.0 - 2020-2-23
### Added
- Added logging verbosity command 

## 3.2.2 - 2020-01-14
### Added
- Increaased server count means more shards required! Updated shard count

## 3.2.1 - 2019-12-11
### Added
- Fixed an issue with unsort command that would cause the tally to contain a zero value

## 3.2.0 - 2019-11-8
### Added
- Fixed an issue where roll set value can sometimes be set incorrectly
- Fixed an issue where the server may roll multiple instances of the same roll
- Add support for unsorting rolls! Check readme for more information

## 3.1.2 - 2019-11-3
### Added
- 26k servers using the bot! Increased shard capacity to support them 

## 3.1.0 - 2019-9-5
### Added
- Added donation information to help command 
- Added !roll donate command

## 3.0.0 - 2019-8-18
### Added
- Forked dice-bag gem. Added support for keeping lowest dice rolls
- Changed min dice roll from d3 to d2.

## 2.9.0 - 2019-6-10
### Added
- Ability to simplify ouput by not reporting the tally. More info in README

## 2.8.1 - 2019-5-21
### Added
- Filtered low dice rolls to prevent abuse

## 2.7.0 - 2019-3-22
### Added
- Support for nicknames
- Additional sharding

## 2.6.0 - 2019-2-2
### Added
- Bulk rolling ability added

## 2.5.3 - 2019-1-26
### Added
- Restricted purge rolls to manage_messages permissions

## 2.5.1 - 2019-1-22
### Added
- Additional sharding

## 2.5.0 - 2019-1-7
### Added
- sqlite3 support for logging
- Additional sharding
- Tweaks to roll error checking

## 2.4.0 - 2019-1-2
### Added
- Initial support for sharding

## 2.3.0 - 2018-11-18
### Added
- bot-info command

## 2.2.0 - 2018-11-17
### Added
- Additional logging

## 2.1.3 - 2018-11-14
### Added
- Refactored server count

## 2.1.2 - 2018-9-29
### Added
- Minor formatting tweaks

## 2.1.1 - 2018-9-28
### Added
- More refactoring: moved most functions to methods

## 2.1.0 - 2018-9-28
### Added
- Lots of refactoring

## 2.0.2 - 2018-9-26
### Added
- Added support for difficulty number

## 2.0.1 - 2018-9-25
### Added
- Added initial support for Wrath and Glory

## 2.0.0 - 2018-8-28
### Added
- Cleaned up formatting and refactored code

## 1.4.0 - 2018-8-28
### Added
- Added support for "Wrath and Glory" Wrath dice

## 1.3.1 - 2018-8-1
### Added
- Updated righteous fury pop to be for personal server only

## 1.3.0 - 2018-7-25
### Added
- Added ping command to check round trip latency

## 1.2.4 - 2018-6-28
### Added
- Added check for size of dice pools

## 1.2.3 - 2018-6-27
### Added
- Added support for large dice pools

## 1.2.2 - 2018-6-27
### Added
- Fixed issue with comments not supporting additional !

## 1.2.1 - 2018-6-18
### Added
- Updated comment command from # to !

## 1.2.0 - 2018-6-7
### Added
- Added comment command

## 1.1.0 - 2017-12-16
### Added
- Added purge command. **NOTE:** This may require re-adding the bot to your discord server due to a permission change.

## 1.0.3 - 2017-12-11
### Added
- Support for exception handling

## 1.0.2 - 2017-11-28
### Added
- Changed log file name
- Support for logging server lists

## 1.0.1 - 2017-11-17
### Added
- Published source code
- Updated regex syntaxes
- Updated tally functionality
- Updated help information

## 1.0.0 - 2017-11-13
### Added
- Initial release
