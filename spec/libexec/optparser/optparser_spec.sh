#shellcheck shell=sh

Describe "libexec/optparser/optparser.sh"
  Include "$SHELLSPEC_LIB/libexec/optparser/optparser.sh"

  parse() {
    eval "$(getoptions parser_definition _parse PREFIX)"
    case $# in
      0) _parse ;;
      *) _parse "$@" ;;
    esac
  }

  Describe "multiple()"
    Before VAR=''

    _multiple() {
      multiple "$@"
      multiple "$@"
      multiple "$@"
    }

    It "joins by separator and store in variable"
      BeforeCall OPTARG=v
      When call _multiple VAR '|'
      The variable VAR should eq "v|v|v"
      The variable VAR should be exported
    End
  End

  Describe "boost()"
    Parameters
      1  1  0
      '' '' 10
    End

    It "sets PROFILER and LIMIT variables"
      BeforeCall OPTARG="$1"
      When call boost PREFIX
      The variable PREFIX_PROFILER should eq "$2"
      The variable PREFIX_PROFILER_LIMIT should eq "$3"
      The variable PREFIX_PROFILER should be exported
      The variable PREFIX_PROFILER_LIMIT should be exported
    End
  End

  Describe "check_env_name()"
    Parameters
      a100  success
      A100  success
      _A100 success
      A_100 success
      1foo  failure
      A-100 failure
    End

    It "checks environment variable name ($1)"
      BeforeCall OPTARG="$1"
      When call check_env_name
      The status should be "$2"
    End
  End

  Describe "set_path()"
    BeforeRun 'unset VAR ||:'

    It "sets to the variable"
      BeforeCall OPTARG="value"
      When call set_path VAR
      The variable VAR should eq value
      The variable VAR should be exported
    End
  End

  Describe "set_env()"
    BeforeRun 'unset VAR ||:'

    It "exports the variable with value"
      BeforeCall OPTARG="VAR=1"
      When call set_env
      The variable VAR should eq 1
      The variable VAR should be exported
    End

    It "exports the variable"
      BeforeCall 'export VAR=2' OPTARG="VAR"
      When call set_env
      The variable VAR should eq 2
      The variable VAR should be exported
    End

    It "exports the variable"
      BeforeCall OPTARG="VAR"
      When call set_env
      The variable VAR should be undefined
    End
  End

  Describe "check_env_fiile()"
    Parameters
      spec/fixture/exist              success   ./spec/fixture/exist
      ./spec/fixture/exist            success   ./spec/fixture/exist
      ./spec/fixture/no-such-a-file   failure   ./spec/fixture/no-such-a-file
    End

    It "checks env file exists ($1)"
      BeforeCall OPTARG="$1"
      When call check_env_file
      The status should be "$2"
      The variable OPTARG should eq "$3"
    End
  End

  Describe "check_directory()"
    Parameters
      spec/dir      success
      spec/..dir    success
      spec/..       failure
      spec/../dir   failure
    End

    It "checks directory name"
      BeforeCall OPTARG="$1"
      When call check_directory
      The status should be "$2"
    End
  End

  Describe "only_failures()"
    It "sets QUICK and REPAIR variables"
      When call only_failures PREFIX
      The variable PREFIX_QUICK should eq 1
      The variable PREFIX_REPAIR should eq 1
      The variable PREFIX_QUICK should be exported
      The variable PREFIX_REPAIR should be exported
    End
  End

  Describe "next_failure()"
    It "sets QUICK, REPAIR, FAIL_FAST_COUNT and RANDOM variables"
      When call next_failure PREFIX
      The variable PREFIX_QUICK should eq 1
      The variable PREFIX_REPAIR should eq 1
      The variable PREFIX_FAIL_FAST_COUNT should eq 1
      The variable PREFIX_RANDOM should eq ''
      The variable PREFIX_QUICK should be exported
      The variable PREFIX_REPAIR should be exported
      The variable PREFIX_FAIL_FAST_COUNT should be exported
      The variable PREFIX_RANDOM should be exported
    End
  End

  Describe "check_random()"
    Parameters
      none            success 'none'
      none:seed       success 'none:seed'
      specfiles       success 'specfiles'
      specfiles:seed  success 'specfiles:seed'
      examples        success 'examples'
      examples:seed   success 'examples:seed'
      other           failure 'other'
    End

    It "checks environment variable name ($1)"
      BeforeCall OPTARG="$1"
      When call check_random
      The status should be "$2"
      The variable OPTARG should eq "$3"
    End
  End

  Describe "random()"
    Parameters
      none            ''          ''
      none:seed       ''          ''
      specfiles       'specfiles' ''
      specfiles:seed  'specfiles' 'seed'
      examples        'examples'  ''
      examples:seed   'examples'  'seed'
    End

    It "sets RANDOM and SEED variables ($1)"
      BeforeCall OPTARG="$1"
      When call random PREFIX
      The variable PREFIX_RANDOM should eq "$2"
      The variable PREFIX_SEED should eq "$3"
      The variable PREFIX_RANDOM should be exported
      The variable PREFIX_SEED should be exported
    End
  End

  Describe "xtrace()"
    Before PREFIX_XTRACE=dummy PREFIX_XTRACE_ONLY=dummy
    Parameters
      0 '' ''
      1 1 dummy
      2 1 1
    End

    It "sets XTRACE and XTRACE_ONLY variables ($1)"
      BeforeCall OPTARG="$1"
      When call xtrace PREFIX
      The variable PREFIX_XTRACE should eq "$2"
      The variable PREFIX_XTRACE_ONLY should eq "$3"
      The variable PREFIX_XTRACE should be exported
      The variable PREFIX_XTRACE_ONLY should be exported
    End
  End

  Describe "detect_color_mode()"
    Before NO_COLOR='' CI='' FORCE_COLOR=''
    Context "when on the terminal"
      is_terminal() { true; }
      It "sets 1 to the COLOR variable"
        When call detect_color_mode PREFIX
        The variable PREFIX_COLOR should eq 1
        The variable PREFIX_COLOR should be exported
      End

      Context "when NO_COLOR variable is set"
        is_terminal() { true; }
        Before FORCE_COLOR=1 CI=1 NO_COLOR=1
        It "sets empty to the COLOR variable"
          When call detect_color_mode PREFIX
          The variable PREFIX_COLOR should eq ''
          The variable PREFIX_COLOR should be exported
        End
      End
    End

    Context "when not on the terminal"
      is_terminal() { false; }
      It "sets empty to the COLOR variable"
        When call detect_color_mode PREFIX
        The variable PREFIX_COLOR should eq ''
        The variable PREFIX_COLOR should be exported
      End

      Context "when FORCE_COLOR variable is set"
        Before FORCE_COLOR=1
        is_terminal() { false; }
        It "sets 1 to the COLOR variable"
          When call detect_color_mode PREFIX
          The variable PREFIX_COLOR should eq 1
          The variable PREFIX_COLOR should be exported
        End
      End
    End
  End

  Describe "quiet()"
    It "sets SKIP_MESSAGE and PENDING_MESSAGE variables"
      When call quiet PREFIX
      The variable PREFIX_SKIP_MESSAGE should eq "quiet"
      The variable PREFIX_PENDING_MESSAGE should eq "quiet"
      The variable PREFIX_SKIP_MESSAGE should be exported
      The variable PREFIX_PENDING_MESSAGE should be exported
    End
  End

  Describe "mode()"
    Parameters
      runner            runner        ""
      gen-bin           gen-bin       ""
      syntax-check      syntax-check  ""
      translate         translate     ""
      task              task          ""
      count             list          ""
      specfiles         list          specfiles
      examples          list          examples
      examples:id       list          examples:id
      examples:lineno   list          examples:lineno
      debug             list          debug
    End

    It "sets MODE and LIST variables"
      BeforeCall OPTARG="$1"
      When call mode PREFIX
      The variable PREFIX_MODE should eq "$2"
      The variable PREFIX_LIST should eq "$3"
      The variable PREFIX_MODE should be exported
      The variable PREFIX_LIST should be exported
    End
  End

  Describe "check_number()"
    Parameters
      012 success
      a12 failure
    End

    It "checks if it is a number"
      BeforeCall OPTARG="$1"
      When call check_number
      The status should be "$2"
    End
  End

  Describe "check_formatter()"
    Parameters
      progress success progress
      p success progress
      d success documentation
      t success tap
      j success junit
      f success failures
      custom success custom
      % failure %
    End

    It "checks if it is a formatter name ($1)"
      BeforeCall OPTARG="$1"
      When call check_formatter
      The status should be "$2"
      The variable OPTARG should eq "$3"
    End
  End

  Describe "help()"
    usage() { %text
      #|Usage: shellspec [options...] [files or directories...]
      #|
      #|  Using + instead of - for short options causes reverses the meaning
      #|
      #|    -s, --shell SHELL               Specify a path of shell [default: "auto" (the shell running shellspec)]
      #|                                      ShellSpec ignores shebang and runs in the specified shell.
      #|        --random TYPE[:SEED]        Run examples by the specified random type | <[none]> [specfiles] [examples]
    }

    It "displays long help when specified --help option"
      When call help --help
      The line 7 should eq "        --random TYPE[:SEED]        Run examples by the specified random type"
    End

    It "displays short help when specified -h option"
      When call help -h
      The line 6 should eq "        --random TYPE[:SEED]        Run examples by the specified random type | <[none]> [specfiles] [examples]"
    End
  End

  Describe "error_handler()"
    Parameters
      default_error:1   "Default error message: --option"
      check_number:1    "Not a number: --option"
      check_formatter:1 "Invalid formatter name: --option"
      check_env_name:1  "Invalid environment name: --option"
      check_env_file:1  "Not found env file: --option"
      check_random:1    "Specify in one of the following formats (none[:SEED], specfiles[:SEED], examples[:SEED]): --option"
    End

    It
      When call error_handler echo "Default error message: --option" "$1" --option
      The output should eq "$2"
      The status should be failure
    End
  End
End
