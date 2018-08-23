# Install Homebrew, if it isn't installed already.
if [ `uname` == 'Darwin' ]; then
    if ! [ `which brew` ]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
fi
