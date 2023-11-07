function awsv
    aws-vault --prompt=terminal $argv
end

function json
    cat $argv[1] | jq .
end

function weather
    curl "http://wttr.in/$argv[1]"
end

function coffee
    echo "> Update brew formulae"
    brew update
    echo "> Upgrade brew apps"
    brew upgrade
    echo "> Cleanup brew downloads"
    brew cleanup
    echo "> Update all apps from the Mac App store"
    mas upgrade
    # echo "> Run system upgdates"
    # softwareupdate --all --install --force
    echo "> Update all omf installations"
    omf update

    echo "> Creating Brewfile and pushing it to git"
    brewfile
    git -C ~/projects/personal/mac-setup/ add brew/Brewfile
    git -C ~/projects/personal/mac-setup/ commit -m "Updated brewfile"
    git -C ~/projects/personal/mac-setup/ push
end

function notebook
    set command $argv[1]
    set notebook_root $argv[2]
    set -q command[1]; or set command start
    set -q notebook_root[1]; or set notebook_root "$HOME/projects/personal/notebook"

    if test "$command" = "start"
        echo "mapping work to $notebook_root"
        docker run -p 8888:8888 -p 4000:4000 --rm -e JUPYTER_ENABLE_LAB=yes -d -P --name notebook -v $notebook_root:/home/jovyan/work jupyter/all-spark-notebook
        docker logs notebook
    else if test "$command" = "stop"
        docker stop notebook
    else if test "$command" = "logs" || test "$command" = "log"
        docker logs notebook
    else
        echo "Invalid command: '$command'"
    end
end

set -g theme_powerline_fonts no

alias cat=bat
alias watch=viddy

function deploy_slides
  set hugo_source_path "/Users/karun/Library/Mobile Documents/iCloud~md~obsidian/Documents/slides"
  set slides_source_path "$hugo_source_path/public"

  echo "> generating latest slides from $hugo_source_path"
  hugo --source "$hugo_source_path"

  echo "> adding current files from $slides_source_path to git"
  git -C $slides_source_path add .

  set commit_message "Latest slides at $(date)"
  echo "> committing with message $commit_message"
  git -C $slides_source_path commit -m $commit_message

  echo "> pushing to remote"
  git -C $slides_source_path push

  echo "> done"
end

function run_slides
  set hugo_source_path "/Users/karun/Library/Mobile Documents/iCloud~md~obsidian/Documents/slides"
  hugo --source "$hugo_source_path" server
end

function pretty_csv
  column -t -s ',' "$argv" | less -F -S -X -K
end
