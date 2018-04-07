# vim: ft=sh fdm=marker foldlevel=0
###############################################################################
#
# This is originally based on agnoster's Theme for ZSH [1], upon which Kenny
# Root [2] did some modifications to adapt it to bash. Although this is a
# somewhat heavily modified version...
#
# [1] https://gist.github.com/3712874
# [2] https://gist.github.com/kruton/8345450
#
#------------------------------------------------------------------------------
# TODO: Allow disabling git stuff (through bash-it options?)
#
#---------------------------------------------------------------------------------------------------
# Bencmarking

# Not pretty, but maybe useful for benchmarking solutions
# create benchmark:
# for i in `seq 1 100`; do start=$(date +%s%N); __agnomod_prompt_command > /dev/null; end=$(date +%s%N); echo ; echo $((end-start)) >> bench1; done
# calculate average:
# cat bench1 | perl -n -e '$count++; $sum+=$_; $avg=$sum/$count; print qq/$avg\n/;' | tail -n 1
#
#------------------------------------------------------------------------------
# Git functionality uses /usr/lib/git-core/git-sh-prompt

GIT_PS1_FILE_LOADED=false
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS=true

__agnomod_load_git_prompt() {
    local git_ps1_file="/usr/lib/git-core/git-sh-prompt"
    if [ "$(declare -f __git_ps1 > /dev/null; echo $?)" = 1 ]; then
        source "${git_ps1_file}"
        if [ "$(declare -f __git_ps1 > /dev/null; echo $?)" = 1 ]; then
            echo "Failed to load __git_ps1 from ${git_ps1_file}"
            return 0
        else
            GIT_PS1_FILE_LOADED=true
        fi
    else
        GIT_PS1_FILE_LOADED=true
    fi
}

__agnomod_git_prompt() {
    local path="${1}"
    local s_repo='\ue0a0' # 
    local unsta='\u25cb' # ○
    local uncom='\u25cf' # ●
    local untra='\u25cc' # ◌
    local s_ahead='\u25b8' # ▸
    local s_behind='\u25c2' # ◂
    local s_even='' # '\u25b4' # ▴

    [ -n "${path}" ] && cd "${path}"

    if ! $GIT_PS1_FILE_LOADED; then
	    return 0
    fi

    local status=$(__git_ps1)

    status=${status:2:$((${#status} - 3))}

    # Add space before status symbols
    if [[ ${status} =~ ^(.*[[:alnum:]])(<|>|<>)$ ]]; then
        status="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
    fi

    if [ -n "${status}" ]; then
        if $use_symbols; then
            status=${status/\*/${unsta}}
            status=${status/\+/${uncom}}
            status=${status/\%/${untra}}

            status=${status/\>/${s_ahead}}
            status=${status/\</${s_behind}}
            status=${status/\=/${s_even}}
        else
            s_repo=' '
        fi

        echo -ne "${status}"
    fi

    [ -n "${path}" ] && cd - > /dev/null
}

__agnomod_prompt_command() {
    RETVAL=$?
    local use_symbols=false
    local __agn_CURRENT_BG='NONE' # default to no background

    # Check that the characters were displayed and replace with ascii if needed

    local separator=$(echo -ne '\ue0b0') # 

    if [ ${#separator} = 1 ]; then
        use_symbols=true
    else
        separator=' '
    fi

    # Define all the functions that will be needed.
    # Color functions {{{
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
        declare -a thecodes=("${!1}")

        seq=""
        for ((i = 0; i < ${#thecodes[@]}; i++)); do
            if [[ -n $seq ]]; then
                seq="${seq};"
            fi
            seq="${seq}${thecodes[$i]}"
        done
        echo -ne "\[\033[${seq}m\]"
    }

    ansi_single() {
        echo -ne "\[\033[${1}m\]"
    }

    #}}}
    __prompt_segment() { #{{{
        # Begin a segment. Takes two arguments, background and foreground. Both can be omitted,
        # rendering default background/foreground.
        local bg fg

        declare -a codes=($(fg_color $1) $(bg_color $2))

        if [[ -z $1 || ( -z $2 && $2 != default ) ]]; then
            codes=("${codes[@]}" $(text_effect reset))
        fi

        if [[ -n $2 ]]; then
            fg=$(fg_color $2)
            codes=("${codes[@]}" $fg)
        fi

        if [ -n "$1" ]; then
            bg=$(bg_color $1)
            codes=("${codes[@]}" $bg)
        fi

        if [[ $__agn_CURRENT_BG != NONE && $1 != $__agn_CURRENT_BG ]]; then
            declare -a intermediate=($(fg_color $__agn_CURRENT_BG) $(bg_color $1))
            echo -ne " $(ansi intermediate[@])${separator}"
        fi
        echo -ne "$(ansi codes[@])"

        [ -n "${3}" ] && echo -ne "$3"
        __agn_CURRENT_BG=$1
    } #}}}
    __prompt_dir() { # {{{

        __prompt_segment blue black
        pwd | sed "s|^$HOME|~|" | awk -F '/' '
        {
            i=1;
            while (i < NF) {
                if (length($i) > 4) {
                    printf "%s../", substr($i, 1, 2);
                }
            else {
                printf "%s/", $i;
            }
            ++i;
        }
        printf "%s", $i; }'
    } # }}}
    __prompt_context() { #{{{
        local user=`whoami`
        local context=""
        local context_bg="cyan"

        [[ -n $SSH_CLIENT ]] && context="$user@$(hostname)"
        if [[ $(sudo -n uptime 2>&1) = *load* ]]; then
            context="!${context}!"
            context_bg="red"
        fi

        [[ -n "$context" ]] && __prompt_segment $context_bg black "$context"
    } #}}}
    __prompt_status() { #{{{
        local symbols=()
        [[ $RETVAL -ne 0 ]] && symbols+="$(ansi_single $(fg_color red))✘"
        [[ $UID -eq 0 ]] && symbols+="$(ansi_single $(fg_color yellow))⚡"
        [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="$(ansi_single $(fg_color cyan))⚙"
        [[ -n "$symbols" ]] && __prompt_segment black default " $symbols "
    } #}}}
    __prompt_git() { #{{{
        local status=$(__agnomod_git_prompt)

        if [ -n "${status}" ]; then
            if [[ "${status}" =~ [[:space:]] ]]; then
                __prompt_segment magenta black
            else
                __prompt_segment green black
            fi

            echo -ne "${status}"
        fi
    } #}}}

    #DEFAULT_USER=''
    echo -ne "\[\033[0m\]"

    # Build the different components
    __prompt_status
    __prompt_context
    __prompt_dir
    __prompt_git

    # Close of the last segment
    if [ -n "${__agn_CURRENT_BG}" ]; then
        declare -a codes=($(text_effect reset) $(fg_color $__agn_CURRENT_BG))
        echo -ne " $(ansi codes[@])${separator}"
    fi

    # Unset bg variable
    unset __agn_CURRENT_BG
    echo -ne "\[\033[0m\]"
}

__agnomod_load_git_prompt

if [[ -n "${BASH_IT}" ]]; then
    # This doesn't work
    # safe_append_prompt_command __agnomod_prompt_command
    # Is there a reason to do anything more fancy, maybe not?
    PROMPT_COMMAND='PS1=$(__agnomod_prompt_command)'
else
    PROMPT_COMMAND='PS1=$(__agnomod_prompt_command)'
fi
