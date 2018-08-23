# Add SDL2 to PATH variable in order to use SDL2 library for game development.
PATH="/usr/local/Cellar/sdl2:/usr/local/bin:/usr/local/include/SDL2:$PATH"

# Set list of themes to load.
# Setting this variable when ZSH_THEME=random causes zsh to load theme from
# this variable instead of looking in ~/.oh-my-zsh/themes/.
# An empty array has no effect.
ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

# Alias for AWS cli.
alias aws="$HOME/Library/Python/3.6/bin/aws"

# You may need to manually set your language environment.
export LANG=en_US.UTF-8

# Compilation flags.
export ARCHFLAGS="-arch x86_64"

# SSH.
export SSH_KEY_PATH="~/.ssh/rsa_id"

