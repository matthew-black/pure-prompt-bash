#!/bin/bash

# pure prompt on bash
#
# Pretty, minimal BASH prompt, inspired by sindresorhus/pure(https://github.com/sindresorhus/pure)
#
# Author: Hiroshi Krashiki(Krashikiworks)
# released under MIT License, see LICENSE

# Colors
readonly BLACK=$(tput setaf 0)
readonly RED=$(tput setaf 1)
readonly GREEN=$(tput setaf 2)
readonly YELLOW=$(tput setaf 3)
readonly BLUE=$(tput setaf 4)
readonly MAGENTA=$(tput setaf 5)
readonly CYAN=$(tput setaf 6)
readonly WHITE=$(tput setaf 7)
readonly BRIGHT_BLACK=$(tput setaf 8)
readonly BRIGHT_RED=$(tput setaf 9)
readonly BRIGHT_GREEN=$(tput setaf 10)
readonly BRIGHT_YELLOW=$(tput setaf 11)
readonly BRIGHT_BLUE=$(tput setaf 12)
readonly BRIGHT_MAGENTA=$(tput setaf 13)
readonly BRIGHT_CYAN=$(tput setaf 14)
readonly BRIGHT_WHITE=$(tput setaf 15)

readonly RESET=$(tput sgr0)

# symbols
pure_prompt_symbol="❯"
pure_symbol_dirty="*"

# if this value is true, remote status update will be async
pure_git_async_update=false
pure_git_raw_remote_status="+0 -0"

__pure_update_git_status() {
	local git_status=""

	# if current directory isn't git repository, skip this
	if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == "true" ]]; then
		git_status="$(git branch --show-current)"

		# check clean/dirty
		git_status="${git_status}$(git diff --quiet || echo "${pure_symbol_dirty}")"

		# coloring
		git_status="${BRIGHT_BLACK}${git_status}${RESET}"
	fi

	pure_git_status=${git_status}
}

# if last command failed, change prompt color
__pure_echo_prompt_color() {
	if [[ $? = 0 ]]; then
		echo ${pure_user_color}
	else
		echo ${RED}
	fi
}

__pure_update_prompt_color() {
	pure_prompt_color=$(__pure_echo_prompt_color)
}

# Cached directory tracking
# https://claude.ai/chat/14a74d99-958a-47da-ba4a-a948decdac03
__pure_track_directory() {
    # Only update if directory has changed
    if [[ "$PWD" != "$LAST_TRACKED_DIR" ]]; then
        local win_path=$(cygpath -w "$PWD")
        printf "\e]9;9;%s\e\\" "$win_path"
        export LAST_TRACKED_DIR="$PWD"
    fi
}

# if user is root, prompt is BRIGHT_YELLOW
case ${UID} in
	0) pure_user_color=${BRIGHT_YELLOW} ;;
	*) pure_user_color=${YELLOW} ;;
esac

# Construct PROMPT_COMMAND
PROMPT_COMMAND=()

# if git isn't installed when shell launches, git integration isn't activated
if [[ -n $(command -v git) ]]; then
	PROMPT_COMMAND+=("__pure_update_git_status")
fi

PROMPT_COMMAND+=("__pure_update_prompt_color")
PROMPT_COMMAND+=("__pure_track_directory")

# Convert PROMPT_COMMAND array to a string with semicolon separation
PROMPT_COMMAND=$(IFS='; '; echo "${PROMPT_COMMAND[*]}")

readonly FIRST_LINE="${MAGENTA}\w \${pure_git_status}\n"
readonly SECOND_LINE="\[\${pure_prompt_color}\]${pure_prompt_symbol}\[$RESET\] "
PS1="\n${FIRST_LINE}${SECOND_LINE}"

# Multiline command
PS2="\[$BLUE\]${prompt_symbol}\[$RESET\] "
