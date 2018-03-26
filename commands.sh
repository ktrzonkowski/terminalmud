function _pickRandom {
  input=("$@")
  echo ${input[$RANDOM % ${#input[@]} ]}
}

function _createCharacter {
  touch $TM_CHARSHEET
  echo "export TM_CHAR_LEVEL=1" > $TM_CHARSHEET
  echo "export TM_CHAR_HP=10" >> $TM_CHARSHEET
  echo "export TM_CHAR_EXP=0" >> $TM_CHARSHEET
}

function _updateCharacter {
  if [ $TM_CHAR_EXP -ge $((TM_CHAR_LEVEL * 150)) ]; then
    printf "*You've leveled up!*\n";
    TM_CHAR_EXP=$((TM_CHAR_EXP-(TM_CHAR_LEVEL * 150)))
    TM_CHAR_LEVEL=$((TM_CHAR_LEVEL+1))
  fi

  echo "export TM_CHAR_LEVEL=${TM_CHAR_LEVEL}" > $TM_CHARSHEET
  echo "export TM_CHAR_HP=${TM_CHAR_HP}" >> $TM_CHARSHEET
  echo "export TM_CHAR_EXP=${TM_CHAR_EXP}" >> $TM_CHARSHEET
}

function _updatePrompt {
  export PS1="\n<${YELLOW}LVL${BRIGHT_YELLOW}${TM_CHAR_LEVEL} ${GREEN}EXP${BRIGHT_GREEN}${TM_CHAR_EXP}${NO_COLOR}> "
}

function look {
  target=${1:0:3}
  directions=("north" "south" "east" "west" "northeast" "southeast" "southwest" "northwest")
  actions=("standing" "sitting" "resting" "dancing" "thinking" "singing" "hiding")

  if [ "$target" = "fil" ] || [ "$target" = "dir" ]; then
    for entry in ./*; do
      display=${entry:2}
      if [ "$target" = "fil" ] && [ -f "$entry" ]; then
        printf "${MAGENTA}${display}${NO_COLOR} is $(_pickRandom ${actions[@]}) here.\n";
      elif [ "$target" = "dir" ] && [ -d "$entry" ]; then
        printf "${CYAN}${display}${NO_COLOR} lies to the $(_pickRandom ${directions[@]}).\n";
      fi
    done
  else
    printf "You are standing in ${PWD}.\n"

    tmp=$(find . -type d -maxdepth 1 | wc -l)
    printf "${tmp} directories are here.\n"

    tmp=$(find . -type f -maxdepth 1 | wc -l)
    printf "${tmp} files are here.\n"
  fi
}

function goto {
  cd $1
}

function attack {
  if [ ! $2 ]; then
    read -p "With what would you like to attack ${1}? " 2
  fi

  if [ -n "$(type -t $2)" ]; then
    printf "You attack ${1} with your ${2}.\n";
    tmp=$((RANDOM%25+6))
    printf "You earn ${tmp} experience!\n";
    export TM_CHAR_EXP=$((TM_CHAR_EXP+$tmp))
    _updateCharacter $TM_CHARSHEET
    sleep 1
    $2 $1 ${@:3}
  else
    printf "You don't know how to '${2}'.\n"
  fi
}

PROMPT_COMMAND=_updatePrompt
