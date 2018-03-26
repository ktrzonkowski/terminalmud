# terminal-mud
Turn your regular terminal experience into a MUD.  Fun not guaranteed.

## Installation
1. Copy or clone this repository into your home folder, i.e. ``~/terminalmud``
2. Add this line to your bash profile (i.e. ~/.bash_profile): ``source ~/terminalmud/script.sh``
3. Either run ``source`` against your bash profile or reload your terminal.

## Commands

``look``
- Lists the number of directories and files in the current room.

``look <files|directories|dir>``
- Lists all the files or directories in the current room.

``goto <DIRECTORY>``
- Alias for cd, but with more flavor.

``attack <TARGET> <ACTION(S)>``
- How to earn experience.  Examples:
-- attack test.txt vim
-- attack target.txt cp destination.txt

``cast <ACTION>``
- Earn experience for commands that don't require a target
-- cast ls -l

## Todo
* [ ] General cleanup and documentation
* [ ] A way to customize room descriptions (i.e. ~/ = "You are standing in your home.  It is warm and cozy here, thanks to the plush rug and crackling fireplace.")
* [ ] More dynamic attacking?  Automatic attacking when using specific commands, i.e. vim test.txt automatically gives xp?
* [ ] User configuration?
* [ ] Incorprate HP?  Gold?  Why?  Whatfore?
