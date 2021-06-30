eval (docker-machine env default)

function dc
    docker-compose $argv
end
