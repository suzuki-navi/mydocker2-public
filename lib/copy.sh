
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
        if [ ! -e $home_path/$fname -a $direction = from-home ]; then
            return 0
        fi
        (
            cd $fname
            mkdir -p $home_path/$fname
            copy $direction $type $home_path/$fname .
        )
        return 0
    fi

    if [ -f $fname ]; then
        if [ $type = overwrite-partial ]; then
            type=overwrite
        fi

        if [ $type = overwrite ]; then
            if [ $direction = to-home ]; then
                if ! cmp -s $fname $home_path/$fname; then
                    echo $(pwd)/$fname -\> $home_path/$fname
                    cp --preserve=mode,timestamp -f $fname $home_path/$fname
                fi
            elif [ $direction = from-home ]; then
                if [ -e $home_path/$fname ] && ! cmp -s $fname $home_path/$fname; then
                    echo $home_path/$fname -\> $(pwd)/$fname
                    cp --preserve=mode,timestamp -f $home_path/$fname $fname
                fi
            fi
        elif [ $type = history ]; then
            if [ $direction = to-home ]; then
                if ! cmp -s $fname $home_path/$fname; then
                    echo $(pwd)/$fname -\> $home_path/$fname
                    (
                        cat $fname
                        diff -u $fname $home_path/$fname | grep -a -e '^+' | grep -a -v -e '^+++' | cut -b2-
                    ) >| $home_path/$fname.merged
                    mv $home_path/$fname.merged $home_path/$fname
                fi
            elif [ $direction = from-home ]; then
                if [ -e $home_path/$fname ] && ! cmp -s $fname $home_path/$fname; then
                    echo $home_path/$fname -\> $(pwd)/$fname
                    (
                        cat $fname
                        diff -u $fname $home_path/$fname | grep -a -e '^+' | grep -a -v -e '^+++' | cut -b2-
                    ) >| $fname.merged
                    mv $fname.merged $fname
                fi
            fi
        elif [ $type = known-hosts ]; then
            if [ $direction = to-home ]; then
                if ! cmp -s $fname $home_path/$fname; then
                    echo $(pwd)/$fname -\> $home_path/$fname
                    cat $fname $home_path/$fname | perl -e '
                        my @arr = ();
                        while (my $line =<STDIN>) {
                            unless (grep {$_ eq $line} @arr) {
                                print $line;
                                push(@arr, $line);
                            }
                        }
                    ' >| $home_path/$fname.merged
                    mv $home_path/$fname.merged $home_path/$fname
                fi
            elif [ $direction = from-home ]; then
                if [ -e $home_path/$fname ] && ! cmp -s $fname $home_path/$fname; then
                    echo $home_path/$fname -\> $(pwd)/$fname
                    cat $fname $home_path/$fname | perl -e '
                        my @arr = ();
                        while (my $line =<STDIN>) {
                            unless (grep {$_ eq $line} @arr) {
                                print $line;
                                push(@arr, $line);
                            }
                        }
                    ' >| $fname.merged
                    mv $fname.merged $fname
                fi
            fi
        fi
    fi
}

copy "$@"

