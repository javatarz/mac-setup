function gs
  git status
end

function gd
  git diff $argv
end

function ga
  git add $argv
end

function pull
  git pull -r
end

function push
  git push
end

function reset
  git reset --hard HEAD
end

function signpersonal
  git config user.signingkey $GPG_KEY_PERSONAL
  git config user.email "$GPG_MAIL_PERSONAL"
end

function signwork
  git config user.signingkey $GPG_KEY_WORK
  git config user.email "$GPG_MAIL_WORK"
end
