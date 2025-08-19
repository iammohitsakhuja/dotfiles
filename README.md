# Mohit's Dotfiles

A collection of useful dotfiles and scripts for MacOS.

## Installation

**Warning:** Even though most dotfiles will work right out of the box for any
\*nix platform, some files are exclusive to MacOS. I recommend forking this
repository, reviewing the code, and making changes to it accordingly before
running the installation script. Don't just blindly use my settings unless you
know what that entails. Use at your own risk!

**Important:** The installation script must be run from within the `macos/` directory.

To install, run the following:

```bash
$ cd macos
$ sudo chmod u+x install.sh
$ ./install.sh --email "your@email.com" --name "Your Name"
```

You can use the `-h` or `--help` flag while running the above command to get
help. The `--email` and `--name` parameters are required for git and SSH configuration.
