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

function path(){
    c=$1
    location=$(which "$c")
    if [ -z $location ]
    then
        echo "builtin $1"
    else
        echo "$location"
    fi
}

function dirs(){
    echo "courses coding gitrepos notes semester testing"
    # echo "testing testing2"
}

function alias_commands(){
    # echo "ls mv cd diff cmp"
    echo "cd"
}

function check_error_type(){
    # check if the error contains word
    # "file" or "directory"

    error=$1
    read -a error <<< $error
    #echo ${#error[@]}
    for e in ${error[@]}
    do
        if [ $e == "file" ]
        then
            return 0
        fi
    done
    return 1
}

function create_alias(){

    commands=$(alias_commands)
    read -a commands <<< $commands
    alias ls="execute ls"
    for command in ${commands[@]}
    do
        alias $command="execute $command"
    done
}

create_alias

function execute(){
    original=$(path $1)

    # redirecting error to output doesn't
    # execute cd command. So need to handle
    # separately. Haven't tested if this is the
    # case with all builtin commands
    if [ $1 == "cd" ]
    then
        $original ${@:2}
        if [ $? -eq 0 ]
        then
            return 0
        fi
    fi

    err=$( $original ${@:2} 2>&1 )
    status=$?

    check_error_type "$err"
    if [ $? -ne 0 ]
    then
        echo "$err"
        return 1
    fi

    if [ $status -eq 0 ]
    then
        return 0
    fi

    d=$(dirs)
    read -a directories <<< $d
    for i in `seq 0 $(expr ${#directories[@]} - 1)`
    do
        directories[i]=$HOME/${directories[i]}
    done

    while [ $status -ne 0 ]
    do
        errfile=$(finderrorfile "$err" 2>/dev/null)
        errfile_path=$(find ${directories[@]} -not -path '*/\.*' -name $errfile)
        read -a errfile_path <<< $errfile_path
        errfile_path=${errfile_path[0]}

        # echo $errfile_path
        if [ -z $errfile_path ]
        then
            echo "Nahi hai!"
            break
        fi

        count=1
        flag=1

        for i in ${@:2}
        do
            if [ $i == $errfile ]
            then
                set -- "${@:1:$count}" "$errfile_path" "${@:$(expr $count + 2)}"
                break
                flag=0
            fi
            count=$(expr $count + 1)
        done

        echo "executing" $original ${@:2}
        if [ $1 == "cd" ]
        then
            $original ${@:2}
            if [ $? -eq 0 ]
            then
                return 0
            fi
        fi
        err=$( $original ${@:2} 2>&1 )
        status=$?

        check_error_type "$err"
        if [ $? -ne 0 ]
        then
            echo $err
            return 1
        fi
    done
}
