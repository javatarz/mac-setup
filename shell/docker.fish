# Colima Docker socket
if test -S "$HOME/.colima/default/docker.sock"
    set -gx DOCKER_HOST "unix://$HOME/.colima/default/docker.sock"
end

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

  else if test "$command" = "update"
    echo ">> Updating docker host IP in hosts file"
    set host_ip (docker-machine ip default)
    echo "$host_ip docker" | sudo tee -a /etc/hosts

  else
    echo "Unknown command: $command"
  end
end
