# Color directories and files differently
alias ls="ls -G"


# start python3 instead of python by default
alias python="/usr/local/bin/python3"
# use pip3 by default
alias pip=pip3


# alias for AWS cli
alias aws="/Users/mohit_sakhuja/Library/Python/3.6/bin/aws"


# add the directory '/System/Library/Frameworks' to the PATH variable
# add the directory '/usr/local/opt/coreutils/libexec/gnubin' to the PATH variable so that macOS recognises utilities like sha256sum and sha512sum
export PATH="$PATH:/System/Library/Frameworks:/Library/Developer:/usr/local/opt/coreutils/libexec/gnubin"
export PATH="/usr/local/Cellar/sdl2:/usr/local/bin:/usr/local/include/SDL2:$PATH"

# Include library path
# export LIBRARY_PATH="$LIBRARY_PATH:/usr/local/lib:/usr/local/Cellar"
# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib:/usr/local/Cellar"


# update MANPATH so that there is no need to prefix 'g' for utilities like sha256sum and sha512sum
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"


# Run greeting script on startup
~/good_morning.sh | lolcat


# Configure the 'remove' command
alias rm="rm -i"


############### Git script beginning ###############

# Enable tab completion
source ~/git-completion.bash

# colors!
green="\[\033[0;32m\]"
cyan="\[\033[0;36m\]"
purple="\[\033[0;35m\]"
reset="\[\033[0m\]"

# Change command prompt
source ~/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
# '\u' adds the name of the current user to the prompt
# '\$(__git_ps1)' adds git-related stuff
# '\W' adds the name of the current directory
export PS1="$purple\u$green\$(__git_ps1)$cyan \W $ $reset"

############### Git script ending ###############


# Configure VS Code to be run simply by 'code' command
alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"


# Create aliases for showing and hiding files
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"


############ COLORS FOR MANPAGES ############
# Colors
default=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
purple=$(tput setaf 5)
orange=$(tput setaf 9)

# Less colors for man pages
export PAGER=less
# Begin blinking
export LESS_TERMCAP_mb=$red
# Begin bold
export LESS_TERMCAP_md=$orange
# End mode
export LESS_TERMCAP_me=$default
# End standout-mode
export LESS_TERMCAP_se=$default
# Begin standout-mode - info box
export LESS_TERMCAP_so=$purple
# End underline
export LESS_TERMCAP_ue=$default
# Begin underline
export LESS_TERMCAP_us=$green

#############################################


# alias to love
alias love="/Applications/love.app/Contents/MacOS/love"

# alias for sqlite
alias sqlite=sqlite3

# flags for C++ compilation
export CXXFLAGS="-std=c++17"


# added by Miniconda3 installer
export PATH="/Users/mohitsakhuja/miniconda3/bin:$PATH"
