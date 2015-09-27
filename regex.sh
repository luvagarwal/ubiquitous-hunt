function finderrorfile(){
    fname=$(echo $1 | sed 's/.*‘//g')
    IFS='’' read -a arr <<< $fname
    if [ ${#arr[@]} -eq 1 ]
    then
        IFS=':' read -a arr <<< $1
        read -a $arr <<< $arr
        length=${#arr[@]}
        echo ${arr[length-2]}
    else
        echo ${arr[0]}
    fi
}

finderrorfile 'mv: cannot move ‘daldj’ to ‘lite/jjajjd/’: Not a directory'
finderrorfile 'bash: cd: djja: No such file or directory'
finderrorfile 'mv: cannot stat ‘dlajda’: No such file or directory
'
finderrorfile 'bash: cd: mine: No such file or directory'

finderrorfile ': ji: No such file or directory'