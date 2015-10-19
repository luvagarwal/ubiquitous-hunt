function finderrorfile(){
    fname=$(echo $1 | sed 's/.*‘//g')
    IFS='’' read -a arr <<< $fname
    if [ ${#arr[@]} -eq 1 ]
    then
        IFS=':' read -a arr <<< $1
        read -a $arr <<< $arr
        length=${#arr[@]}
        arr=${arr[length-2]}
        read -a arr <<< $arr
        echo ${arr[${#arr[@]}-1]}
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
    echo "Downloads courses coding gitrepos notes semester testing"
    # echo "testing testing2"
}

function alias_commands(){
    echo "stat ls dir diff diff3 du vdir v bzip2 mv cd cp comm csplit cut cmp cat chown"
    # echo "cd"
}

function check_error_type(){
    # check if the error contains word
    # "file" or "directory", "No" or "Not"

    flagw1=0 # for "file" or "direcoty"
    flagw2=0 # for "No" or "Not"

    error=$1
    read -a error <<< $error
    ftype=""
    for e in ${error[@]}
    do
        if [ "$e" == "file" ]; then
            flagw1=1
            f="f"
        fi
        if [ "$e" == "directory" ] || [ "$e" == "directory." ]; then
            flagw1=1
            d="d"
        fi
        if [ "$e" == "No" ] || [ "$e" == "Not" ]; then
            flagw2=1
        fi
    done
    if [ $flagw1 -eq 1 ] && [ $flagw2 -eq 1 ]; then
        echo "$f$d"
    fi
}

function create_alias(){

    commands=$(alias_commands)
    read -a commands <<< $commands
    for command in ${commands[@]}
    do
        alias $command="execute $command"
    done
}

create_alias

function execute(){
    orange=`tput setaf 3`
    blue=`tput setaf 4`
    reset=`tput sgr0`

    original=$(path $1)

    d=$(dirs)
    read -a directories <<< $d
    for i in `seq 0 $(expr ${#directories[@]} - 1)`
    do
        directories[i]=$HOME/${directories[i]}
    done

    status=1
    while [ $status -ne 0 ]
    do
        # deal with changing directory separately as
        # each subshell has there own current diretory
        # and if it is run inside $() the current dir
        # will change as soon as it comes out of $()
        if [ $1 == "cd" ]
        then
            $original ${@:2} 2>/dev/null
            if [ $? -eq 0 ]; then return 0; fi
        fi

        # store stderr and output stdout by swapping
        # the file descriptors of stdin and stdout
        err=$( $original ${@:2} 3>&2 2>&1 1>&3- )
        status=$?
        if [ $status -eq 0 ]; then return 0; fi

        ftype=$(check_error_type "$err")
        if [ -z $ftype ]; then
            echo "$err"
            return 1
        fi

        errfile_orig=$(finderrorfile "$err" 2>/dev/null)
        # extract the name after last '/'. Ex for
        # errfile='pqrs/ab' extract ab
        IFS='/' read -a errfile <<< $errfile_orig
        errfile=${errfile[${#errfile[@]}-1]}

        if [ "$ftype" == "fd" ]; then
            p=""
        else
            p="-type $ftype"
        fi

        errfile_path=$(find -O3 ${directories[@]} -not -path '*/\.*' $p -iname *$errfile*)
        read -a errfile_path <<< $errfile_path
        errfile_path=${errfile_path[0]}

        if [ -z $errfile_path ]; then
            echo "${orange}Hunt unsuccessful${reset}"
            break
        fi

        count=1
        flag=1

        for i in ${@:2}; do
            if [ $i == $errfile_orig ]; then
                set -- "${@:1:$count}" "$errfile_path" "${@:$(expr $count + 2)}"
                break
                flag=0
            fi
            count=$(expr $count + 1)
        done
        echo "${blue}Executing" $original ${@:2} "${reset}"
    done
}
