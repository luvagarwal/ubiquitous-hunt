function path(){
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

function search_file(){
    find ~ -name gitrepos
}

function dirs(){
    echo "courses coding Downloads gitrepos notes semester"
}

function create_alias(){
    alias cd="execute cd"
}

create_alias

function execute(){
    d=$(dirs)
    read -a directories <<< $d
    for i in `seq 0 $(expr ${#directories[@]} - 1)`
    do
        #echo ${directories[i]}
        directories[i]=$HOME/${directories[i]}
    done 
    original=$(path $1)
    $original ${@:2}

    if [ $? -ne 0 ]
    then
        err=$( $original ${@:2} 2>&1 )
        res=$(find ${directories[@]} -type d -not -path '*/\.*' -name ${@:2})
        # echo "find ${directories[@]} -not -path '*/\.*' -iname $@"
        # res has newlines but using $res will convert newlines to space
        # while using "$res" keeps the newline as it is.
        read -a result <<< $res
        if [ -z "$result" ]
        then
            :
        else
            $1 ${result[0]}
        fi
    fi
}

