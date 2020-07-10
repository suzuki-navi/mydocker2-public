
set -Ceu


function copy() {
    direction=$1
    type=$2
    home_path=$3
    fname=$4

    if [ $fname = . ]; then
        if [ $type = overwrite-partial ]; then
            for f in $(ls -a); do
                if [ $f != . -a $f != .. ]; then
                    copy $direction $type $home_path $f
                fi
            done
        fi
        return 0
    fi

    if [ -d $fname ]; then
        (
            cd $fname
            mkdir -p $home_path/$fname
            copy $direction $type $home_path/$fname .
        )
        return 0
    fi

    if [ -f $fname ]; then
        if [ $type = overwrite-partial ]; then
            if [ $direction = to-home ]; then
                cp --preserve=mode,timestamp -vf $fname $home_path/$fname
            elif [ $direction = from-home ]; then
                cp --preserve=mode,timestamp -vf $home_path/$fname $fname
            fi
        fi
    fi
}

copy "$@"

