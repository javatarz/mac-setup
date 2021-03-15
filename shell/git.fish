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
    git checkout main
end

function remove_all_branches
    git branch | grep -v main | xargs git branch -D
end

function signpersonal
    git config user.signingkey $GPG_KEY_PERSONAL
    git config user.email "$GPG_MAIL_PERSONAL"
end

function signwork
    git config user.signingkey $GPG_KEY_WORK
    git config user.email "$GPG_MAIL_WORK"
end

function fuck_it
    set commit_message (curl -s http://whatthecommit.com/index.txt)
    git commit -m "$commit_message"
end