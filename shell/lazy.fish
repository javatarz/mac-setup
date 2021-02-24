function awsv
    aws-vault --prompt=terminal $argv
end

function json
    cat $argv[1] | jq .
end

function dc
    docker-compose $argv
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
end

function notebook
    set command $argv[1]
    set notebook_root $argv[2]
    set -q command[1]; or set command start
    set -q notebook_root[1]; or set notebook_root "$HOME/projects/personal/notebook"

    if test "$command" = "start"
        echo "mapping work to $notebook_root"
        docker run -p 8888:8888 -d -P --name notebook -v $notebook_root:/home/jovyan/work jupyter/datascience-notebook
        docker logs notebook
    else if test "$command" = "stop"
        docker stop notebook
        docker rm notebook
    else if test "$command" = "logs" || test "$command" = "log"
        docker logs notebook
    else
        echo "Invalid command: '$command'"
    end
end
