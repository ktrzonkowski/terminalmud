
function _pickRandom {
  input=("${!1}")
  echo ${input["$[RANDOM % ${#input[@]}]"]}
}

function _createCharacter {
  echo "export TM_CHAR_LEVEL=1" > "$TM_CHARSHEET"
  echo "export TM_CHAR_HP=10" >> "$TM_CHARSHEET"
  echo "export TM_CHAR_EXP=0" >> "$TM_CHARSHEET"
  echo "export TM_CHAR_INV=" >> "$TM_CHARSHEET"
}

function _updateCharacter {
  if [ $TM_CHAR_EXP -ge $((TM_CHAR_LEVEL * 150)) ]; then
    printf "*You've leveled up!*\n";
    TM_CHAR_EXP=$((TM_CHAR_EXP-(TM_CHAR_LEVEL * 150)))
    TM_CHAR_LEVEL=$((TM_CHAR_LEVEL+1))
  fi

  echo "export TM_CHAR_LEVEL=${TM_CHAR_LEVEL}" > "$TM_CHARSHEET"
  echo "export TM_CHAR_HP=${TM_CHAR_HP}" >> "$TM_CHARSHEET"
  echo "export TM_CHAR_EXP=${TM_CHAR_EXP}" >> "$TM_CHARSHEET"
  echo "export TM_CHAR_INV=("$(printf '%s ' "${TM_CHAR_INV[@]}")")" >> "$TM_CHARSHEET"
}

function _earnRewards {
  tmp=$((RANDOM%25+6))
  printf "You earn ${tmp} experience!\n";
  export TM_CHAR_EXP=$((TM_CHAR_EXP+$tmp))

  if [ $(( ( RANDOM % 2 ) + 1 )) -eq 1 ]; then
    if [ -z "$TM_CHAR_INV" ]; then
      export TM_CHAR_INV=()
    fi

    items=($(ls ~/terminalmud/items |sort -R))

    for item in "${items[@]}"; do
      item="${item%.*}"
      doNotHave=1

      for have in "${TM_CHAR_INV}"; do
        if [ "$have" = "$item" ]; then
          doNotHave=0
          break
        fi
      done

      if [ $doNotHave -eq 1 ]; then
         printf "You have found: $(_fetchItem $item name)!\n"
         TM_CHAR_INV[${#TM_CHAR_INV[@]}]=${item}
         break
      fi
    done
  fi

  _updateCharacter
}

function _fetchItem {
  item=$1
  field=$2
  path=~/terminalmud/items/${item}.txt

  if [ -f "$path" ]; then
    chmod +x "$path"
    case "${field}" in
      "name") echo $(sed '1q;d' "$path");;
      "desc"|"description") echo $(sed '2q;d' "$path");;
      "keywords") echo $(sed '3q;d' "$path");;
    esac
  fi
}

function _updatePrompt {
  source "$TM_CHARSHEET"
  export PS1="\n<${YELLOW}LVL${BRIGHT_YELLOW}${TM_CHAR_LEVEL} ${GREEN}EXP${BRIGHT_GREEN}${TM_CHAR_EXP}${NO_COLOR}> "
}

function look {
  target=${1:0:3}
  directions=("north" "south" "east" "west" "northeast" "southeast" "southwest" "northwest")
  actions=("standing" "sitting" "resting" "dancing" "thinking" "singing" "hiding from you" "hoping you don't notice it" "running around" "creating trouble")

  if [ "$target" = "fil" ] || [ "$target" = "dir" ]; then
    for entry in `ls -A`; do
      display=${entry}
      if [ "$target" = "fil" ] && [ -f "$entry" ]; then
        printf "${MAGENTA}${display}${NO_COLOR} is $(_pickRandom "actions[@]") here.\n";
      elif [ "$target" = "dir" ] && [ -d "$entry" ]; then
        printf "${CYAN}${display}${NO_COLOR} lies to the $(_pickRandom "directions[@]").\n";
      fi
    done
  else
    printf "You are standing in ${PWD}.\n"

    tmp=$(find . -type d -maxdepth 1 -mindepth 1 | wc -l)
    printf "${tmp} directories are here.\n"

    tmp=$(find . -type f -maxdepth 1 | wc -l)
    printf "${tmp} files are here.\n"
  fi
}

function goto {
  cd $1
  look
}

function attack {
  source "$TM_CHARSHEET"
  target=$1
  action=$2

  if [ ! $action ]; then
    read -p "With what would you like to attack ${target}? " action
  fi

  if [ -n "$(type -t $action)" ]; then
    printf "You attack ${target} with your ${action}.\n";
    _earnRewards
    sleep 1
    $action $target ${@:3}
  else
    printf "You don't know how to '${action}'.\n"
  fi
}

function cast {
  source "$TM_CHARSHEET"
  spell=$1

  if [ ! $spell ]; then
    read -p "What spell would you like to cast? " spell
  fi

  if [ -n "$(type -t $spell)" ]; then
    printf "You recite the incantation to cast ${spell}.\n";
    _earnRewards
    sleep 1
    ${@:1}
  else
    printf "You don't know how to cast '${spell}'.\n"
  fi
}

function inv {
  source "$TM_CHARSHEET"
  printf "Your inventory:\n"

  for item in "${TM_CHAR_INV[@]}"; do
    printf "  $(_fetchItem $item name)\n";
  done
}

function inspect {
  search=$1
  found=0

  for item in "${TM_CHAR_INV[@]}"; do
    name=$(_fetchItem $item name)
    keywords=($(_fetchItem $item keywords))

    if [ "$name" = "$search" ]; then
      printf "$(_fetchItem $item desc)\n"
      found=1
      break
    fi

    case "${keywords[@]}" in *"$search"*)
      printf "$(_fetchItem $item desc)\n"
      found=1
      break
    esac
  done

  if [ $found -eq 0 ]; then
    printf "You don't see a '${search}' in your inventory."
  fi
}

PROMPT_COMMAND=_updatePrompt
