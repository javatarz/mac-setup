function gs
    git status
end

function gd
    git diff $argv
end

function ga
    git add $argv
end

function gc
    git commit $argv
end

function pull
    git pull -r
end

function push
    set AWS_PROFILE "dev"
    git push -u origin (git rev-parse --abbrev-ref HEAD)
end

function reset
    git reset --hard HEAD
end

function stash
    git stash $argv
end

function pop
    git stash pop $argv
end

function main
  if git branch | grep -q main
    git checkout main
  else
    git checkout master
  end
end

function remove_all_branches
    git branch | grep -v main | xargs git branch -D
end

function sign_personal
    git config user.signingkey $GPG_KEY_PERSONAL
    git config user.email "$GPG_MAIL_PERSONAL"
end

function sign_client
    git config user.signingkey $GPG_KEY_CLIENT
    git config user.email "$GPG_MAIL_CLIENT"
end

function sign_work
    git config user.signingkey $GPG_KEY_WORK
    git config user.email "$GPG_MAIL_WORK"
end

function fuck_it
    set commit_message (curl -s http://whatthecommit.com/index.txt)
    git commit -m "$commit_message"
end
