delete_if_available() {
  defaults read $1 $2 > /dev/null 2>&1  

  if [ $? = 0 ]; then
    defaults delete $1 $2
  fi
}
