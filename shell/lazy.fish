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
  curl "http://v2.wttr.in/$argv[1]"
end
