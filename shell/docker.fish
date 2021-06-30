function dc
    docker-compose $argv
end

function dh
  set command $argv[1]

  if test "$command" = "start"
    echo ">> Starting docker machine"
    docker-machine start

    echo ">> Reloading docker machine environment"
    eval (docker-machine env default)

  else if test "$command" = "shell"
    echo ">> Reloading docker machine environment"
    eval (docker-machine env default)

  else if test "$command" = "stop"
    echo ">> Stopping docker machine"
    docker-machine stop

  else
    echo "Unknown command: $command"
  end
end
