#!/bin/bash
# Use first Python 3 version found when set to 0
PREFER_LATEST=1

# Directories to search for Python 3 executables
PYPATHS=(/usr/bin /usr/local/bin)

# Script arguments
SCR="${1}"
QUERY="${2}"
WF_DATA_DIR=$alfred_workflow_data

# Create workflow data directory if not present
[ ! -d "$WF_DATA_DIR" ] && mkdir "$WF_DATA_DIR"

SCRPATH="$0"
SCRIPT_DIR="$(dirname $SCRPATH)"

# Cache file containing path to Python binary
PYALIAS="$WF_DATA_DIR/py3"

CONFIG_PREFIX="Config"
DEBUG=0

pyrun() {
  $py3 "${SCR}" "${QUERY}"
  RES=$?
  [[ $RES -eq 127 ]] && handle_py_notfound
  return $RES
}

handle_py_notfound() {
  # Handle OS reconfiguration or Python 3 uninstallation cases
  log_debug "Python 3 configuration changed, attempting to reconfigure"
  setup_python_alias
}

verify_not_stub() {
  PYBIN="${1}"
  $PYBIN -V > /dev/null 2>&1
  return $?
}

getver() {
  PYBIN="${1}"
  # Convert Python 3 version to comparable decimal format
  VER=$($PYBIN -V |  cut -f2 -d" " | sed -E 's/\.([0-9]+)$/\1/')
  echo $VER
  log_debug "Version: $VER"
}

make_alias() {
  PYBIN="${1}"
  PYVER="$2"
  # Validate Python binary path before creating alias
  [ -z "${PYBIN}"  ] && log_msg "Error: invalid Python 3 path" && exit 255
  [ -z "${PYVER}" ] && PYVER="$(getver "$PYBIN")"
  echo "export py3='$PYBIN'" > "$PYALIAS"
  log_msg "Python 3 was found at $PYBIN." "Version: $PYVER, Proceed typing query or re-run workflow"
}

log_msg() {
  log_json "$CONFIG_PREFIX: $1" "$2"
  log_debug "$1"
}

log_json() {
# Output JSON format for Alfred script filter as notifications
title="$1"
sub="$2"
[ -z "$sub" ] && sub="$title"
cat <<EOF
{
    "items": [
        {
            "title": "$title",
            "subtitle": "$sub",
        }
    ]
}
EOF
}

log_debug() {
  [[ $DEBUG -eq 1 ]] && echo "DEBUG: $*" >&2
}

setup_python_alias() {
  current_py=""
  current_ver=0.00
  for p in "${PYPATHS[@]}"
  do
    if [ -f $p/python3 ]
    then
      # Verify executable is not a stub
      # set -x
      ! verify_not_stub "$p/python3"  && continue
      # Find highest version when PREFER_LATEST is enabled
      if [ $PREFER_LATEST -eq 1 ]
      then
        thisver=$(getver $p/python3)
        if  [[ $(echo "$thisver > $current_ver" | bc -l) -eq 1 ]]
        then
          current_ver=$thisver
          current_py=$p/python3
        fi
      else
        # Use first valid Python 3 executable found
        make_alias "$p/python3"
        return 0
      fi
    fi
  done
  if [ $current_ver = 0.00 ]
  then
    log_msg "Error: no valid Python 3 version found" "Please locate Python version and add to PYPATHS variable"
    exit 255
  fi
  make_alias "$current_py" "$current_ver"
  . "$PYALIAS"
}

# Script execution starts here
if [ -f "$PYALIAS" ]
then
  . "$PYALIAS"
  pyrun
  exit
else
  setup_python_alias
fi