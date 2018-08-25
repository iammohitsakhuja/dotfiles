#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $* == "--help" ]] || [[ $* == "-h" ]] ; then
    echo -n "Usage: ./install.sh "
    echo -n "[ -h | --help ] [ -c | --copy] [ -cr | --copy-rc ] [ -lr | --link-rc ] "
    echo "[ -cs | --copy-scripts ] [ -ls | --link-scripts ] [ -a | --all ]"
    echo "-h, --help          | Show this help"
    echo "-c, --copy          | Copy rc files and startup scripts rather than linking"
    echo "-cr, --copy-rc      | Copy just the rc files"
    echo "-lr, --link-rc      | Link just the rc files"
    echo "-cs, --copy-scripts | Copy just the startup scripts"
    echo "-ls, --link-scripts | Link just the startup scripts"
    echo "-a, --all           | Link rc files and startup scripts (default)"
    exit 0
fi

case $* in
    --copy|-c)
        echo "Copying config files into $HOME/ ..."
        cp -r $(pwd)/config/ $HOME/
        echo -e "\nCopying startup scripts into $HOME/ ..."
        cp -r $(pwd)/startup_scripts/ $HOME/
        ;;
    --copy-rc|-cr)
        echo "Copying config files into $HOME/ ..."
        cp -r $(pwd)/config/ $HOME/
        ;;
    --link-rc|-lr)
        echo "Linking config files into $HOME/ ..."
        for file in $DIR/config/.??*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
        done
        ;;
    --copy-scripts|-cs)
        echo "Copying startup scripts into $HOME/ ..."
        cp -r $(pwd)/startup_scripts/ $HOME/
        ;;
    --link-scripts|-ls)
        echo "Linking startup scripts into $HOME/ ..."
        for file in $DIR/startup_scripts/*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
        done
        ;;
    *)
        echo "Linking config files into $HOME/ ..."
        for file in $DIR/config/.??*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
        done
        echo -e "\nLinking startup scripts into $HOME/ ..."
        for file in $DIR/startup_scripts/*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
        done
        ;;
esac


echo -e "\nRunning install scripts..."
for script in $DIR/scripts/*
do
    bash $script
done

