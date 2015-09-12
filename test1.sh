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

function search_dir(){
  find ~ -iname gitrepos
}

function dirs(){
  echo "courses coding Downloads gitrepos notes semester"
}

function cd(){
  d=$(dirs)
  read -a directories <<< $d
  #echo ${directories[0]}
  original=$(original_command cd)
  $original $@
  if [ $? -ne 0 ]
  then
    #echo ${directories[@]}
    res=$(find ${directories[@]} -iname $@)
    # res has newlines but using $res will convert newlines to space
    # while using "$res" keeps the newline as it is.
    read -a result <<< $res
    if [ -z "$result" ]
    then
      :
    else
      cd ${result[0]}
    fi
  fi
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