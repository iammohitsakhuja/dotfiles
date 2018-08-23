DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $* == "--help" ]] || [[ $* == "-h" ]]
then
    echo "usage: ./install.sh [ -h | --help ] [ --link | -l ]"
    echo "-h, --help | show this help"
    echo "-l, --link | link rc files rather than copying"
    exit 0
fi

CONFIG_FILES=(
    ".bash_profile"
    ".clang-format"
    ".hyper.js"
    ".mongorc.js"
    ".sqliterc"
    ".vimrc"
    ".zshrc"
)

if [[ $* == "--link" ]] || [[ $* == "-l" ]]
then
    echo "Linking config files..."
    for file in "${CONFIG_FILES[@]}"
    do
        ln -s $DIR/$file ~/$file
    done
else
    echo -d "\nCopying config files..."
    for file in "${CONFIG_FILES[@]}"
    do
        cat $DIR/$file >> ~/$file
    done
fi

# echo -e "\nRunning install scripts..."
# for script in $DIR/scripts/*
# do
#     bash $script
# done

