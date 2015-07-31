function original_command(){
c=$1
location=$(whereis "$c")
read -a loc <<< "$location"
if [ -z "${loc[1]}" ]
then
  IFS=':' read -a loc <<< $loc
  ret="builtin ${loc[0]}"
  echo "$ret"
else
  echo "${loc[1]}"
fi
}

function test2(){
  $@
}

function cd(){
  original=$(original_command cd)
  $original $@
}

function ls1(){
original=$(original_command ls)
$original $@
  if [ $? -ne 0 ]
  then
    echo "meri script"
    /bin/ls gitrepos
  fi
}
