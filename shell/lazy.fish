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
    brew update
    brew upgrade
    brew outdated --cask | cut -f 1 -d " " | xargs brew reinstall
    brew cleanup
    mas upgrade
    # softwareupdate --all --install --force
    omf update
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

function 1p
    set -q OP_SESSION_japhet; or eval (op signin japhet | head -n 1 | sed 's/export /set -g /' | sed 's/=/ /')
    OP_SESSION_japhet=$OP_SESSION_japhet op $argv
end
