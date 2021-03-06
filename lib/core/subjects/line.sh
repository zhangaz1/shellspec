#shellcheck shell=sh

shellspec_syntax 'shellspec_subject_line'

shellspec_subject_line() {
  shellspec_syntax_param count [ $# -ge 1 ] || return 0
  shellspec_syntax_param 1 is number "$1" || return 0

  # shellcheck disable=SC2034
  SHELLSPEC_META="text"
  if [ ${SHELLSPEC_STDOUT+x} ]; then
    # shellcheck disable=SC2034
    SHELLSPEC_SUBJECT=$SHELLSPEC_STDOUT
  else
    unset SHELLSPEC_SUBJECT ||:
  fi
  shellspec_off UNHANDLED_STDOUT

  eval shellspec_syntax_dispatch modifier line ${1+'"$@"'}
}
