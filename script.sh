source ~/terminalmud/colors.sh
source ~/terminalmud/commands.sh

printf "Welcome to terminalMUD.\n"

while true; do
  read -p "Who are you? " name
  export TM_CHAR_NAME=$name
  break;
done

export TM_CHARSHEET=~/terminalmud/characters/$TM_CHAR_NAME.sh
if [ ! -f $TM_CHARSHEET ]; then
  _createCharacter $TM_CHARSHEET
fi

source $TM_CHARSHEET

printf "\n"

look
