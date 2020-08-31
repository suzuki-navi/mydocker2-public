
set -Ceu

(
    find $HOME/.mydocker2/credentials -type f | LC_ALL=C sort | while read path; do
        echo $path
        cat $path
    done
) >| $HOME/.mydocker2/credentials.raw.txt.1

if [ -e $HOME/.mydocker2/credentials.txt ] && cmp -s $HOME/.mydocker2/credentials.raw.txt $HOME/.mydocker2/credentials.raw.txt.1; then
    echo "Credentials no changes"
    exit 0
fi

(
    diff -u $HOME/.mydocker2/credentials.raw.txt $HOME/.mydocker2/credentials.raw.txt.1 || true

    cd $HOME/.mydocker2/credentials

    tar czf $HOME/.mydocker2/credentials.tar.gz .
    cat $HOME/.mydocker2/credentials.tar.gz | openssl enc -e -aes256 -pbkdf2 | base64 >| $HOME/.mydocker2/credentials.txt
    echo >> $HOME/.mydocker2/credentials.txt

    cat $HOME/.mydocker2/credentials.txt
    cp $HOME/.mydocker2/credentials.raw.txt.1 $HOME/.mydocker2/credentials.raw.txt
)

