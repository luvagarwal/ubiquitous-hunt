function findErrorFile(){
    fname=$(echo $1 | sed "s/.*'//g")
    IFS="'" read -a arr <<< $fname
    if [ ${#arr[@]} -eq 1 ]
    then
        IFS=':' read -a arr <<< $1
        # read -a arr <<< $arr
        length=${#arr[@]}
        arr=${arr[length-2]}
        read -a arr <<< $arr
        errfile=${arr[${#arr[@]}-1]}
    else
        errfile=${arr[0]}
    fi
    # remove quotations from 'dir/fname'
    echo $(echo "$errfile" | sed "s/'//g")
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

function alias_commands(){
	cat "${HOME}/gitrepos/ubiquitous-hunt/commands"
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

function save_visited(){
    visited="${HOME}/.ubiquitous-hunt/visited-direcotires"
    visited_freq="${HOME}/.ubiquitous-hunt/visited-direcotires-freq"
    pwdir=$(pwd)
    res=$(grep visited -rn -e r"*$pwdir$")

    if [ -z $res ]; then
        echo $pwdir >> visited
        echo "1" >> visited_freq
    else
        IFS=":" read -a res <<< "$res"
        lno=${res[0]}
        origlno=$lno
        freq=$(head -$lno visited_freq | tail -1)
        freq=$(($freq + 1))
        while [ $lno -ne 0 ]; do
            lno=$(($lno - 1))
            f=$(head -$lno visited_freq | tail -1)
            if [ $f -gt $freq ]; then break
                lastmatch=$lno
            fi
        done
        sed -i "$origlno d" visited_freq
        sed -i "$lno i $freq" visited_freq
        sed -i "$origlno d" visited
        sed -i "$lno i ${res[1]}" visited_freq
    fi
}

function execute(){
    orange=`tput setaf 3`
    blue=`tput setaf 4`
    reset=`tput sgr0`

    original=$(path $1)

    # escape all the white space characters in the arguments
    # count=1
    # for i in "${@:2}"; do
    #     newval=$(printf "%q" "$i")
    #     set -- "${@:1:$count}" "$newval" "${@:$(($count + 2))}"
    #     count=$(($count + 1))
    # done

    status=1
    while [ $status -ne 0 ]
    do
        # deal with changing directory separately as
        # each subshell has there own current diretory
        # and if it is run inside $() the current dir
        # will change as soon as it comes out of $()
        if [ $1 == "cd" ]
        then
            $original "${@:2}" 2>/dev/null
            if [ $? -eq 0 ]; then
                return 0;
            fi
        fi

        # store stderr and output stdout by swapping
        # the file descriptors of stdin and stdout
        err=$( $original "${@:2}" 3>&2 2>&1 1>&3- )
        status=$?
        if [ $status -eq 0 ]; then return 0; fi

        # echo "$err" >&2

        ftype=$(check_error_type "$err")
        if [ -z $ftype ]; then
            echo "$err"
            return 1
        fi
        errfile_orig=$(findErrorFile "$err" 2>/dev/null)
        # echo "$errfile_orig" >&2

        errfile="$errfile_orig"
        # Remove last '/' if any
        last=$((${#errfile}-1))
        if [[ "${errfile:$last:1}" == "/" ]]; then
        	# remove last character
        	errfile="${errfile%?}"
        fi

        # echo "$errfile" >&2

        if [ "$ftype" == "fd" ]; then
            p=""
        else
            p="-type $ftype"
        fi

        # locate_out=$(locate -r "/$errfile[^\/]*$")
        locate_out=$(locate -r "/$errfile$")
        # echo "$locate_out"
        # errfile_path=$(locate -b '\$errfile$')
        read -a errfile_path <<< "$locate_out"

        errfile_path=${errfile_path[0]}

        if [ -z $errfile_path ]; then
            echo "${orange}Hunt unsuccessful${reset}"
            break
        fi

        count=1
        flag=1

        for i in ${@:2}; do
            if [ $i == $errfile_orig ]; then
                set -- "${@:1:$count}" "$errfile_path" "${@:$(($count + 2))}"
                break
                flag=0
            fi
            count=$(($count + 1))
        done
        echo "${orange}Executing" $original ${@:2} "${reset}"
    done
}
