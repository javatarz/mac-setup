if test -d /opt/homebrew
    set -l brew_prefix /opt/homebrew
else
    set -l brew_prefix /usr/local
end

fish_add_path $brew_prefix/opt/curl/bin
fish_add_path $brew_prefix/sbin

set LANG english

if command -v ngrok &>/dev/null;
  eval "$(ngrok completion)"
end
