# vim: ft=sh

# This is originally based on agnoster's Theme for ZSH
#   https://gist.github.com/3712874
# and further based on a bash conversion by Kenny Root
#   https://gist.github.com/kruton/8345450

CURRENT_BG='NONE'
# SEGMENT_SEPARATOR='⮀'
SEGMENT_SEPARATOR=$'\ue0b0'

Color_Off="\[\033[0m\]"       # Text Reset
Color_Red="\[\033[0;31m\]"          # Red

# Colors variables {{{

# Reset

# Regular Colors
Black="\[\033[0;30m\]"        # Black
Green="\[\033[0;32m\]"        # Green
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
Purple="\[\033[0;35m\]"       # Purple
Cyan="\[\033[0;36m\]"         # Cyan
White="\[\033[0;37m\]"        # White

# Bold
BBlack="\[\033[1;30m\]"       # Black
BRed="\[\033[1;31m\]"         # Red
BGreen="\[\033[1;32m\]"       # Green
BYellow="\[\033[1;33m\]"      # Yellow
BBlue="\[\033[1;34m\]"        # Blue
BPurple="\[\033[1;35m\]"      # Purple
BCyan="\[\033[1;36m\]"        # Cyan
BWhite="\[\033[1;37m\]"       # White

# Underline
UBlack="\[\033[4;30m\]"       # Black
URed="\[\033[4;31m\]"         # Red
UGreen="\[\033[4;32m\]"       # Green
UYellow="\[\033[4;33m\]"      # Yellow
UBlue="\[\033[4;34m\]"        # Blue
UPurple="\[\033[4;35m\]"      # Purple
UCyan="\[\033[4;36m\]"        # Cyan
UWhite="\[\033[4;37m\]"       # White

# Background
On_Black="\[\033[40m\]"       # Black
On_Red="\[\033[41m\]"         # Red
On_Green="\[\033[42m\]"       # Green
On_Yellow="\[\033[43m\]"      # Yellow
On_Blue="\[\033[44m\]"        # Blue
On_Purple="\[\033[45m\]"      # Purple
On_Cyan="\[\033[46m\]"        # Cyan
On_White="\[\033[47m\]"       # White

# High Intensty
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow
IBlue="\[\033[0;94m\]"        # Blue
IPurple="\[\033[0;95m\]"      # Purple
ICyan="\[\033[0;96m\]"        # Cyan
IWhite="\[\033[0;97m\]"       # White

# Bold High Intensty
BIBlack="\[\033[1;90m\]"      # Black
BIRed="\[\033[1;91m\]"        # Red
BIGreen="\[\033[1;92m\]"      # Green
BIYellow="\[\033[1;93m\]"     # Yellow
BIBlue="\[\033[1;94m\]"       # Blue
BIPurple="\[\033[1;95m\]"     # Purple
BICyan="\[\033[1;96m\]"       # Cyan
BIWhite="\[\033[1;97m\]"      # White

# High Intensty backgrounds
On_IBlack="\[\033[0;100m\]"   # Black
On_IRed="\[\033[0;101m\]"     # Red
On_IGreen="\[\033[0;102m\]"   # Green
On_IYellow="\[\033[0;103m\]"  # Yellow
On_IBlue="\[\033[0;104m\]"    # Blue
On_IPurple="\[\033[10;95m\]"  # Purple
On_ICyan="\[\033[0;106m\]"    # Cyan
On_IWhite="\[\033[0;107m\]"   # White

# }}}

text_effect() {
  case "$1" in
    reset)     echo 0;;
    bold)      echo 1;;
    underline) echo 4;;
  esac
}

fg_color() {
  case "$1" in
    black)   echo 30;;
    red)     echo 31;;
    green)   echo 32;;
    yellow)  echo 33;;
    blue)    echo 34;;
    magenta) echo 35;;
    cyan)    echo 36;;
    white)   echo 37;;
  esac
}

bg_color() {
  case "$1" in
    black)   echo 40;;
    red)     echo 41;;
    green)   echo 42;;
    yellow)  echo 43;;
    blue)    echo 44;;
    magenta) echo 45;;
    cyan)    echo 46;;
    white)   echo 47;;
  esac;
}

ansi() {
  local seq
  declare -a codes=("${!1}")

  seq=""
  for ((i = 0; i < ${#codes[@]}; i++)); do
    if [[ -n $seq ]]; then
      seq="${seq};"
    fi
    seq="${seq}${codes[$i]}"
  done
  echo -ne '\[\033['${seq}'m\]'
}

ansi_single() {
  echo -ne '\[\033['$1'm\]'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  declare -a codes
  if [[ -z $1 || ( -z $2 && $2 != default ) ]]; then
    codes=("${codes[@]}" $(text_effect reset))
  fi
  if [[ -n $1 ]]; then
    bg=$(bg_color $1)
    codes=("${codes[@]}" $bg)
  fi
  if [[ -n $2 ]]; then
    fg=$(fg_color $2)
    codes=("${codes[@]}" $fg)
  fi

  if [[ $CURRENT_BG != NONE && $1 != $CURRENT_BG ]]; then
    declare -a intermediate=($(fg_color $CURRENT_BG) $(bg_color $1))
    echo -ne " $(ansi intermediate[@])$SEGMENT_SEPARATOR$(ansi codes[@]) "
  else
    echo -ne "$(ansi codes[@]) "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    declare -a codes=($(text_effect reset) $(fg_color $CURRENT_BG))
    echo -ne " $(ansi codes[@])$SEGMENT_SEPARATOR"
  fi
  declare -a reset=($(text_effect reset))
  echo -ne " $(ansi reset[@])"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ $user != $DEFAULT_USER || -n $SSH_CLIENT ]]; then
    prompt_segment black default "$user@\h"
  fi
}

git_status_dirty() {
  dirty=$(git status -s 2> /dev/null | tail -n 1)
  [[ -n $dirty ]] && echo "*"
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ZSH_THEME_GIT_PROMPT_DIRTY='±'
    dirty=$(git_status_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green black
    fi
    echo -n "${ref/refs\/heads\//⭠ }$dirty"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment blue black '\w'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="(ansi_single $(fg_color red))✘"
  [[ $UID -eq 0 ]] && symbols+="$(ansi_single $(fg_color yellow))⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="$(ansi_single $(fg_color cyan))⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

# PS1="$(bColor_Off$(build_prompt)"
PS1="$(ansi_single $(text_effect reset))$(build_prompt)"
