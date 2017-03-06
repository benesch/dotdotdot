# prepend_to_path NEW-PATH
#
# Adds NEW-PATH to the beginning of the $PATH environment variable.
prepend_to_path() {
  PATH="$1:$PATH"
}

# append_to_path NEW-PATH
#
# Adds NEW-PATH to the end of the $PATH environment variable.
append_to_path() {
  PATH="$PATH:$1"
}

# have_command COMMAND
#
# Exits successfully if COMMAND exists on the PATH; exits unsucessfully
# otherwise.
have_command() {
  hash "$1" 2> /dev/null
}

# color [-p] [FORMAT-STRING...]
#
# Outputs formatted FORMAT-STRINGs. If -p is specified, the outputted
# string will include \[ and \] escapes to allow Bash to properly
# calculate the prompt width.
#
# FORMAT STRING
#    A format string is a plain ol' shell string with some format codes mixed
#    in. Format codes consist of a code wrapped in curly braces: `{code}`
#
#    A format code applies to all following characters until it's overriden by
#    another format code.
#
# CAVEATS
#    You *must* send the `clear` format code when you're finished outputting
#    formatted text, or you'll format the user's prompt and future programs!
#
#    Example:
#        '{red}Red, {bold}bold beautiful text!{clear}'
#
# FORMAT CODES
#    See `$_format_codes` for a list of possible format codes

_format_codes=(
  clear                  # reset
  black red green yellow # colors
  blue purple cyan white
  bold dim               # bold/bright, unbold/dim
  rev                    # reverse video
  under nounder          # underline, nounderline
)

_format_escapes=(
  "$(tput sgr0)"
  "$(tput setaf 0)" "$(tput setaf 1)" "$(tput setaf 2)" "$(tput setaf 3)"
  "$(tput setaf 4)" "$(tput setaf 5)" "$(tput setaf 6)" "$(tput setaf 7)"
  "$(tput bold)" "$(tput dim)"
  "$(tput rev)"
  "$(tput smul)" "$(tput rmul)"
)

color() {
  local strings match replace prompt_escapes=false

  if [[ "$1" = -p ]]; then
    prompt_escapes=true
    shift
  fi

  strings="$@"

  for (( i=0; i < ${#_format_codes[@]}; ++i )); do
    match="{${_format_codes[i]}}"
    replace="${_format_escapes[i]}"
    $prompt_escapes && replace="\[$replace\]"
    strings=${strings//${match}/${replace}}
  done

  echo "${strings[@]}"
}
