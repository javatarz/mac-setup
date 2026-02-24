fish_add_path (brew --prefix)"/opt/curl/bin"
fish_add_path (brew --prefix)"/sbin"

set LANG english

if command -v ngrok &>/dev/null;
  eval "$(ngrok completion)"
end
