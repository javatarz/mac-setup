#!/usr/local/bin/fish

omf list | grep bobthefish >/dev/null
if test $status -ne 0
  omf install bobthefish
else
  echo ">>> Theme bobthefish already installed"
end

# setup default before bobthefish so you get an interesting mix of the two shells which I love
omf theme default
omf theme bobthefish

omf list | grep bass >/dev/null
if test $status -ne 0
  omf install https://github.com/edc/bass
else
  echo ">>> bass already installed"
end
