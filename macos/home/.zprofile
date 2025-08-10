# Link homebrew in this manner only if terminal is running in native mode.
# Possible values are:
#   0 -> Running in native mode.
#   1 -> Running in Rosetta mode.
if [ "$(sysctl -in sysctl.proc_translated)" = "0" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
