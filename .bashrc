#!/bin/env bash
# AUTHOR: Chris Marsh
# Github: https://github.com/chris-marsh

if [ "$(echo $TERM)" == "linux" ]; then
	
	# PureLine - A Pure Bash Powerline PS1 Command Prompt 
	
	# -----------------------------------------------------------------------------
	# returns a string with the powerline symbol for a section end
	# arg: $1 is foreground color of the next section
	# arg: $2 is background color of the next section
	function section_end {
		if [ "$__last_color" == "$2" ]; then
			# Section colors are the same, use a foreground separator
			local end_char="${symbols[soft_separator]}"
			local fg=$1
		else
			# section colors are different, use a background separator
			local end_char="${symbols[hard_separator]}"
			local fg=$__last_color
		fi
		if [ -n "$__last_color" ]; then
			echo "${colors[$fg]}${colors[On_$2]}$end_char"
		fi
	}
	
	# -----------------------------------------------------------------------------
	# returns a string with background and foreground colours set
	# arg: $1 foreground color
	# arg: $2 background color
	# arg: $3 content
	function section_content {
		echo "${colors[$1]}${colors[On_$2]}$3"
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: current time
	# arg: $1 foreground color
	# arg: $2 background color
	# optional arg: $3 - true/false to show seconds
	function time_module {
		local bg_color=$1
		local fg_color=$2
		if [ "$3" = true ]; then
			local content="\t"
		else
			local content="\A"
		fi
		PS1+=$(section_end $fg_color $bg_color)
		PS1+=$(section_content $fg_color $bg_color " $content ")
		__last_color=$bg_color
	}
	
	#------------------------------------------------------------------------------
	# append to prompt: user@host or user or root@host
	# arg: $1 foreground color (red if root)
	# arg: $2 background color
	# optional arg: $3 - true/false to show the hostname
	function user_module {
		local bg_color=$1
		local fg_color=$2
		# Show host if true or when user is remote/root
		if [[ "$3" = true || "${SSH_CLIENT}" || "${SSH_TTY}" || ${EUID} = 0 ]]; then
			local content="\u@\h"
		else
			local content="\u"
		fi
		PS1+=$(section_end $fg_color $bg_color)
		PS1+=$(section_content $fg_color $bg_color " $content ")
		__last_color=$bg_color
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: user@host
	# arg: $1 foreground color
	# arg: $2 background color
	# optional arg: $3 - true/false to show the username
	function host_module {
		local bg_color=$1
		local fg_color=$2
		if [ "$3" = true ]; then
			local content="\u@\h"
		else
			local content="\h"
		fi
		PS1+=$(section_end $fg_color $bg_color)
		PS1+=$(section_content $fg_color $bg_color " $content ")
		__last_color=$bg_color
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: current directory
	# arg: $1 foreground color
	# arg; $2 background color
	# optional arg: $3 - 0 — fullpath, 1 — current dir, [x] — trim to x number of
	# directories
	function path_module {
		local bg_color=$1
		local fg_color=$2
		local content="\w"
		if [ $3 -eq 1 ]; then
			local content="\W"
		elif [ $3 -gt 1 ]; then
			PROMPT_DIRTRIM=$3
		fi
		PS1+=$(section_end $fg_color $bg_color)
		PS1+=$(section_content $fg_color $bg_color " $content ")
		__last_color=$bg_color
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: the number of background jobs running
	# arg: $1 foreground color
	# arg; $2 background color
	function jobs_module {
		local bg_color=$1
		local fg_color=$2
		local number_jobs=$(jobs -p | wc -l)
		if [ ! "$number_jobs" -eq 0 ]; then
			PS1+=$(section_end $fg_color $bg_color)
			PS1+=$(section_content $fg_color $bg_color " ${symbols[enter]} $number_jobs ")
			__last_color=$bg_color
		fi
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: indicator is the current directory is ready-only
	# arg: $1 foreground color
	# arg; $2 background color
	function read_only_module {
		local bg_color=$1
		local fg_color=$2
		if [ ! -w "$PWD" ]; then
			PS1+=$(section_end $fg_color $bg_color)
			PS1+=$(section_content $fg_color $bg_color " ${symbols[lock]} ")
			__last_color=$bg_color
		fi
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: git branch with indictors for;
	#     number of; modified files, staged files and conflicts
	# arg: $1 foreground color
	# arg; $2 background color
	# optional arg: $3 - foreground color used if the working directory is dirty
	function git_module {
		local git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
		if [ -n "$git_branch" ]; then
			local bg_color=$1
			local fg_color=$2
			local content="${symbols[git]} $git_branch$git"
	
			if [ -n "$3" -a -n "$(git status --porcelain)" ]; then
				fg_color=$3
			fi
	
			local number_modified=$(git diff --name-only --diff-filter=M 2> /dev/null | wc -l )
			if [ ! "$number_modified" -eq "0" ]; then
				content+=" ${symbols[soft_separator]} ${symbols[plus]} $number_modified"
			fi
	
			local number_staged=$(git diff --staged --name-only --diff-filter=AM 2> /dev/null | wc -l)
			if [ ! "$number_staged" -eq "0" ]; then
				content+=" ${symbols[soft_separator]} ${symbols[tick]} $number_staged"
			fi
	
			local number_conflicts=$(git diff --name-only --diff-filter=U 2> /dev/null | wc -l)
			if [ ! "$number_conflicts" -eq "0" ]; then
				content+=" ${symbols[soft_separator]} ${symbols[cross]} $number_conflicts"
			fi
	
			local number_untracked=$(git ls-files --other --exclude-standard | wc -l)
			if [ ! "$number_untracked" -eq "0" ]; then
				content+=" ${symbols[soft_separator]} ${symbols[untracked]} $number_untracked"
			fi
	
			PS1+=$(section_end $fg_color $bg_color)
			PS1+=$(section_content $fg_color $bg_color " $content ")
			__last_color=$bg_color
		fi
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: number of git stash
	# arg: $1 foreground color
	# arg; $2 background color
	function git_stash_module {
		local number_stash=$(git stash list 2>/dev/null | wc -l)
		if [ ! "$number_stash" -eq 0 ]; then
			local bg_color=$1
			local fg_color=$2
			local content="${symbols[stash]} $number_stash"
			PS1+=$(section_end $fg_color $bg_color)
			PS1+=$(section_content $fg_color $bg_color " $content ")
			__last_color=$bg_color
		fi
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: repository status against upstream
	# arg: $1 foreground color
	# arg; $2 background color
	function git_ahead_behind_module {
	    local number_behind_ahead=$(git rev-list --count --left-right '@{upstream}...HEAD' 2>/dev/null)
	    local number_ahead="${number_behind_ahead#*	}"
	    local number_behind="${number_behind_ahead%	*}"
	    if [ ! "0$number_ahead" -eq 0 -o ! "0$number_behind" -eq 0 ]; then
			local bg_color=$1
			local fg_color=$2
	        local content=""
	        if [ ! "$number_ahead" -eq 0 ]; then
	            content+=" ${symbols[ahead]} $number_ahead"
	        fi
	        if [ ! "$number_behind" -eq 0 ]; then
	            content+=" ${symbols[behind]} $number_behind"
	        fi
			PS1+=$(section_end $fg_color $bg_color)
			PS1+=$(section_content $fg_color $bg_color "$content ")
			__last_color=$bg_color
		fi
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: python virtual environment name
	# arg: $1 foreground color
	# arg; $2 background color
	function virtual_env_module {
		if [ -n "$VIRTUAL_ENV" ]; then
			local venv="${VIRTUAL_ENV##*/}"
			local bg_color=$1
			local fg_color=$2
			local content=" ${symbols[python]} $venv"
			PS1+=$(section_end $fg_color $bg_color)
			PS1+=$(section_content $fg_color $bg_color "$content ")
			__last_color=$bg_color
		fi
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: indicator for battery level
	# arg: $1 foreground color
	# arg; $2 background color
	function battery_module {
		local bg_color=$1
		local fg_color=$2
		local batt_dir
		local content
		local batt_dir="/sys/class/power_supply/BAT1"
	
		local cap=$(<"$batt_dir/capacity")
		local status=$(<"$batt_dir/status")
	
		if [ "$status" == "Discharging" ]; then
			content="${symbols[battery_discharging]} "
		else
			content="${symbols[battery_charging]}"
		fi
		content="$content$cap%"
	
		PS1+=$(section_end $fg_color $bg_color)
		PS1+=$(section_content $fg_color $bg_color " $content ")
		__last_color=$bg_color
	}
	
	
	# -----------------------------------------------------------------------------
	# append to prompt: append a '$' prompt with optional return code for previous command
	# arg: $1 foreground color
	# arg; $2 background color
	function prompt_module {
		# if we're root then use '#' as the prompt-string
		if [ ${EUID} -eq 0 ]; then
			local prompt_char="#"
		else
			local prompt_char="$"
		fi
		local bg_color=$1
		local fg_color=$2
		local content=" $prompt_char "
		PS1+=$(section_end $fg_color $bg_color)
		PS1+=$(section_content $fg_color $bg_color "$content")
		__last_color=$bg_color
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: append a '$' prompt with optional return code for previous command
	# arg: $1 foreground color
	# arg; $2 background color
	function return_code_module {
		if [ ! "$__return_code" -eq 0 ]; then
			local bg_color=$1
			local fg_color=$2
			local content=" ${symbols[flag]} $__return_code "
			PS1+=$(section_end $fg_color $bg_color)
			PS1+=$(section_content $fg_color $bg_color "$content")
			__last_color=$bg_color
		fi
	}
	
	# -----------------------------------------------------------------------------
	# append to prompt: end the current promptline and start a newline
	function newline_module {
		if [ -n "$__last_color" ]; then
			PS1+=$(section_end $__last_color 'Default')
		fi
		PS1+="\n"
		unset __last_color
	}
	
	# -----------------------------------------------------------------------------
	function pureline_ps1 {
		__return_code=$?      # save the return code
		PS1=""
	
		# load the modules
		for module in "${!pureline_modules[@]}"; do
			${pureline_modules[$module]}
		done
	
		# final end point
		if [ -n "$__last_color" ]; then
			PS1+=$(section_end $__last_color 'Default')
		else
			PS1="$"
		fi
	
		# cleanup
		PS1+="${colors[Color_Off]} "
		unset __last_color
		unset __return_code
	}
	
	# -----------------------------------------------------------------------------
	
	# define the basic color set
	declare -A colors=(
	[Color_Off]='\[\e[0m\]'       # Text Reset
	# Foreground
	[Default]='\[\e[0;39m\]'      # Default
	[Black]='\[\e[0;30m\]'        # Black
	[Red]='\[\e[0;31m\]'          # Red
	[Green]='\[\e[0;32m\]'        # Green
	[Yellow]='\[\e[0;33m\]'       # Yellow
	[Blue]='\[\e[0;34m\]'         # Blue
	[Purple]='\[\e[0;35m\]'       # Purple
	[Cyan]='\[\e[0;36m\]'         # Cyan
	[White]='\[\e[0;37m\]'        # White
	# Background
	[On_Default]='\[\e[49m\]'     # Default
	[On_Black]='\[\e[40m\]'       # Black
	[On_Red]='\[\e[41m\]'         # Red
	[On_Green]='\[\e[42m\]'       # Green
	[On_Yellow]='\[\e[43m\]'      # Yellow
	[On_Blue]='\[\e[44m\]'        # Blue
	[On_Purple]='\[\e[45m\]'      # Purple
	[On_Cyan]='\[\e[46m\]'        # Cyan
	[On_White]='\[\e[47m\]'       # White
	)
	
	# define symbols
	declare -A symbols=(
	[hard_separator]=""
	[soft_separator]=""
	[git]=""
	[lock]=""
	[flag]="⚑"
	[plus]="✚"
	[tick]="✔"
	[cross]="✘"
	[enter]="⏎"
	[python]="λ"
	[battery_charging]="⚡"
	[battery_discharging]="▮"
	[untracked]="U"
	[stash]="🐿"
	[ahead]="+"
	[behind]="-"
	)
	
	# check if an argument has been given for a config file
	if [ -f "$1" ]; then
		source $1
	else
		# define default modules to load
		declare -a pureline_modules=(
		'path_module        Blue        White       0'
		'time_module		Green		Black		false'
		'battery_module		Yellow		Black		false'
		'git_module			Cyan		Black		false'
		'read_only_module   Red         White'
		)
	fi
	
	# dynamically set the  PS1
	[[ ! ${PROMPT_COMMAND} =~ 'pureline_ps1;' ]] && PROMPT_COMMAND="pureline_ps1; $PROMPT_COMMAND" || true
else
    ## AUTHOR: Rio
    ## Github: https://github.com/riobard
	## Uncomment to disable git info
	#POWERLINE_GIT=0
	
	__powerline() {
	    # Colorscheme
	    readonly RESET='\[\033[m\]'
	    readonly COLOR_CWD='\[\033[1;37m\]' # white
	    readonly COLOR_GIT='\[\033[1;36m\]' # cyan
	    readonly COLOR_GIT_MODIFIED='\[\033[1;32m\]' #green
	    readonly COLOR_SUCCESS='\[\033[1;37m\]' # white
	    readonly COLOR_FAILURE='\[\033[1;31m\]' # red
	
	    readonly SYMBOL_GIT_BRANCH=' '
	    readonly SYMBOL_GIT_MODIFIED='  '
	    readonly SYMBOL_GIT_PUSH='  '
	    readonly SYMBOL_GIT_PULL='  '
	
	    if [[ -z "$PS_SYMBOL" ]]; then
	      case "$(uname)" in
	          Darwin)   PS_SYMBOL='';;
	          Linux)    PS_SYMBOL='$';;
	          *)        PS_SYMBOL='%';;
	      esac
	    fi
	
	    __git_info() { 
	        [[ $POWERLINE_GIT = 0 ]] && return # disabled
	        hash git 2>/dev/null || return # git not found
	        local git_eng="env LANG=C git"   # force git output in English to make our work easier
	
	        # get current branch name
	        local ref=$($git_eng symbolic-ref --short HEAD 2>/dev/null)
	
	        if [[ -n "$ref" ]]; then
	            # prepend branch symbol
	            ref=$SYMBOL_GIT_BRANCH$ref
	        else
	            # get tag name or short unique hash
	            ref=$($git_eng describe --tags --always 2>/dev/null)
	        fi
	
	        [[ -n "$ref" ]] || return  # not a git repo
	
	        local marks
	
	        # scan first two lines of output from `git status`
	        while IFS= read -r line; do
	            if [[ $line =~ ^## ]]; then # header line
	                [[ $line =~ ahead\ ([0-9]+) ]] && marks+=" $SYMBOL_GIT_PUSH${BASH_REMATCH[1]}"
	                [[ $line =~ behind\ ([0-9]+) ]] && marks+=" $SYMBOL_GIT_PULL${BASH_REMATCH[1]}"
	            else # branch is modified if output contains more lines after the header line
	                marks="$SYMBOL_GIT_MODIFIED$marks"
	                break
	            fi
	        done < <($git_eng status --porcelain --branch 2>/dev/null)  # note the space between the two <
	
	        # print the git branch segment without a trailing newline
	        printf " $COLOR_GIT$ref$COLOR_GIT_MODIFIED$marks"
	    }
	
	    ps1() {
	        # Check the exit code of the previous command and display different
	        # colors in the prompt accordingly. 
	        if [ $? -eq 0 ]; then
	            local symbol="$COLOR_SUCCESS $PS_SYMBOL $RESET"
	        else
	            local symbol="$COLOR_FAILURE $PS_SYMBOL $RESET"
	        fi
	
	        local cwd="$COLOR_CWD\w$RESET"
	        # Bash by default expands the content of PS1 unless promptvars is disabled.
	        # We must use another layer of reference to prevent expanding any user
	        # provided strings, which would cause security issues.
	        # POC: https://github.com/njhartwell/pw3nage
	        # Related fix in git-bash: https://github.com/git/git/blob/9d77b0405ce6b471cb5ce3a904368fc25e55643d/contrib/completion/git-prompt.sh#L324
	        if shopt -q promptvars; then
	            __powerline_git_info="$(__git_info)"
	            local git="${__powerline_git_info}$RESET"
	        else
	            # promptvars is disabled. Avoid creating unnecessary env var.
	            local git="$(__git_info)$RESET"
	        fi
	
	        PS1="$cwd$git$symbol"
	    }
	
	    PROMPT_COMMAND="ps1${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
	}
	
	__powerline
	unset __powerline
fi

alias ls='ls -hN --color=always --group-directories-first'
alias grep='grep --color=always'
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias usb="cd /run/media/$USER"
alias suspend="systemctl suspend"
alias hibernate="systemctl hibernate"
alias neoimage="neofetch --backend w3m ~/.config/i3/simplepanda.png"
alias wifilist="nmcli device wifi list"
alias savedwifi="nmcli connection show"
alias update-mirrorlist="sudo reflector --latest 200 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist"
alias recordscreenwosound="ffmpeg -y -f x11grab -s 1920x1080 -i :0.0 out.mkv"
alias recordscreen="ffmpeg -y -f x11grab -s 1920x1080 -i :0.0 -f alsa -i default out.mkv"
alias recordcamera="ffmpeg -y -i /dev/video0 out.mkv"
alias showcamera="mpv --no-osc --no-input-default-bindings --input-conf=/dev/null --geometry=-0-0 --autofit=20% --title="mpvfloat" /dev/video0"
alias increasetemp="sudo mount -o remount,size=8G,noatime /tmp;"
