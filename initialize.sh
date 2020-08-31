
set -Ceu

mkdir -p $HOME/.mydocker2/credentials
chmod 700 $HOME/.mydocker2/credentials

touch $HOME/.mydocker2/credentials.raw.txt
touch $HOME/.mydocker2/credentials.raw.txt.1
chmod 600 $HOME/.mydocker2/credentials.raw.txt
chmod 600 $HOME/.mydocker2/credentials.raw.txt.1

if [ ! -e $HOME/.mydocker2/credentials.txt ]; then
    echo "cat > ~/.mydocker2/credentials.txt"
    exit 1
fi

(
    cd $HOME/.mydocker2/credentials
    cat $HOME/.mydocker2/credentials.txt | base64 -d | openssl enc -d -aes256 -pbkdf2 >| $HOME/.mydocker2/credentials.tar.gz
    tar xzf $HOME/.mydocker2/credentials.tar.gz
)

(
    find $HOME/.mydocker2/credentials -type f | LC_ALL=C sort | while read path; do
        echo $path
        cat $path
    done
) >| $HOME/.mydocker2/credentials.raw.txt

if [ -e $HOME/.mydocker2/credentials/initialize.sh ]; then
    bash $HOME/.mydocker2/credentials/initialize.sh
fi

